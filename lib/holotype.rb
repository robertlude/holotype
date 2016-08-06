require 'memorandum'

require_relative 'holotype/version.rb'

class Holotype
  # Singleton Definition

  class << self
    extend Memorandum

    def attribute name, &default
      name = name.to_sym

      attributes << name

      __attribute_default[name] = default if default

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
      []
    end
    memo :attributes

    def __attribute_default
      Hash[]
    end
    memo :__attribute_default
  end

  # Instance Definition

  extend Memorandum

  def initialize **attributes
    self.class.attributes.each do |attribute|
      next unless attributes.key? attribute

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
    Hash[]
  end
  memo :__attribute_has_value?
end
