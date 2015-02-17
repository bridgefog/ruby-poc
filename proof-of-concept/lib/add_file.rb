require 'ipfs'

class AddFile
  def initialize(config)
    @config = config
    @filename = config.argv[0] or raise ArgumentError.new("Pass filename")
  end

  def ipfs
    @ipfs ||= IPFSClient.new
  end

  attr_accessor :filename, :config

  def add
    binding.pry
  end

  def storage
    config.storage
  end
end
