require 'spec_helper'

describe Gemical::Singleton do

  class TestSingleton
    include Gemical::Singleton
  end

  it 'should make the main constructor private' do
    lambda { TestSingleton.new }.should raise_error(NoMethodError)
  end

  it 'should allow accesing the instance' do
    TestSingleton.instance.should be_a(TestSingleton)
  end

end