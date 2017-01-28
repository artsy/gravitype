require "gravitype/list_type"
require "gravitype/Introspection"

module Gravitype
  class Introspection
    class Data < Introspection
      def introspect(fields_with_getters = exposed_fields_and_getters)
        fields_with_classes = Hash.new { |h,k| h[k] = Set.new }
        @model.all.each do |doc|
          fields_with_getters.each do |field, getter|
            value = doc.send(getter)
            raise TypeError, "Hash support is not implemented yet" if value.is_a?(Hash)
            if list = List.for_list(value)
              classes = value.inject(list) { |list, element| list << element.class }
              fields_with_classes[field] << classes
            else
              fields_with_classes[field] << value.class
            end
          end
        end
        fields_with_classes.each do |field, classes|
          lists = classes.select { |x| x.is_a?(List) }
          unless lists.empty?
            classes.delete_if { |x| x.is_a?(List) }
            classes << lists.reduce(:+).to_list
          end
        end
        fields_with_classes
      end
    end
  end
end
