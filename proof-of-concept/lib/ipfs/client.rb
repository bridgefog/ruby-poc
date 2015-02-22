require 'base64'
require 'oj'
require 'ipfs/dag'

module IPFS
  PARTICIPATION_BADGE = "__WOOT__"

  class Client
    # Add a file at `filename` and return the key
    def add(filename, recursive: false)
      cmd = ['ipfs', 'add']
      cmd << '-r' if recursive
      cmd << filename
    end

    def initialize(client)
      @client = client
    end
    attr_reader :client

    def add_object(object)
      file = JSONFile.new(object)
      p object: file.string
      response = client.post('object/put?arg=json', data: file)

      handle_response(response.net_http_res)
    end

    def get_object(key)
      response = client.get "object/get?arg=#{key}"
      hash = handle_response(response.net_http_res)
      DagObject.new.from_hash(hash[0])
    end

    def dht_find_providers(key)
      response = client.get "dht/findprovs?arg=#{key}"
      provider_responses = handle_response(response.net_http_res)
      providers = []
      provider_responses.each do |r|
        next unless r['Type'] == 4

        Array(r['Responses']).each do |peer|
          providers << peer['ID']
        end
      end
      providers
    end

    def name_resolve(key)
      response = client.get("name/resolve?arg=#{key}")
      hash = handle_response(response.net_http_res).first
      hash['Key']
    end

    def publish_badge(key)
      value = badge_string(key)
      obj = DagObject.new([], value)
      add_object(obj)
    end

    def badge_string(key)
      ['CEOL', key, Date.today.to_s].join(':')
    end

    def badge_multihash(key)
      string = badge_string(key)
      Subprocess.check_output(['bin/ipfs-badge-object-hash', string]).chomp
    end

    def publish_participation_badge
      publish_badge(PARTICIPATION_BADGE)
    end

    def find_participating_peers
      dht_find_providers(badge_multihash(PARTICIPATION_BADGE))
    end

    private

    def handle_response(response)
      # explode if response not 2xx
      response.value

      objects = []

      case response['Content-Type']
      when /json/
        Oj.load(response.body, mode: :compat) { |object|
          objects << object
        }
        return objects
      else
        return [{ body: response.body }]
      end
    end

    class JSONFile < StringIO
      def initialize(obj)
        super(Oj.dump(obj, mode: :compat))
      end

      def path
        '_'
      end

      def content_type
        'application/json'
      end
    end
  end
end
