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

    context 'when the definition has a value class' do
      let(:definition_value_class) { double }

      context 'when the value is `nil`' do
        let(:value) { nil }

        it 'returns `nil`' do
          expect(result).to be nil
        end
      end

      context 'when the value is not `nil`' do
        junklet :value

        let(:value_class_instance) { double }

        before do
          expect(definition_value_class)
            .to receive(:new)
            .with(value)
            .and_return(value_class_instance)
        end

        it 'creates an instance of that value class with the value' do
          expect(result).to be value_class_instance
        end
      end
    end

    context 'when the definition does not have a value class' do
      it 'returns the value' do
        expect(result).to eq value
      end
    end

    context 'when the definition specifies immutability' do
      let(:definition_immutable) { true }

      it 'freezes the value' do
        expect(result).to be_frozen
      end
    end

    context 'when the definition does not specify immutability' do
      let(:definition_immutable) { false }

      it 'does not freeze the value' do
        expect(result).not_to be_frozen
      end
    end
  end
end
