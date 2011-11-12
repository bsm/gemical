class Gemical::Auth
  include Gemical::Singleton

  def configuration
    Gemical.configuration
  end

  def verify_account!
    @verified_account ||= if credentials
      get_account
    else
      say_ok "\nWelcome to Gemical! You are new, right?"
      say_ok "We need to authenticate your account:"
      collect_credentials
    end
  end

  def verify_vault!
    verify_account!

    @verified_vault ||= if primary_vault
      get_vault(primary_vault) || collect_vault("Ooops, you don't seem to have access to '#{primary_vault}' anymore.")
    else
      collect_vault("You haven't specified your primary vault yet.")
    end
  end

  def vaults
    verify_account!
    @vaults ||= Gemical.connection.get("/vaults").map do |hash|
      Gemical::Vault.new(hash)
    end
  end

  def credentials
    return nil unless configuration.credentials?
    pair = configuration.credentials.read.split(/\s+/)[0..1]
    pair if pair.size == 2 && pair.all? {|v| string_value?(v) }
  end

  def basic_auth
    [credentials.last, 'x'] if credentials
  end

  def primary_vault
    return nil unless configuration.primary_vault?
    value = configuration.primary_vault.read.split(/\s+/).first
    value if string_value?(value)
  end

  private

    def get_account
      Gemical.connection.get("/account")
    rescue Gemical::Connection::HTTPUnauthorized
      renew_credentials?
    end

    def collect_credentials(attempt = 1)
      email   = ask('Email:    ')
      pass    = password
      account = Gemical.connection.get "/account", :basic_auth => [email, pass]
      configuration.write! :credentials, email, account["authentication_token"]
      say_ok "Authentication successful. Thanks!\n"
      account
    rescue Gemical::Connection::HTTPUnauthorized
      if attempt < 3
        say_warning "\nInvalid email and/or password."
        say_warning "Try again:"
        attempt += 1
        retry
      else
        say_error "\nAre your sure you have the right credentials?"
        say_error "Visit http://gemical.com/password/new for instructions."
        exit(1)
      end
    end

    def renew_credentials?
      say_warning "\nYour stored credentials seem to be outdated."
      if agree("Do you want to re-authenticate your account? ")
        collect_credentials
      else
        say_warning "You can check your stored credentials in #{configuration.credentials}."
        exit(1)
      end
    end

    def get_vault(name)
      ensure_vaults!
      vaults.find {|v| v == name }
    end

    def collect_vault(message, save = true)
      ensure_vaults!
      say_warning "\n#{message}"
      name = ask "Which one should it be: ", vaults
      configuration.write! :primary_vault, name
      get_vault(name)
    end

    def ensure_vaults!
      return unless vaults.empty?
      say_error "You have no vaults associated with your account."
      say_error "Please sign in to your account and create one: http://gemical.com/sign_in."
      exit(1)
    end

    def string_value?(value)
      value.is_a?(String) && !value.strip.empty?
    end

end