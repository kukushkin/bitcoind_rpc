require 'logger'
require_relative 'bitcoind_rpc/version'
require_relative 'bitcoind_rpc/connection'

module BitcoindRPC
  DEFAULT_OPTIONS = {
    logger: Logger.new(STDOUT).tap { |l| l.level = ::Logger::WARN }
  }.freeze

  def self.configure(opts = {})
    opts = DEFAULT_OPTIONS.dup.merge(opts.dup)
    @connection = BitcoindRPC::Connection.new(opts)
    @logger     = opts[:logger] if opts[:logger]
    @connection
  end

  def self.connection
    @connection
  end

  def self.logger
    @logger ||= DEFAULT_OPTIONS[:logger]
  end

  def self.logger=(new_logger)
    @logger = new_logger
  end
end # module BitcoindRPC
