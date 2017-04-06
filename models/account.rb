class Account
  include Mongoid::Document
  include Mongoid::Timestamps

  field :email, :type => String
  field :username, :type => String
  field :password, :type => String
  field :access_token, :type => String # must have user_likes permission

  validates_uniqueness_of :email, :username, :access_token

  has_many :friends, :dependent => :destroy
  has_many :pages, :dependent => :destroy
  has_many :groups, :dependent => :destroy
  has_many :messages, :dependent => :destroy
  has_many :events, :dependent => :destroy

  def agent
    @agent ||= Mechanize.new
  end

  attr_accessor :logged_in
  def login
    agent.get('https://m.facebook.com').form_with(id: 'login_form') do |form|
      form.field_with(name: 'email').value = username
      form.field_with(name: 'pass').value = password
    end.submit
    @logged_in = true
  end

  def clear
    %w{friends pages groups messages events}.each { |x| eval("#{x}.destroy_all") }
  end

  def load_events(page_id)
    login unless @logged_in
    page = agent.get("https://m.facebook.com/#{page_id}?v=events&is_past=1&refid=17")
    
    while page
      page.search('div.bt.bu').each { |div|
        title = div.search('h3').text
        puts title
        fbid = div.search('a').first['href'].split('/events/')[1].split('?')[0]
        when_details = div.search('.cm')[1].try(:text)
        location = div.search('.cm.cr .cs').map { |node| node.text }.join(', ')
        events.create fbid: fbid, title: title, when_details: when_details, location: location
      }
      if next_link = page.link_with(:text => /see more events/i)
        page = next_link.click
      else
        page = nil
      end
    end
  end

  def load_friends
    login unless @logged_in
    page = agent.get('https://m.facebook.com/friends/center/friends')

    i = 1
    while page.search('#u_0_0 a')[0] do
      puts i
      page.search('td.v.s').each { |td|
        name = td.search('a').text
        puts name
        fbid = td.search('a').first['href'].split('uid=')[1].split('&')[0]
        mutual_friends = td.search('div').text.split(' ').first.to_i
        friends.create fbid: fbid, name: name, mutual_friends: mutual_friends
      }
      page = agent.get('https://m.facebook.com'+ page.search('#u_0_0 a')[0]['href'])
      i += 1
    end

  end

  def load_pages
    oauth_access_token = access_token
    @graph = Koala::Facebook::API.new(oauth_access_token)
    likes = @graph.get_connections('me', 'likes')
    while likes
      likes.each { |page|
        puts page['name']
        pages.create fbid: page['id'], name: page['name']
      }
      likes = likes.next_page
    end
  end

  def load_groups
    login unless @logged_in
    page = agent.get('https://m.facebook.com/groups/?seemore&refid=27')
    page.search("a[href^='/groups/']").each { |a|
      fbid = a['href'].split('/groups/')[1].split('?')[0]
      if fbid == fbid.to_i.to_s
        name = a.text
        puts name
        groups.create fbid: fbid, name: name
      end
    }
  end

  def load_messages
    login unless @logged_in
    page = agent.get('https://m.facebook.com/messages/?pageNum=0&selectable&pagination_direction=1&refid=11')
    while page
      puts page.uri
      page.search("a[href^='/messages/read/?tid=']").each { |a|
        who = a.text
        puts who
        messages.create tid: a['href'].split('tid=')[1].split('&refid')[0], who: who, last_active: (begin; Date.parse(a.parent.next.next.text); rescue; end)
      }
      if next_link = page.link_with(:text => /see older messages/i)
        page = next_link.click
      else
        page = nil
      end
    end
  end

  def self.admin_fields
    {
      :email => :email,
      :username => :text,
      :password => :password,
      :access_token => :text,
    }
  end

  def self.authenticate(email, password)
    account = find_by(email: /^#{Regexp.escape(email)}$/i) if email.present?
    (account && account.password == password) ? account : nil
  end

  def admin?
    true
  end

end
