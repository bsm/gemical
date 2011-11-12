class Gemical::Format < Commander::HelpFormatter::Terminal

  def template name
    path = File.expand_path("../format/#{name}.erb", __FILE__)
    ERB.new File.read(path), nil, '-'
  end

end