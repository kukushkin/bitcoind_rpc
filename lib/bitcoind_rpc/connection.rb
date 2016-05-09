require 'oj'
require 'net/http'

module BitcoindRPC
  class Connection
    attr_reader :options, :uri

    DEFAULT_OPTIONS = {
      host: 'localhost',
      port: 18332 # Default for testnet: 18332, for mainnet: 8332
    }.freeze

    CONTENT_TYPE = 'application/json'.freeze

    # Creates a new connection to a bitcoind
    #
    # @param [Hash] opts Connection parameters
    # @option opts [String] :host
    # @option opts [String] :port
    # @option opts [String] :username
    # @option opts [String] :password
    # @option opts [String,URI] :uri Specify a complete URI instead of separate host, port etc
    #
    def initialize(opts)
      @options = DEFAULT_OPTIONS.dup.merge(opts.dup)
      @uri = @options[:uri] ? URI(@options[:uri]) : URI(uri_to_s)
    end

    def respond_to_missing?(name, _include_all = false)
      supported_methods.include?(name.to_sym) || super
    end

    def method_missing(name, *args)
      return request(name, *args) if supported_methods.include?(name.to_sym)
      super
    end

    def request(name, *args)
      BitcoindRPC.logger.debug "> #{name}: #{args.join(',')}"
      response = request_http_post(name, args)
      BitcoindRPC.logger.debug '<< RAW RESPONSE:'
      BitcoindRPC.logger.debug response.inspect
      BitcoindRPC.logger.debug '<< ---'
      # require 'pry'; binding.pry
      BitcoindRPC.logger.debug "< #{response.code} #{response.message}"
      raise Error, response.message unless (200...300).cover?(response.code.to_i)
      begin
        response = Oj.load(response.body, symbol_keys: true, bigdecimal_load: true)
      rescue StandardError => e
        BitcoindRPC.logger.warn "Failed to parse JSON response: #{e}"
        raise
      end
      raise Error, response[:error] if response[:error]
      response[:result]
    end

    # Makes a request to a bitcoind instance once and returns the list of supported RPC methods
    #
    def supported_methods
      return @supported_methods if @supported_methods
      help_response = request(:help)
      mm = help_response.split("\n").select { |l| l =~ /^\w+(\s|$)/ }
      @supported_methods = mm.map { |l| l.split(' ').first }.map(&:to_sym)
    end

    private

    def uri_to_s
      "http://#{options[:username]}:#{options[:password]}@#{options[:host]}:#{options[:port]}"
    end

    def request_http_post(name, params)
      username = uri.user
      password = uri.password
      http = Net::HTTP.new(uri.host, uri.port)
      request = Net::HTTP::Post.new(uri.request_uri)
      request.basic_auth(username, password)
      request.body = request_body(name, params)
      request['Content-Type'] = CONTENT_TYPE
      http.request(request)
    end

    def request_body(name, params)
      Oj.dump({ method: name, params: params, id: 'jsonrpc' }, mode: :compat)
    end

    class Error < RuntimeError; end
  end # class Connection
end # module BitcoindRPC
