class Gemical::Vault < String

  attr_reader :token

  def initialize(hash)
    @token = hash["token"]
    super hash["name"]
  end

end