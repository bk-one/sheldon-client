class SheldonClient
  module HTTP
    def send_request( method, uri, body = nil )
      Net::HTTP.start( uri.host, uri.port ) do |http| 
        http.read_timeout = 3600
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
      Addressable::URI.parse( self.host + "/nodes/#{from}/connections/#{options[:type]}/#{to}" )
    end
    
    def create_node_url(options)
      Addressable::URI.parse( self.host + "/nodes/#{options[:type]}" )
    end

    def build_node_url( id )
       Addressable::URI.parse( self.host + "/nodes/" + id.to_s )
    end
    
    def build_edge_url( id )
       Addressable::URI.parse( self.host + "/connections/" + id.to_s )
    end

    def build_node_ids_of_type_url( type )
       Addressable::URI.parse( self.host + "/nodes/" + type.to_s + '/ids' )
    end

    def build_reindex_node_url( id )
      Addressable::URI.parse( self.host + '/nodes/' + id.to_s + '/reindex' )
    end

    def build_reindex_edge_url( id )
      Addressable::URI.parse( self.host + '/connections/' + id.to_s + '/reindex' )
    end

    def build_fetch_edge_url( from, to, type )
      Addressable::URI.parse( self.host + '/nodes/' + from.to_s + '/connections/' + type.to_s + '/' + to.to_s )
    end
  end
end
