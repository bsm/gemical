require 'spec_helper'

describe Gemical::Auth do

  subject do
    described_class.instance
  end

  it { should be_a(Gemical::Singleton) }

  it 'should should link configuration' do
    subject.configuration.should == Gemical.configuration
  end

  it 'should read credentials' do
    Gemical.configuration.write! :credentials, "alice@example.com", "SECRET"
    subject.credentials.should == ["alice@example.com", "SECRET"]
  end

  it 'should construct basic auth creds' do
    Gemical.configuration.write! :credentials, "alice@example.com", "SECRET"
    subject.basic_auth.should == ["SECRET", "x"]
  end

  it 'should ignore missing credentials' do
    subject.credentials.should be_nil
  end

  it 'should ignore invalid credentials' do
    Gemical.configuration.write! :credentials, "alice@example.com"
    subject.credentials.should be_nil
    Gemical.configuration.write! :credentials, " ", "SECRET"
    subject.credentials.should be_nil
  end

  it 'should read primary vault' do
    Gemical.configuration.write! :primary_vault, "VAULT"
    subject.primary_vault.should == "VAULT"
    subject.primary_vault.should be_instance_of(String)
  end

  it 'should ignore missing primary vault' do
    subject.primary_vault.should be_nil
  end

  it 'should ignore invalid primary vault' do
    Gemical.configuration.write! :primary_vault, "  "
    subject.primary_vault.should be_nil
    Gemical.configuration.write! :primary_vault, "", "VAULT"
    subject.primary_vault.should be_nil
  end

  describe "pulling vaults" do

    before do
      Gemical.configuration.write! :credentials, "alice@example.com", "SECRET"
      stub_request(:get, //).to_return :status => 200, :body => %([{"name":"a-vault","token":"TOKEN"}])
      subject.stub(:verify_account!)
    end

    it 'should ensure account is verified' do
      subject.should_receive(:verify_account!)
      subject.vaults.should == ['a-vault']
      subject.vaults.first.should be_instance_of(Gemical::Vault)
    end

    it 'should request vaults' do
      subject.vaults.should == ['a-vault']
      a_request(:get, "http://SECRET:x@api.gemical.com/vaults").should have_been_made
    end

  end

  describe "account verification (when credentials present)" do
    before do
      Gemical.configuration.write! :credentials, "alice@example.com", "SECRET"
    end

    it 'should query account' do
      stub_request(:get, //).to_return :status => 200, :body => %({"a":1})
      subject.verify_account!.should == { "a" => 1 }
      a_request(:get, "http://SECRET:x@api.gemical.com/account").should have_been_made
    end

    it 'should ask user if he wants to update credentials when access forbidden' do
      stub_request(:get, //).to_return :status => 401
      subject.should_receive(:collect_credentials).and_return(nil)
      $terminal.should_receive(:agree).and_return(true)
      subject.verify_account!
      $terminal.output.string.should include("credentials seem to be outdated")
    end
  end

  describe "account verification (when credentials are not there)" do

    before do
      stub_request(:get, //).to_return :status => 200, :body => %({"authentication_token":"TOKEN"})
    end

    it 'should ask for credentials' do
      subject.should_receive(:collect_credentials).and_return(nil)
      subject.verify_account!
    end

    it 'should use credentials to retreive account' do
      $terminal.should_receive(:ask).twice.and_return("email", "pass")
      subject.verify_account!.should == {"authentication_token" => "TOKEN" }
      a_request(:get, "http://email:pass@api.gemical.com/account").should have_been_made
    end

    it 'should store credentials' do
      Gemical.auth.credentials.should be_nil
      $terminal.should_receive(:ask).twice.and_return("email", "pass")
      subject.verify_account!
      Gemical.auth.credentials.should == ["email", "TOKEN"]
    end

  end


  describe "vault verification" do

    before do
      Gemical.configuration.write! :credentials, "alice@example.com", "SECRET"
      stub_request(:get, /vaults/).to_return :status => 200, :body => %([{"name":"a-vault","token":"TOKEN"}])
      subject.stub :verify_account! => true
    end

    it 'should ensure account is verified' do
      Gemical.configuration.write! :primary_vault, "a-vault"
      subject.should_receive(:verify_account!)
      subject.verify_vault!
    end

    describe "if primary vault defined (and present)" do

      before do
        Gemical.configuration.write! :primary_vault, "a-vault"
      end

      it 'should assign vault (if present)' do
        subject.verify_vault!.should == 'a-vault'
        subject.verify_vault!.should be_instance_of(Gemical::Vault)
      end

    end

    describe "if primary vault defined (but missing)" do

      before do
        Gemical.configuration.write! :primary_vault, "b-vault"
      end

      it 'should re-collect vault information' do
        subject.should_receive(:collect_vault).and_return('b-vault')
        subject.verify_vault!.should == 'b-vault'
      end

    end

    describe "if primary vault is not defined" do

      it 'should collect vault information' do
        $terminal.should_receive(:ask).and_return("a-vault")
        subject.verify_vault!.should == 'a-vault'
        subject.verify_vault!.should be_instance_of(Gemical::Vault)
      end

      it 'should store primary vault' do
        Gemical.auth.primary_vault.should be_nil
        $terminal.should_receive(:ask).and_return("a-vault")
        subject.verify_vault!.should == 'a-vault'
        subject.verify_vault!.should be_instance_of(Gemical::Vault)
        Gemical.auth.primary_vault.should == "a-vault"
      end

    end
  end

end
