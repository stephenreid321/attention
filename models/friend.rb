class Friend
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :account
  validates_presence_of :fbid, :account
  validates_uniqueness_of :fbid, :scope => :account

  field :fbid, :type => String
  field :name, :type => String
  field :username, :type => String
  field :email, :type => String
  field :following, :type => Boolean
  field :mutual_friends, :type => Integer

  def self.admin_fields
    {
      :fbid => :text,
      :name => :text,
      :username => :text,
      :email => :email,
      :following => :check_box,
      :mutual_friends => :number,
      :account_id => :lookup
    }
  end
  
  def get_info(account = self.account)
    account.login unless account.logged_in
    page = account.agent.get("https://m.facebook.com/#{fbid}")
    self.username = page.uri.path.split('/').last
    about = page.link_with(:href => /\/about/).try(:click)
    self.email = about.search("div[title='Email address'] td:last-child").text
    self.following = about.link_with(:text => 'Unfollow') ? true : false
    self.save
  end

  def unfollow(account = self.account)
    account.login unless account.logged_in
    page = account.agent.get("https://m.facebook.com/mbasic/more/?owner_id=#{fbid}&refid=17")
    page.link_with(:href => /subscriptions\/remove/).try(:click)
  end

end
