class SheldonClient
  module Search
    
    protected 
    
    def parse_search_result( json_string )
      JSON.parse( json_string ).map do |node_data|
        Node.new node_data
      end
    end
    
    def build_search_url( type, query_parameters )
      uri = Addressable::URI.parse( self.host + "/search/nodes/" + type.to_s )
      uri.query_values = query_parameters
      uri
    end
  end
end