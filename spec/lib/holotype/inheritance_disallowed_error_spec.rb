describe Holotype::InheritanceDisallowedError do
  # Subject

  subject { described_class.new name }

  # Tests

  it 'is a StandardError' do
    expect(subject).to be_kind_of StandardError
  end

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
