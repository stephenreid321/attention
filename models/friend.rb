class Friend
  include Mongoid::Document
  include Mongoid::Timestamps
  
  belongs_to :account
  validates_presence_of :fbid, :account

  field :fbid, :type => String
  field :name, :type => String
  field :mutual_friends, :type => String  
          
  def self.admin_fields
    {      
      :fbid => :text,
      :name => :text,
      :mutual_friends => :number,
      :account_id => :lookup      
    }
  end
  
  def unfollow
    account.login unless @logged_in    
    page = account.agent.get("https://m.facebook.com/mbasic/more/?owner_id=#{fbid}&refid=17")      
    page.link_with(:href => /subscriptions\/remove/).try(:click)
  end
    
end
