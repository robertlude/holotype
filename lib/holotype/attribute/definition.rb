require_relative 'definition/default_conflict_error.rb'

class Holotype
  class Attribute
    class Definition
      attr_reader :name

      def initialize name, **options, &default_block
        @klass    = options[:class]
        @name     = name
        @required = options.fetch :required, false

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
        if @klass
          @klass.new **(symbolize_keys value)
        else
          value
        end.freeze
      end

      def required?
        !!@required
      end

      def has_class?
        !!@klass
      end

      private

      def symbolize_keys hash
        Hash[hash.map { |key, value| [key.to_sym, value] }]
      end
    end
  end
end