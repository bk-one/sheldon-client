require 'spec_helper'

describe SheldonClient::Status do
  include HttpSupport
  include WebMockSupport

  context "getting status information from sheldon" do
    before(:each) do
      stub_request(:get, "#{SheldonClient.host}/status").
        with( :headers => {'Accept' =>'application/json', 'Content-Type'=> 'application/json'}).
        to_return(:status => 200, :body => sheldon_status.to_json)
    end

    it "should fetch all the current node and edge types supported by sheldon" do
      SheldonClient.node_types.should == [ :movies, :persons ]
      SheldonClient.connection_types.should == [ :likes, :actors, :g_tags ]
    end

    it "should extract all valid outgoing connection types for a node" do
      SheldonClient::Status.valid_connections_from( :movie ).should == [ :actors, :g_tags ]
      SheldonClient::Status.valid_connections_from( :users ).should == [ :likes ]
    end

    it "should extract all valid incoming connection types for a node" do
      SheldonClient::Status.valid_connections_to( :movie ).should == [ :likes ]
      SheldonClient::Status.valid_connections_to( :users ).should == [ ]
    end

    it "should know valid source and target node types for specific edges" do
      SheldonClient.status['schema']['connections']['likes']['sources'].should == [ 'users' ]
      SheldonClient.status['schema']['connections']['likes']['targets'].should == [ 'movies', 'persons' ]
    end

    it "should fetch the size of nodes/edges of a specific type" do
      SheldonClient.status['schema']['nodes']['movies']['count'].should  == 4
      SheldonClient.status['schema']['nodes']['persons']['count'].should == 6
      SheldonClient.status['schema']['connections']['likes']['count'].should  == 3
    end


    xit "should fetch the total amount of edges/nodes" do
      SheldonClient.status['schema']['connections']['count'].should  == 22
      SheldonClient.status['schema']['nodes']['count'].should  == 11
    end
  end
end