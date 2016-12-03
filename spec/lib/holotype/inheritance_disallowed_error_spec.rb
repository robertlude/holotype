describe Holotype::InheritanceDisallowedError do
  # Subject

  subject { described_class.new }

  # Class Tests

  it 'is a StandardError' do
    expect(described_class.ancestors).to include StandardError
  end

  # Instance Tests

  describe '#message' do
    let(:result) { subject.message }

    it 'returns a descriptive message' do
      expect(result).to eq 'Cannot inherit from immutable class'
    end

    it 'returns a frozen value' do
      expect(result).to be_frozen
    end
  end
end
