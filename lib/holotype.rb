%i[
  attribute
  attributes_already_defined_error
  inheritance_disallowed_error
  missing_required_attributes_error
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
    __check_for_missing_required attributes
    __store attributes
  end

  def frozen?
    true
  end

  def to_hash
    Hash[
      attributes
        .map do |key, attribute|
          definition = attribute.definition

          value = if definition.has_class? || definition.has_collection_class?
                    attribute.value.to_hash
                  else
                    attribute.value
                  end

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

  private

  def __check_for_missing_required attributes
    self
      .class
      .attributes
      .flat_map do |name, attribute|
        # select missing required attribute names
        next [] unless attribute.required?
        next [] if attributes.key? name
        [name]
      end
      .tap do |missing_attributes|
        next if missing_attributes.empty?
        raise MissingRequiredAttributesError.new self.class, missing_attributes
      end
  end

  def __store attributes
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
