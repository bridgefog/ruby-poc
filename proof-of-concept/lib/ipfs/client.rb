require 'base64'
require 'set'
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
      @peerlist = Set.new
    end
    attr_reader :client, :peerlist

    def add_object(object)
      file = JSONFile.new(object)
      p object: file.string
      response = client.post('object/put?arg=json', data: file)

      handle_response(response.net_http_res).first.fetch('Hash')
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
      peerlist.merge dht_find_providers(badge_multihash(PARTICIPATION_BADGE))
    end

    def publish!(object_key)
      response = client.get("name/publish?arg=#{object_key}")
      handle_response(response.net_http_res).first
    end
    alias_method :name_publish, :publish!

    def name_resolve(peerid)
      response = client.get("name/resolve?arg=#{peerid}")
      hash = handle_response(response.net_http_res).first
      hash['Key'] or raise 'Name not found'
    end

    def retrieve_peers_peerlist(peerid)
      key = name_resolve(peerid)
      peers = get_object(key + "/peerlist")
      peers.links.map(&:hash)
    end

    def get_peers_peers
      peerlist.each do |peerid|
        warn "Getting peerlist for #{peerid}"
        begin
          this_peers_peerlist = retrieve_peers_peerlist(peerid)
          p new_peers: this_peers_peerlist
          peerlist.merge(this_peers_peerlist)
        rescue => ex
          warn ex.to_s
          next
        end
      end
    end

    def publish_peerlist
      peerlist_as_links = peerlist.map { |pid| DagLink.new(pid) }
      o = DagObject.new(peerlist_as_links)
      peerlist_key = add_object(o)
      toplevel_object = DagObject.new([DagLink.new(peerlist_key, 'peerlist')])
      toplevel_object_key = add_object(toplevel_object)
      publish!(toplevel_object_key)
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
