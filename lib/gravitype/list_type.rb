require "set"

module Gravitype
  class List < ::Set
    def self.for_list(list)
      case list
      when ::Array then Array.new
      when ::Set then Set.new
      end
    end

    def +(other)
      raise TypeError, "Conflicting list types" if other.class != self.class
      super
    end

    def <<(klass)
      raise TypeError, "Unexpected nested list type" if [Array, Set, Hash].include?(klass)
      super
    end

    class Array < List
      alias_method :to_list, :to_a
    end

    class Set < List
      alias_method :to_list, :to_set
    end
  end
end
