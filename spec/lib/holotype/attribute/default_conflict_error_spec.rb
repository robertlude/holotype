describe Holotype::Attribute::DefaultConflictError do
  # Subject

  subject { described_class.new }

  # Instance Method Tests

  describe '#message' do
    let(:result) { subject.message }

    it 'returns a descriptive error message' do
      expect(result)
        .to eq 'Attributes cannot have both a default value and a default block'
    end
  end
end
