class Holotype
  class Attribute
    class ReadOnlyError < StandardError
      attr_reader :name

      def initialize name
        @name = name.freeze
      end

      def message
        "Cannot modify read-only attribute `#{name}`".freeze
      end
    end
  end
end
