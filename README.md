# Holotype

[![Build Status](https://travis-ci.org/robertlude/holotype.svg?branch=master)](https://travis-ci.org/robertlude/holotype)

> hol·o·type
>
> noun (*BOTANY* *ZOOLOGY*)
>
> a single type specimen upon which the description and name of a new species is
> based.

Simply simple models

## This is a pre-release version!

It should work as advertised generally. There are a couple small issues left to
tackle as I move toward v1.0.0:

* [ ] Finishing the documentation
* [ ] Fixing a small bug where an incorrect-but-related error is raised instead
      of the intended error which is more descriptive
* [ ] Finish verifying the readme examples
* [ ] Final scan for `TODO`s

If you encounter anything unrelated to the above, please file an issue.

## Usage

Extend `Holotype` to create a model.

```ruby
class Example
  extend Holotype

  attribute :my_first_attribute
end

example = Example.new my_first_attribute: 'some value'

puts "My first attribute's value: #{example.my_first_attribute}"
```

Output:

```
My first attribute's value: some value
```

### Attribute Options

| Option             | Description                                                              | Default  |                                   |
| ------------------ | ------------------------------------------------------------------------ | -------- | --------------------------------- |
| `collection_class` | Specifies the class to use for the collection                            | `Array`  | [Examples](#collections)          |
| `collection`       | Specifies whether or not the attribute is a collection                   | `false`  | [Examples](#collections)          |
| `default`          | Specifies a static value to use as a default for the value               | **none** | [Examples](#defaults)             |
| `read_only`        | Specifies whether or not the attribute is read only                      | `false`  | [Examples](#read-only-attributes) |
| `required`         | Specifies whether or not the attribute is required during initialization | `false`  | [Examples](#required)             |
| `value_class`      | Specifies the class to use for the value                                 | **none** | [Examples](#value_class)          |
| (given block)      | Specifies a block to use for dynamic default assignment                  | **none** | [Examples](#defaults)             |

### Collections

Use options `collection` and `collection_class` to control how collections are
handled. Note that providing a `collection_class` automatically sets
`collection: true`.

```ruby
class CollectionExample
  extend Holotype

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
```

Output:

```
no_initial_value_example.an_array_collection.inspect:
  []

initial_value_example.an_array_collection.inspect:
  [1, 2, 2, 3, 3, 3]

set_value_example.a_set_collection.inspect:
  #<Set: {1, 2, 3}>

hash_value_example.a_hash_collection.inspect:
  {:a=>1, :b=>2, :c=>3}
```

### Defaults

Use option `default` *or* provide a block to create default values. There is a
difference between `default` and providing a block, however.

Providing option `default` will use the same instance of that value for the
default of each object. This is handy for static values. It should be noted,
however, that because it is the same instance for every object, that
modifications to the value object itself will apply to every object using that
default.

Providing a block will defer until the first time the option is accessed or
serialized, and will run in the context of the object itself. This is handy for
calculating values based on other attributes or even simply creating unique
instances of default values. These default blocks are run only once.

Providing both a `default` option and a block will result in an error.

Providing either type of default and a `required` option also result in an
error.

```ruby
class DefaultExample
  extend Holotype

  attribute :static_default,
            default: 1234

  attribute(:dynamic_default) { static_default * 2 }
end

example = DefaultExample.new

puts "example.static_default  = #{example.static_default}"
puts "example.dynamic_default = #{example.dynamic_default}"
```

Output:

```
example.static_default  = 1234
example.dynamic_default = 2468
```

### Read Only Attributes

Use option `read_only: true` to prevent changing the value of an attribute.

```ruby
class ReadOnlyExample
  extend Holotype

  attribute :read_only_attribute,
            read_only: true
end

write_error_example = ReadOnlyExample.new read_only_attribute: 123

begin
  write_error_example.read_only_attribute = 456
rescue Holotype::Attribute::ReadOnlyError => error
  puts "Read only error: #{error.message}"
end
```

#### Immutable Objects

```ruby
class ImmutableExampleChild
  extend Holotype

  attribute :some_attribute
end

class ImmutableExample
  extend Holotype

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
```
