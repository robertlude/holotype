class ToSym < ::RSpec::Junklet::Formatter
  def format
    input.to_sym
  end
end
