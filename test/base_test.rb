require 'test_helper'

class People
  def rethink_attributes
    {
      id: id,
      first_name: first_name,
      last_name: last_name,
      address: address,
      city: city
    }
  end
end

class BaseTest < MiniTest::Unit::TestCase

  def setup
    unless RethinkAPI.r.db_list.run(RethinkAPI.conn).include?('test_rethink_api')
      RethinkAPI.r.db_create('test_rethink_api').run(RethinkAPI.conn)
    end
  end

  def teardown
    RethinkAPI.r.db_drop('test_rethink_api').run(RethinkAPI.conn)
  end

  def test_bootstrap
    RethinkAPI::Base.bootstrap
    assert_equal RethinkAPI.conn, RethinkAPI::Base.conn
    assert_equal RethinkAPI.database, RethinkAPI::Base.database
    assert_equal 'base', RethinkAPI::Base.table_name
  end

  def test_initialize
    RethinkAPI::Base.bootstrap
    people = People.new
    people.id = 123
    api = RethinkAPI::Base.new(people)
    assert_equal people, api.instance_variable_get(:@obj)
    assert !!api.table
    assert !!api.table.get('123').run(api.conn)
  end

  def test_attributes
    RethinkAPI::Base.bootstrap
    people = People.new
    people.id = 123
    people.first_name = 'thierry'
    people.last_name = 'zires'
    api = RethinkAPI::Base.new(people)
    api.refresh
    assert_equal 5, api.attributes.keys.size
    assert_equal '123', api.attributes['id']
    assert_equal 'thierry', api.attributes['first_name']
    assert_equal 'zires', api.attributes['last_name']
    people.last_name = 'herry'
    api.refresh
    assert_equal 'herry', api.attributes['last_name']
  end

  def test_pluck
    RethinkAPI::Base.bootstrap
    people = People.new
    people.id = 123
    people.first_name = 'thierry'
    people.last_name = 'zires'
    api = RethinkAPI::Base.new(people)
    api.refresh
    assert_equal ['id', 'last_name'].sort, api.pluck('id', 'last_name').keys.sort
    assert_equal ['id', 'last_name'].sort, api.pluck(:id, :last_name).keys.sort
    assert_equal ['id', 'last_name'].sort, api.pluck(['id', 'last_name']).keys.sort
    assert_equal ['id', 'last_name'].sort, api.pluck([:id, :last_name]).keys.sort
  end

end

