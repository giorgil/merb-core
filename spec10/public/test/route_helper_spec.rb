require File.expand_path(File.join(File.dirname(__FILE__), "spec_helper"))

class TestController < Merb::Controller
  def get(id = nil); end
  def post; end
end

describe Merb::Test::RouteHelper do
  include Merb::Test::RouteHelper
  
  before(:each) do
    Merb::Router.prepare do
      match("/").defer_to do |request, params|
        { :controller => 'test_controller', :action => request.raw_post } unless request.raw_post.blank?
      end
      match("/", :method => :get).to(:controller => "test_controller", :action => "get").name(:getter)
      match("/", :method => :post).to(:controller => "test_controller", :action => "post")
      match("/:id").to(:controller => "test_controller", :action => "get").name(:with_id)
      default_routes
    end
  end
  
  describe "#url" do
    it "should use Merb::Router" do
      url(:getter).should == "/"
    end
    
    it "should work with a parameters hash" do
      url(:with_id, :id => 123).should == "/123"
    end
    
    it "should turn extra hash items into query params" do
      generated_url = url(:getter, :id => 123, :color => 'red', :size => 'large')
      lambda {
        generated_url.match(/\bid=123\b/) &&
        generated_url.match(/\bsize=large\b/) &&
        generated_url.match(/\bcolor=red\b/)
      }.call.should_not be_nil
    end
    
    it "should remove items with nil values from query params" do
      url(:getter, :color => nil, :size => 'large').should == "/?size=large"
    end
    
    it "should remove items with nil values from query params when named route isn't specified" do
      url(:controller => 'cont', :action => 'act', :color => nil, :size => 'large').should == "/cont/act?size=large"
    end
  end
  
  describe "#request_to" do
    it "should GET if no method is given" do
      request_to("/")[:action].should == "get"
    end
    
    it "should return a hash" do
      Hash.should === request_to("/")
    end
    
    it "should contain the controller in the result" do
      request_to("/")[:controller].should == "test_controller"
    end
    
    it "should contain the action in the result" do
      request_to("/")[:action].should == "get"
    end
    
    it "should contain any parameters in the result" do
      request_to("/123")[:id].should == "123"
    end

    it "should play nice with raw_post in deferred routing" do
      request_to("/", :post, {:post_body => 'deferred'})[:action].should == 'deferred'
    end
  end
end
