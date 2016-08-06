class Holotype
  class Attribute
    attr_reader *%i[
      default_proc
      name
    ]

    def initialize name, **options, &default_block
      @default_proc = default_block
      @name         = name
      @required     = options.fetch :required, false
    end

    def required?
      @required
    end
  end
end
