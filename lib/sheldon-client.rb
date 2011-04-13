require 'net/http'
require 'json'
require 'uri'

class SheldonClient

  def self.create_edge( options )
    uri = URI.parse( self.host + self.build_request_url(options) )
    response = Net::HTTP.start(uri.host, uri.port) do |http|
      req = Net::HTTP::Put.new( uri.path )
      req['Content-Type'] = 'application/json'
      req['Accept'] = 'application/json'
      req.body = { :weight => options[:payload][:weight] }.to_json
      http.request(req)
    end
  end
  def self.host
    @host 
  end

  def self.host=( value )
    @host = value
  end

  private

  def self.build_request_url(options)
    "/nodes/" + options[:from].to_s + "/connections/" + options[:type].to_s  + "/" + options[:to].to_s
  end

end
