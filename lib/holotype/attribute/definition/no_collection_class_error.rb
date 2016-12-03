class Holotype
  class Attribute
    class Definition
      class NoCollectionClassError < StandardError
        attr_reader :definition

        def initialize definition
          @definition = definition
        end

        def message
          "No collection class for attribute definition: #{definition.name}"
            .freeze
        end
      end
    end
  end
end
