%i[
  attribute
  missing_required_attributes_error
  version
].each { |name| require_relative "holotype/#{name}.rb" }

class Holotype
  # Singleton Definition

  class << self
    def attribute name, **options, &default
      # symbolize name
      name = name.to_sym

      # create attribute defintion
      attribute = Attribute.new name, options, &default

      # store the attribute definition
      attributes[name] = attribute

      # create an attribute reader
      define_method name do
        # return the value if there is one
        next __attribute_get name if __attribute_has_value?[name]

        # use the default value
        __attribute_set name, attribute.default(self)
      end
    end

    def attributes
      @attributes ||= Hash[]
    end
  end

  # Instance Definition

  def initialize **attributes
    __check_for_missing_required attributes
    __store attributes
  end

  def frozen?
    true
  end

  def to_hash
    Hash[
      self.class.attributes.map do |name, attribute|
        key   = name
        value = public_send name

        value = value.to_hash if attribute.has_class?

        [key, value]
      end
    ]
  end

  def == other
    return false unless self.class == other.class

    self.class.attributes.each do |name, _|
      self_value  = self.public_send name
      other_value = other.public_send name

      return false unless self_value == other_value
    end

    true
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
    self
      .class
      .attributes
      .each do |name, _|
        next unless attributes.key? name
        __attribute_set name, attributes[name].freeze
      end
  end

  def __attribute_get name
    if __attribute_has_value?[name]
      instance_variable_get "@#{name}"
    else
      __attribute_set name, self.class.attributes[name].default(self)
    end
  end

  def __attribute_set name, value
    normalized_value = self.class.attributes[name].normalize value

    instance_variable_set "@#{name}", normalized_value
    __attribute_has_value?[name] = true

    normalized_value
  end

  def __attribute_has_value?
    @__attribute_has_value ||= Hash.new { |_| false }
  end
end
