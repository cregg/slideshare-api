require 'uri'

class SearchController < ApplicationController
  skip_before_action :verify_authenticity_token

  def index
   end

  def new
  end

  def create
    hash = Digest::MD5.hexdigest("patriceBergeron" + Time.now.to_i.to_s)[0..7]
    DocRankerJob.perform_later(params[:company_url], URI.encode(params[:company_name]), hash)
    render plain: hash
  end

  def show
    items = $redis[params[:id]]
    status = $redis[params[:id] + "_status"] == nil ? "" : $redis[params[:id] + "_status"]
    key_people = $redis[params[:id] + "_key_people"]
    key_words = $redis[params[:id] + "_key_words"]
    puts "Status: " + status
    render json: { :items => items, :status => status, :key_people => key_people, :key_words => key_words }
  end  
end
