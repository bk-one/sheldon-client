require 'net/http'
require 'json'
require 'addressable/uri'
require 'sheldon-client/configuration'
require 'sheldon-client/http'
require 'sheldon-client/node'
require 'sheldon-client/search'

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
  def self.search( type, options )
    uri = build_search_url( type, options )
    response = send_request( :get, uri )
    response.code == '200' ? parse_search_result(response.body) : []
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
  #    SheldonClient.create_edge from: matrix, to: action, type: 'hasGenre', payload: { weight: 1.0 }
  #    => true
  #
  def self.create_edge( options )
    response = send_request( :put, create_edge_url( options ), options[:payload] )
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
    response = send_request( :get, build_node_url( id ) )
    response.code == '200' ? Node.new(JSON.parse(response.body)) : nil
  end
end
