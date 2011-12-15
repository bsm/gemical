# -*- encoding: utf-8 -*-
require File.expand_path('../lib/gemical/version', __FILE__)

Gem::Specification.new do |s|
  s.platform = Gem::Platform::RUBY
  s.required_ruby_version = '>= 1.8.7'
  s.required_rubygems_version = ">= 1.3.6"

  s.name         = "gemical"
  s.summary      = "Gemical command-line client."
  s.description  = "Manage your private Gems through the command line."
  s.version      = Gemical::VERSION::STRING

  s.authors      = ["Black Square Media Ltd"]
  s.email        = "info@blacksquaremedia.com"
  s.homepage     = "http://github.com/bsm/gemical"
  s.require_path = "lib"
  s.executables  = "gemical"

  s.files        = Dir['README.*', 'lib/**/*', 'bin/**/*']

  s.add_dependency "commander"
  s.add_dependency "rest-client"
  s.add_dependency "multi_json"

  case RUBY_PLATFORM
  when "java"
    s.add_dependency "jruby-openssl"
  end

  s.add_development_dependency "rake"
  s.add_development_dependency "rspec"
  s.add_development_dependency "webmock"
end
