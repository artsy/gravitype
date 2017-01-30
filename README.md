 ██████╗ ██████╗  █████╗ ██╗   ██╗██╗████████╗██╗   ██╗██████╗ ███████╗
██╔════╝ ██╔══██╗██╔══██╗██║   ██║██║╚══██╔══╝╚██╗ ██╔╝██╔══██╗██╔════╝
██║  ███╗██████╔╝███████║██║   ██║██║   ██║    ╚████╔╝ ██████╔╝█████╗
██║   ██║██╔══██╗██╔══██║╚██╗ ██╔╝██║   ██║     ╚██╔╝  ██╔═══╝ ██╔══╝
╚██████╔╝██║  ██║██║  ██║ ╚████╔╝ ██║   ██║      ██║   ██║     ███████╗
 ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝  ╚═══╝  ╚═╝   ╚═╝      ╚═╝   ╚═╝     ╚══════╝

 Typing support for Gravity, Artsy’s Core API. It’s not actually bound to Gravity, though, it’s more of a Mongoid addon
 that needs finishing and some more generalization to be useful to other projects.

## Status

- [x] Expresses interfaces for pre-existing data in a database.
- [x] DSL to describe interfaces.
- [ ] Make recommendations about what types to add to which fields, based on pre-existing data.
- [ ] Tool to apply recommendations in an automated fashion.
- [ ] Export interfaces, in a format like JSON Schema, so it can be used to generate TypeScript interfaces etc.
- [ ] Add data validations to model on definition and allow checing validity of existing data.

## DSL

To specify type information, you can use the `Gravitype::Type::Sugar` module.

```ruby
include Gravitype::Type::Sugar
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

## License

The gem is available as open source under the terms of the [MIT License](LICENSE).

