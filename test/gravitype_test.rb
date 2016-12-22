require 'test_helper'

class TestDoc
  include Mongoid::Document

  Mongoid::Fields::TYPE_MAPPINGS.each do |name, type|
    field "mongoid_#{name}", type: type
  end
end

class GravitypeTest < Minitest::Spec
  it 'works' do
    doc = TestDoc.new(mongoid_string: 'hello')
    doc.save!
    assert doc
  end
end
