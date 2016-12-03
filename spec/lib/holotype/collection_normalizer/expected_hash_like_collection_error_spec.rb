describe Holotype::CollectionNormalizer::ExpectedHashLikeCollectionError do
  # Subject

  subject { described_class.new attribute }

  # Lets

  junklet :attribute

  # Class Tests

  it 'is a StandardError' do
    expect(described_class.ancestors).to include StandardError
  end

  # Instance Tests

  describe '#message' do
    let(:result) { subject.message }

    it 'returns a descriptive error message' do
      expect(result).to eq "Attribute `#{attribute}` expected Hash-like " \
                           "collection, received Array-like collection"
    end
  end
end
