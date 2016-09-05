class Holotype
  class Attribute
    class ReadOnlyError < StandardError
      attr_reader :name

      def initialize name
        @name = name.freeze
      end

      def message
        "Attribute `#{name}` is read-only and may not be written to".freeze
      end
    end
  end
end
