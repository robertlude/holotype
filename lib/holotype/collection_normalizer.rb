%w[
  expected_array_like_collection_error
  expected_hash_like_collection_error
].each { |file| require_relative "collection_normalizer/#{file}" }

class Holotype
  class CollectionNormalizer
    extend Memorandum

    attr_reader :definition

    def initialize definition
      @definition = definition
    end

    def normalize collection
      check_likeness_of collection

      result = classify normalized collection

      if definition.immutable?
        result.freeze
      else
        result
      end
    end

    private

    memo def value_normalizer
      ValueNormalizer.new definition
    end

    def check_likeness_of collection
      if hash_like?
        raise ExpectedHashLikeCollectionError.new definition.name \
          unless class_is_hash_like? collection.class
      else
        raise ExpectedArrayLikeCollectionError.new definition.name \
          unless !class_is_hash_like? collection.class
      end
    end

    def hash_like?
      return false unless definition.has_collection_class?

      class_is_hash_like? definition.collection_class
    end

    def class_is_hash_like? klass
      klass
        .ancestors
        .include? Hash
    end

    def hash_like collection
      return collection unless definition.has_collection_class?

      definition
        .collection_class
        .new
        .tap do |result|
          collection.each { |key, value| result[key] = value }
        end
    end

    def array_like collection
      return collection unless definition.has_collection_class?

      definition
        .collection_class
        .new
        .tap do |result|
          collection.each { |value, index| result << value }
        end
    end

    def classify collection
      if collection.kind_of? Hash
        hash_like collection
      else
        array_like collection
      end
    end

    def normalized collection
      if collection.kind_of? Hash
        normalized_hash collection
      else
        normalized_array collection
      end
    end

    def normalized_hash collection
      Hash[
        collection.map do |key, value|
          [key, value_normalizer.normalize(value)]
        end
      ]
    end

    def normalized_array collection
      collection.map { |value| value_normalizer.normalize value }
    end
  end
end
