require_relative 'attribute/default_conflict_error.rb'

class Holotype
  class Attribute
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
        @klass.new value
      else
        value
      end.freeze
    end

    def required?
      !!@required
    end
  end
end
