require "gravitype/introspection"

require "ruby-progressbar"

module Gravitype
  class Introspection
    # Collects type information from the actual data of the model.
    class Data < Introspection
      def introspect(fields_with_getters)
        if ENV["TESTING"]
          progressbar = Object.new
          def progressbar.increment; end
          def progressbar.finish; end
        else
          progressbar = ProgressBar.create(
            total: @model.all.count + fields_with_getters.size,
            title: @model.name,
            format: "%t |%E | %B | %p%%",
          )
        end

        fields = {}
        @model.all.each do |doc|
          fields_with_getters.each do |name, getter|
            name = name.to_sym
            value = doc.send(getter)
            field = Field.new(name, Type.of(value))
            if fields[name]
              fields[name].merge!(field)
            else
              fields[name] = field
            end
          end
          progressbar.increment
        end

        result = fields.map do |name, field|
          normalized = field.normalize
          progressbar.increment
          normalized
        end

        progressbar.finish
        result
      end
    end
  end
end
