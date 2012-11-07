# maybe-chain

## Installation

Add this line to your application's Gemfile:

    gem 'maybe-chain'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install maybe-chain

## Usage

```ruby
m1 = "a".to_maybe.upcase.gsub(/A/, "B")

maybe(m1) do |str|
  puts str # => B
end

m2 = nil.to_maybe.upcase.gsub(/A/, "B")

maybe(m2) do |str|
  puts str # No Execute
end

maybe(m2, "a") do |str|
  puts str # => a
end
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
