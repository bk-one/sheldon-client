require 'net/http'
require 'json'
require 'addressable/uri'
require 'sheldon-client/configuration'
require 'sheldon-client/http'
require 'sheldon-client/node'
require 'sheldon-client/search'
require 'sheldon-client/edge'

class SheldonClient
  extend SheldonClient::Configuration
  extend SheldonClient::HTTP
  extend SheldonClient::Search
  
  
  # Search for Sheldon Nodes. This will return an array of SheldonClient::Node Objects
  # or an empty array.
  #
  # ==== Parameters
  # 
  # * <tt>type</tt> - plural of any known sheldon node type like :movies or :genres
  # * <tt>options</tt> - the search option that will be forwarded to lucene. This depends
  #   on the type, see below.
  #
  # ==== Search Options
  # 
  # Depending on the type of nodes you're searching for, different search options should
  # be provided. Please refer to the sheldon documentation for the most up-to-date version
  # of this. As of today, the following search options are supported.
  #
  # * <tt>movies</tt> - title, production_year
  # * <tt>genres</tt> - name
  # * <tt>person</tt> - name
  #
  # Sheldon will pass the search options to lucene, so if an option is supported and 
  # interpreted as exptected need to be verified by the Sheldon team. See http://bit.ly/hBpr4a
  # for more information.
  #  
  # ==== Examples
  #
  # Search for a specific movie
  # 
  #   SheldonClient.search :movies, { title: 'The Matrix' }
  #   SheldonClient.search :movies, { title: 'Fear and Loathing in Las Vegas', production_year: 1998 }
  #
  # Search for a specific genre
  #  
  #    SheldonClient.search :genres, { name: 'Action' }
  #
  # And now with wildcards
  #
  #    SheldonClient.search :movies, { title: 'Fist*' }
  #
  def self.search( type, options, index=:exact )
    uri = build_search_url( type, options, index )
    response = send_request( :get, uri )
    response.code == '200' ? parse_search_result(response.body) : []
  end

  # Fetch all the edges of a certain type connected to a given node.
  #
  # ==== Parameters
  #
  # * <tt> node </tt> The node that we are going to fetch edges from
  # * <tt> type </tt> The egde type we are interesting in
  #
  # ==== Examples
  #
  #  m = SheldonClient.search(:movies, { title: '99 Euro*'} ).first
  #  e = SheldonClient.fetch_edges(m, 'genre_taggings')
  #
  #  g = SheldonClient.search(:genres, name: 'Drama').first
  #  e = SheldonClient.fetch_edges(m, 'genre_taggings')
  #
  #  m = SheldonClient.fetch_node( 430 )
  #  e = SheldonClient.fetch_edges(
  #

  def self.fetch_edges( node, type )
    uri = build_edge_search_url( node.id, type)
    response = send_request( :get, uri )
    response.code == '200' ? parse_search_result(response.body) : []
  end
  
  
  # Fetches the node with the given id
  #
  # ==== Parameters
  #
  # * <tt> id </tt> The id of the node that is going to be fetched
  #
  # ==== Examples
  # 
  # m = SheldonClient.fetch_node( 430 )

  def self.fetch_node( id )
    uri = build_node_url id
    response = send_request( :get, uri )
    response.code == '200' ? parse_node(response.body) : nil
  end

  # Create an edge between two sheldon nodes. 
  #
  # ==== Parameters
  # 
  # * <tt>options</tt> - the options to create an edge. This must
  #   include <tt>from</tt>, <tt>to</tt>, <tt>type</tt> and 
  #   <tt>payload</tt>. The <tt>to</tt> and <tt>from</tt> option
  #   accepts a SheldonClient::Node Object or an integer.
  #
  # ==== Examples
  #
  # Create an edge between a movie and a genre.
  #
  #    matrix = SheldonClient.search( :movies, title: 'The Matrix' ).first
  #    action = SheldonClient.search( :genres, name: 'Action').first
  #    SheldonClient.create_edge {from: matrix, to: action, type: 'genretagging', payload: { weight: 1.0 }
  #    => true
  #
  
  def self.create_edge( options )
    response = send_request( :put, create_edge_url( options ), options[:payload] )
    response.code == '200' ? true : false
  end
  
  # Create a new node at sheldon.
  #
  # ==== Parameters
  # * <tt>options</tt> - the options to create a node. This must
  #   include the <tt>payload</tt>.
  #
  # ==== Examples
  #
  # Create a new node
  #
  #    SheldonClient.create_node(type: :movie, payload: { title: "Full Metal Jacket" })
  #    => SheldonClient::Node object
  #
  
  def self.create_node( options )
    response = send_request( :post, create_node_url( options ), options[:payload] )
    response.code == '201' ? true : false
  end

  # Updates the payload in a node
  #
  # ==== Parameters
  # * <tt>options</tt> - The options that is going to be updated in the node
  #   include the <tt>payload</tt>
  #
  # ==== Examples 
  #
  # Update a node
  #
  #   SheldonClient.update_node( 450, { payload: { year: '1999'} }
  #    => true
  #
  #   SheldonClient.update_node( 456, { payload: { title: 'Air bud'} }
  #    => true

  def self.update_node( id, options )
    node = node( id ) or return false
    response = SheldonClient.send_request( :put, build_node_url( node.id ), options )
    response.code == '200' ? true : false
  end

  # Deletes a node from the database
  #
  # ==== Parameters
  # * <tt>id</tt> - The node id we want to be deleted from the database 
  #
  # ==== Examples 
  #  SheldonClient.delete_node(2011)
  #   => true
  #
  #  SheldonClient.delete_node(201) //Non existant node
  #   => false
  #
  
  def self.delete_node(id)
    response = SheldonClient.send_request( :delete, build_node_url( id ) )
    response.code == '200' ? true : false
  end
  
  # Deletes a edge from the database
  #
  # ==== Parameters
  # * <tt>id</tt> - The edge id we want to be deleted from the database 
  #
  # ==== Examples 
  #  SheldonClient.delete_edge(2011)
  #   => true
  #
  #  SheldonClient.delete_edge(201) //Non existant edge
  #   => false
  #
  
  def self.delete_edge(id)
    response = SheldonClient.send_request( :delete, build_edge_url( id ) )
    response.code == '200' ? true : false
  end

  # Fetch a single node object from sheldon
  #
  # ==== Parameters
  #
  # * <tt>id</tt> - the sheldon id
  #
  # ==== Examples
  #
  #   SheldonClient.node 17007
  #   => #<Sheldon::Node 17007 (Movie/Tonari no Totoro)>]
  #
  def self.node( id )
    uri = build_node_url( id ) 
    response = send_request( :get, uri )
    response.code == '200' ? Node.new(JSON.parse(response.body)) : nil
  end

  #
  # Fetches all the node ids of a given node type
  #
  # === Parameters
  #
  #   * <tt>type</tt> - The node type
  #
  # === Examples
  #
  #   SheldonClient.get_node_ids_of_type( :movies )
  #   => [1,2,3,4,5,6,7,8, ..... ,9999]
  #
  def self.get_node_ids_of_type( type )
    uri = build_node_ids_of_type_url(type)
    response = send_request( :get, uri )
    response.code == '200' ? JSON.parse( response.body ) : nil
  end

  #
  # Reindexes a node in sheldon
  #
  # === Paremeters
  #
  #  * <tt>node_id</tt> - The node
  #
  # === Examples
  #
  #  SheldonClient.reindex_node( 13 )
  #  => true
  #
  #  SheldonClient.reindex_node( 37 ) // Non existing node
  #  => false

  def self.reindex_node( node_id ) 
    uri = build_reindex_url( node_id )
    response = send_request( :put , uri )
    response.code == '200' ? true : false
  end

  #
  # Fetches an edge between two nodes of a given type
  #
  # === Parameters
  #
  # * <tt>from</tt> - The source node
  # * <tt>to</tt> - The target node
  # * <tt>type</tt> - The edge type
  #
  # === Examples
  #
  # from = SheldonClient.search( :movies, {title: 'The Matrix} )
  # to = SheldonClient.search( :genres, {name: 'Action'} )
  # edge = SheldonClient.edge( from, to, 'genres' )
  #

  def self.edge( from, to, type) 
    uri = build_fetch_edge_url( from, to, type )
    response = send_request( :get, uri )
    response.code == '200' ? JSON.parse( response.body ) : nil
  end

  def self.facebook_item( fbid )
    ['users', 'movies', 'persons'].each do |type|
      result = search( type, {facebook_ids: fbid } ).first
      return result if result
    end
    nil
  end
end
