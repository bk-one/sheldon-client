require 'addressable/uri'

class SheldonClient
  module UrlHelper
    include ActiveSupport::Inflector
    
    def connections_url( from, type, to = nil )
      if to.nil?
        path = "/nodes/#{from.to_i}/connections/#{type.to_s.pluralize}"
      else
        path = "/nodes/#{from.to_i}/connections/#{to.to_i}/#{type.to_s.pluralize}"
        
      end
      Addressable::URI.parse( SheldonClient.host + path )
    end
    
    def node_url( *args )
      if     args[0].is_a?(Numeric) and args[1].nil?
        # e.g. node_url( 1 )
        path = "/nodes/#{args[0]}"
      elsif !args[1].nil? and args[1].is_a?(Symbol)
        # e.g. node_url( 1, :reindex )
        path = "/nodes/#{args[0]}/#{args[1]}"
      elsif !args[1].nil?
        # e.g. node_url( :movie, 2 )
        path = "/nodes/#{args[0].to_s.pluralize}/#{args[1]}"
      elsif  args[0].is_a?(Symbol) or args[0].is_a?(String)
        # e.g. node_url( :movie )
        path = "/nodes/#{args[0].to_s.pluralize}"
      end
      Addressable::URI.parse( SheldonClient.host + path )
    end
    
    def neighbours_url( from, type = nil )
      path = "/nodes/#{from}/neighbours"
      path = path + "/#{type.to_s.pluralize}" if type
      Addressable::URI.parse( SheldonClient.host + path )
    end
    
    def status_url
      Addressable::URI.parse( SheldonClient.host + "/status" )
    end
  end
end
