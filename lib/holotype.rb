require_relative 'holotype/missing_required_attributes_error.rb'
require_relative 'holotype/version.rb'

class Holotype
  # Singleton Definition

  class << self
    def attribute name, **options, &default
      # symbolize the name
      name = name.to_sym

      # remember the attribute
      attributes << name

      # store the default block if supplied
      __attribute_default[name] = default if default

      # remember if the attribute is required
      __required_attributes << name if options[:required]

      # create an attribute reader
      define_method name do
        internal_name = "@#{name}"

        # return the value if there is one
        next instance_variable_get internal_name \
          if __attribute_has_value?[name]

        # get a default if a default block was given
        if (default_proc = self.class.__attribute_default[name])
          value = default_proc.call

          instance_variable_set internal_name, value
          __attribute_has_value?[name] = true

          next value
        end

        # no set value and no default block means no value
        nil
      end
    end

    def attributes
      @attributes ||= []
    end

    def __attribute_default
      @__attribute_default ||= Hash[]
    end

    def __required_attributes
      @__required_attributes ||= []
    end
  end

  # Instance Definition

  def initialize **attributes
    klass = self.class

    # check for missing required attributes
    klass
      .attributes
      .select do |name|
        next false unless klass.__required_attributes.include? name
        !attributes.key? name
      end
      .tap do |missing_attributes|
        next if missing_attributes.empty?
        raise MissingRequiredAttributesError.new klass, missing_attributes
      end

    # store provided attributes
    klass.attributes.each do |attribute|
      required = klass.__required_attributes.include? attribute
      provided = attributes.key? attribute

      raise MissingRequiredAttributeError.new klass, attribute \
        if required && !provided

      next unless provided

      value = attributes[attribute].freeze
      __attribute_has_value?[attribute] = true
      instance_variable_set "@#{attribute}", value
    end
  end

  def frozen?
    true
  end

  def to_hash
    Hash[
      self.class.attributes.map do |attribute|
        [attribute, public_send(attribute)]
      end
    ]
  end

  def == other
    return false unless self.class == other.class

    self.class.attributes.each do |attribute|
      self_value  = self.public_send attribute
      other_value = other.public_send attribute

      return false unless self_value == other_value
    end

    true
  end

  def with **attributes
    self.class.new to_hash.merge attributes
  end

  private

  def __attribute_has_value?
    @__attribute_has_value ||= Hash.new { |_| false }
  end
end
