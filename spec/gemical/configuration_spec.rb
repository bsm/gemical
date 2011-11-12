require 'spec_helper'

describe Gemical::Configuration do

  let :root_path do
    File.join(SCENARIO_HOME, '.gemical')
  end

  subject do
    described_class.instance
  end

  it { should be_a(Gemical::Singleton) }

  it 'should have a root path' do
    subject.root.should be_a(Pathname)
    subject.root.to_s.should == root_path
  end

  it 'should have a credentials path' do
    subject.credentials.should be_a(Pathname)
  end

  it 'should have a primary vault path' do
    subject.primary_vault.should be_a(Pathname)
  end

  it 'should check if root exists' do
    subject.should_not be_root
    subject.create_root!
    subject.should be_root
  end

  it 'should check if credentials exists' do
    subject.should_not be_credentials
    subject.write! :credentials, "alice@example.com", "SECRET"
    subject.should be_credentials
  end

  it 'should check if primary vault exists' do
    subject.should_not be_primary_vault
    subject.write! :primary_vault, "VAULT"
    subject.should be_primary_vault
  end

  it 'should create root path' do
    subject.create_root!
    File.stat(root_path).mode.should == 040700
  end

  it 'should write files' do
    subject.write! :primary_vault, "VAULT"
    subject.primary_vault.read.should == "VAULT\n"
    subject.primary_vault.stat.mode.should == 0100600
  end

  it 'should ensure root when writing files' do
    subject.should_not be_root
    subject.write! :primary_vault, "VAULT"
    subject.should be_root
  end

end
