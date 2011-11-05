require 'gemical'

class Gemical::CLI

  def initialize(argv, env)
    @argv, @env = argv, env
  end

  def run
    warn "  WARNING! You are using a DEPRECATED version of Gemical."
    warn "  Please update your client by running `gem update gemical`."
  end

end