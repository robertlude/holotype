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

  let :options do
    Hash[].tap do |options|
      options[:collection] = option_collection \
        if defined? option_collection

      options[:collection_class] = option_collection_class \
        if defined? option_collection_class

      options[:default] = option_default \
        if defined? option_default

      options[:immutable] = option_immutable \
        if defined? option_immutable

      options[:read_only] = option_read_only \
        if defined? option_read_only

      options[:required] = option_required \
        if defined? option_required

      options[:value_class] = option_value_class \
        if defined? option_value_class
    end
  end

  let :default_conflict_error do
    described_class::DefaultConflictError
  end

  # Class Method Tests

  describe '.new' do
    it 'stores the name' do
      expect(subject.name).to be name
    end

    context 'given no option `required`' do
      it 'provides `false` as a default' do
        expect(subject.required?).to be false
      end
    end

    context 'given option `required`' do
      let(:option_required) { true }

      it 'stores the value' do
        expect(subject.required?).to be option_required
      end
    end

    context 'given option `default` and a block' do
      let(:default_block)  { -> { } }
      let(:option_default) { junk }

      it 'raises an error' do
        expect { subject }.to raise_error default_conflict_error
      end
    end
  end

  # Instance Method Tests

  describe '#required?' do
    let(:result) { subject.required? }

    context 'when the attribute was created with option `required: true`' do
      let(:option_required) { true }

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

  describe '#has_value_class?' do
    let(:result) { subject.has_value_class? }

    context 'when the attribute was created with option `value_class`' do
      junklet :option_value_class

      it 'returns `true`' do
        expect(result).to be true
      end
    end

    context 'when the attribute was not created with option `value_class`' do
      it 'returns `false`' do
        expect(result).to be false
      end
    end
  end

  describe '#value_class' do
    let(:result) { subject.value_class }

    context 'when the attribute was created with option `value_class`' do
      junklet :option_value_class

      it 'returns the given value_class' do
        expect(result).to be option_value_class
      end
    end

    context 'when the attribute was not created with option `value_class`' do
      it 'raises an appropriate error' do
        expect { result }.to raise_error do |error|
          expect(error).to be_a described_class::NoValueClassError
          expect(error.definition).to be subject
        end
      end
    end
  end

  describe '#collection?' do
    let(:result) { subject.collection? }

    context 'when the attribute was created with option `collection: true`' do
      let(:option_collection) { true }

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

  describe '#immutable?' do
    let(:result) { subject.immutable? }

    context 'when the attribute was created with option `immutable: true`' do
      let(:option_immutable) { true }

      it 'returns `true`' do
        expect(result).to be true
      end
    end

    context 'when the attribute was not created with option `immutable: true`' do
      it 'returns `false`' do
        expect(result).to be false
      end
    end
  end

  describe '#read_only?' do
    let(:result) { subject.read_only? }

    context 'when the attribute was created with option `read_only: true`' do
      let(:option_read_only) { true }

      it 'returns `true`' do
        expect(result).to be true
      end
    end

    context 'when the attribute was not created with option `read_only: true`' do
      it 'returns `false`' do
        expect(result).to be false
      end
    end
  end

  describe '#has_collection_class?' do
    let(:result) { subject.has_collection_class? }

    context 'when the attribute was created with option `collection_class`' do
      let(:option_collection_class) { junk }

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

  describe '#collection_class' do
    let(:result) { subject.collection_class }

    context 'when the instance was created with option `collection_class`' do
      junklet(:option_collection_class) { double }

      it 'returns the given `collection_class`' do
        expect(result).to be option_collection_class
      end
    end

    context 'when the instance was not created with option `collection_class`' do
      it 'raises an appropriate error' do
        expect { result }.to raise_error do |error|
          expect(error).to be_a described_class::NoCollectionClassError
          expect(error.definition).to be subject
        end
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
      junklet :option_default

      it 'returns the specified default value' do
        expect(result).to eq option_default
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

    let :test_value_class do
      Class.new(Holotype) { attribute :a }
    end

    context 'when the attribute was created with option `value_class`' do
      let(:option_value_class) { test_value_class }

      it 'converts the value into an instance of that class' do
        expect(result).to be_an option_value_class
        expect(result.a).to be 1
      end
    end

    context 'when the attribute was created without without option `value_class`' do
      it 'returns the frozen given value' do
        expect(result).to be_frozen
        expect(result).to eq value
      end
    end

    context 'when the attribute was created with option `collection: true`' do
      let(:option_collection) { true }
      let(:value)             { [ value_a, value_b ] }
      let(:value_a)           { Hash a: 1 }
      let(:value_b)           { Hash a: 2 }

      it 'returns a collection of frozen objects' do
        expect(result).to all be_frozen
      end

      context 'when the attribute was created with option `collection_class`' do
        let(:option_collection_class) { Set }

        it 'returns an instance of the given collection class' do
          expect(result.class).to be option_collection_class
        end

        context 'when the collection class is `Hash`-like' do
          let(:key_a)                   { "key_a_#{junk}".to_sym }
          let(:key_b)                   { "key_b_#{junk}".to_sym }
          let(:keys)                    { [ key_a, key_b ] }
          let(:option_collection_class) { Hash }

          let :value do
            Hash[
              key_a => value_a,
              key_b => value_b,
            ]
          end

          it 'preserves the given keys' do
            expect(result.keys).to eq keys
          end
        end
      end

      context 'when the attribute was created without option `collection_class`' do
        it 'returns an instance of `Array`' do
          expect(result.class).to be Array
        end
      end

      context 'when the attribute was created with option `value_class`' do
        let(:option_value_class) { test_value_class }

        it 'returns a collection of objects of the given class' do
          expect(result.map &:class).to all be test_value_class
        end
      end

      context 'when the attribute was created without option `value_class`' do
        it 'returns a collection of the original values' do
          expect(result).to eq [ value_a, value_b ]
        end
      end
    end
  end
end
