require 'domainatrix'
require 'screen_scraper'
## TODO: not sure why you are requiring the following libraries ?
require 'uri'
require 'socket'
require 'net/http'
require 'net/protocol'

class StoriesController < ApplicationController
  before_action :set_story, only: [:show, :edit, :update, :destroy]

  def scrape
  end

  # GET /stories
  # GET /stories.json
  def index
    @stories = Story.order("id DESC").all
    # render text: self._process_action_callbacks
  end

  # GET /stories/1
  # GET /stories/1.json
  def show
    @url = @story.urls.find(params[:id])
  end

  # GET /stories/new
  def new
    # parse the domain
    @source_url_pre = params[:source_url_pre]  #grab user input
    if @source_url_pre.present?
      get_domain_info(@source_url_pre)
      @screen_scraper = ScreenScraper.new
      if @screen_scraper.scrape!(@full_web_url)
        @story = Story.new
        url = @story.urls.build
        url.images.build
        set_scrape_fields
        # @images = Image.new  # make page_imgs available to image model
        # @images.page_imgs = @page_imgs  # make page_imgs available to image model
      else
        flash.now.alert = "We can't find that URL – give it another shot"
        render :scrape
      end
    else
      flash.now.alert = "You have to enter a URL for this to work"
      render :scrape
    end
  end

  def set_scrape_fields
    @title = @screen_scraper.title
    @meta_desc = @screen_scraper.meta_desc
    @meta_keywords = @screen_scraper.meta_keywords
    @meta_type = @screen_scraper.meta_type
    @meta_author = @screen_scraper.meta_author
    @year = @screen_scraper.year
    @month = @screen_scraper.month
    @day = @screen_scraper.day
    @page_imgs = @screen_scraper.page_imgs

    @itemprop_pub_date_match

  end

  # POST /stories
  # POST /stories.json
  def create
    my_params = set_image_params(story_params)
    @story = Story.new(my_params)

    respond_to do |format|
      if @story.save
        format.html { redirect_to @story, notice: 'Story was successfully created.' }
        format.json { render :show, status: :created, location: @story }
      else
        @source_url_pre = @story.urls.first.url_full
        get_domain_info(@source_url_pre)
        # @screen_scraper = ScreenScraper.new
        # @screen_scraper.scrape!(@full_web_url)
        # set_scrape_fields
        set_scrape_fields_on_fail(story_params)
        format.html { render :new }
        format.json { render json: @story.errors, status: :unprocessable_entity }
      end
    end
  end

  # GET /stories/1/edit
  def edit
    @story = Story.find(params[:id])
    @meta_type = @story.scraped_type
    @meta_author = @story.author
    @year = @story.story_year
    @month = @story.story_month
    @day = @story.story_date
    @source_url_pre = @story.urls.first.url_full
    @base_domain = @story.urls.first.url_domain
    @title = @story.urls.first.url_title
    @meta_desc = @story.urls.first.url_desc
    @meta_keywords = @story.urls.first.url_keywords
    @full_web_url = @story.urls.first.url_full
  end

  # PATCH/PUT /stories/1
  # PATCH/PUT /stories/1.json
  def update
    respond_to do |format|
      if @story.update(story_params)
        format.html { redirect_to @story, notice: 'Story was successfully updated.' }
        format.json { render :show, status: :ok, location: @story }
      else
        format.html { render :edit }
        format.json { render json: @story.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /stories/1
  # DELETE /stories/1.json
  def destroy
    @story.destroy
    respond_to do |format|
      format.html { redirect_to stories_url, notice: 'Story was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  def get_domain_info(source_url_pre)
    d_url = Domainatrix.parse(source_url_pre)
    @full_domain = d_url.host
    split_full_domain = @full_domain.split(".")
    if split_full_domain.length == 2
      @base_domain = split_full_domain[0].to_s + "." + split_full_domain[1].to_s
    else
      @base_domain = split_full_domain[1].to_s + "." + split_full_domain[2].to_s
    end
    @full_web_url = d_url.url
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_story
    @story = Story.find(params[:id])
  end

  def set_scrape_fields_on_fail(hash)
    # to do
  end

  def set_image_params(story_params)
    image_data = story_params["urls_attributes"]["0"]["images_attributes"]["0"]["image_data"]
    image_data_hash = JSON.parse(image_data)
    story_params["urls_attributes"]["0"]["images_attributes"]["0"]["src_url"] = image_data_hash["src_url"]
    story_params["urls_attributes"]["0"]["images_attributes"]["0"]["alt_text"]= image_data_hash["alt_text"]
    story_params
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def story_params
    params.require(:story).permit(
      :media_id, :scraped_type, :story_type, :author, :story_month, :story_date, :story_year, :editor_tagline,
      :location_code, :category_code,:raw_author_scrape, :raw_story_year_scrape, :raw_story_month_scrape, :raw_story_date_scrape,
      urls_attributes: [
        :id, :url_type, :url_full, :url_title, :url_desc, :url_keywords, :url_domain, :primary, :story_id,
        :url_title_track, :url_desc_track, :url_keywords_track,
        :raw_url_title_scrape, :raw_url_desc_scrape, :raw_url_keywords_scrape,
            images_attributes: [:id, :src_url, :alt_text, :image_data ]])
  end

end
