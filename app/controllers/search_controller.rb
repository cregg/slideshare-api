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
    status = $redis[params[:id] + "_status"]
    puts "Status: " + status
    render json: {:items => items, :status => status}
  end

  

    
end
