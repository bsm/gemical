class Gemical::Commands::Base

  protected

    def current_path
      @current_path ||= Pathname.new(File.expand_path('.'))
    end

    def terminate(message)
      say_error message
      exit(1)
    end

    def success(message)
      say_ok message
      exit(0)
    end

    def full_errors(errors, mappings = {})
      errors.map do |attr, messages|
        name = mappings[attr] || attr
        messages.map do |message|
          "#{name} #{message}"
        end.join(', ')
      end.join(', ')
    end

    def authenticate!
      Gemical.auth.verify_account!
    end

    def conn
      Gemical.connection
    end

    def current_vault(options)
      options.vault || primary_vault
    end

    def primary_vault
      Gemical.auth.verify_vault!
    end

end
