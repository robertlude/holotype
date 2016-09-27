class Holotype
  class ValueNormalizer
    attr_reader :definition

    def initialize definition
      @definition = definition
    end

    def normalize value
      result = if definition.has_value_class?
                 definition.value_class.new value
               else
                 value
               end

      if definition.immutable?
        result.freeze
      else
        result
      end
    end
  end
end
