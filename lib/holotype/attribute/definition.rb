require_relative 'definition/default_conflict_error.rb'

class Holotype
  class Attribute
    class Definition
      attr_reader :name

      def initialize name, **options, &default_block
        @collection       = options.fetch :collection, false
        @collection_class = options[:collection_class]
        @immutable        = options.fetch :immutable, false
        @klass            = options[:class]
        @name             = name
        @read_only        = options.fetch :read_only, false
        @required         = options.fetch :required, false

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

      def has_class?
        !!@klass
      end

      def collection?
        !!@collection
      end

      def has_collection_class?
        !!@collection_class
      end

      def read_only?
        !!@read_only
      end

      def immutable?
        !!@immutable
      end

      private

      def normalize_single value
        if has_class?
          @klass.new **(symbolize_keys value)
        else
          value
        end.freeze
      end

      def normalize_collection values
        normalized_values = values.map { |value| normalize_single value }

        if has_collection_class?
          @collection_class.new normalized_values
        else
          normalized_values
        end.freeze
      end

      def symbolize_keys hash
        Hash[hash.map { |key, value| [key.to_sym, value] }]
      end
    end
  end
end
