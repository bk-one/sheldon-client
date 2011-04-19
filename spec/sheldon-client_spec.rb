require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "SheldonClient" do
  context "configuration" do
    it "should have a predefined host" do
      SheldonClient.host.should == 'http://sheldon.labs.mvp.to:2311'
    end

    it "should return to the configured host" do
      SheldonClient.host = 'http://i.am.the.real.sheldon/'
      SheldonClient.host.should == 'http://i.am.the.real.sheldon'
    end
  end

  context "building request urls" do
    it "should create correct url from given options" do
      SheldonClient.host = 'http://i.am.the.real.sheldon/'
      SheldonClient.create_edge_url( from: 13, to: 14, type: :foo ).path.should == "/node/13/connections/foo/14"
      SheldonClient.create_edge_url( from: 10, to: 11, type: :bar ).path.should == "/node/10/connections/bar/11"
      SheldonClient.create_node_url( type: :movie ).path.should == "/nodes/movie"
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

  context "creating edges in sheldon" do
    before(:each) do
      SheldonClient.host = 'http://sheldon.host'
    end

    it "should create an request to create an edge" do
      stub_request(:put, "http://sheldon.host/node/13/connections/movies_genres/14").
          with(:headers => {'Accept'=>'application/json', 'Content-Type'=>'application/json'},
               :body    => { :weight => 1.0 }.to_json).to_return(:status => 200)

	    SheldonClient.create_edge( from: 13, to: 14, type: :movies_genres, payload: { weight: 1.0 } )
	  end

    it "should be able to talk to a different host" do
      stub_request(:put, "http://other.sheldon.host/node/10/connections/movies_genres/11").
          with(:headers => {'Accept'=>'application/json', 'Content-Type'=>'application/json'},
               :body    => { :weight => 1.0 }.to_json).to_return(:status => 200)

      SheldonClient.host = 'http://other.sheldon.host'
	    SheldonClient.create_edge( from: 10, to: 11, type: :movies_genres, payload: { weight: 1.0 } )
    end

    it "should include the right payload" do
      stub_request(:put, "http://other.sheldon.host/node/10/connections/movies_genres/11").
          with(:headers => {'Accept'=>'application/json', 'Content-Type'=>'application/json'},
               :body    => { :weight => 0.4 }.to_json).to_return(:status => 200)

      SheldonClient.host = 'http://other.sheldon.host'
	    SheldonClient.create_edge( from: 10, to: 11, type: :movies_genres, payload: { weight: 0.4 } )
    end

    it "should create edges from node objects" do
      stub_request(:put, "http://sheldon.host/node/123/connections/movies_genres/321").
          with(:headers => {'Accept'=>'application/json', 'Content-Type'=>'application/json'},
               :body    => { :weight => 0.4 }.to_json).to_return(:status => 200)
               
 	    SheldonClient.create_edge( from: SheldonClient::Node.new({'id' => 123, 'type' => 'Movie'}), 
 	                                 to: SheldonClient::Node.new({'id' => 321, 'type' => 'Genre'}),
 	                               type: :movies_genres, payload: { weight: 0.4 } )
    end
  end

  context "searching for nodes" do
    it "should search for movies" do
      stub_request(:get, "http://sheldon.host/search/nodes/movies?production_year=1999&title=Matrix").
          with(:headers => {'Accept'=>'application/json', 'Content-Type'=>'application/json'}).
          to_return(:status => 200, :body => [{ "type" => "Movie", "id" => "123" }].to_json )
          
      result = SheldonClient.search( :movies, title: 'Matrix', production_year: '1999' )
      result.first.should be_a SheldonClient::Node
      result.first.id.should == "123"
      result.first.type.should == 'Movie'
    end
    
    it "should search for genres" do
      stub_request(:get, "http://sheldon.host/search/nodes/genres?name=Action").
          with(:headers => {'Accept'=>'application/json', 'Content-Type'=>'application/json'}).
          to_return(:status => 200, :body => [{ "type" => "Genre", "id" => "321" }].to_json )
          
      result = SheldonClient.search( :genres, name: 'Action' )
      result.first.should be_a SheldonClient::Node
      result.first.id.should == "321"
      result.first.type.should == 'Genre'
    end
    
    it "should return an empty array on no-content responses" do
      stub_request(:get, "http://sheldon.host/search/nodes/genres?name=Action").
          with(:headers => {'Accept'=>'application/json', 'Content-Type'=>'application/json'}).
          to_return(:status => 204, :body => '' )
          
      SheldonClient.search( :genres, name: 'Action' ).should == []
    end
  end

  context "node payloads" do
    it "should return the payload of a given node" do
      stub_request(:get, "http://sheldon.host/node/2001").
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
      stub_request(:get, "http://sheldon.host/node/500").
              with(:headers => {'Accept'=>'application/json', 'Content-Type'=>'application/json'}).
         to_return(:status => 200, :body => { :id => 500, :type => "Movie", :payload => { :year => 2000 } }.to_json )
      stub_request(:put, "http://sheldon.host/node/500").
              with(:headers => {'Accept'=>'application/json', 'Content-Type'=>'application/json'},
                   :body    => { :year => 2000 }.to_json).to_return(:status => 200)
      SheldonClient.update_node( 500, { year: 2000 } ).should == true
    end
  end

end
