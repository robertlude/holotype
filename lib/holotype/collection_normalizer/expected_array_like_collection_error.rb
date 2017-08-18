module Holotype
  class CollectionNormalizer
    class ExpectedArrayLikeCollectionError < StandardError
      attr_reader :attribute

      def initialize attribute
        @attribute = attribute
      end

      def message
        "Attribute `#{attribute}` expected Array-like collection, received " \
        "Hash-like collection".freeze
      end
    end
  end
end
