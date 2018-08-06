class LandingController < ApplicationController
  def index
  end

  def create
    require 'net/http'
    require 'json'
    response = call_api
    if response.kind_of? Net::HTTPSuccess
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
