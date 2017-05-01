%w[
  definition
  frozen_modification_error
  immutable_value_error
  read_only_error
].each { |file| require_relative "attribute/#{file}" }

class Holotype
  class Attribute
    attr_reader :definition, :owner

    def initialize owner, definition, **options
      @definition = definition
      @owner      = owner

      set_value options[:value] if options.key? :value
    end

    def name
      definition.name
    end

    def value
      set_value definition.default owner unless @has_value
      @value
    end

    def value= new_value
      raise ImmutableValueError.new     name if definition.immutable?
      raise FrozenModificationError.new name if owner.frozen?
      raise ReadOnlyError.new           name if definition.read_only?

      set_value new_value
    end

    private

    def set_value new_value
      @has_value = true
      @value     = definition.normalize new_value
    end
  end
end
