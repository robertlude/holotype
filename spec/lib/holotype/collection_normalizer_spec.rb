describe Holotype::CollectionNormalizer do
  # Subject

  subject { described_class.new definition }

  # Setup

  include_context 'fake definition'
  include_context 'fake value normalizer'

  # Tests

  describe '#definition' do
    let(:result) { subject.definition }

    it 'returns the definition the instance was initialized with' do
      expect(result).to be definition
    end
  end

  describe '#normalize' do
    let(:collection)            { [ value_a, value_b ] }
    let(:normalized_collection) { [ normalized_value_a, normalized_value_b ] }
    let(:result)                { subject.normalize collection }

    it 'returns a collection of normalized values' do
      expect(result).to eq normalized_collection
    end

    context 'when the definition specifies immutability' do
      let(:definition_immutable) { true }

      it 'freezes the result' do
        expect(result).to be_frozen
      end
    end

    context 'when the definition specifies a collection class' do
      context 'when the collection class is Array-like' do
        let(:definition_collection_class) { Class.new Array }

        it 'returns an instance of the collection class' do
          expect(result).to be_a definition_collection_class
        end
      end

      context 'when the collection class is Hash-like' do
        junklet :key_a, :key_b

        let :collection do
          Hash[
            key_a => value_a,
            key_b => value_b,
          ]
        end

        let(:definition_collection_class) { Class.new Hash }

        it 'returns an instance of the collection class' do
          expect(result).to be_a definition_collection_class
        end

        it 'preserves the keys in the collection' do
          expect(result.keys).to match_array collection.keys
        end
      end
    end
  end
end
