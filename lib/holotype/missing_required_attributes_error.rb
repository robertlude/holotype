class Holotype
  class MissingRequiredAttributesError < StandardError
    attr_reader :attributes, :original_class

    def initialize original_class, attributes
      @attributes     = attributes
      @original_class = original_class
    end

    def message
      "Class `#{original_class.name}` requires the following attributes:" \
      "#{format_list required_attributes}"                                \
      "\n\n"                                                              \
      "Missing attributes:"                                               \
      "#{format_list attributes}".freeze
    end

    private

    def required_attributes
      original_class
        .attributes
        .values
        .select(&:required?)
        .map(&:name)
    end

    def format_list attributes
      attributes
        .map { |name| "\n  * #{name}" }
        .join
    end
  end
end
