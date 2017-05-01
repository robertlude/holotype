%w[
  default_conflict_error
  no_collection_class_error
  no_value_class_error
  required_conflict_error
].each { |file| require_relative "definition/#{file}" }

require_relative 'definition/default_conflict_error.rb'

class Holotype
  class Attribute
    class Definition
      attr_reader :name

      def initialize name, **options, &default_block
        @collection = options.fetch :collection, false
        @immutable  = options.fetch :immutable, false
        @name       = name
        @read_only  = options.fetch :read_only, false
        @required   = options.fetch :required, false

        if options.key? :collection_class
          @collection           = true
          @has_collection_class = true
          @collection_class     = options[:collection_class]
        else
          if collection?
            @has_collection_class = true
            @collection_class     = Array
          else
            @has_collection_class = false
          end
        end

        if options.key? :value_class
          @has_value_class = true
          @value_class     = options[:value_class]
        else
          @has_value_class = false
        end

        if default_block
          raise DefaultConflictError.new  if options.key? :default
          raise RequiredConflictError.new if @required

          @default      = default_block
          @default_type = :dynamic
        elsif options.key? :default
          raise RequiredConflictError.new if @required

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
        return @collection_class if has_collection_class?
        raise NoCollectionClassError.new self
      end

      def read_only?
        !!@read_only
      end

      def immutable?
        !!@immutable
      end

      private

      def normalize_single value
        ValueNormalizer
          .new(self)
          .normalize value
      end

      def normalize_collection values
        CollectionNormalizer.new(self).normalize values
      end

      def symbolize_keys hash
        Hash[hash.map { |key, value| [key.to_sym, value] }]
      end
    end
  end
end
