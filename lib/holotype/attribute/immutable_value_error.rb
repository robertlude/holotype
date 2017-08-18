module Holotype
  class Attribute
    class ImmutableValueError < StandardError
      attr_reader :name

      def initialize name
        @name = name.freeze
      end

      def message
        "Cannot modify value of `#{name}` in immutable class".freeze
      end
    end
  end
end
