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

  let :attribute_a_double do
    double name:      attribute_a,
           required?: true
  end

  let :attribute_b_double do
    double name:      attribute_b,
           required?: true
  end

  let :attribute_c_double do
    double name:      attribute_c,
           required?: true
  end

  let :attribute_doubles do
    Hash[
      attribute_a => attribute_a_double,
      attribute_b => attribute_b_double,
      attribute_c => attribute_c_double,
    ]
  end

  let :original_class do
    double attributes: attribute_doubles,
           name:       fake_class_name
  end

  # Class Tests

  it 'is a StandardError' do
    expect(described_class.ancestors).to include StandardError
  end

  # Instance Tests

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

    it 'returns a frozen value' do
      expect(result).to be_frozen
    end
  end
end
