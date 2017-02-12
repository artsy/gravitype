require "gravitype/introspection"

require "ruby-progressbar"

module Gravitype
  class Introspection
    # Collects type information from the actual data of the model.
    class Data < Introspection
      attr_accessor :visitors

      def initialize(*)
        super
        @visitors = [
          Visitor::Mongoid.new(@model),
          Visitor::JSONFields.new(@model, :all),
          Visitor::JSONFields.new(@model, :public),
          Visitor::JSONFields.new(@model, :short),
        ]
      end

      def introspect
        return @result if @result

        @model.all.each do |document|
          @visitors.each do |visitor|
            visitor.visit(document)
          end
          print "." unless ENV["TESTING"]
        end

        @result = @visitors.inject({}) do |result, visitor|
          result[visitor.type] = visitor.collected
          result
        end
      end

      class Visitor
        def initialize(model)
          @model = model
          @collected = {}
        end

        def type
          raise NotImplementedError
        end

        def type_of(field, value)
          Type.of(value)
        end

        def visit(attributes)
          attributes.each do |name, value|
            name = name.to_sym
            field = Field.new(name, type_of(name, value))
            if @collected[name]
              @collected[name].merge!(field)
            else
              @collected[name] = field
            end
          end
        end

        def collected
          @collected.values.map(&:normalize).extend(ResultSet)
        end
      end

      class Visitor
        class Mongoid < Visitor
          def type
            :mongoid_data
          end

          def fields
            @fields ||= @model.fields.keys
          end

          def visit(document)
            super(fields.inject({}) do |attributes, field|
              attributes[field] = document.send(field)
              attributes
            end)
          end
        end

        class JSONFields < Visitor
          def self.scoped_fields(scope)
            "#{scope}_json_fields".to_sym
          end

          def initialize(model, scope)
            super(model)
            @scope = scope
          end

          def type
            self.class.scoped_fields(@scope)
          end

          def references
            @model.cached_json_reference_defs[@scope]
          end

          def type_of(field, value)
            if value && reference = references[field]
              scope = reference[:reference_properties] || (@scope == :all ? :all : :short)
              type = Type::Reference.new("#{reference[:metadata].class_name}.#{self.class.scoped_fields(scope)}")
              if reference[:metadata].macro == :has_many
                type = Type::Array.new([type])
              end
              type
            else
              super
            end
          end

          def visit(document)
            super(document.as_json(properties: @scope))
          end
        end
      end
    end
  end
end
