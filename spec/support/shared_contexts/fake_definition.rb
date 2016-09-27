shared_context 'fake definition' do
  # Lets

  junklet :definition_name

  let(:definition_immutable) { false }

  let :definition do
    Holotype::Attribute::Definition.new(
      definition_name,
      **definition_options,
    )
  end

  let :definition_options do
    Hash[
      immutable: definition_immutable,
    ].tap do |options|
      options[:value_class] = definition_value_class \
        if defined? definition_value_class

      options[:collection_class] = definition_collection_class \
        if defined? definition_collection_class
    end
  end
end
