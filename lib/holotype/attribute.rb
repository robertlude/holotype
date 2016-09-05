%w[
  definition
  read_only_error
].each { |file| require_relative "attribute/#{file}" }

class Holotype
  class Attribute
    attr_reader :definition

    def initialize definition, **options
      @definition = definition

      set_value options[:value] if options.key? :value
    end

    def name
      definition.name
    end

    def value
      self.value = definition.default self unless @has_value
      @value
    end

    def value= new_value
      raise ReadOnlyError.new name if definition.read_only?

      set_value new_value
    end

    private

    def set_value new_value
      @has_value = true
      @value     = definition.normalize new_value
    end
  end
end
