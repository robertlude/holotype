class Holotype
  class Attribute
    class FrozenModificationError < StandardError
      attr_reader :attribute_name

      def initialize attribute_name
        @attribute_name = attribute_name.freeze
      end

      def message
        "Cannot modify value of `#{attribute_name}` in frozen object".freeze
      end
    end
  end
end
