shared_context 'fake definition' do
  # Lets

  junklet :definition_name

  let :definition do
    block = if defined? definition_block
              definition_block
            else
              nil
            end

    Holotype::Attribute::Definition.new(
      definition_name,
      **definition_options,
      &block
    )
  end

  let :definition_options do
    Hash[].tap do |options|
      options[:immutable] = definition_immutable \
        if defined? definition_immutable

      options[:value_class] = definition_value_class \
        if defined? definition_value_class

      options[:collection_class] = definition_collection_class \
        if defined? definition_collection_class

      options[:read_only] = definition_read_only \
        if defined? definition_read_only

      options[:collection] = definition_collection \
        if defined? definition_collection

      options[:default] = definition_default \
        if defined? definition_default
    end
  end
end
