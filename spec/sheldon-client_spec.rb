require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "SheldonClient" do
  context "configuration" do
    it "should have a predefined host" do
      SheldonClient.host.should == 'http://sheldon-production.ci-dev.moviepilot.com'
      #SheldonClient.host.should == 'http://sheldon.labs.mvp.to:2311'
    end

    it "should return to the configured host" do
      SheldonClient.host = 'http://i.am.the.real.sheldon/'
      SheldonClient.host.should == 'http://i.am.the.real.sheldon'
    end
  end

  context "building request urls" do
    it "should create correct url from given options" do
      SheldonClient.host = 'http://i.am.the.real.sheldon/'
      SheldonClient.create_edge_url( from: 13, to: 14, type: :foo ).path.should == "/nodes/13/connections/foo/14"
      SheldonClient.create_edge_url( from: 10, to: 11, type: :bar ).path.should == "/nodes/10/connections/bar/11"
      SheldonClient.create_node_url( type: :movie ).path.should == "/nodes/movie"
      SheldonClient.build_node_ids_of_type_url( :movies ).path.should == '/nodes/movies/ids'
      SheldonClient.build_node_ids_of_type_url( :genres ).path.should == '/nodes/genres/ids'
      SheldonClient.build_reindex_node_url( 3 ).path.should == '/nodes/3/reindex'
      SheldonClient.build_reindex_edge_url( 3 ).path.should == '/connections/3/reindex'
      SheldonClient.build_fetch_edge_url( 13, 37, 'genre_taggings' ).path.should == '/nodes/13/connections/genre_taggings/37'
      SheldonClient.build_fetch_edge_url( 37, 13, 'actings' ).path.should == '/nodes/37/connections/actings/13'
    end
  end


  context "create nodes in sheldon" do
     before(:each) do
        SheldonClient.host = 'http://sheldon.host'
      end
      
      it "should create a node" do
        stub_request(:post, "http://other.sheldon.host/nodes/movie").
            with(:headers => {'Accept'=>'application/json', 'Content-Type'=>'application/json'},
                 :body    => { :weight => 1.0 }.to_json).to_return(:status => 200)

        SheldonClient.host = 'http://other.sheldon.host' 
        SheldonClient.create_node( type: :movie, payload: { weight: 1.0 }) 
      end
  end
  
  context "delete nodes in sheldon" do
     before(:each) do
        SheldonClient.host = 'http://sheldon.host'
      end
      
      it "should create a node" do
        stub_request(:delete, "http://other.sheldon.host/nodes/12").
            with(:headers => {'Accept'=>'application/json', 'Content-Type'=>'application/json'}).
            to_return(:status => 200)

        SheldonClient.host = 'http://other.sheldon.host' 
        SheldonClient.delete_node(12).should == true
      end
      
      it "should return false when deleting non existance nodes" do
        stub_request(:delete, "http://other.sheldon.host/nodes/122").
            with(:headers => {'Accept'=>'application/json', 'Content-Type'=>'application/json'}).
            to_return(:status => 404)

        SheldonClient.host = 'http://other.sheldon.host' 
        SheldonClient.delete_node(122).should == false
      end
  end
  
  context "delete connections in sheldon" do
      before(:each) do
         SheldonClient.host = 'http://sheldon.host'
       end

       it "should create a node" do
         stub_request(:delete, "http://other.sheldon.host/connections/12").
             with(:headers => {'Accept'=>'application/json', 'Content-Type'=>'application/json'}).
             to_return(:status => 200)

         SheldonClient.host = 'http://other.sheldon.host' 
         SheldonClient.delete_edge(12).should == true
       end

       it "should return false when deleting non existance nodes" do
         stub_request(:delete, "http://other.sheldon.host/connections/122").
             with(:headers => {'Accept'=>'application/json', 'Content-Type'=>'application/json'}).
             to_return(:status => 404)

         SheldonClient.host = 'http://other.sheldon.host' 
         SheldonClient.delete_edge(122).should == false
       end
   end
  

  context "creating edges in sheldon" do
    before(:each) do
      SheldonClient.host = 'http://sheldon.host'
    end

    it "should create an request to create an edge" do
      stub_request(:put, "http://sheldon.host/nodes/13/connections/movies_genres/14").
          with(:headers => {'Accept'=>'application/json', 'Content-Type'=>'application/json'},
               :body    => { :weight => 1.0 }.to_json).to_return(:status => 200)

	    SheldonClient.create_edge( from: 13, to: 14, type: :movies_genres, payload: { weight: 1.0 } )
	  end

    it "should be able to talk to a different host" do
      stub_request(:put, "http://other.sheldon.host/nodes/10/connections/movies_genres/11").
          with(:headers => {'Accept'=>'application/json', 'Content-Type'=>'application/json'},
               :body    => { :weight => 1.0 }.to_json).to_return(:status => 200)

      SheldonClient.host = 'http://other.sheldon.host'
	    SheldonClient.create_edge( from: 10, to: 11, type: :movies_genres, payload: { weight: 1.0 } )
    end

    it "should include the right payload" do
      stub_request(:put, "http://other.sheldon.host/nodes/10/connections/movies_genres/11").
          with(:headers => {'Accept'=>'application/json', 'Content-Type'=>'application/json'},
               :body    => { :weight => 0.4 }.to_json).to_return(:status => 200)

      SheldonClient.host = 'http://other.sheldon.host'
	    SheldonClient.create_edge( from: 10, to: 11, type: :movies_genres, payload: { weight: 0.4 } )
    end

    it "should create edges from node objects" do
      stub_request(:put, "http://sheldon.host/nodes/123/connections/movies_genres/321").
          with(:headers => {'Accept'=>'application/json', 'Content-Type'=>'application/json'},
               :body    => { :weight => 0.4 }.to_json).to_return(:status => 200)
               
 	    SheldonClient.create_edge( from: SheldonClient::Node.new({'id' => 123, 'type' => 'Movie'}), 
 	                                 to: SheldonClient::Node.new({'id' => 321, 'type' => 'Genre'}),
 	                               type: :movies_genres, payload: { weight: 0.4 } )
    end
  end

  context "searching for nodes" do
    it "should search for movies" do
      stub_request(:get, "http://sheldon.host/search/nodes/movies?production_year=1999&title=Matrix&type=fulltext").
          with(:headers => {'Accept'=>'application/json', 'Content-Type'=>'application/json'}).
          to_return(:status => 200, :body => [{ "type" => "Movie", "id" => "123" }].to_json )
          
      result = SheldonClient.search( :movies, {title: 'Matrix', production_year: '1999'}, :fulltext )
      result.first.should be_a SheldonClient::Node
      result.first.id.should == "123"
      result.first.type.should == 'Movie'
    end
    
    it "should search for genres" do
      stub_request(:get, "http://sheldon.host/search/nodes/genres?name=Action").
          with(:headers => {'Accept'=>'application/json', 'Content-Type'=>'application/json'}).
          to_return(:status => 200, :body => [{ "type" => "Genre", "id" => "321" }].to_json )
          
      result = SheldonClient.search( :genres, {name: 'Action'} )
      result.first.should be_a SheldonClient::Node
      result.first.id.should == "321"
      result.first.type.should == 'Genre'
    end
    
    it "should return an empty array on no-content responses" do
      stub_request(:get, "http://sheldon.host/search/nodes/genres?name=Action").
          with(:headers => {'Accept'=>'application/json', 'Content-Type'=>'application/json'}).
          to_return(:status => 204, :body => '' )
          
      SheldonClient.search( :genres, {name: 'Action'} ).should == []
    end
  end

  context "node payloads" do
    it "should return the payload of a given node" do
      stub_request(:get, "http://sheldon.host/nodes/2001").
          with(:headers => {'Accept'=>'application/json', 'Content-Type'=>'application/json'}).
          to_return(:status => 200, :body => { "type" => "Movie", "id" => "123", "payload" => { "title" => "MyTitle" } }.to_json )
      
      result = SheldonClient.node( 2001 )
      result.should be_a SheldonClient::Node
      result.id.should == "123"
      result.payload.should == { "title" => "MyTitle" }
    end
  end

  context "updating nodes" do
    it "should update the the year of a given node" do
      stub_request(:get, "http://sheldon.host/nodes/500").
              with(:headers => {'Accept'=>'application/json', 'Content-Type'=>'application/json'}).
         to_return(:status => 200, :body => { :id => 500, :type => "Movie", :payload => { :year => 2000 } }.to_json )
      stub_request(:put, "http://sheldon.host/nodes/500").
              with(:headers => {'Accept'=>'application/json', 'Content-Type'=>'application/json'},
                   :body    => { :year => 2000 }.to_json).to_return(:status => 200)
      SheldonClient.update_node( 500, { year: 2000 } ).should == true
    end
  end

  context "getting all the ids of a node type" do
    it "should fetch all the movie ids" do
      stub_request(:get, "http://sheldon.host/nodes/movies/ids" ).
              with(:headers => {'Accept' => 'application/json', 'Content-Type'=>'application/json'}).
          to_return(:status => 200, :body => [1,2,3,4,5].to_json )
      result = SheldonClient.get_node_ids_of_type( :movies )
      result.should == [1,2,3,4,5]
    end
  end
  context "reindexing nodes and edges" do
    it "should send a reindex request to a node" do
      stub_request( :put, 'http://sheldon.host/nodes/1337/reindex').
              with(:headers => {'Accept' => 'application/json', 'Content-Type'=>'application/json'}).
              to_return( :status => 200, :body => {type: 'Movie', id: '1337', payload: { title: 'Spirited Away'} }.to_json )
      result = SheldonClient.reindex_node( 1337 )
      result.id.should == '1337'
      result.payload['title'].should == 'Spirited Away'
    end

    it "should send a reindex request to an edge" do
      stub_request( :put, 'http://sheldon.host/connections/43/reindex').
              with( :headers => { 'Accept'=>'application/json', 'Content-Type' => 'application/json', 'User-Agent'=>'Ruby'} ).
              with( :headers => { 'Accept'=>'application/json', 'Content-Type'=>'application/json', 'User-Agent'=>'Ruby'}).
         to_return( :status => 200, :headers => {},:body => { 'id' => 43, 'type' => 'actings', 'from' => '13', 'to' => '14', 'payload' => { 'weight' => '0.5'}}.to_json )
      result = SheldonClient.reindex_edge 43
      result.id.should == 43
      result.from.should == '13'
      result.to.should == '14'
      result.type.should == 'actings'
      result.payload['weight'].should == '0.5'

    end
  end
  
  context "fetching edges" do
    it "should get one edge between two nodes of a certain edge type" do
      stub_request( :get, 'http://sheldon.host/nodes/13/connections/actings/15').
             with( :headers => {'Accept' => 'application/json', 'Content-Type' => 'application/json'}).
        to_return( :status  => 200, :body => { 'id' => 45, 'type' => 'actings', 'from' => '13', 'to' => '15', 'payload' => { 'weight' => '0.5' }}.to_json )
      result = SheldonClient.edge(13, 15, 'actings')
      result.id.should == 45
      result.from.should == '13'
      result.to.should == '15'
      result.type.should == 'actings'
      result.payload['weight'].should == '0.5'
    end
    it "should get a non-existing node between two nodes" do
      stub_request( :get, 'http://sheldon.host/nodes/13/connections/genre_taggings/15').
             with( :headers => {'Accept' => 'application/json', 'Content-Type' => 'application/json'}).
        to_return( :status  => 404, :body => '' )
      result = SheldonClient.edge( 13, 15, 'genre_taggings' )
      result.should == nil

    end
  end

  context "fetching nodes based on facebook id regardless node type" do

    it "should do one successful search" do
     stub_request(:get, "http://sheldon.host/search/nodes/users?facebook_ids=123456").
             with(:headers => {'Accept'=>'application/json', 'Content-Type'=>'application/json', 'User-Agent'=>'Ruby'}).
        to_return(:status => 200, :body => [{ "type" => "users", "id" => "123", 'payload'=> {'facebook_ids' =>'123456' }}].to_json, :headers => {})

      result = SheldonClient.facebook_item( '123456' )
      result.type.should == 'users'
      result.payload['facebook_ids'].should == '123456'
    end

    it "should do a search that fails and one that is successful" do
      stub_request(:get, "http://sheldon.host/search/nodes/users?facebook_ids=123456").
              with(:headers => {'Accept'=>'application/json', 'Content-Type'=>'application/json', 'User-Agent'=>'Ruby'}).
         to_return(:status => 200, :body => [].to_json )

      stub_request(:get, "http://sheldon.host/search/nodes/movies?facebook_ids=123456").
              with(:headers => {'Accept'=>'application/json', 'Content-Type'=>'application/json', 'User-Agent' => 'Ruby'}).
         to_return(:status => 200, :body => [{ "type" => "movies", "id" => "123" , 'payload'=> {'facebook_ids' =>'123456' }}].to_json )

      result = SheldonClient.facebook_item( '123456' )
      result.type.should == 'movies'
      result.payload['facebook_ids'].should == '123456'
    end

    it "should do two searches that fails and one that is successful" do
      stub_request(:get, "http://sheldon.host/search/nodes/users?facebook_ids=123456").
              with(:headers => {'Accept'=>'application/json', 'Content-Type'=>'application/json'}).
         to_return(:status => 200, :body => [].to_json )

      stub_request(:get, "http://sheldon.host/search/nodes/movies?facebook_ids=123456").
              with(:headers => {'Accept'=>'application/json', 'Content-Type'=>'application/json'}).
         to_return(:status => 200, :body => [].to_json )

      stub_request(:get, "http://sheldon.host/search/nodes/persons?facebook_ids=123456").
              with(:headers => {'Accept'=>'application/json', 'Content-Type'=>'application/json'}).
         to_return(:status => 200, :body => [{ "type" => "persons", "id" => "123" , 'payload'=> {'facebook_ids' =>'123456' }}].to_json )

      result = SheldonClient.facebook_item( '123456' )
      result.type.should == 'persons'
      result.payload['facebook_ids'].should == '123456'
    end

    it "should return nil if no node was found" do
      stub_request(:get, "http://sheldon.host/search/nodes/users?facebook_ids=123456").
              with(:headers => {'Accept'=>'application/json', 'Content-Type'=>'application/json'}).
         to_return(:status => 200, :body => [].to_json )

      stub_request(:get, "http://sheldon.host/search/nodes/movies?facebook_ids=123456").
              with(:headers => {'Accept'=>'application/json', 'Content-Type'=>'application/json'}).
         to_return(:status => 200, :body => [].to_json )
      stub_request(:get, "http://sheldon.host/search/nodes/persons?facebook_ids=123456").
              with(:headers => {'Accept'=>'application/json', 'Content-Type'=>'application/json'}).
         to_return(:status => 200, :body => [].to_json )
      SheldonClient.facebook_item( '123456' ).should == nil
    end

  end
end
