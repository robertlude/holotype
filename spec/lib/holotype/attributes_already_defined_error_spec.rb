describe Holotype::AttributesAlreadyDefinedError do
  # Subject

  subject { described_class.new }

  # Tests

  it 'is a StandardError' do
    expect(subject).to be_kind_of StandardError
  end

  describe '#message' do
    let(:result) { subject.message }

    it 'returns a descriptive message' do
      expect(result).to eq 'Cannot make class immutable afer attributes are ' \
                           'defined'
    end

    it 'returns a frozen value' do
      expect(result).to be_frozen
    end
  end
end
