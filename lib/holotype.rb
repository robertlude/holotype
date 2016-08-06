require_relative 'holotype/version.rb'

class Holotype
  class << self
    def attribute name
      define_method(name) { instance_variable_get "@#{name}" }
    end
  end

  def initialize **attributes
    attributes.each do |key, value|
      instance_variable_set "@#{key}", value.freeze
    end
  end

  def frozen?
    true
  end
end
