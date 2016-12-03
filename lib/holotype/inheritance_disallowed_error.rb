class Holotype
  class InheritanceDisallowedError < StandardError
    def message; MESSAGE; end

    private

    MESSAGE = 'Cannot inherit from immutable class'.freeze
  end
end
