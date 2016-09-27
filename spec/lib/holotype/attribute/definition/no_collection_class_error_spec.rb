describe Holotype::Attribute::Definition::NoCollectionClassError do
  # Subject

  subject { described_class.new attribute_definition }

  # Lets

  junklet :attribute_definition_name

  let :attribute_definition do
    double name: attribute_definition_name
  end

  # Tests

  describe '#definition' do
    let(:result) { subject.definition }

    it 'returns the definition given during creation' do
      expect(result).to eq attribute_definition
    end
  end

  describe '#message' do
    let(:result) { subject.message }

    it 'returns a descriptive message' do
      expect(result).to eq "No collection class for attribute definition: " \
                           "#{attribute_definition.name}"
    end
  end
end
