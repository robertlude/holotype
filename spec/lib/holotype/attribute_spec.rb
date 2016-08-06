describe Holotype::Attribute do
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
    Hash[
      required: false
    ]
  end

  # Class Method Tests

  describe '.new' do
    it 'stores the name' do
      expect(subject.name).to be name
    end

    context 'given no block' do
      let(:default_block) { }

      it 'does not store a default proc' do
        expect(subject.default_proc).to be nil
      end
    end

    context 'given a block' do
      let(:default_block) { -> { :value_from_default_block } }

      it 'stores the block as `default_proc`' do
        expect(subject.default_proc).to be default_block
      end
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
  end
end
