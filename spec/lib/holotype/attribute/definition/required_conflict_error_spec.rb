describe Holotype::Attribute::Definition::RequiredConflictError do
  # Subject

  subject { described_class.new }

  # Class Tests

  it 'is a StandardError' do
    expect(described_class.ancestors).to include StandardError
  end

  # Instance Tests

  describe '#message' do
    let(:result) { subject.message }

    it 'returns a descriptive error message' do
      expect(result).to eq 'Attribute definitions cannot both be required ' \
                           'and provide a default'
    end

    it 'returns a frozen value' do
      expect(result).to be_frozen
    end
  end
end
