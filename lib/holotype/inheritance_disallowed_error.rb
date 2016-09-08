class Holotype
  class InheritanceDisallowedError < StandardError
    def message
      'Cannot inherit from immutable class'.freeze
    end
  end
end
