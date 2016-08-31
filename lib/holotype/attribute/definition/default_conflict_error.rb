class Holotype
  class Attribute
    class Definition
      class DefaultConflictError < StandardError
        def message
          'Attribute definitions cannot have both a default value and a ' \
          'default block'
        end
      end
    end
  end
end
