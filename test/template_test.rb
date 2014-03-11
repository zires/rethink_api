require 'test_helper'

class TemplateTest < MiniTest::Unit::TestCase

  def setup
    @template = RethinkAPI::Template.new('test')
  end

  def test_attribute
    @template.attribute :foo
    @template.attribute :foo1, key: :bar
    fun = lambda{}
    @template.attribute fun, key: 'function'
    assert_equal [{method_name: fun, alias_name: 'function'}], @template.dynamic_attrs
    assert_equal [{method_name: 'foo', alias_name: 'foo'}, {method_name: 'foo1', alias_name: 'bar'}], @template.static_attrs
  end

  def test_attributes
    @template.attributes :foo, :bar
    assert_equal [], @template.dynamic_attrs
    assert_equal [{method_name: 'foo', alias_name: 'foo'}, {method_name: 'bar', alias_name: 'bar'}], @template.static_attrs
  end

  def test_map_static_attrs
    @template.attributes :foo, :bar
    assert_equal ['foo', 'bar'], @template.attribute_names
  end

end

