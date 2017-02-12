require "gravitype/type"

module Gravitype
  class Type
    class Reference < Type
      def inspect
        "#<Type:Reference(#{type})>"
      end
    end
  end
end
