class ReportsController < ApplicationController
  before_filter :authenticate_user!
  after_action :verify_authorized

  def export_stories_users
    authorize Report

    require 'csv'
    require 'sendgrid-ruby'

    logged_in_user_email = User.find(current_user).email

    # story export
    file = Rails.root.join('tmp','story_listing.csv')
    puts "File will be #{file}"

    stories = Story.eager_load(:urls => [:images]).eager_load(:locations).eager_load(:place_categories).eager_load(:story_categories).order(:id)

    CSV.open( file, 'w' ) do |writer|
      writer << ["Id", "Created","SAP Publish","Story Type","YY","MM","DD","Tagline","Location","Place Category","Story Category","Author Trk", \
            "Story Yr Trk","Story Mnth Trk","Story Dt Trk","DataEntry Secs","URL","Domain","Media Owner Id","Manual Img","Data Entered By","Story Complete"]
      stories.each do |s|
        @url_full,@url_domain,@manual_enter,@location_name,@pc_name,@sc_name = ["","","","","",""]
        s.urls.each do |u|
          @url_full = u.url_full
          @url_domain = u.url_domain
          u.images.each do |i|
            @manual_enter = i.manual_enter
          end
        end
        @location_name = s.locations.map { |l| l.code }.join(',')
        @pc_name = s.place_categories.map { |pc| pc.code }.join(',')
        @sc_name = s.story_categories.map { |sc| sc.code }.join(',')

        writer << [s.id, s.created_at, s.sap_publish_date, s.story_type, s.story_year, s.story_month, s.story_date, s.editor_tagline, \
                  @location_name, @pc_name, @sc_name, s.author_track, s.story_year_track, s.story_month_track, s.story_date_track, \
                  s.data_entry_time, @url_full, @url_domain, s.mediaowner_id, @manual_enter, s.data_entry_user, s.story_complete]
      end
    end

    # stories = Story.includes(:urls => [:images]).includes(:locations).includes(:place_categories).includes(:story_categories).order(:id)
    # # stories = Story.includes(:urls => [:images]).order(:id)
    #
    # CSV.open( file, 'w' ) do |writer|
    #   writer << ["Id", "Created","SAP Publish","Story Type","YY","MM","DD","Tagline","Location","Place Category","Story Category","Author Trk", \
    #         "Story Yr Trk","Story Mnth Trk","Story Dt Trk","DataEntry Secs","URL","Domain","Manual"]
    #   stories.each do |s|
    #     s.locations.each do |l|
    #     s.urls.each do |u|
    #       u.images.each do |i|
    #         writer << [s.id, s.created_at, s.sap_publish_date, s.story_type, s.story_year, s.story_month, s.story_date, s.editor_tagline, \
    #               s.author_track, s.story_year_track, \
    #               s.story_month_track, s.story_date_track, s.data_entry_time, u.url_full, u.url_domain, i.manual_enter]
    #       end
    #     end
    #     end
    #   end
    # end

    # user export
    file2 = Rails.root.join('tmp','user_listing.csv')
    # puts "File will be #{file2}"

    users = User.all

    CSV.open( file2, 'w' ) do |writer|
      writer << ["id","first_name","last_name","role","email","reset_password_sent_at","remember_created_at","sign_in_count", \
      "created_at","updated_at","confirmed_at", \
      "confirmation_sent_at","unconfirmed_email","city_preference"]
      
      users.each do |u|
            writer << [u.id,u.first_name,u.last_name,u.role,u.email,u.reset_password_sent_at,u.remember_created_at,u.sign_in_count, \
      u.created_at,u.updated_at,u.confirmed_at, \
      u.confirmation_sent_at,u.unconfirmed_email,u.city_preference]
      end
    end

    client = SendGrid::Client.new(api_user: ENV["SENDGRID_USERNAME"], api_key: ENV["SENDGRID_PASSWORD"])

    mail = SendGrid::Mail.new do |m|
      m.to = "#{logged_in_user_email}"
      m.from = 'StoriesAboutPlaces.com'
      m.subject = 'CSV Export'
      m.text = 'Your latest export is attached.'
    end

    mail.add_attachment("#{file}")
    mail.add_attachment("#{file2}")
    puts client.send(mail)

    redirect_to :back, notice: "Export sent to #{logged_in_user_email}"

end

  def export_stories
    authorize Report

    require 'csv'
    require 'sendgrid-ruby'

    logged_in_user_email = User.find(current_user).email

    # story export
    file = Rails.root.join('tmp','story_listing.csv')
    # puts "File will be #{file}"

    stories = Story.includes(:urls => [:images]).order(:id)

    CSV.open( file, 'w' ) do |writer|
      writer << ["Id", "Created","SAP Publish","Story Type","YY","MM","DD","Tagline","Location","Place Category","Story Category","Author Trk", \
            "Story Yr Trk","Story Mnth Trk","Story Dt Trk","DataEntry Secs","URL","Domain","Manual"]
      stories.each do |s|
        s.urls.each do |u|
          u.images.each do |i|
            writer << [s.id, s.created_at, s.sap_publish_date, s.story_type, s.story_year, s.story_month, s.story_date, s.editor_tagline, \
                  s.location_code, s.place_category, s.story_category, s.author_track, s.story_year_track, \
                  s.story_month_track, s.story_date_track, s.data_entry_time, u.url_full, u.url_domain, i.manual_enter]
          end
        end
      end
    end

    client = SendGrid::Client.new(api_user: ENV["SENDGRID_USERNAME"], api_key: ENV["SENDGRID_PASSWORD"])

    mail = SendGrid::Mail.new do |m|
      m.to = "#{logged_in_user_email}"
      m.from = 'StoriesAboutPlaces.com'
      m.subject = 'CSV Export'
      m.text = 'Your latest export is attached.'
    end

    mail.add_attachment("#{file}")
    puts client.send(mail)

    redirect_to :back, notice: "Export sent to #{logged_in_user_email}"

  end

  def user_actions
    authorize Report

    require 'csv'
    require 'sendgrid-ruby'

    logged_in_user_email = User.find(current_user).email

    # action export
    file1 = Rails.root.join('tmp','action_listing.csv')
    # puts "File1 will be #{file1}"
    file2 = Rails.root.join('tmp','outbound_click_listing.csv')
    # puts "File2 will be #{file2}"

    actions = User.includes(:events).joins(:events).order("ahoy_events.time")
    # actions = User.includes(:events)

    CSV.open( file1, 'w' ) do |writer|
      writer << ["Id","First","Last","Email","Date-Time","Controller","Controller-Action","Location","Place Category","Story Category","Button"]
        actions.each do |a|
          a.events.each do |e|
            if e.properties.values[5].present?  # filter actions
              writer << [a.id, a.first_name, a.last_name, a.email, e.time, e.properties.values[6], e.properties.values[7], \
                  e.properties.values[2], e.properties.values[3], e.properties.values[4], e.properties.values[5]]
            end
            unless e.properties.values[5].present?  # non-filter actions
              writer << [a.id, a.first_name, a.last_name, a.email, e.time, e.properties.values[0], e.properties.values[1]]
            end
          end
        end
    end

    outbound_clicks = OutboundClick.all

    CSV.open( file2, 'w' ) do |writer|
      writer << ["Id","UserId","Url","Created"]
      outbound_clicks.each do |c|
        writer << [c.id, c.user_id, c.url, c.created_at]
      end
    end

    client = SendGrid::Client.new(api_user: ENV["SENDGRID_USERNAME"], api_key: ENV["SENDGRID_PASSWORD"])

    mail = SendGrid::Mail.new do |m|
      m.to = "#{logged_in_user_email}"
      m.from = 'StoriesAboutPlaces.com'
      m.subject = 'Internal User Actions and External Outbound Clicks'
      m.text = 'Your latest export is attached.'
    end

    mail.add_attachment("#{file1}")
    mail.add_attachment("#{file2}")
    puts client.send(mail)

    redirect_to :back, notice: "Export sent to #{logged_in_user_email}"

  end

end
