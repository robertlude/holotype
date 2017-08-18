module Holotype
  class Attribute
    class Definition
      class RequiredConflictError < StandardError
        def message; MESSAGE; end

        private

        MESSAGE = 'Attribute definitions cannot both be required and provide ' \
                  'a default'.freeze
      end
    end
  end
end
