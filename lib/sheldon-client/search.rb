class SheldonClient
  module Search
    
    protected 
    
    def parse_search_result( json_string )
      JSON.parse( json_string ).map do |data|
        if is_edge?( data )
          Edge.new data
        else
          Node.new data
        end
      end
    end
    
    def parse_node(json_string)
      Node.new JSON.parse( json_string )
    end

    def is_edge?( data )
       data['from'] and data['to']
    end

    def build_search_url( type, query_parameters, index )
      uri = Addressable::URI.parse( self.host + "/search/nodes/" + type.to_s )
      query_parameters['type'] = index.to_s if index != :exact
      uri.query_values = query_parameters
      uri
    end

    def build_edge_search_url( node_id, type )
      uri = Addressable::URI.parse( self.host + "/nodes/" + node_id.to_s + "/connections/" + type.to_s )
    end

    def build_node_url( node_id )
      uri = Addressable::URI.parse( self.host + "/nodes/" + node_id.to_s)
    end
  end
end
