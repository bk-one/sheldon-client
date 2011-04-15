require 'net/http'
require 'json'
require 'addressable/uri'


class SheldonClient
  
  def self.create_edge( options )
    uri = self.build_request_url(options)
    response = Net::HTTP.start(uri.host, uri.port) do |http|
      req = Net::HTTP::Put.new( uri.request_uri )
      default_headers(req)
      req.body = { :weight => options[:payload][:weight] }.to_json
      http.request(req)
    end
  end
  
  def self.node_payload( id )
    uri = self.build_node_url( id )
    response = Net::HTTP.start( uri.host, uri.port ) do |http|
      req = Net::HTTP::Get.new( uri.request_uri )
      default_headers(req)
      http.request(req)
    end
    response.code == '200' ? JSON.parse(response.body)['payload'] : nil
  end

  def self.search_movie( title, production_year = nil )
    uri = self.build_search_url( :movies, { :title => title, :production_year => production_year } )
    response = Net::HTTP.start( uri.host, uri.port ) do |http|
      req = Net::HTTP::Get.new( uri.request_uri )
      default_headers(req)
      http.request(req)
    end
    response.code == '200' ? JSON.parse(response.body).first['id'] : nil
  end
  
  def self.host
    @host
  end

  def self.host=( value )
    @host = value.chomp("/")
  end
  
  private

  def self.default_headers( request )
    request['Content-Type'] = 'application/json'
    request['Accept'] = 'application/json'
  end

  def self.build_request_url(options)
    Addressable::URI.parse( self.host + "/nodes/" + options[:from].to_s + "/connections/" + options[:type].to_s  + "/" + options[:to].to_s )
  end
  
  def self.build_node_url( id )
    Addressable::URI.parse( self.host + "/node/" + id.to_s )
  end
  
  def self.build_search_url( type, query_parameters )
    uri = Addressable::URI.parse( self.host + "/search/nodes/" + type.to_s )
    uri.query_values = query_parameters
    uri
  end

end
