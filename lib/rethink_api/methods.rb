module RethinkAPI
  module Methods
    extend ActiveSupport::Concern

    module ClassMethods
      # Make current class can rethink api.
      #
      # @example
      #   class Foo
      #     extend RethinkAPI::Methods
      #
      #     rethink_api
      #
      #     -or-
      #
      #     rethink_api(class_name: 'BarAPI')
      #
      #   end
      def rethink_api(opts = {})
        class_name = opts[:class_name] || opts['class_name'] || "#{name.demodulize}RethinkAPI"
        class_variable_set(:@@_r_api_const, const_set( class_name, Class.new(RethinkAPI::Base) ))
        class_variable_set(:@@_r_templates, {})
        rethink_api_const.bootstrap
      end

      # TODO: description
      #
      # @example
      #
      #   api_template :bar do
      #     attributes :id, :name
      #
      #     attribute :combined_address, key: :address
      #
      #     attribute -> (m, o) { m.name }, key: :address
      #
      #     has_many :foos, class_name: 'Foo', foreign_key: 'foo_id', template: :lala
      #
      #     after -> (attrs) { attrs[:callback] = true }
      #   end
      def api_template(name = nil, &block)
        name   ||= 'default'
        template = RethinkAPI::Template.new(name.to_s, self.name)
        template.instance_eval(&block)
        rethink_api_templates[name.to_s] = template
      end

      # rthink api const
      def rethink_api_const
        class_variable_get :@@_r_api_const
      end

      def rethink_api_templates
        class_variable_get(:@@_r_templates)
      end

    end # End of ClassMethods

    def api_json(name = 'default', opts = {})
      template = self.class.rethink_api_templates[name]
      if template
        template.api_json(rethink, opts)
      end
    end

    def rethink
      @_rethink ||= self.class.rethink_api_const.new(self)
    end

    def refresh_rethink
      rethink.refresh
    end

    def rethink_attributes
      attrs = {id: id.to_s}
      self.class.rethink_api_templates.each do |name, template|
        template.static_attrs.each { |kv| attrs[ kv[:alias_name] ] = self.send(kv[:method_name]) }
      end
      attrs
    end

  end
end
