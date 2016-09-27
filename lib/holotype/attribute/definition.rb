%w[
  default_conflict_error
  no_collection_class_error
  no_value_class_error
].each { |file| require_relative "definition/#{file}" }

require_relative 'definition/default_conflict_error.rb'

class Holotype
  class Attribute
    class Definition
      attr_reader :name

      # TODO add attribute option disallow_nil

      def initialize name, **options, &default_block
        @collection       = options.fetch :collection, false
        @immutable        = options.fetch :immutable, false
        @name             = name
        @read_only        = options.fetch :read_only, false
        @required         = options.fetch :required, false

        if options.key? :collection_class
          @has_collection_class = true
          @collection_class     = options[:collection_class]
        else
          @has_collection_class = false
        end

        if options.key? :value_class
          @has_value_class = true
          @value_class     = options[:value_class]
        else
          @has_value_class = false
        end

        if default_block
          raise DefaultConflictError.new if options.key? :default
          @default      = default_block
          @default_type = :dynamic
        elsif options.key? :default
          @default      = options[:default]
          @default_type = :constant
        end
      end

      def default receiver
        case @default_type
        when :constant then @default
        when :dynamic  then receiver.instance_exec(&@default).freeze
        else nil
        end
      end

      def normalize value
        if collection?
          normalize_collection value
        else
          normalize_single value
        end
      end

      def required?
        !!@required
      end

      def has_value_class?
        @has_value_class
      end

      def value_class
        raise NoValueClassError.new self unless has_value_class?
        @value_class
      end

      def collection?
        !!@collection
      end

      def has_collection_class?
        @has_collection_class
      end

      def collection_class
        raise NoCollectionClassError.new self unless has_collection_class?
        @collection_class
      end

      def read_only?
        !!@read_only
      end

      def immutable?
        !!@immutable
      end

      private

      def normalize_single value
        ValueNormalizer.new(self).normalize value
      end

      def normalize_collection values
        if has_collection_class? && @collection_class.ancestors.include?(Hash)
          normalize_hash_like_collection values
        else
          normalize_array_like_collection values
        end
      end

      def normalize_array_like_collection values
        normalized_values = (values || []) # TODO test this
                              .map { |value| normalize_single value }

        if has_collection_class?
          @collection_class.new normalized_values
        else
          normalized_values
        end
      end

      def normalize_hash_like_collection values
        normalized_values = values.map do |key, value|
                              [key, normalize_single(value)]
                            end

        @collection_class[normalized_values]
      end

      def symbolize_keys hash
        Hash[hash.map { |key, value| [key.to_sym, value] }]
      end
    end
  end
end
