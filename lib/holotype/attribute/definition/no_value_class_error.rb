class Holotype
  class Attribute
    class Definition
      class NoValueClassError < StandardError
        attr_reader :definition

        def initialize definition
          @definition = definition
        end

        def message
          "No value class for attribute definition: #{definition.name}"
        end
      end
    end
  end
end
