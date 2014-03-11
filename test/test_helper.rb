begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end

require 'pry'
require 'test/unit'

# Enable turn if it is available
begin
  require 'turn'
rescue LoadError
end

require 'rethink_api'

RethinkAPI.database = 'test_rethink_api'

class People < Struct.new(:first_name, :last_name, :address, :city, :id)
end
