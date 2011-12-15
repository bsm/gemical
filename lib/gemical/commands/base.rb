class Gemical::Commands::Base

  protected

    # @return [Pathname]
    #   The current working path
    def current_path
      @current_path ||= Pathname.new(File.expand_path('.'))
    end

    # Output error message and exit
    # @param [String] message
    #   Message to be printed in the console as an error
    # @param [Integer] status
    #   Exit status, defaults to 1
    def terminate(message, status = 1)
      say_error message
      exit(status)
    end

    # Output success message and exit
    # @param [String] message
    #   Message to be printed to the console
    # @param [Integer] status
    #   Exit status, defaults to 0
    def success(message, status = 0)
      say_ok message
      exit(status)
    end

    # Expands API errors to messages
    # @param [Array] errors
    #   Original errors
    # @param [Hash] mappings
    #   Message mapptings
    # @return [String]
    #   Full error messages
    def full_errors(errors, mappings = {})
      errors.map do |attr, messages|
        name = mappings[attr] || attr
        messages.map do |message|
          "#{name} #{message}"
        end.join(', ')
      end.join(', ')
    end

    # Authenticate the user
    def authenticate!
      Gemical.auth.verify_account!
    end

    # Connection accessor
    def conn
      Gemical.connection
    end

    # @param [Commander::Command::Options]
    #   The parsed command line options
    # @return [String]
    #   The current vault name
    def current_vault(options)
      options.vault || primary_vault
    end

    # @return [String]
    #   The user's primary name
    def primary_vault
      Gemical.auth.verify_vault!
    end

end
