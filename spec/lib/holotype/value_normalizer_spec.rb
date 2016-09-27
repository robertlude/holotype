describe Holotype::ValueNormalizer do
  # Subject

  subject { described_class.new definition }

  # Setup

  include_context 'fake definition'

  # Tests

  describe '#definition' do
    let(:result) { subject.definition }

    it 'returns the definition the instance was initialized with' do
      expect(result).to be definition
    end
  end

  describe '#normalize' do
    junklet :value

    let(:result) { subject.normalize value }

    it 'returns the given value' do
      expect(result).to eq value
    end

    context 'when the definition specifies immutability' do
      let(:definition_immutable) { true }

      it 'freezes the value' do
        expect(result).to be_frozen
      end
    end

    context 'when the definition specifies a value class' do
      let(:definition_value_class) { fake_value_class }
      let(:fake_value_class)       { double }
      let(:fake_value_instance)    { double }

      before do
        expect(fake_value_class)
          .to receive(:new)
          .with(value)
          .and_return(fake_value_instance)
      end

      it 'uses the value to create an instance of the value class' do
        expect(result).to be fake_value_instance
      end
    end

    context 'when the given value is `nil`' do
      let(:value) { }

      context 'when the definition disallows nil' do
        it 'raises an error'
      end

      context 'when the definition allows nil' do
        it 'returns nil' do
          expect(result).to be nil
        end
      end
    end
  end
end
