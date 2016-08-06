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
end
