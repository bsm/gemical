require 'fileutils'

class Gemical::Configuration
  include Gemical::Singleton

  attr_writer :home

  def initialize
    @home = ENV['HOME']
  end

  def root
    @root ||= Pathname.new File.join(@home, ".gemical")
  end

  def credentials
    root.join('credentials')
  end

  def primary_vault
    root.join('primary_vault')
  end

  def root?
    root.directory? && root.readable?
  end

  def credentials?
    readable_file? credentials
  end

  def primary_vault?
    readable_file? primary_vault
  end

  def create_root!
    return if root?
    FileUtils.mkdir_p root
    FileUtils.chmod_R 0700, root
  end

  def write!(symbol, *lines)
    create_root!
    send(symbol).open "w", 0600 do |file|
      file << (lines + ['']).join("\n")
    end
  end

  private

    def readable_file?(path)
      root? && path.file? && path.readable?
    end

end