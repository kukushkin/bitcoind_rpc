# Bitcoind RPC

A Ruby client for the *bitcoind* ([Bitcoin Core](https://github.com/bitcoin/bitcoin) compatible) JSON-RPC.

Features:

* Parses floats as BigDecimal
* Lists methods supported by the connected bitcoind
* Allows access to RPC methods as plain Ruby methods of Connection object

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'bitcoind_rpc'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install bitcoind_rpc

## Usage

```ruby

require 'bitcoind_rpc'

bitcoind = BitcoindRPC::Connection.new(uri: 'http://{username}:{password}@{host}:{port}')

bitcoind.supported_methods # => [ :getbestblockhash, :getblock, ... ]
bitcoind.getbalance # => #<BigDecimal:...>
bitcoind.blablabla # => NoMethodError

bitcoind.getblock "3d587773d2cbaf64f208f165f5f7717d7324350612d189063b4d1d2f14711380" # => { :hash => "3d58..." ...}

```


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/kukushkin/bitcoind_rpc. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

