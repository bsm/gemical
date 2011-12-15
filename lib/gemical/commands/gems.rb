class Gemical::Commands::Gems < Gemical::Commands::Base

  def index(args, options)
    authenticate!

    vault = current_vault(options)
    conn.get("/vaults/#{vault}/gems").each do |rubygem|
      versions = rubygem["versions"].map {|v| v["name"] }.sort.reverse
      say "#{rubygem["name"]} (#{versions.join(', ')})"
    end
  rescue Gemical::Connection::HTTPNotFound
    terminate "Sorry, no such vault '#{vault}'."
  end

  def create(args, options)
    terminate "Please provide a GEM file." unless args.first.is_a?(String)

    files = Pathname.glob(args).select(&:file?)
    terminate "Hmm, no files found!" if files.empty?

    authenticate!
    vault = current_vault(options)
    files.each do |file|
      upload(file, vault)
    end
  rescue Gemical::Connection::HTTPNotFound
    terminate "Sorry, no such vault '#{vault}'."
  rescue Gemical::Connection::HTTPUnprocessable => e
    terminate "Sorry, #{full_errors(e.response, 'name' => 'gem')}"
  end

  def destroy(args, options)
    name, version = args.first(2)
    terminate "Please provide a valid GEM name." unless name.to_s =~ /\A[\w\-]+\z/
    terminate "Please provide a valid VERSION." unless version.to_s =~ /\A[\w\-\.]+\z/

    authenticate!
    vault    = current_vault(options)
    response = conn.delete("/vaults/#{vault}/gems/#{name}/#{version}")
    success "#{name} (#{version}) was successfully removed from #{vault}."
  rescue Gemical::Connection::HTTPNotFound
    terminate "Sorry, unable to find '#{name} (#{version})' in vault '#{vault}'."
  rescue Gemical::Connection::HTTPUnprocessable => e
    "Sorry, #{full_errors(e.response)}"
  end

  private

    def upload(file, vault)
      res = conn.post("/vaults/#{vault}/gems", :params => { "rubygem[file]" => file.open('rb') })
      say_ok "#{res['original_name']} was successfully added to vault '#{vault}'."
    rescue Gemical::Connection::HTTPUnprocessable => e
      say_error "Sorry, #{full_errors(e.response, 'name' => 'gem')} (#{file.basename})"
    end

end
