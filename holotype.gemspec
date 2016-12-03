require File.expand_path '../lib/holotype/version', __FILE__

Gem::Specification.new do |gem_specification|
  # Data

  basic_attributes = Hash[
    author:                'Robert Lude',
    date:                  '2016-08-06',
    email:                 'rob@ertlu.de',
    homepage:              'https://www.github.com/robertlude/holotype',
    license:               'MIT',
    name:                  'holotype',
    required_ruby_version: '~> 2.1',
    summary:               'Simple models',
    version:               Holotype::VERSION,
  ]

  filename_base = 'lib/holotype'

  file_list = %w[
    attribute
    attribute/definition
    attribute/definition/default_conflict_error
    attribute/definition/no_collection_class_error
    attribute/definition/no_value_class_error
    attribute/immutable_value_error
    attribute/read_only_error
    attributes_already_defined_error
    collection_normalizer
    inheritance_disallowed_error
    missing_required_attributes_error
    value_normalizer
    version
  ]

  dependencies = Hash[
    development: Hash[
      byebug:             nil,
      memorandum:         '~> 2.1.2',
      rspec:              '~> 3.0',
      :'rspec-junklet' => '~> 2.0',
    ],
    runtime: Hash[
    ],
  ]

  # Value Assignment

  require_gems = -> (environment) do
    dependencies[environment].each do |gem_name, version|
      gem_specification.public_send "add_#{environment}_dependency",
                                    gem_name,
                                    version
    end
  end

  basic_attributes.each { |key, value| gem_specification.send "#{key}=", value }

  gem_specification.files = file_list
                              .map { |file| "/#{file}" }
                              .unshift('')
                              .map { |file| "#{filename_base}#{file}.rb" }

  require_gems[:runtime]
  require_gems[:development]
end
