describe Holotype::Attribute::ImmutableValueError do
  # Subject

  subject { described_class.new name }

  # Lets

  junklet :name

  # Tests

  it 'is a StandardError' do
    expect(subject).to be_kind_of StandardError
  end

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
      expect(result).to eq "Attribute `#{name}` is read-only and may not be "\
                           "written to"
    end

    it 'returns a frozen value' do
      expect(result).to be_frozen
    end
  end
end
