require 'memorandum'

require_relative 'holotype/version.rb'

class Holotype
  class << self
    extend Memorandum

    def attribute name
      attributes << name.to_sym
      define_method(name) { instance_variable_get "@#{name}" }
    end

    def attributes
      []
    end
    memo :attributes
  end

  def initialize **attributes
    attributes.each do |key, value|
      instance_variable_set "@#{key}", value.freeze
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
end
