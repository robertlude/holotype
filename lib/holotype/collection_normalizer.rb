%w[
  expected_array_like_collection_error
  expected_hash_like_collection_error
].each { |file| require_relative "collection_normalizer/#{file}" }

class Holotype
  class CollectionNormalizer
    extend Memorandum

    ARRAY_LIKE_METHODS = %i[
      []
      []=
    ].freeze

    HASH_LIKE_METHODS = %i[
      []
      []=
      keys
      values
    ]

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
          unless collection.nil? || object_is_hash_like?(collection)
      elsif array_like?
        raise ExpectedArrayLikeCollectionError.new definition.name \
          unless collection.nil? || object_is_array_like?(collection)
      end
    end

    def hash_like?
      return false unless definition.has_collection_class?

      class_is_hash_like? definition.collection_class
    end

    def array_like?
      return false unless definition.has_collection_class?
      return false if hash_like?

      class_is_array_like? definition.collection_class
    end

    def class_is_array_like? klass
      return false if class_is_hash_like? klass

      instance_methods = klass.instance_methods

      ARRAY_LIKE_METHODS.all? do |method|
        instance_methods.include? method
      end
    end

    def class_is_hash_like? klass
      instance_methods = klass.instance_methods

      HASH_LIKE_METHODS.all? do |method|
        instance_methods.include? method
      end
    end

    def object_is_array_like? object
      return false if object_is_hash_like? object

      ARRAY_LIKE_METHODS.all? do |method|
        object.respond_to? method
      end
    end

    def object_is_hash_like? object
      HASH_LIKE_METHODS.all? do |method|
        object.respond_to? method
      end
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
          collection.each { |value| result << value }
        end
    end

    def classify collection
      if object_is_hash_like? collection
        hash_like collection
      else
        array_like collection
      end
    end

    def normalized collection
      if hash_like?
        normalized_hash collection
      else
        normalized_array collection
      end
    end

    def normalized_hash collection
      collection ||= Hash[]

      Hash[
        collection.map do |key, value|
          [key, value_normalizer.normalize(value)]
        end
      ]
    end

    def normalized_array collection
      collection ||= []

      collection.map { |value| value_normalizer.normalize value }
    end
  end
end
