class SheldonClient
  module HTTP
    def send_request( method, uri, body = nil )
      Net::HTTP.start( uri.host, uri.port ) do |http|
        req = build_request( method, uri, body )
        default_headers(req)
        http.request(req)
      end
    end

    def build_request( method, uri, body = nil )
      request = Object.module_eval("Net::HTTP::#{method.capitalize}").new( uri.request_uri )
      request.body = body.to_json if body
      request
    end

    def default_headers( request )
      request['Content-Type'] = 'application/json'
      request['Accept'] = 'application/json'
    end

    def create_edge_url(options)
      from = options[:from].is_a?(Node) ? options[:from].id : options[:from].to_i
      to   = options[:to].is_a?(Node) ? options[:to].id : options[:to].to_i
      Addressable::URI.parse( self.host + "/node/#{from}/connections/#{options[:type]}/#{to}" )
    end

    def build_node_url( id )
      Addressable::URI.parse( self.host + "/node/" + id.to_s )
    end
  end
end