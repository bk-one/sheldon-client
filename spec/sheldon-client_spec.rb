require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "SheldonClient" do
  context "configuration" do
    it "should not have a predefined host" do
      SheldonClient.host.should be_nil
    end

    it "should return to the configured host" do
      SheldonClient.host = 'http://i.am.the.real.sheldon/'
      SheldonClient.host.should == 'http://i.am.the.real.sheldon'
    end
  end

  context "building request urls" do
    it "should create correct url from given options" do
      SheldonClient.host = 'http://i.am.the.real.sheldon/'
      SheldonClient.build_request_url( from: 13, to: 14, type: :foo ).path.should == "/nodes/13/connections/foo/14"
      SheldonClient.build_request_url( from: 10, to: 11, type: :bar ).path.should == "/nodes/10/connections/bar/11"
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

  end

  context "searching for nodes" do
    it "should search for a movie" do
      stub_request(:get, "http://other.sheldon.host/search/nodes/movies?production_year=1999&title=Matrix").
          with(:headers => {'Accept'=>'application/json', 'Content-Type'=>'application/json'}).
          to_return(:status => 200, :body => [{ "type" => "Movie", "id" => "123" }].to_json )
      
      SheldonClient.search_movie( 'Matrix', '1999' ).should == "123"
    end
  end

  context "node payloads" do
    it "should return the payload of a given node" do
      stub_request(:get, "http://other.sheldon.host/node/2001").
          with(:headers => {'Accept'=>'application/json', 'Content-Type'=>'application/json'}).
          to_return(:status => 200, :body => { "type" => "Movie", "id" => "123", "payload" => { "title" => "MyTitle"} }.to_json )
      
      SheldonClient.node_payload( 2001 ).should == { "title" => "MyTitle" }
    end
  end

end
