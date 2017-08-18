module Holotype
  class Attribute
    class Definition
      class DefaultConflictError < StandardError
        def message; MESSAGE; end

        private

        MESSAGE = 'Attribute definitions cannot have both a default value ' \
                  'and a default block'.freeze
      end
    end
  end
end
