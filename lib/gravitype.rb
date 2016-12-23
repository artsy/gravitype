require 'set'

module Gravitype
  class List < ::Set
    def self.for_list(list)
      case list
      when ::Array then Array.new
      when ::Set then Set.new
      end
    end

    def +(other)
      raise TypeError, 'Conflicting list types' if other.class != self.class
      super
    end

    def <<(klass)
      raise TypeError, 'Unexpected nested list type' if [Array, Set, Hash].include?(klass)
      super
    end

    class Array < List
      alias_method :to_list, :to_a
    end

    class Set < List
      alias_method :to_list, :to_set
    end
  end

  def self.introspect_data(model, fields_with_getters)
    fields_with_classes = Hash.new { |h,k| h[k] = Set.new }
    model.all.each do |doc|
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
