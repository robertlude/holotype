shared_context 'fake value normalizer' do
  # Setup

  include_context 'fake definition'

  # Lets

  junklet *%i[
    normalized_value_a
    normalized_value_b
    value_a
    value_b
  ]

  let :value_normalizer do
    Holotype::ValueNormalizer.new definition
  end

  # Wrappers

  before do
    allow(Holotype::ValueNormalizer)
      .to receive(:new)
      .with(definition)
      .and_return(value_normalizer)

    allow(value_normalizer)
      .to receive(:normalize)
      .with(value_a)
      .and_return(normalized_value_a)

    allow(value_normalizer)
      .to receive(:normalize)
      .with(value_b)
      .and_return(normalized_value_b)
  end
end
