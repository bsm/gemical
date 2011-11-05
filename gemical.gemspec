# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.platform = Gem::Platform::RUBY
  s.required_ruby_version = '>= 1.8.7'
  s.required_rubygems_version = ">= 1.3.6"

  s.name         = "gemical"
  s.summary      = "Gemical command-line client."
  s.description  = "Manage your private Gems through the command line."
  s.version      = "0.0.1"

  s.authors      = ["Black Square Media Ltd"]
  s.email        = "info@blacksquaremedia.com"
  s.homepage     = "http://github.com/bsm/gemical"
  s.require_path = "lib"
  s.executables  = "gemical"

  s.files        = Dir['README.*', 'lib/**/*', 'bin/**/*']
end
