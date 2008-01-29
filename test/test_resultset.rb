require "test_sdb_harness"

class TestItem < Test::Unit::TestCase
  def setup
    @base = Amazon::SDB::Base.new 'API_KEY', 'SECRET_KEY'
    @domain = @base.domain 'testdb'
    # @key = 'TEST_ITEM'
    # @multimap = Amazon::SDB::Multimap.new({"foo" => "bar", "baz" => "quux"})
    # 
    # @empty_item = Amazon::SDB::Item.new(@domain, @key)
    # @item = Amazon::SDB::Item.new(@domain, @key, @multimap)
  end
  
  def test_more_items_true
  end
  
  def test_more_items_false
  end
  
  def test_load_next_more_results
  end
  
  def test_load_next_no_more
    
  end
  
  def test_keys
    
  end
end