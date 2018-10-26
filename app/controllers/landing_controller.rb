class LandingController < ApplicationController
  def index
    remote_ip_addr = request.remote_ip == '::1' || request.remote_ip == '127.0.0.1' ? '202.131.102.54' : request.remote_ip
    @get_location = Geocoder.search(remote_ip_addr)
  end

  def create
    require 'net/http'
    require 'json'
    response = call_api
    if response.kind_of? Net::HTTPSuccess
      flash[:success] = "Your inquiry recieved, We will get back to you shortly."
      redirect_to root_path
    else
      json_response = JSON.parse(response.body)
      json_response["errors"].each do |error|
        @errors << error["field"] + " " + error["detail"]
      end
      render 'index'
    end
  end

  private

  def call_api
    url = URI.parse(ENV['API_BASE_URL']+'/contact_messages')
    http = Net::HTTP.new(url.host, url.port)
    @errors = []
    request = Net::HTTP::Post.new(url, {'Content-Type' => 'application/json'})
    request.body = params.to_json
    response = http.request(request)
    return response
  end
end
