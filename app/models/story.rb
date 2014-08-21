class Story < ActiveRecord::Base
  has_many :urls, :dependent => :delete_all
  accepts_nested_attributes_for :urls

  validates :story_type, presence: true
  validates :author, presence: true

  attr_accessor :scraped_domain
  attr_accessor :source_url_pre
  attr_accessor :meta_author_scrape
end
