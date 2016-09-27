class Holotype
  class CollectionNormalizer
    extend Memorandum

    attr_reader :definition

    def initialize definition
      @definition = definition
    end

    def normalize collection
      # TODO test mismatches of collection/collection_class hash_like/array_like
      normalized_collection = if collection.kind_of? Hash
                                normalized_hash collection
                              else
                                normalized_array collection
                              end

      if has_collection_class?
        if collection_class.kind_of? Hash
          collection_class.new **normalized_collection
        else
          collection_class.new *normalized_collection
        end
      end

      if definition.immutable?
        result.freeze
      else
        result
      end
    end

    private

    def value_normalizer
      ValueNormalizer.new definition
    end
    memo :value_normalizer

    def hash_like?
      return false unless definition.has_collection_class?

      definition
        .collection_class
        .ancestors
        .include? Hash
    end

    def hash_like collection
      if definition.has_collection_class?
        definition.collection_class.new **collection
      else
        collection
      end
    end

    def array_like collection
      if definition.has_collection_class?
        definition.collection_class.new *collection
      else
        collection
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
