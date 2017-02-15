class Page
  include Mongoid::Document
  include Mongoid::Timestamps
  
  belongs_to :account
  validates_presence_of :fbid, :account

  field :fbid, :type => String
  field :name, :type => String
          
  def self.admin_fields
    {      
      :fbid => :text,
      :name => :text,
      :account_id => :lookup      
    }
  end
  
  def unfollow(account = self.account)
    account.login unless account.logged_in
    p = account.agent.get("https://m.facebook.com/#{fbid}")
    p.link_with(:href => /page\/follow_mutator/).try(:click)
  end  
  
  def unlike(account = self.account)
    account.login unless account.logged_in
    p = account.agent.get("https://m.facebook.com/#{fbid}")
    p.link_with(:href => /unfan/).try(:click)
  end 
  
end

