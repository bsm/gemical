require 'spec_helper'

describe Gemical::Connection do

  subject do
    described_class.instance
  end

  before do
    Gemical.configuration.write! :credentials, "alice@example.com", "SECRET"
  end

  it { should be_a(Gemical::Singleton) }

  it 'should have a base-url' do
    subject.base_url.should == "http://api.gemical.com"
  end

  it 'should allow configure URLs' do
    subject.should respond_to(:base_url=)
    subject.should respond_to(:proxy=)
  end

  it 'should request resources' do
    stub_request(:get, //).to_return(:status => 200, :body => %({"key":"value"}))
    subject.get "/resource"
    stub_request(:get, "http://SECRET:x@api.gemical.com/resource").should have_been_made
  end

  it 'should request with custom auth' do
    stub_request(:get, //).to_return(:status => 200, :body => %({"key":"value"}))
    subject.get "/resource", :basic_auth => ["USER", "PASS"]
    stub_request(:get, "http://USER:PASS@api.gemical.com/resource").should have_been_made
  end

  it 'should handle correct responses' do
    stub_request(:get, //).to_return(:status => 200, :body => %({"key":"value"}))
    subject.get("/resource").should == {"key" => "value"}
  end

  it 'should handle forbidden responses' do
    stub_request(:get, //).to_return(:status => 401)
    lambda { subject.get "/resource" }.should raise_error(described_class::HTTPUnauthorized)
  end

  it 'should handle error responses' do
    stub_request(:get, //).to_return(:status => 500)
    lambda { subject.get "/resource" }.should raise_error(described_class::HTTPServerError)
  end

end
