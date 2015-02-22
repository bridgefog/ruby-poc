require 'restclient'
require 'uri'

class RestClientWrapper
  def initialize(base_url)
    @base_url = URI(base_url)

    RestClient.log = $stderr
  end

  [:get, :post, :head, :delete, :patch, :put, :options].each do |method|
    define_method(method) do |url, *args, &block|
      real_url = URI.join(@base_url, url).to_s
      RestClient.public_send(method, real_url, *args, &block)
    end
  end
end
