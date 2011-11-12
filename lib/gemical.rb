require 'rubygems'
require 'pathname'
require 'erb'
require 'commander'

include Commander::UI
include Commander::UI::AskForClass

module Gemical
  autoload :Auth, 'gemical/auth'
  autoload :Format, 'gemical/format'
  autoload :Commands, 'gemical/commands'
  autoload :Configuration, 'gemical/configuration'
  autoload :Connection, 'gemical/connection'
  autoload :Singleton, 'gemical/singleton'
  autoload :Vault, 'gemical/vault'
  autoload :VERSION, 'gemical/version'

  def self.auth
    Gemical::Auth.instance
  end

  def self.configuration
    Gemical::Configuration.instance
  end

  def self.connection
    Gemical::Connection.instance
  end

end