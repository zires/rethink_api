require 'test_helper'

class Human < People
  include RethinkAPI::Methods

  def say(word)
    word
  end
end

class Car < Struct.new(:id, :name, :human_id)
  include RethinkAPI::Methods
end

class RethinkAPITest < MiniTest::Unit::TestCase

  def setup
    unless RethinkAPI.r.db_list.run(RethinkAPI.conn).include?('test_rethink_api')
      RethinkAPI.r.db_create('test_rethink_api').run(RethinkAPI.conn)
    end
  end

  def teardown
    RethinkAPI.r.db_drop('test_rethink_api').run(RethinkAPI.conn)
  end

  def test_rethink_api_method
    Human.rethink_api
    Human.rethink_api(class_name: 'HumanAPI')
    assert Human.constants.include?(:HumanRethinkAPI)
    assert Human.constants.include?(:HumanAPI)
  end

  def test_api_template
    Human.rethink_api(class_name: 'HumanHa')
    Human.api_template(:simple) do
      attribute :last_name
    end
    people = Human.new
    people.id = 123
    people.last_name = 'zires'
    people.refresh_rethink
    assert_equal 'zires', people.api_json('simple')['last_name']
  end

  def test_rethink_instance_method
    Human.rethink_api(class_name: 'HumanHb')
    Human.api_template(:simple) do
      attribute :last_name, key: :name
    end
    people = Human.new
    people.id = 123
    people.last_name = 'zires'
    people.refresh_rethink
    assert_equal 'zires', people.api_json('simple')['name']
    assert Human.rethink_api_templates['simple'].static_attrs.include?({method_name: 'last_name', alias_name: 'name'})
  end

  def test_api_json_with_dynamic_methods
    Human.rethink_api(class_name: 'HumanHc')
    Human.api_template(:simple) do
      attribute ->(p,o){ p.say('hello') }, key: :word
    end
    people = Human.new
    people.id = 123
    people.last_name = 'zires'
    people.refresh_rethink
    assert_equal 'hello', people.api_json('simple')['word']
  end

  def test_api_json_with_has_many
    Human.rethink_api(class_name: 'HumanHd')
    Human.api_template(:simple) do
      has_many :cars
    end
    Car.rethink_api
    Car.api_template(:simple) do
      attributes :name, :human_id
    end
    people = Human.new
    people.id = '123'
    people.last_name = 'zires'
    car = Car.new
    car.id = 456
    car.human_id = '123'
    car.name = 'porsche'
    people.refresh_rethink
    car.refresh_rethink
    assert_equal 'porsche', people.api_json('simple')['cars'].first['name']
  end

end
