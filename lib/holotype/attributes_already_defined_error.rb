module Holotype
  class AttributesAlreadyDefinedError < StandardError
    def message; MESSAGE; end

    private

    MESSAGE = 'Cannot make class immutable afer attributes are defined'.freeze
  end
end
