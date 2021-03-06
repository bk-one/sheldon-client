class SheldonClient
  module Search

     def build_facebook_id_search_url( facebook_id )
      uri = Addressable::URI.parse( self.host + "/search")
      #uri.query_values = { 'facebook_ids' => facebook_id.to_s}
      uri.query_values = { 'q' => facebook_id.to_s}
      uri
    end

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

    def build_url( uri )
      Addressable::URI.parse( self.host + uri )
    end
  end
end
