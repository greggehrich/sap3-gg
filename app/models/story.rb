class Story < ActiveRecord::Base
  has_many :urls, inverse_of: :story
  accepts_nested_attributes_for :urls

  validates :story_type, presence: true
  # validates :author, presence: true

  # attr_accessor :source_url_pre

  attr_accessor :source_url_pre, :raw_author_scrape, :raw_story_year_scrape, :raw_story_month_scrape, :raw_story_date_scrape

  before_validation :set_story_track_fields, on: :create

  def set_story_track_fields

    self.author_track = (self.raw_author_scrape == self.author ? true : false)
    self.story_year_track = (self.raw_story_year_scrape == self.story_year.to_s ? true : false)
    self.story_month_track = (self.raw_story_month_scrape == self.story_month.to_s ? true : false)
    self.story_date_track = (self.raw_story_date_scrape == self.story_date.to_s ? true : false)
  end

end
