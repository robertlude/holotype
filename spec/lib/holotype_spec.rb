describe Holotype do
  # Constants

  ATTRIBUTE_IDS = [ :a, :b, :c ].freeze

  # Helpers

  def map_attributes
    Hash[
      ATTRIBUTE_IDS.map do |id|
        key   = id
        value = yield id

        [key, value]
      end
    ]
  end

  def junk_map_attributes key
    map_attributes { |id| "attribute_#{id}_#{key}_#{junk}".to_sym }
  end

  def mock_attribute_objects
    base_options = if defined? default_attribute_options
                     default_attribute_options
                   else
                     Hash[]
                   end

    final_options = if make_immutable
                      Hash immutable: true
                    else
                      Hash[]
                    end

    ATTRIBUTE_IDS.each do |id|
      options = [
                  base_options,
                  attribute_options[id],
                  final_options,
                ].reduce :merge

      expect(described_class::Attribute::Definition)
        .to receive(:new)
        .with(
          attribute_names[id],
          **options,
          &attribute_blocks[id]
        )
        .and_return attribute_object_doubles[id]
    end
  end

  # Lets

  let(:attribute_blocks)      { map_attributes { |_| } }
  let(:attribute_defaults)    { junk_map_attributes 'default_value' }
  let(:attribute_names)       { junk_map_attributes 'name' }
  let(:attribute_options)     { map_attributes { |_| Hash[] } }
  let(:given_attributes)      { junk_map_attributes 'given_value' }
  let(:make_immutable)        { false }
  let(:normalized_attributes) { junk_map_attributes 'normalized_value' }
  let(:test_class_name)       { "TestClass_#{junk}" }
  let(:test_instance)         { test_class.new **instance_attributes }

  let :attribute_object_doubles do
    map_attributes do |id|
      is_required = attribute_options[id].fetch(:required, false)

      double default:    attribute_defaults[id],
             immutable?: make_immutable,
             normalize:  normalized_attributes[id],
             required?:  is_required
    end
  end

  let :instance_attribute_values do
    map_attributes { |id| test_instance.send attribute_names[id] }
  end

  let :instance_attributes do
    Hash[
      ATTRIBUTE_IDS.map do |id|
        name  = attribute_names[id]
        value = given_attributes[id]

        [name, value]
      end
    ]
  end

  let :test_class do
    Class
      .new
      .extend(described_class)
      .tap do |klass|
        klass.send :make_immutable if make_immutable

        klass.send :default_attribute_options, **default_attribute_options \
          if defined? default_attribute_options

        ATTRIBUTE_IDS.each do |id|
          klass.send :attribute,
                     attribute_names[id],
                     **attribute_options[id],
                     &attribute_blocks[id]
        end

        allow(klass)
          .to receive(:name)
          .and_return(test_class_name)
      end
  end

  # Class Method Tests

  describe '.attribute' do
    it 'creates a Holotype::Attribute::Definition object for each attribute' do
      mock_attribute_objects
      test_class
    end

    it 'generates a getter for each attribute' do
      attribute_names.values.each do |attribute_name|
        expect(test_instance).to respond_to attribute_name
      end
    end

    describe 'generated getter' do
      before { mock_attribute_objects }

      shared_examples 'normalized values' do
        it 'returns the normalized value' do
          map_attributes do |attribute_id|
            expect(test_instance.public_send attribute_names[attribute_id])
              .to eq normalized_attributes[attribute_id]
          end
        end
      end

      context 'when the attribute has a value' do
        include_examples 'normalized values'

        it 'consults the associated Attribute::Definition object to normalize the value' do
          map_attributes do |attribute_id|
            expect(attribute_object_doubles[attribute_id])
              .to receive(:normalize)
              .with(given_attributes[attribute_id])
          end

          test_instance
        end
      end

      context 'when the attribute does not have a value' do
        let(:instance_attributes) { Hash[] }

        include_examples 'normalized values'

        it 'consults the associated Attribute::Definition object to normalize the value' do
          map_attributes do |attribute_id|
            expect(attribute_object_doubles[attribute_id])
              .to receive(:normalize)
              .with(attribute_defaults[attribute_id])

            test_instance.public_send attribute_names[attribute_id]
          end
        end

        it 'consults the associated Attribute::Definition object for a default value' do
          map_attributes do |attribute_id|
            test_instance.public_send attribute_names[attribute_id]

            expect(attribute_object_doubles[attribute_id])
              .to have_received(:default)
              .with(test_instance)
          end
        end
      end
    end
  end

  describe '.make_immutable' do
    let(:make_immutable) { true }

    it 'disallows subclassing' do
      expect { Class.new test_class }
        .to raise_error described_class::InheritanceDisallowedError
    end

    it 'prevents changing values' do
      ATTRIBUTE_IDS.each do |id|
        expect { test_instance.public_send "#{attribute_names[id]}=", junk }
          .to raise_error described_class::Attribute::ImmutableValueError
      end
    end

    context 'when attributes have already been defined' do
      let(:make_immutable) { false }

      let :test_class do
        super().tap { |test_class| test_class.make_immutable }
      end

      it 'raises an error' do
        expect { test_class }
          .to raise_error described_class::AttributesAlreadyDefinedError
      end
    end
  end

  describe '.immutable?' do
    let(:result) { test_class.immutable? }

    context 'when the class is immutable' do
      let(:make_immutable) { true }

      it 'returns `true`' do
        expect(result).to be true
      end
    end

    context 'when the class is not immutable' do
      it 'returns `false`' do
        expect(result).to be false
      end
    end
  end

  describe '.default_attribute_options' do
    let(:default_attribute_options) { Hash junk.to_sym => junk }

    it 'uses the supplied options as defaults' do
      mock_attribute_objects
      test_class
    end

    context 'when called twice'
  end

  # Instance Method Tests

  describe '#initialize' do
    it 'accepts attribute values' do
      expect(instance_attribute_values).to eq given_attributes
    end

    it 'freezes values given in the initializer' do
      expect(instance_attribute_values.values).to all be_frozen
    end

    context 'with required attributes' do
      let(:required_attributes) { attribute_names.values_at *required_ids }
      let(:required_ids)        { ATTRIBUTE_IDS.sample 2 }

      before do
        required_ids.each { |id| attribute_options[id].merge! required: true }
      end

      context 'when required attribute values are supplied' do
        let(:instance_attributes) { Hash[] }

        it 'raises an error' do
          error_type = described_class::MissingRequiredAttributesError

          expect { test_instance }.to raise_error error_type do |error|
            expect(error.attributes).to match_array required_attributes
            expect(error.original_class).to be test_class
          end
        end
      end

      context 'when each required value is supplied' do
        it 'does not raise an error' do
          expect { test_instance }.not_to raise_error
        end
      end
    end
  end

  describe '#frozen?' do
    let(:result) { test_instance.frozen? }

    it 'returns `true`' do
      expect(result).to be true
    end
  end

  describe '#==' do
    let(:other_instance) { test_class.new **other_attributes }
    let(:result)         { test_instance == other_instance }

    context 'when the objects have equal attribute values' do
      let(:other_attributes) { instance_attributes }

      it 'returns `true`' do
        expect(result).to be true
      end
    end

    context 'when the objects have differing attribute values' do
      let(:other_given_attributes) { junk_map_attributes 'other_value' }

      let :other_attributes do
        Hash[
          ATTRIBUTE_IDS.map do |id|
            name  = attribute_names[id]
            value = other_given_attributes[id]

            [name, value]
          end
        ]
      end

      it 'returns `false`' do
        expect(result).to be false
      end
    end
  end

  describe '#to_hash' do
    junklet :test_value_class_attribute_value

    let(:attribute_with_class) { ATTRIBUTE_IDS.sample }
    let(:result)               { test_instance.to_hash }

    let :test_value_class_attribute_name do
      "test_value_class_attribute_name_#{junk}".to_sym
    end

    let :test_value_class do
      Class.new.extend(described_class).tap do |klass|
        klass.send :attribute, test_value_class_attribute_name
      end
    end

    let :attribute_options do
      super().tap do |attribute_options|
        attribute_options
        attribute_options[attribute_with_class] = Hash class: test_value_class
        attribute_options
      end
    end

    let :given_attributes do
      super().tap do |given_attributes|
        given_attributes[attribute_with_class] = Hash[
          test_value_class_attribute_name => test_value_class_attribute_value
        ]
      end
    end

    it 'returns a hash of attributes and values' do
      expect(result).to eq instance_attributes
    end

    it 'returns a hash acceptable for creating an equal instance' do
      expect(test_class.new result).to eq test_instance
    end
  end

  describe '#with' do
    let(:missing_attribute) { ATTRIBUTE_IDS.sample }
    let(:result)            { test_instance.with new_attributes }

    let :new_values do
      junk_map_attributes('new_value').delete_if do |attribute_id|
        attribute_id == missing_attribute
      end
    end

    let :new_attributes do
      Hash[
        new_values.keys.map do |attribute_id|
          name  = attribute_names[attribute_id]
          value = new_values[attribute_id]

          [name, value]
        end
      ]
    end

    it 'returns an instance with specified attributes set and unspecified attributes inherited' do
      expect(result.to_hash).to eq instance_attributes.merge new_attributes
    end
  end

  describe '#inspect' do
    let(:result) { test_instance.inspect }

    let :inner_data_string do
      /^#{test_class.name}\((.*)\)$/
        .match(result)
        .[](1)
    end

    let :data do
      Hash[
        inner_data_string
          .split(', ')
          .map { |pair| pair.split ': ' }
      ]
    end

    let :expected_data do
      Hash[
        instance_attributes.map do |key, value|
          [
            key.to_s,
            value.inspect,
          ]
        end
      ]
    end

    it 'returns a string containing the class name and each attribute/value ' \
       'pair' do
      expect(data).to match expected_data
    end
  end
end
