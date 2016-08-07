class Holotype
  class Attribute
    class DefaultConflictError < StandardError
      def message
        'Attributes cannot have both a default value and a default block'
      end
    end
  end
end
