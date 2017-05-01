%w[
  memorandum
].each { |gem| require gem }

%i[
  attribute
  attributes_already_defined_error
  collection_normalizer
  inheritance_disallowed_error
  missing_required_attributes_error
  value_normalizer
  version
].each { |name| require_relative "holotype/#{name}.rb" }

class Holotype
  # Singleton Definition

  class << self
    def attribute name, **options, &default
      # symbolize name
      name = name.to_sym

      # prepare options
      processed_options = if immutable?
                            [
                              __default_attribute_options,
                              options,
                              IMMUTABLE_OPTION,
                            ].reduce :merge
                          else
                            [
                              __default_attribute_options,
                              options,
                            ].reduce :merge
                          end

      # create attribute definition
      attribute = Attribute::Definition.new name,
                                            **processed_options,
                                            &default

      # store the attribute definition
      attributes[name] = attribute

      # create an attribute reader
      define_method name do
        self.attributes[name].value
      end

      # create an attribute writer
      define_method "#{name}=" do |value|
        self.attributes[name].value = value
      end
    end

    def attributes
      @attributes ||= Hash[]
    end

    def make_immutable
      raise AttributesAlreadyDefinedError.new if attributes.count != 0

      define_singleton_method :inherited do |_|
        raise InheritanceDisallowedError.new
      end

      @immutable = true
    end

    def immutable?
      !!@immutable
    end

    def default_attribute_options **options
      @default_attribute_options = options.freeze
    end

    private

    IMMUTABLE_OPTION = Hash[immutable: true].freeze

    def __default_attribute_options
      @default_attribute_options || Hash[]
    end
  end

  # Instance Definition

  attr_reader :attributes

  def initialize **attributes
    __holotype_check_for_missing_required attributes
    __holotype_store attributes
  end

  def frozen?
    true
  end

  def to_hash
    Hash[
      attributes
        .map do |key, attribute|
          definition = attribute.definition

          value = __holotype_hashify attribute.value

          [key, value]
        end
    ]
  end

  def == other
    return false unless self.class == other.class

    attributes.all? do |name, attribute|
      attribute.value == other.attributes[name].value
    end
  end

  def with **attributes
    self.class.new to_hash.merge attributes
  end

  def inspect
    data = to_hash
             .map { |attribute, value| "#{attribute}: #{value.inspect}" }
             .join(', ')

    "#{self.class.name}(#{data})"
  end

  private

  def __holotype_hashify value
    if value.respond_to? :to_hash
      value.to_hash
    elsif value.kind_of? Enumerable
      value.map { |value| __holotype_hashify value }
    else
      value
    end
  end

  def __holotype_check_for_missing_required attributes
    self
      .class
      .attributes
      .flat_map do |name, attribute|
        # skip non-required attributes
        next [] unless attribute.required?

        # skip attributes with provided values
        next [] if attributes.key? name

        [name]
      end
      .tap do |missing_attributes|
        next if missing_attributes.empty?
        raise MissingRequiredAttributesError.new self.class, missing_attributes
      end
  end

  def __holotype_store attributes
    @attributes = Hash[
                    self
                      .class
                      .attributes
                      .map do |name, definition|
                        options = if attributes.key? name
                                    Hash value: attributes[name]
                                  else
                                    Hash[]
                                  end

                        attribute = Attribute.new self, definition, **options

                        [name, attribute]
                      end
                  ].freeze
  end
end
