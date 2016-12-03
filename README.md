# Holotype

> hol·o·type
>
> noun (*BOTANY* *ZOOLOGY*)
>
> a single type specimen upon which the description and name of a new species is based.

Simply simple models

## Usage

**TODO** *Coming soon!*

### Examples

```ruby
class Example < Holotype
  # TODO
end
```

#### Immutable Objects

```ruby
class ImmutableExample < Holotype
  make_immutable
end
```

### Attributes Options

| Option             | Description                                                              | Default  |
| ------------------ | ------------------------------------------------------------------------ | -------- |
| `collection_class` | Specifies the class to use for the collection                            | `Array`  |
| `collection`       | Specifies whether or not the attribute is a collection                   | `false`  |
| `default`          | Specifies a static value to use as a default for the value               | **none** |
| `immutable`        | Specifies whether or not the attribute is immutable                      | `false`  |
| `read_only`        | Specifies whether or not the attribute is read only                      | `false`  |
| `required`         | Specifies whether or not the attribute is required during initialization | `false`  |
| `value_class`      | Specifies the class to use for the value                                 | **none** |
| (given block)      | Specifies a block to use for dynamic default assignment                  | **none** |

## TODO

### v1.0 - Initial Release

* Finish this readme
* Scan code for `TODO`s
  * `README.md`
* Handle when `default` and `required` are both specified. One of:
  * Raise error
  * Ignore required
* Object methods
  * `#clone` (conventionally shallow copy of internal state)
  * `#dup` (conventionally calls `.new` to create new object)
  * `#freeze` (should freeze attribute values as well)
    * Deep freeze?
    * Deep freeze option?
  * `#hash`
  * `#inspect`
* Accept objects of same class as input

### v1.1 - Feature Release

* Allow multiple attributes to be defined at once with the same options
* Add `[]` value access
* Consider fate of Holotype data store patches in other projects. One of:
  * Move to this gem
  * Move to companion gem
* Add hooks
  * `before_initialize`
  * `after_initialize`
* Update `Holotype::Attribute::Definition`
  * Add attribute option `allow_nil` (default: `true`)
  * Add attribute option `serialize` (default: `true`)
  * Add attribute option `frozen` (default: `false`)
  * Add attribute option `initializable` (default: `true`)
  * Add attribute option `auto` (default: `nil`; allowed values: `uuid4`)
  * Add custom normalizers
  * Add parent designation

### v1.2+ - Performance Release

* Rewrite in C!
