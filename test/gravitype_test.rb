require 'test_helper'

class TestDoc
  include Mongoid::Document
  include Mongoid::CachedJson

  Mongoid::Fields::TYPE_MAPPINGS.each do |name, type|
    field "mongoid_#{name}", type: type
  end

  def ruby_method?
    'string'
  end

  json_fields \
    mongoid_string: {},
    ruby_method: { definition: :ruby_method? }
end

# mongoid_hash

describe 'Data introspection of Mongoid backed fields' do
  it 'returns all types that exist for a `string` field' do
    result = introspect_field(:mongoid_string, [nil, 'foo', 'bar'])
    result.must_equal Set.new([NilClass, String])
  end

  it 'returns all types that exist for a `symbol` field' do
    result = introspect_field(:mongoid_symbol, [nil, :foo, :bar])
    result.must_equal Set.new([NilClass, Symbol])
  end

  it 'returns all types that exist for a `boolean` field' do
    result = introspect_field(:mongoid_boolean, [nil, true, true, false])
    result.must_equal Set.new([NilClass, TrueClass, FalseClass])
  end

  it 'returns all types that exist for a `integer` field' do
    result = introspect_field(:mongoid_integer, [nil, 21, 42])
    result.must_equal Set.new([NilClass, Fixnum])
  end

  it 'returns all types that exist for a `float` field' do
    result = introspect_field(:mongoid_float, [nil, 21.0, 42.0])
    result.must_equal Set.new([NilClass, Float])
  end

  it 'returns all types that exist for a `big_decimal` field' do
    result = introspect_field(:mongoid_float, [nil, BigDecimal.new('42'), BigDecimal.new('42424242424242424242424.42')])
    result.must_equal Set.new([NilClass, Float])
  end

  it 'returns all types that exist for a `time` field' do
    result = introspect_field(:mongoid_time, [nil, Time.now, Time.now, 'foo'])
    result.must_equal Set.new([NilClass, Time])
  end

  it 'returns all types that exist for a `date` field' do
    result = introspect_field(:mongoid_date, [nil, Date.today, Date.today])
    result.must_equal Set.new([NilClass, Date])
  end

  it 'returns all types that exist for a `datetime` field' do
    result = introspect_field(:mongoid_date_time, [nil, DateTime.now, DateTime.now])
    result.must_equal Set.new([NilClass, DateTime])
  end

  it 'returns all types that exist for a `object_id` field' do
    result = introspect_field(:mongoid_object_id, [nil, BSON::ObjectId.new.to_s, BSON::ObjectId.new])
    result.must_equal Set.new([NilClass, BSON::ObjectId])
  end

  it 'returns all types that exist for a `binary` field' do
    result = introspect_field(:mongoid_binary, [nil, 'baz', BSON::Binary.new('foo'), BSON::Binary.new('bar')])
    result.must_equal Set.new([NilClass, BSON::Binary, String])
  end

  it 'returns all types that exist for a `range` field' do
    result = introspect_field(:mongoid_range, [nil, 21..42, 21...42])
    result.must_equal Set.new([NilClass, Range])
  end

  it 'returns all types that exist for a `regexp` field' do
    result = introspect_field(:mongoid_regexp, ['foo', /foo/, /bar/])
    result.must_equal Set.new([BSON::Regexp::Raw])
  end

  it 'returns all types that exist for an `array` field' do
    result = introspect_field(:mongoid_array, [nil, [], ['foo', :bar], [42]])
    result.must_equal Set.new([NilClass, [String, Symbol, Fixnum]])
  end

  it 'returns all types that exist for a `set` field' do
    result = introspect_field(:mongoid_set, [nil, Set.new, Set.new(['foo', :bar]), Set.new([42])])
    result.must_equal Set.new([Set.new([String, Symbol, Fixnum])])
  end

  # it 'returns all types that exist for a `hash` field' do
  #   result = introspect_field(:mongoid_hash, [nil, {}, { 21 => 'bar', 'foo' => 42 }])
  #   result.must_equal Set.new([nil, { Set.new([String, Fixnum]) => Set.new([String, Fixnum]) }])
  # end

  private

  def introspect_field(field, values)
    values.each { |value| TestDoc.create!(field => value) }
    Gravitype.introspect_data(TestDoc, field => field)[field]
  end
end

describe 'Data introspection of Ruby backed fields' do
  it 'uses the provided method alias to get the value from the document' do
    TestDoc.create!
    result = Gravitype.introspect_data(TestDoc, :ruby_method => :ruby_method?)
    result[:ruby_method].must_equal Set.new([String])
  end
end

describe Gravitype do
  it 'returns a list of exposed JSON fields and their model getters' do
    Gravitype.exposed_fields_and_getters(TestDoc).must_equal({
      mongoid_string: :mongoid_string,
      ruby_method: :ruby_method?,
    })
  end
end
