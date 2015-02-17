require 'subprocess'
require 'base64'
require 'oj'

module IPFS
  class DagObject < Struct.new(:links, :data)
    def to_hash
      {
        "Links" => (links || []).map(&:to_hash),
        "Data" => Base64.encode64(data.to_s)
      }
    end

    def to_s
      s = "<DAG Object"
      if links.any?
        s << ' links=['
        links.each do |l|
          s << "\n    #{l.to_s},"
        end
        s << ']'
      end
      if self.data
        if data.respond_to?(:length) and data.length > 300
          d = data[0, 300].inspect << "... (length=#{data.length})"
        else
          d = data.inspect
        end
        s << " data=#{d}"
      end

    end

    def from_hash(h)
      self.links = h.fetch('Links', []).map { |l| DagLink.new.from_hash(l) }
      self.data = Base64.decode64(h['Data'] || '')
      self
    end
  end

  class DagLink < Struct.new(:hash, :name, :size)
    def to_hash
      {
        'Name' => name,
        'Hash' => hash,
        'Size' => size
      }
    end

    def from_hash(h)
      self.hash = h['Hash']
      self.size = h['Size']
      self.name = h['Name']
      self
    end
  end

  class Client
    # Add a file at `filename` and return the key
    def add(filename, recursive: false)
      cmd = ['ipfs', 'add']
      cmd << '-r' if recursive
      cmd << filename
    end


    def add_object(object)
      Tempfile.create('ipfs-object') do |f|
        f.puts Oj.dump(object, mode: :compat)
        f.close
        out = Subprocess.check_output(%W[ ipfs object put #{f.path} json ])
        if (m = /added (.+)/.match(out))
          return m[1]
        end
        raise out
      end
    end

    def get_object(key)
      out = Subprocess.check_output(%W[ ipfs object get #{key} --encoding=json ])
      hash = Oj.load(out, mode: :compat)
      p out: out, hash: hash
      DagObject.new.from_hash(hash)
    end

    def cat(key)
      Subprocess.check_output(%W[ ipfs cat #{key} ])
    end
  end
end
