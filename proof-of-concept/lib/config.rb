require 'moneta'

class Config
  def initialize(argv)
    @argv = argv
    parse
  end

  attr_accessor :argv, :debug, :api_endpoint

  alias_method :debug?, :debug

  def parse
    @debug = !!(@argv.delete('--debug') || @argv.delete('-d') || ENV.key?('DEBUG'))

    @api_endpoint = ENV['IPFS_API_ENDPOINT']
  end

  def storage
    @storage ||= Moneta.new(:File, dir: storage_path)
  end

  def storage_path
    File.expand_path('../../db', __FILE__)
  end
end
