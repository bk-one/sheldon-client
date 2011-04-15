class SheldonClient
  module HTTP
    def send_request( method, uri )
      Net::HTTP.start( uri.host, uri.port ) do |http|
        req = build_request( method, uri )
        default_headers(req)
        http.request(req)
      end
    end

    def build_request( method, uri, body = nil )
      request = Object.module_eval("Net::HTTP::#{method.capitalize}").new( uri.request_uri )
      request.body = body if body
      request
    end

    def default_headers( request )
      request['Content-Type'] = 'application/json'
      request['Accept'] = 'application/json'
    end

    def create_edge_url(options)
      Addressable::URI.parse( self.host + "/node/" + options[:from].to_s + "/connections/" + options[:type].to_s  + "/" + options[:to].to_s )
    end

    def build_node_url( id )
      Addressable::URI.parse( self.host + "/node/" + id.to_s )
    end
  end
end