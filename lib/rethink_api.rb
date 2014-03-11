require 'rethinkdb'
require 'active_support/core_ext/module/attribute_accessors'
require 'active_support/core_ext/module/delegation'
require 'active_support/core_ext/string/inflections'
require 'active_support/core_ext/hash/indifferent_access'
require 'active_support/concern'

module RethinkAPI
  extend RethinkDB::Shortcuts

  mattr_accessor :database, :host, :port
  self.database = 'test'
  self.host     = 'localhost'
  self.port     = 28015

  mattr_accessor :conn
  self.conn = r.connect(host: host, port: port, db: database)
end

require 'rethink_api/base'
require 'rethink_api/methods'
require 'rethink_api/template'
