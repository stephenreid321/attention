class Account
  include Mongoid::Document
  include Mongoid::Timestamps
  extend Dragonfly::Model
            
  field :name, :type => String
  field :email, :type => String
  field :admin, :type => Boolean
  field :time_zone, :type => String
  field :crypted_password, :type => String
  field :picture_uid, :type => String
  
  has_many :friends, :dependent => :destroy
  
  
  
  def agent
    @agent ||= Mechanize.new
  end
  
  def login
    agent.get('https://m.facebook.com').form_with(id: 'login_form') do |form|
      form.field_with(name: 'email').value = ENV['FACEBOOK_USERNAME']
      form.field_with(name: 'pass').value = ENV['FACEBOOK_PASSWORD']
    end.submit   
    puts 'logged in'
    @logged_in = true
  end  
  
  def load_friends
    login unless @logged_in
    page = agent.get('https://m.facebook.com/friends/center/friends')
        
    i = 1
    while page.search('#u_0_0 a')[0] do
      puts i
      page.search('td.v.s').each { |td|        
        name = td.search('a.bm').text
        puts name
        fbid = td.search('a.bm').first['href'].split('uid=')[1].split('&')[0]
        mutual_friends = td.search('.bn.bo').text.split(' ').first.to_i        
        friends.create! fbid: fbid, name: name, mutual_friends: mutual_friends
      }
      page = agent.get('https://m.facebook.com'+ page.search('#u_0_0 a')[0]['href'])
      i += 1
    end    
    
  end
  
  
  
  # Dragonfly
  dragonfly_accessor :picture  
  attr_accessor :rotate_picture_by
  before_validation :rotate_picture
  def rotate_picture
    if self.picture and self.rotate_picture_by
      picture.rotate(self.rotate_picture_by)
    end  
  end  
  
  has_many :provider_links, :dependent => :destroy
  accepts_nested_attributes_for :provider_links  
          
  attr_accessor :password

  validates_presence_of :name, :time_zone    
  validates_presence_of     :email
  validates_length_of       :email,    :within => 3..100
  validates_uniqueness_of   :email,    :case_sensitive => false
  validates_format_of       :email,    :with => /\A[^@\s]+@[^@\s]+\.[^@\s]+\Z/i
  validates_presence_of     :password,                   :if => :password_required
  validates_length_of       :password, :within => 4..40, :if => :password_required
          
  def self.admin_fields
    {
      :name => :text,
      :email => :text,
      :picture => :image,
      :admin => :check_box,
      :time_zone => :select,
      :password => {:type => :password, :new_hint => 'Leave blank to keep existing password'},
      :provider_links => :collection
    }
  end
  
  def self.edit_hints
    {
      :password => 'Leave blank to keep existing password'      
    }
  end     
  
  def firstname
    name.split(' ').first
  end
               
  def self.time_zones
    ['']+ActiveSupport::TimeZone::MAPPING.keys.sort
  end  
      
  def uid
    id
  end
  
  def info
    {:email => email, :name => name}
  end
  
  def self.authenticate(email, password)
    account = find_by(email: /^#{Regexp.escape(email)}$/i) if email.present?
    account && account.has_password?(password) ? account : nil
  end
  
  before_save :encrypt_password, :if => :password_required

  def has_password?(password)
    ::BCrypt::Password.new(crypted_password) == password
  end

  def self.generate_password(len)
    chars = ("a".."z").to_a + ("0".."9").to_a
    return Array.new(len) { chars[rand(chars.size)] }.join
  end   
  
  def reset_password!
    self.password = Account.generate_password(8)
    if self.save
      mail = Mail.new
      mail.to = self.email
      mail.from = ENV['MAIL_FROM']
      mail.subject = "New password for #{ENV['DOMAIN']}"
      mail.body = "Hi #{self.firstname},\n\nSomeone (hopefully you) requested a new password for #{ENV['DOMAIN']}.\n\nYour new password is: #{self.password}\n\nYou can sign in at http://#{ENV['DOMAIN']}/sign_in."
      mail.deliver       
    else
      return false
    end
  end

  private
  
  def encrypt_password
    self.crypted_password = ::BCrypt::Password.create(self.password)
  end

  def password_required
    crypted_password.blank? || self.password.present?
  end  
end
