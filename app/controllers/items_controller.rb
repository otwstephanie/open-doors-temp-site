class ItemsController < ApplicationController
  require 'application_helper'

  include OtwArchive
  include OtwArchive::Request
  include ApplicationHelper

  def initialize
    import_config = OtwArchive::ImportConfig.new("http://localhost:3000", Rails.application.secrets[:ao3api][:local][:key], "testy")
    @client = OtwArchive::Client.new(import_config)
    super
  end

  def import
    respond_to :json
    type = params[:type]
    id = params[:id]

    if type == "story"
      story = Story.find(id)
      item = { works: [story_to_work(story)] }
    else
      bookmark = Bookmark.find(id)
      item = { work: [bookmark_to_ao3(bookmark, @client.config.archivist)]}
    end

    response = @client.import(item)
    render json: response, content_type: 'text/json'
  end
end
