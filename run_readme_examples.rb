#!/usr/bin/env ruby

# Ruby standard libraries

require 'set'

# Gems

require 'colorize'

# Local files

require_relative './lib/holotype'

# Example helper

def example name, &example_block
  puts name.blue
  puts
  example_block[]
  puts
end

# Examples

example 'Usage' do
  class Example < Holotype
    attribute :my_first_attribute
  end

  example = Example.new my_first_attribute: 'some value'

  puts "My first attribute's value: #{example.my_first_attribute}"
end

example 'Collections' do
  class CollectionExample < Holotype
    attribute :an_array_collection,
              collection: true

    attribute :a_set_collection,
              collection_class: Set

    attribute :a_hash_collection,
              collection_class: Hash
  end

  no_initial_value_example = CollectionExample.new
  initial_value_example    = CollectionExample.new(
                               an_array_collection: [1, 2, 2, 3, 3, 3],
                             )
  set_value_example        = CollectionExample.new(
                               a_set_collection: [1, 2, 2, 3, 3, 3],
                             )
  hash_value_example       = CollectionExample.new(
                               a_hash_collection: Hash[a: 1, b: 2, c: 3],
                             )

  puts "no_initial_value_example.an_array_collection.inspect:"
  puts "  #{no_initial_value_example.an_array_collection.inspect}"
  puts
  puts "initial_value_example.an_array_collection.inspect:"
  puts "  #{initial_value_example.an_array_collection.inspect}"
  puts
  puts "set_value_example.a_set_collection.inspect:"
  puts "  #{set_value_example.a_set_collection.inspect}"
  puts
  puts "hash_value_example.a_hash_collection.inspect:"
  puts "  #{hash_value_example.a_hash_collection.inspect}"
end

example 'Defaults' do
  class DefaultExample < Holotype
    attribute :static_default,
              default: 1234

    attribute(:dynamic_default) { static_default * 2 }
  end

  example = DefaultExample.new

  puts "example.static_default  = #{example.static_default}"
  puts "example.dynamic_default = #{example.dynamic_default}"
end

example 'Read Only Attributes' do
  class ReadOnlyExample < Holotype
    attribute :read_only_attribute,
              read_only: true
  end

  write_error_example = ReadOnlyExample.new read_only_attribute: 123

  begin
    write_error_example.read_only_attribute = 456
  rescue Holotype::Attribute::ReadOnlyError => error
    puts "Read only error: #{error.message}"
  end
end

example 'Immutable Objects' do
  class ImmutableExampleChild < Holotype
    attribute :some_attribute
  end

  class ImmutableExample < Holotype
    make_immutable

    attribute :basic_attribute

    attribute :collection_attribute,
              collection: true

    attribute :child_attribute,
              value_class: ImmutableExampleChild
  end

  immutable_example = ImmutableExample.new(
                        basic_attribute:      123,
                        child_attribute:      Hash[some_attribute: 'hello'],
                        collection_attribute: %i[x y z]
                      )

  immutable_example.basic_attribute = 456

  immutable_example.collection_attribute << :w

  immutable_example.child_attribute.some_attribute = 'goodbye'
end
