require 'test_helper'

class TestDoc
  include Mongoid::Document

  field :string, type: String
end

class GravitypeTest < Minitest::Spec
  it 'works' do
    doc = TestDoc.new(string: 'hello')
    doc.save!
    assert doc
  end
end
