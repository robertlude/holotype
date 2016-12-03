describe Holotype::Attribute::ImmutableValueError do
  # Subject

  subject { described_class.new name }

  # Lets

  junklet :name

  # Class Tests

  it 'is a StandardError' do
    expect(described_class.ancestors).to include StandardError
  end

  # Instance Tests

  describe '#name' do
    let(:result) { subject.name }

    it 'returns the name supplied during creation' do
      expect(result).to eq name
    end

    it 'returns a frozen value' do
      expect(result).to be_frozen
    end
  end

  describe '#message' do
    let(:result) { subject.message }

    it 'returns a descriptive message' do
      expect(result).to eq "Cannot modify value of `#{name}` in immutable " \
                           "class".freeze
    end

    it 'returns a frozen value' do
      expect(result).to be_frozen
    end
  end
end
