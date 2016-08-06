describe Holotype::MissingRequiredAttributesError do
  # Subject

  subject { described_class.new original_class, missing_attributes }

  # Lets

  let(:attribute_a)         { "attribute_a_#{junk}".to_sym }
  let(:attribute_b)         { "attribute_b_#{junk}".to_sym }
  let(:attribute_c)         { "attribute_c_#{junk}".to_sym }
  let(:fake_class_name)     { Array(rand 2..4) { junk.capitalize }.join '::' }
  let(:missing_attributes)  { [ attribute_a, attribute_b ] }
  let(:required_attributes) { [ attribute_a, attribute_b, attribute_c ] }

  let :original_class do
    double __required_attributes: required_attributes,
           name:                  fake_class_name
  end

  # Instance Method Tests

  describe '#attributes' do
    let(:result) { subject.attributes }

    it 'returns the supplied attributes' do
      expect(result).to be missing_attributes
    end
  end

  describe '#original_class' do
    let(:result) { subject.original_class }

    it 'returns the supplied attribute' do
      expect(result).to be original_class
    end
  end

  describe '#message' do
    let(:result) { subject.message }

    let :expected_error_message do
      "Class `#{fake_class_name}` requires the following attributes:\n" \
      "  * #{attribute_a}\n" \
      "  * #{attribute_b}\n" \
      "  * #{attribute_c}\n" \
      "\n" \
      "Missing attributes:\n" \
      "  * #{attribute_a}\n" \
      "  * #{attribute_b}"
    end

    it 'returns a descriptive error message' do
      expect(result).to eq expected_error_message
    end
  end
end