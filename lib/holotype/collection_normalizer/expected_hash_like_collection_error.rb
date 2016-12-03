class Holotype
  class CollectionNormalizer
    class ExpectedHashLikeCollectionError < StandardError
      attr_reader :attribute

      def initialize attribute
        @attribute = attribute
      end

      def message
        "Attribute `#{attribute}` expected Hash-like collection, received " \
        "Array-like collection".freeze
      end
    end
  end
end
