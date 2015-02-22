require 'moneta'

class Configuration
  def initialize(argv)
    @argv = argv
    parse
  end

  attr_accessor :argv, :debug, :api_endpoint

  alias_method :debug?, :debug

  def parse
    @debug = !!(@argv.delete('--debug') || @argv.delete('-d') || ENV.key?('DEBUG'))

    @api_endpoint = ENV['IPFS_API_ENDPOINT'] || 'http://0.0.0.0:5001/api/v0/'
  end

  def storage
    @storage ||= Moneta.new(:File, dir: storage_path)
  end

  def storage_path
    File.expand_path('../../db', __FILE__)
  end
end
