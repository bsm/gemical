class Gemical::Commands::Bundle < Gemical::Commands::Base

  class Evaluator
    attr_reader :sources

    def initialize(file)
      @sources = []
      instance_eval file.read
    end

    def source(path, *)
      @sources << path
    end

    def method_missing(sym, *a)
    end
  end

  def create(args, options)
    gemfile = current_path.join('Gemfile')
    terminate "Unable to find a Gemfile in #{current_path}" unless gemfile.file?
    terminate "Gemfile in #{current_path} is not writable" unless gemfile.writable?

    evaluation = Evaluator.new(gemfile)
    terminate "Gemfile doesn't seem to be valid" if evaluation.sources.empty?

    authenticate!
    vault = current_vault(options)

    if evaluation.sources.any? {|s| s.to_s.include?(vault.token) }
      terminate "Vault '#{vault}' is already sourced in your Gemfile."
    end

    source = gemfile.open('r')
    output = Tempfile.new "Gemfile"

    while string = source.gets
      output << string
      if string =~ /^(\s*)source\b/
        output << "#{$1}source 'http://#{vault.token}@bundle.gemical.com'\n"
      end
    end
    output.close

    FileUtils.cp output.path, source.path
    success "Vault '#{vault}' was added as a source to your Gemfile."
  end

end
