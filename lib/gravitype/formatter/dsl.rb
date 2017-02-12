require "gravitype/type"

module Gravitype
  class Type
    def to_dsl(as_nullable = false)
      if type == NilClass
        "null"
      else
        nonnull_to_dsl(as_nullable)
      end
    end

    def nonnull_to_dsl(as_nullable)
      "#{Type::SPECIAL_TYPES[type] || type.name}#{as_nullable ? "?" : "!"}"
    end
  end

  class Type::Union
    def to_dsl
      if nullable? && type = prominent_type
        type.to_dsl(true)
      else
        types.map(&:to_dsl).join(" | ")
      end
    end
  end

  class Type::Reference
    def nonnull_to_dsl(as_nullable)
      "Reference#{as_nullable ? "?" : "!"}(#{type.inspect})"
    end
  end

  class Type::List
    def to_dsl(as_nullable = false)
      type = nonnull_to_dsl(as_nullable)
      empty? ? type : "#{type}#{contents_to_dsl}"
    end

    def contents_to_dsl
      "(#{values.types.map(&:to_dsl).join(", ")})"
    end
  end

  class Type::Hash
    def contents_to_dsl
      "(#{keys.to_dsl} => #{values.to_dsl})"
    end
  end
end
