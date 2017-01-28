require "set"

module Gravitype
  class List < ::Set
    def self.for_list(input)
      list = case input
             when ::Array then Array.new
             when ::Set then Set.new
             end
      list.add_types(input) if list
    end

    def +(other)
      raise TypeError, "Conflicting list types" if other.class != self.class
      super
    end

    def <<(klass)
      raise TypeError, "Unexpected nested list type" if [Array, Set, Hash].include?(klass)
      super
    end

    def add_types(input)
      input.inject(self) { |list, element| list << element.class }
    end

    class Array < List
      alias_method :to_list, :to_a
    end

    class Set < List
      alias_method :to_list, :to_set
    end
  end
end
