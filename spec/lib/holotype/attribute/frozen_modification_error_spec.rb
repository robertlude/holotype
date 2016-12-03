describe Holotype::Attribute::FrozenModificationError do
  # Subject

  subject { described_class.new attribute_name }

  # Lets

  junklet :attribute_name

  # Class Tests

  it 'is a StandardError' do
    expect(described_class.ancestors).to include StandardError
  end

  # Instance Tests

  describe '#attribute_name' do
    let(:result) { subject.attribute_name }

    it 'returns the initialized attribute name' do
      expect(result).to eq attribute_name
    end

    it 'returns a frozen value' do
      expect(result).to be_frozen
    end
  end

  describe '#message' do
    let(:result) { subject.message }

    it 'returns a descriptive message' do
      expect(result).to eq "Cannot modify value of `#{attribute_name}` in " \
                           "frozen object"
    end

    it 'returns a frozen value' do
      expect(result).to be_frozen
    end
  end
end
