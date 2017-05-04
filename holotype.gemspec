require File.expand_path '../lib/holotype/version', __FILE__

Gem::Specification.new do |gemspec|
  # Basic Attributes

  Hash[
    author:                'Robert Lude',
    date:                  '2017-05-01',
    email:                 'rob@ertlu.de',
    homepage:              'https://www.github.com/robertlude/holotype',
    license:               'MIT',
    name:                  'holotype',
    required_ruby_version: '~> 2.1',
    summary:               'Simple models',
    version:               Holotype::VERSION,
  ].each { |attribute, value| gemspec.public_send "#{attribute}=", value }

  # File List

  %w[
    attribute
    attribute/definition
    attribute/definition/default_conflict_error
    attribute/definition/no_collection_class_error
    attribute/definition/no_value_class_error
    attribute/definition/required_conflict_error
    attribute/frozen_modification_error
    attribute/immutable_value_error
    attribute/read_only_error
    attributes_already_defined_error
    collection_normalizer
    collection_normalizer/expected_array_like_collection_error
    collection_normalizer/expected_hash_like_collection_error
    inheritance_disallowed_error
    missing_required_attributes_error
    value_normalizer
    version
  ] .map { |file| "/#{file}" }               # prepend each with '/'
    .unshift('')                             # add a blank entry with no '/'
    .map { |file| "lib/holotype#{file}.rb" } # concatenate the final name
    .tap { |files| gemspec.files = files }   # set the file list

  # Dependencies

  Hash[
    development: Hash[
      byebug:             '~> 9.0',
      rspec:              '~> 3.0',
      :'rspec-junklet' => '~> 2.0',
    ],
    runtime: Hash[
      memorandum: '~> 2.1.2',
    ],
  ].each do |environment, dependencies|
    dependencies.each do |gem_name, version|
      gemspec.public_send "add_#{environment}_dependency",
                          gem_name,
                          version
    end
  end
end
