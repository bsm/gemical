class Gemical::Vault < String

  attr_reader :token

  # Constructor
  # @param [Hash] with "token" and "name" keys
  def initialize(hash)
    @token = hash["token"]
    super hash["name"]
  end

end