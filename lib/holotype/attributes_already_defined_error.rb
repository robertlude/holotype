class Holotype
  class AttributesAlreadyDefinedError < StandardError
    def message
      'Cannot make class immutable afer attributes are defined'.freeze
    end
  end
end
