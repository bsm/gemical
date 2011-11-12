$: << File.expand_path('../../lib', __FILE__)

require 'rubygems'
require 'bundler/setup'

require 'fileutils'
require 'rspec'
require 'gemical'

require 'webmock/rspec'
WebMock.disable_net_connect!

SCENARIO_HOME = File.expand_path('../scenario', __FILE__)
FileUtils.mkdir_p SCENARIO_HOME

HighLine.class_eval do
  attr_accessor :input, :output
end

RSpec.configure do |c|
  c.before do
    [Gemical::Connection, Gemical::Configuration, Gemical::Auth].each &:reload!
    Gemical.configuration.home = File.join(SCENARIO_HOME)
    FileUtils.rm_rf File.join(SCENARIO_HOME, '.gemical')

    $terminal.input  = StringIO.new
    $terminal.output = StringIO.new
  end
end
