describe Holotype::Attribute::Definition::DefaultConflictError do
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
      expect(result).to eq 'Attribute definitions cannot have both a default ' \
                           'value and a default block'
    end
  end
end
