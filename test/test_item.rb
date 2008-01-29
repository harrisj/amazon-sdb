require "test_sdb_harness"

class TestItem < Test::Unit::TestCase
  def setup
    @base = Amazon::SDB::Base.new 'API_KEY', 'SECRET_KEY'
    @domain = @base.domain 'testdb'
    @key = 'TEST_ITEM'
    @multimap = Amazon::SDB::Multimap.new({"foo" => "bar", "baz" => "quux"})
    
    @empty_item = Amazon::SDB::Item.new(@domain, @key)
    @item = Amazon::SDB::Item.new(@domain, @key, @multimap)
  end

  def test_save
    @domain.responses << generic_response('PutAttributes')
    @item.save
    
    assert_in_url_query({'Action' => 'PutAttributes', 'DomainName' => 'testdb', 'ItemName' => 'TEST_ITEM', 
                         'Attribute.0.Replace' => 'true', 'Attribute.1.Replace' => 'true'}, @domain.uris.first)
  end
  
  def test_reload!
    # tests sends a get attributes
    @domain.responses << <<-EOF
    <GetAttributesResponse xmlns="http://sdb.amazonaws.com/doc/2007-11-07"> 
    <GetAttributesResult> 
    <Attribute><Name>Color</Name><Value>Blue</Value></Attribute> 
    <Attribute><Name>Size</Name><Value>Med</Value></Attribute> 
    <Attribute><Name>Price</Name><Value>14</Value></Attribute> 
    </GetAttributesResult> 
    <ResponseMetadata> 
    <RequestId>b1e8f1f7-42e9-494c-ad09-2674e557526d</RequestId> 
    <BoxUsage>0.0000219907/<BoxUsage> 
    </ResponseMetadata> 
    </GetAttributesResponse> 
    EOF
    
    @item.reload!
    
    assert_in_url_query({'Action' => 'GetAttributes', 'DomainName' => 'testdb', 'ItemName' => 'TEST_ITEM'}, @domain.uris.first)
    assert_equal 'Blue', @item['Color']
    assert_equal 'Med', @item['Size']
    assert_equal '14', @item['Price']
  end
  
  def test_empty?
    assert @empty_item.empty?
    assert !@item.empty?
  end
  
  def test_destroy!
    # tests sends a delete attributes with 0 attrs
    @domain.responses << generic_response('DeleteAttributes')
    
    @item.destroy!
    assert_in_url_query({'Action' => 'DeleteAttributes', 'DomainName' => 'testdb', 'ItemName' => 'TEST_ITEM'}, @domain.uris.first)
  end
  
  def test_each
  end
  
  def test_each_pair
    
  end
end
  
  