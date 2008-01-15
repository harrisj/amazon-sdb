require "test_sdb_harness"

class TestMultimap < Test::Unit::TestCase
  include Amazon::SDB
  
  def setup
    @m = Multimap.new
  end
  
  def test_init_nil
    assert_equal 0, @m.size
    @m.each_pair do |k, v|
      flunk 'Shouldn''t be anything in the multimap'
    end
  end
  
  def test_init_array
    m = Multimap.new [['a', 1], ['b', 2], ['a', 3]]
    assert_equal 3, m.size
    assert_equal [1, 3], m.get('a')
    assert_equal 2, m.get('b')
  end
  
  def test_init_array_bad
    assert_raise(ArgumentError) { m = Multimap.new [:a, :b, :c] }
  end
  
  def test_init_hash
    m = Multimap.new({:a => 'a', :b => 'b'})
    assert_equal 2, m.size
    assert_equal 'a', m.get(:a)
    assert_equal 'b', m.get(:b)
  end
  
  def test_init_null_value
    m = Multimap.new({:a => nil, :b => 'b'})
    assert_nil(m.get(:a))
    assert_equal 'b', m.get(:b)
  end
  
  def test_init_null_put
    m = Multimap.new({:a => nil})
    assert_equal 1, m.size
    
    m.put(:a, 1)
    assert_equal 1, m.size
  end
  
  def test_indifferent_access
    m = Multimap.new({:a => 1})
    assert_equal 1, m["a"]
  end
  
  def test_indifferent_both
    m = Multimap.new({:a => 1, "a" => 2})
    assert_equal 2, m.size
    assert_equal [2, 1], m[:a]
  end
  
  def test_put
    @m["a"] = 23
    assert_equal(23, @m.get("a"))
  end
  
  def test_put_append
    @m.put("a", 2)
    @m.put("a", 4)
    assert_equal 2, @m.size
  end
  
  def test_put_replace
    @m.put("a", 2)
    @m.put("a", 4, :replace => true)
    assert_equal 1, @m.size
    assert_equal 4, @m["a"]
  end
  
  def test_bracket_read
    m = Multimap.new({:a => 5})
    assert_equal 5, m[:a]
    assert_nil m["b"]
  end
  
  def test_bracket_write
    @m[:a] = 1
    @m[:a] = 3
    assert_equal(1, @m.size)
    assert_equal(3, @m[:a])
  end
  
  def test_delete_key
    # m = Multimap.new([[:a, 1][:a, 2][:a, 3]])
    # assert_equal 3, m.size
    # m.delete
  end
  
  def test_fixnum_padding
    @m['Num'] = 12
    Amazon::SDB::Base.number_padding = 6
    
    assert_equal '000012', @m.to_sdb['Attribute.0.Value']
  end
  
  def test_numeric
    @m['Num'] = Amazon::SDB::Multimap.numeric(12.34, 10, 4)
    assert_equal '00012.3400', @m['Num']
  end
  
  def test_boolean_to_sdb
    @m['a'] = true
   
    assert_equal 'true', @m.to_sdb['Attribute.0.Value']
  end
    
  def test_to_sdb_replace_all
    @m[:a] = "foo"
    @m[:b] = "bar"
    
    out = @m.to_sdb({:replace => :all})
    assert out.key?('Attribute.0.Replace')
    assert out.key?('Attribute.1.Replace')
  end
  
  def test_to_sdb_replace_by_name
    @m[:a] = "foo"
    
    out = @m.to_sdb({:replace => 'a'})
    assert out.key?('Attribute.0.Replace')
  end
  
  def test_delete_pair
    
  end
  
  def test_char_escape
    @m["a\'b"] = "c\\d"
    
    out = @m.to_sdb
    
    assert_equal 'a\\\'b', out["Attribute.0.Name"]
    assert_equal 'c\\\\d', out["Attribute.0.Value"]
  end
  
  def test_method_missing_get
    @m["foo"] = "bar"
    
    assert_equal "bar", @m.foo
    assert_raise(NoMethodError) { @m.baz }
  end
  
  def test_method_missing_get_before_cast
    @m.from_sdb([["foo","0000000000000000023"]])
    
    assert_equal 23, @m.foo
    assert_equal "0000000000000000023", @m.foo_before_cast
  end
  
  def test_coerce_int
    m = Multimap.new
    m.from_sdb([["a", "00000000023"],["b", "1992"]])
    
    assert_equal 23, m["a"]
    assert_equal "00000000023", m.get("a", :before_cast => true)
    assert_equal "1992", m["b"]
  end
  
  def test_coerce_float
    m = Multimap.new
    m.from_sdb([["a", "0000000000034.3400000000"]])
    
    assert_in_delta(34.34, m["a"], 2 ** -20)
    assert_equal "0000000000034.3400000000", m.get("a", :before_cast => true)
  end
  
  def test_coerce_boolean
    m = Multimap.new
    m.from_sdb([["a", "true"], ["b", "false"]])
  
    assert_equal true, m["a"]
    assert_equal false, m["b"]
  end
  
  def test_coerce_datetime
    now = Time.now
    
    m = Multimap.new
    m.from_sdb([["a", now.iso8601]])
    assert_equal now.to_s, m["a"].to_s
    assert_instance_of(Time, m["a"])
  end
end