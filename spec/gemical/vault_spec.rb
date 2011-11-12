require 'spec_helper'

describe Gemical::Vault do

  subject do
    described_class.new "name" => "a-vault", "token" => "SECRET"
  end

  it { should be_a(String) }
  it { should == "a-vault" }
  its(:token) { should == "SECRET" }


end