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
      "#{Formatter::SPECIAL_TYPES[type] || type.name}#{as_nullable ? "?" : "!"}"
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
      "#{nonnull_to_sugar(as_nullable)}(#{values.types.map(&:to_sugar).join(", ")})"
    end
  end

  class Type::Hash
    def to_sugar(as_nullable = false)
      "#{nonnull_to_sugar(as_nullable)}(#{keys.to_sugar} => #{values.to_sugar})"
    end
  end

  module Formatter
    SPECIAL_TYPES = Type::Sugar::SCALAR_TYPES.inject({}) do |hash, (name, klass)|
      if klass.name.include?("::")
        hash[klass] = name
      end
      hash
    end.freeze

    def self.format(type)
      type.to_sugar
    end
  end
end
