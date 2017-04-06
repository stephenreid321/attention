class Event
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :account
  validates_presence_of :fbid, :account
  validates_uniqueness_of :fbid, :scope => :account

  field :fbid, :type => String
  field :title, :type => String
  field :when_details, :type => String
  field :location, :type => String

  def self.admin_fields
    {
      :fbid => :text,
      :title => :text,
      :when_details => :text,
      :location => :text,
      :account_id => :lookup
    }
  end

end
