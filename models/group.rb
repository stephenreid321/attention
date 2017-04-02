class Group
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :account
  validates_presence_of :fbid, :account
  validates_uniqueness_of :fbid, :scope => :account

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
    page = account.agent.get("https://m.facebook.com/groups/#{fbid}?view=info&refid=18")
    page.link_with(:href => /subscriptions\/remove/).try(:click)
  end

  def leave(account = self.account)
    account.login unless account.logged_in
    page = account.agent.get("https://m.facebook.com/group/leave/?group_id=#{fbid}&refid=18")
    page.form_with(:action => '/a/group/leave/').try(:submit)
  end

  def notification_level(level, admin_level = level, account = self.account)
    ### level 2 - friends, level 3 - all
    account.login unless account.logged_in
    page = account.agent.get("https://m.facebook.com/group/settings/?group_id=#{fbid}&refid=18")
    form = page.form_with(:action => "/a/group/settings/?group_id=#{fbid}")
    admin = page.link_with(:href => /madminpanel/)
    l = admin ? admin_level : level
    puts "#{name}: #{l}"
    form.radiobutton_with(:name => 'level', :value => "#{l}").check
    form.submit
  end

end
