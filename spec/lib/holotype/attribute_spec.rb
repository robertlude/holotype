describe Holotype::Attribute do
  # Subject

  subject do
    if create_with_value
      described_class.new owner, definition, value: given_value
    else
      described_class.new owner, definition
    end
  end

  # Lets

  junklet *%i[
    attribute_name
    given_value
    normalized_value
  ]

  let(:attribute_read_only) { false }
  let(:create_with_value)   { true }
  let(:owner)               { double }

  let :definition do
    double(
      name:       attribute_name,
      read_only?: attribute_read_only,
    )
  end

  # Wrappers

  before do
    if create_with_value
      expect(definition)
        .to receive(:normalize)
        .once
        .with(given_value)
        .and_return(normalized_value)
    end
  end

  # Tests

  describe '#name' do
    let(:result) { subject.name }

    it 'returns the name according to the definition' do
      expect(result).to eq attribute_name
    end
  end

  describe '#value' do
    let(:result) { subject.value }

    context 'when there is a stored value' do
      it 'returns the stored value' do
        expect(result).to eq normalized_value
      end
    end

    context 'when there is no stored value' do
      junklet *%i[
        default_value
        normalized_default_value
      ]

      let(:create_with_value) { false }

      before do
        expect(definition)
          .to receive(:default)
          .once
          .with(owner)
          .and_return(default_value)

        expect(definition)
          .to receive(:normalize)
          .once
          .with(default_value)
          .and_return(normalized_default_value)
      end

      it 'returns the default according to the definition' do
        expect(result).to eq normalized_default_value
      end

      it 'stores the default value on the first call' do
        subject.value
        subject.value
      end
    end
  end

  describe '#value=' do
    junklet *%i[
      new_normalized_value
      new_value
    ]

    let(:result) { subject.public_send :value=, new_value }

    context 'when the attribute is not read only' do
      before do
        expect(definition)
          .to receive(:normalize)
          .once
          .with(new_value)
          .and_return(new_normalized_value)
      end

      it 'stores the normalized value' do
        result
        expect(subject.value).to eq new_normalized_value
      end
    end

    context 'when the attribute is read only' do
      let(:attribute_read_only) { true }
      let(:error_class)         { described_class::ReadOnlyError }

      it 'raises an error' do
        expect { result }.to raise_error error_class do |error|
          expect(error.name).to eq attribute_name
        end
      end
    end
  end
end
