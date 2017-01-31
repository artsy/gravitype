```
 ██████╗ ██████╗  █████╗ ██╗   ██╗██╗████████╗██╗   ██╗██████╗ ███████╗
██╔════╝ ██╔══██╗██╔══██╗██║   ██║██║╚══██╔══╝╚██╗ ██╔╝██╔══██╗██╔════╝
██║  ███╗██████╔╝███████║██║   ██║██║   ██║    ╚████╔╝ ██████╔╝█████╗
██║   ██║██╔══██╗██╔══██║╚██╗ ██╔╝██║   ██║     ╚██╔╝  ██╔═══╝ ██╔══╝
╚██████╔╝██║  ██║██║  ██║ ╚████╔╝ ██║   ██║      ██║   ██║     ███████╗
 ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝  ╚═══╝  ╚═╝   ╚═╝      ╚═╝   ╚═╝     ╚══════╝
```

Typing support for Gravity, Artsy’s Core API. It’s not actually bound to Gravity, though, it’s more of a Mongoid addon
that needs finishing and some more generalization to be useful to other projects.

It’s current main focus is to provide type information about payloads to clients such as [metaphysics]. It does this by
providing type information of model properties exported through the use of `json_fields`, including the various scopes,
such as `all`, `short`, etc, such that the clients using these interfaces can only use the properties actually provided.

Additionally it can be used as a starting point for various other type information related tasks, such as validating
existing and incoming data.

## Status

- [x] Expresses interfaces for pre-existing data in a database.
- [x] DSL to describe interfaces.
- [ ] Make recommendations about what types to add to which fields, based on pre-existing data.
- [ ] Tool to apply recommendations in an automated fashion.
- [ ] Export interfaces, in a format like JSON Schema, so it can be used to generate TypeScript interfaces etc.
- [ ] Add data validations to model on definition and allow checing validity of existing data.

## DSL

To specify type information, you can use the `Gravitype::Type::DSL` module.

```ruby
include Gravitype::Type::DSL
```

The bang methods are used to define types.

```ruby
String!                    # => #<Type:String>
```

You can allow multiple types by creating a union of them.

```ruby
String! | Integer!         # => #<Type:Union [#<Type:String>, #<Type:Integer>]>
```

Sometimes a field can also be null.

```ruby
String! | Integer! | null  # => #<Type:Union [#<Type:String>, , #<Type:Integer>, #<Type:NilClass>]>
```

If you’re defining a single type, but nullable, use the question mark methods instead.

```ruby
String?                    # => #<Type:Union [#<Type:String>, #<Type:NilClass>]>
```

You can have collections too, you use them like you normally would.

```ruby
Set!(String!, Integer!)    # => #<Type:Set [#<Type:Union [#<Type:String>, #<Type:Integer>]>]>
Array!(String!, Integer!)  # => #<Type:Array [#<Type:Union [#<Type:String>, #<Type:Integer>]>]>
Hash!(String! => Integer!) # => #<Type:Hash { [#<Type:Union [#<Type:String>]>] => [#<Type:Union [#<Type:Integer>]>] }>
```

## Mongoid

_NOTE: This is not yet implemented._

```ruby
class Artist
  include Mongoid::Document
  include Gravitype::Type::DSL

  field :name, type: String?
  field :image_versions, type: Array!(Symbol!)
  field :image_urls, type: Hash!(String! => String!)
end
```

The type information is stored for later reflection, for example when generating a JSON Schema, and model validations
are added to ensure the data conforms to the type.

## License

The gem is available as open source under the terms of the [MIT License](LICENSE).

[metaphysics]: http://github.com/artsy/metaphysics
