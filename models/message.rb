class Message
  include Mongoid::Document
  include Mongoid::Timestamps
  
  belongs_to :account
  validates_presence_of :tid, :account

  field :tid, :type => String
  field :who, :type => String  
  field :last_active, :type => Date
          
  def self.admin_fields
    {      
      :tid => :text,
      :who => :text,
      :last_active => :date,
      :account_id => :lookup      
    }
  end
  
  def archive(account = self.account)
    account.login unless account.logged_in
    page = account.agent.get("https://m.facebook.com/messages/read/?tid=#{tid}&refid=11#fua")
    form = page.form_with(:action => /messages\/action_redirect/)
    if form
      if button = form.button_with(:name => 'archive')
        account.agent.submit(form, button)
        puts "archived #{who or tid}"
      else
        puts "skipped #{who or tid}"
      end
    end
  end  

end

