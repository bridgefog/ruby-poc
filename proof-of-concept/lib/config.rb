require 'moneta'

class Config
  def initialize(argv)
    @argv = argv
    parse
  end

  attr_accessor :argv, :debug

  alias_method :debug?, :debug

  def parse
    @debug = !!(@argv.delete('--debug') || @argv.delete('-d') || ENV.key?('DEBUG'))
  end

  def storage
    @storage ||= Moneta.new(:File, dir: storage_path)
  end

  def storage_path
    File.expand_path('../../db', __FILE__)
  end
end
