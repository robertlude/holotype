describe Holotype::Attribute::Definition do
  # Subject

  subject do
    if default_block
      described_class.new name, **options, &default_block
    else
      described_class.new name, **options
    end
  end

  # Lets

  let(:default_block) { }
  let(:name)          { "name_#{junk}".to_sym }
  let(:options)       { Hash[] }

  let :default_conflict_error do
    described_class::DefaultConflictError
  end

  # Class Method Tests

  describe '.new' do
    it 'stores the name' do
      expect(subject.name).to be name
    end

    context 'given no option `required`' do
      let(:options) { super().delete_if { |key, _| key == :required } }

      it 'provides `false` as a default' do
        expect(subject.required?).to be false
      end
    end

    context 'given option `required`' do
      let(:options)  { super().merge required: required }
      let(:required) { true }

      it 'stores the value' do
        expect(subject.required?).to be required
      end
    end

    context 'given option `default` and a block' do
      let(:default_block) { -> { } }
      let(:options)       { Hash default: junk }

      it 'raises an error' do
        expect { subject }.to raise_error default_conflict_error
      end
    end
  end

  # Instance Method Tests

  describe '#required?' do
    let(:result) { subject.required? }

    context 'when the attribute was created with option `required: true`' do
      let(:options) { Hash required: true }

      it 'returns `true`' do
        expect(result).to be true
      end
    end

    context 'when the attribute was not created with option `required: true`' do
      it 'returns `false`' do
        expect(result).to be false
      end
    end
  end

  describe '#has_class?' do
    let(:result) { subject.has_class? }

    context 'when the attribute was created with option `class`' do
      let(:options) { Hash class: junk }

      it 'returns `true`' do
        expect(result).to be true
      end
    end

    context 'when the attribute was not created with option `class`' do
      it 'returns `false`' do
        expect(result).to be false
      end
    end
  end

  describe '#collection?' do
    let(:result) { subject.collection? }

    context 'when the attribute was created with option `collection: true`' do
      let(:options) { Hash collection: true }

      it 'returns `true`' do
        expect(result).to be true
      end
    end

    context 'when the attribute was not created with option `collection: true`' do
      it 'returns `false`' do
        expect(result).to be false
      end
    end
  end

  describe '#has_collection_class?' do
    let(:result) { subject.has_collection_class? }

    context 'when the attribute was created with option `collection_class`' do
      let(:options) { Hash collection_class: junk }

      it 'returns `true`' do
        expect(result).to be true
      end
    end

    context 'when the attribute was not created with option `collection_class`' do
      it 'returns `false`' do
        expect(result).to be false
      end
    end
  end

  describe '#default' do
    let(:receiver) { double x: 2 }
    let(:result)   { subject.default receiver }

    context 'when the attribute was created with a block' do
      let :default_block do
        -> do
          BlockWatcher.record_call
          x ** 4
        end
      end

      it 'lazily calls the block in the context of the receiver' do
        subject # initialize subject

        expect(BlockWatcher.total_calls).to be 0
        expect(result).to be 16
        expect(BlockWatcher.total_calls).to be 1
      end
    end

    context 'when the attribute was created with option `default`' do
      junklet :default

      let(:options) { Hash default: default }

      it 'returns the specified default value' do
        expect(result).to eq default
      end
    end

    context 'when the attribute was not created with either type of default' do
      it 'returns `nil`' do
        expect(result).to be nil
      end
    end
  end

  describe '#normalize' do
    let(:result) { subject.normalize value }
    let(:value)  { Hash a: 1 }

    let :attribute_class do
      Class.new(Holotype) { attribute :a }
    end

    context 'when the attribute was created with option `class`' do
      let(:options) { Hash class: attribute_class }

      it 'converts the value into an instance of that class' do
        expect(result).to be_a attribute_class
        expect(result.a).to be 1
      end
    end

    context 'when the attribute was created without without option `class`' do
      it 'returns the frozen given value' do
        expect(result).to be_frozen
        expect(result).to eq value
      end
    end

    context 'when the attribute was created with option `collection: true`' do
      let(:options) { Hash collection: true }
      let(:value)   { [ value_a, value_b ] }
      let(:value_a) { Hash a: 1 }
      let(:value_b) { Hash a: 2 }

      it 'returns a collection of frozen objects' do
        expect(result).to all be_frozen
      end

      context 'when the attribute was created with option `collection_class`' do
        let(:collection_class) { Set }

        let :options do
          super().merge collection_class: collection_class
        end

        it 'returns an instance of the given collection class' do
          expect(result.class).to be collection_class
        end
      end

      context 'when the attribute was created without option `collection_class`' do
        it 'returns an instance of `Array`' do
          expect(result.class).to be Array
        end
      end

      context 'when the attribute was created with option `class`' do
        let(:options) { super().merge class: attribute_class }

        it 'returns a collection of objects of the given class' do
          expect(result.map &:class).to all be attribute_class
        end
      end

      context 'when the attribute was created without option `class`' do
        it 'returns a collection of the original values' do
          expect(result).to eq [ value_a, value_b ]
        end
      end
    end
  end
end
