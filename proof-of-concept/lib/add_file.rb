require 'ipfs/client'
require 'rest_client'

class AddFile
  include IPFS

  def initialize(config)
    @config = config
    @filename = config.argv[0] or raise ArgumentError.new("Pass filename")
  end

  def ipfs
    @ipfs ||= Client.new(ipfs_api_connection)
  end

  def ipfs_api_connection
    @ipfs_api_connection ||= RestClientWrapper.new(config.api_endpoint)
  end

  attr_accessor :filename, :config

  def add
    binding.pry
  end

  def storage
    config.storage
  end
end
