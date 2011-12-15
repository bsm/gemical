require 'fileutils'

class Gemical::Configuration
  include Gemical::Singleton

  attr_writer :home

  def initialize
    @home = ENV['HOME']
  end

  # @return [Pathname] credentials store
  def root
    @root ||= Pathname.new File.join(@home, ".gemical")
  end

  # @return [Pathname] credentials storage file
  def credentials
    root.join('credentials')
  end

  # @return [Pathname] primary vault storage file
  def primary_vault
    root.join('primary_vault')
  end

  # @return [Boolean] true, if configuration root exists
  def root?
    root.directory? && root.readable?
  end

  # @return [Boolean] true, if credentials are available
  def credentials?
    readable_file? credentials
  end

  # @return [Boolean] true, if primary vault is available
  def primary_vault?
    readable_file? primary_vault
  end

  # Create a configuration root directory
  def create_root!
    return if root?
    FileUtils.mkdir_p root
    FileUtils.chmod_R 0700, root
  end

  # Write a file
  # @param [Symbol] symbol
  #   Either :credentials or :primary_vault
  # @param [Array] lines
  #   Lines to write
  def write!(symbol, *lines)
    create_root!
    send(symbol).open "w", 0600 do |file|
      file << (lines + ['']).join("\n")
    end
  end

  private

    # @param [Pathname] path
    # @return [Boolean] true, if file is readable
    def readable_file?(path)
      root? && path.file? && path.readable?
    end

end