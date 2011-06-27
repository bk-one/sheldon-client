require 'spec_helper'

describe SheldonClient::UrlHelper do
  include SheldonClient::UrlHelper

  context "neighbours_url" do
    it "should generate all neighbour url" do
      uri = neighbours_url( 1 )
      uri.should be_a( Addressable::URI )
      uri.path.should == "/nodes/1/neighbours"
    end
    
    it "should generate neighbour url for type" do
      uri = neighbours_url( 1, :like )
      uri.should be_a( Addressable::URI )
      uri.path.should == "/nodes/1/neighbours/likes"
    end
  end
  
  context "node_url" do
    it "should create an url with type" do
      uri = node_url(:movie)
      uri.should be_a( Addressable::URI )
      uri.path.should == "/nodes/movies"
    end
    
    it "should create an url with type and id" do
      uri = node_url(:movie, 1)
      uri.should be_a( Addressable::URI )
      uri.path.should == "/nodes/movies/1"
    end
    
    it "should create an url with id" do
      uri = node_url(1)
      uri.should be_a( Addressable::URI )
      uri.path.should == "/nodes/1"
    end

    it "should create the reindex url" do
      uri = node_url(1, :reindex)
      uri.should be_a( Addressable::URI )
      uri.path.should == "/nodes/1/reindex"
    end
  end
  
  context "status_url" do
    it "should create sheldons status url" do
      uri = status_url
      uri.should be_a( Addressable::URI )
      uri.path.should == "/status"
    end
  end
 
  context "connections_url" do
    it "should create new connection url" do
      uri = connections_url( 1, :like, 2 )
      uri.should be_a( Addressable::URI )
      uri.path.should == "/nodes/1/connections/2/likes"
    end
    
    it "should create fetch connections url" do
      uri = connections_url( 1, :like )
      uri.should be_a( Addressable::URI )
      uri.path.should == "/nodes/1/connections/likes"
    end
    
  end
  
end
