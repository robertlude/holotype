module Holotype
  class ValueNormalizer
    attr_reader :definition

    def initialize definition
      @definition = definition
    end

    def normalize value
      result = if definition.has_value_class?
                 if value.nil?
                   nil
                 else
                   definition.value_class.new value
                 end
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
