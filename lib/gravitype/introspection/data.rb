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
          Visitor::Mongoid.new,
          Visitor::JSONFields.new(:all),
          Visitor::JSONFields.new(:public),
          Visitor::JSONFields.new(:short),
        ]
      end

      def introspect
        return @result if @result

        @model.all.each do |document|
          @visitors.each do |visitor|
            visitor.visit(document)
          end
        end

        @result = @visitors.inject({}) do |result, visitor|
          result[visitor.type] = visitor.collected
          result
        end
      end

      class Visitor
        def initialize
          @collected = {}
        end

        def type
          raise NotImplementedError
        end

        def visit(attributes)
          attributes.each do |name, value|
            name = name.to_sym
            field = Field.new(name, Type.of(value))
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

          def visit(document)
            super(document.class.fields.keys.inject({}) do |attributes, field|
              attributes[field] = document.send(field)
              attributes
            end)
          end
        end

        class JSONFields < Visitor
          def initialize(scope)
            super()
            @scope = scope
          end

          def type
            "#{@scope}_json_fields".to_sym
          end

          def visit(document)
            super(document.as_json(properties: @scope))
          end
        end
      end
    end
  end
end
