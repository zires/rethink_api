module RethinkAPI
  class Base

    class << self
      attr_accessor :conn, :database, :table_name

      def create_table
        RethinkAPI.r.db(database).table_create(table_name).run(conn) unless table_exists?
      end

      def table_exists?
        RethinkAPI.r.db(database).table_list.run(conn).include?(table_name)
      end

      def set_default_settings
        # Set default valuse.
        self.conn       = RethinkAPI.conn
        self.database   = RethinkAPI.database
        self.table_name = name.demodulize.underscore
      end

      def bootstrap
        set_default_settings
        create_table
      end

      def table
        RethinkAPI.r.db(database).table(table_name)
      end

    end

    attr_reader :table, :attributes, :obj
    delegate :id, :rethink_attributes, to: :obj

    def initialize(obj)
      @obj   = obj
      @table = r.db(database).table(table_name)
      ensure_existing
    end

    def r
      RethinkAPI.r
    end

    def database
      self.class.database
    end

    def table_name
      self.class.table_name
    end

    def conn
      self.class.conn
    end

    def attributes
      table.get(id.to_s).run(conn)
    end

    def pluck(*attrs)
      table.get(id.to_s).pluck(*attrs).run(conn)
    end

    def refresh
      attrs = self.rethink_attributes.with_indifferent_access
      attrs[:id] = attrs[:id].to_s
      rep = table.get(id.to_s).replace(attrs).run(conn)
      if rep['errors'] > 0
        raise rep['first_error']
      else
        true
      end
    end

    private

      def ensure_existing
        table.insert({id: id.to_s}).run(conn) unless table.get(id.to_s).run(conn)
      end

  end
end

