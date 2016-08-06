describe Holotype do
  # Lets

  let(:attributes)    { Hash[] }
  let(:test_class)    { Class.new described_class }
  let(:test_instance) { test_class.new **attributes }

  # Class Method Tests

  describe '.attribute' do
    junklet :attribute_name, :attribute_value

    let(:attributes)         { Hash attribute_name.to_sym => attribute_value }
    let(:instance_methods)   { test_class.instance_methods false }
    let(:instance_attribute) { test_instance.public_send attribute_name }

    let :instance_attributes do
      Hash attribute_name => attribute_value
    end

    let :test_class do
      Class.new(described_class).tap do |test_class|
        test_class.send :attribute, attribute_name
      end
    end

    it 'creates an accessor for the attribute' do
      expect(instance_methods).to match_array [ attribute_name.to_sym ]
    end

    it 'accepts the attribute in the initializer with a Symbol key' do
      expect(instance_attribute).to eq attribute_value
    end

    it 'freezes the value given in the initializer' do
      expect(instance_attribute).to be_frozen
    end
  end

  # Instance Method Tests

  describe '#frozen?' do
    let(:result) { test_instance.frozen? }

    it 'returns `true`' do
      expect(result).to be true
    end
  end
end
