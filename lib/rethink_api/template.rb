module RethinkAPI
  class Template

    attr_reader :name, :static_attrs, :dynamic_attrs, :has_many_relations

    def initialize(name, host_name = nil)
      @name          = name
      @host_name     = host_name
      @static_attrs  = []
      @dynamic_attrs = []
      @has_many_relations = []
    end

    def attribute(name, opts = {})
      opts = opts.with_indifferent_access
      if name.kind_of?(Proc)
        raise 'If name is a lambda, must have a key option.' if opts[:key].nil?
        @dynamic_attrs << {method_name: name, alias_name: opts[:key].to_s}
      else
        alias_name = opts[:key] || name
        @static_attrs << {method_name: name.to_s, alias_name: alias_name.to_s}
      end
    end

    def attributes(*names)
      names.each { |name| attribute(name) }
    end

    def attribute_names
      static_attrs.map { |attrs| attrs[:alias_name] }
    end

    # has_many :foos, class_name: 'Foo', foreign_key: 'foo_id', template: :lala, key: 'bar'
    def has_many(name, opts = {})
      opts = opts.with_indifferent_access
      alias_name    = opts[:key] || name
      class_name    = opts[:class_name] || name.to_s.classify
      foreign_key   = opts[:foreign_key] || @host_name.to_s.singularize.foreign_key
      template_name = opts[:template] || @name
      @has_many_relations << {alias_name: alias_name.to_s, class_name: class_name, foreign_key: foreign_key, template_name: template_name}
    end

    # TODO: after callback
    def after(&block)
      return unless block_given?
    end

    def api_json(api, opts = {})
      # Static attributes
      attrs = api.pluck(attribute_names)

      # Dynamic attributes
      self.dynamic_attrs.each do |attr|
        attrs[ attr[:alias_name] ] = attr[:method_name].call(api.obj, opts)
      end

      # Has many relations
      self.has_many_relations.each do |relation|
        const = relation[:class_name].safe_constantize
        attrs[ relation[:alias_name] ] = const.rethink_api_const.table \
          .pluck(const.rethink_api_templates[ relation[:template_name] ].attribute_names) \
          .eq_join(relation[:foreign_key], api.table).zip.run(const.rethink_api_const.conn).to_a
      end

      attrs
    end

  end
end
