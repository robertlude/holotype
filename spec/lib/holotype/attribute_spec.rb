describe Holotype::Attribute do
  # Subject

  subject do
    if create_with_value
      described_class.new owner, definition, value: given_value
    else
      described_class.new owner, definition
    end
  end

  # Helpers

  def expect_normalize
    expect(definition)
      .to receive(:normalize)
      .once
      .with(given_value)
      .and_return(normalized_value)
  end

  # Setup

  include_context 'fake definition'

  # Lets

  junklet *%i[
    given_value
    normalized_value
  ]

  let(:create_with_value) { false }
  let(:owner)             { double frozen?: owner_frozen }
  let(:owner_frozen)      { false }

  # Wrappers

  before { expect_normalize if create_with_value }

  # Class Tests

  describe '.new' do
    it 'stores the given owner' do
      expect(subject.owner).to be owner
    end

    it 'stores the given definition' do
      expect(subject.definition).to be definition
    end
  end

  # Instance Tests

  describe '#name' do
    let(:result) { subject.name }

    it 'returns the definition name' do
      expect(result).to be definition_name
    end
  end

  describe '#value' do
    let(:result) { subject.value }

    context 'when created with a value' do
      let(:create_with_value) { true }

      it 'returns the given value' do
        expect(result).to be normalized_value
      end
    end

    context 'when created without a value' do
      junklet :definition_default

      let(:create_with_value) { false }

      it 'returns the default value from the definition' do
        expect(result).to be definition_default
      end
    end
  end

  describe '#value=' do
    let(:result) { subject.value = given_value }

    context 'when the attribute is immutable' do
      let(:definition_immutable) { true }

      it 'raises an error' do
        expect { result }.to raise_error described_class::ImmutableValueError
      end
    end

    context 'when the attribute is not immutable' do
      let(:definition_immutable) { false }

      context 'when the owner is frozen' do
        let(:owner_frozen) { true }

        it 'raises an error' do
          expect { result }
            .to raise_error described_class::FrozenModificationError
        end
      end

      context 'when the owner is not frozen' do
        let(:owner_frozen) { false }

        context 'when the attribute is read only' do
          let(:definition_read_only) { true }

          it 'raises an error' do
            expect { result }.to raise_error described_class::ReadOnlyError
          end
        end

        context 'when the attribute is not read only' do
          let(:definition_read_only) { false }

          it 'normalizes and stores the value' do
            expect_normalize

            result

            expect(subject.value).to eq normalized_value
          end
        end
      end
    end
  end
end
