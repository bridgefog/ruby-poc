require 'subprocess'
require 'base64'
require 'json'

class IPFSClient
  class DagObject
    def links
      @links ||= []
    end

    attr_accessor :data

    def to_json
      JSON.dump({
        "links" => links,
        "data" => Base64.encode64(data.to_s)
      })
    end
  end

  # Add a file at `filename` and return the key
  def add(filename, recursive: false)
    cmd = ['ipfs', 'add']
    cmd << '-r' if recursive
    cmd << filename
  end


  def add_object(object)
    cmd = ['ipfs', 'object', 'put', object.to_json, 'json']
    p cmd: cmd
    Subprocess.check_output(cmd)
  end

  def cat(key)
    `ipfs cat #{key}`
  end
end
