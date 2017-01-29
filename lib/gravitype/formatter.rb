require "gravitype/type"

module Gravitype
  class Type
    def to_sugar(as_nullable = false)
      if type == NilClass
        "null"
      else
        nonnull_to_sugar(as_nullable)
      end
    end

    def nonnull_to_sugar(as_nullable)
      "#{Type::SPECIAL_TYPES[type] || type.name}#{as_nullable ? "?" : "!"}"
    end
  end

  class Type::Union
    def to_sugar
      if nullable? && type = prominent_type
        type.to_sugar(true)
      else
        types.map(&:to_sugar).join(" | ")
      end
    end
  end

  class Type::List
    def to_sugar(as_nullable = false)
      type = nonnull_to_sugar(as_nullable)
      empty? ? type : "#{type}#{contents_to_sugar}"
    end

    def contents_to_sugar
      "(#{values.types.map(&:to_sugar).join(", ")})"
    end
  end

  class Type::Hash
    def contents_to_sugar
      "(#{keys.to_sugar} => #{values.to_sugar})"
    end
  end

  module Formatter
    def self.format(type)
      type.to_sugar
    end
  end
end
