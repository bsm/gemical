class Gemical::Commands::Vaults < Gemical::Commands::Base

  def index(args, options)
    authenticate!

    Gemical.auth.vaults.each do |vault|
      say vault
    end
  end

end
