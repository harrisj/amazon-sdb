require 'test_sdb_harness'

QUERY_RESPONSE = <<-EOF
<QueryResponse xmlns="http://sdb.amazonaws.com/doc/2007-11-07"> 
<QueryResult> 
<ItemName>item1</ItemName> 
<ItemName>item2</ItemName> 
<ItemName>item3</ItemName> 
</QueryResult> 
<ResponseMetadata> 
<RequestId>c74ef8c8-77ff-4d5e-b60b-097c77c1c266</RequestId> 
<BoxUsage>0.0000219907</BoxUsage> 
</ResponseMetadata> 
</QueryResponse> 
EOF

GET_ATTRIBUTES_RESPONSE = <<-EOF
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

class TestAmazonDomain < Test::Unit::TestCase
  def setup
    @sdb = Amazon::SDB::Base.new 'API_KEY', 'SECRET_KEY'
    @domain = @sdb.domain('testdb')
    @attr_hash = {"foo" => "bar", "baz" => "quux"}
  end
  
  def test_no_such_domain_error
#    @domain.responses << error_response('NoSuchDomain', 'No such domain found')
        
#    assert_raise(DomainNotFoundError) { @domain.get_attributes() }
  end
  
  def test_put_attributes
    @domain.responses << generic_response('PutAttributes')
    
    m = Amazon::SDB::Multimap.new(@attr_hash)
    @domain.put_attributes 'item_key', m
    
    assert_equal 1, @domain.uris.length
    assert_in_url_query({'Action' => 'PutAttributes', 'DomainName' => @domain.name, 'ItemName' => 'item_key'}, @domain.uris.first)
    assert_attr_pairs_in_query @attr_hash, @domain.uris.first
  end
  
  def test_put_attributes_hash
    @domain.responses << generic_response('PutAttributes')
    
    @domain.put_attributes 'item_key', @attr_hash
    
    assert_equal 1, @domain.uris.length
    assert_in_url_query({'Action' => 'PutAttributes', 'DomainName' => @domain.name, 'ItemName' => 'item_key'}, @domain.uris.first)
    assert_attr_pairs_in_query @attr_hash, @domain.uris.first    
  end
  
  def test_put_attributes_replace_by_name
    @domain.responses << generic_response('PutAttributes')
    
    @domain.put_attributes 'item_key', @attr_hash, :replace => :baz
  end
  
  def test_put_attributes_replace_all
    @domain.responses << generic_response('PutAttributes')
    
    m = Amazon::SDB::Multimap.new @attr_hash
    
    @domain.put_attributes 'item_key', m, :replace => :all
    
    assert_in_url_query({'Attribute.0.Replace' => 'true', 'Attribute.1.Replace' => 'true'}, @domain.uris.first)
  end
  
  def test_get_attributes
    @domain.responses << GET_ATTRIBUTES_RESPONSE
    
    item = @domain.get_attributes('key')
    
    assert_equal 1, @domain.uris.size
    
    assert_in_url_query({'Action' => 'GetAttributes', 'DomainName' => @domain.name, 'ItemName' => 'key'}, @domain.uris.first)
    assert_instance_of(Amazon::SDB::Item, item)
    assert_equal 'Blue', item['Color']
  end
  
  def test_get_attributes_not_found
    @domain.responses << <<-EOF
    <GetAttributesResponse xmlns="http://sdb.amazonaws.com/doc/2007-11-07"> 
    <GetAttributesResult> 
    </GetAttributesResult> 
    <ResponseMetadata> 
    <RequestId>b1e8f1f7-42e9-494c-ad09-2674e557526d</RequestId> 
    <BoxUsage>0.0000219907/<BoxUsage> 
    </ResponseMetadata> 
    </GetAttributesResponse>    
    EOF

    assert_raise(Amazon::SDB::RecordNotFoundError) { @domain.get_attributes('key') }
    assert_equal 1, @domain.uris.size
  end

  def test_get_attributes_specific
    @domain.responses << GET_ATTRIBUTES_RESPONSE
    
    item = @domain.get_attributes 'key', 'attr1', :attr2
    
    assert_in_url_query({'AttributeName' => ['attr1','attr2']}, @domain.uris.first)
  end
  
  def test_delete_attributes_all
    @domain.responses << generic_response('DeleteAttributes')
    
    @domain.delete_attributes 'key'
    
    assert_equal 1, @domain.uris.length
    assert_in_url_query({'Action' => 'DeleteAttributes', 'DomainName' => @domain.name, 'ItemName' => 'key'}, @domain.uris.first)
  end
  
  def test_delete_attributes_name
    @domain.responses << generic_response('DeleteAttributes')
    
    @domain.delete_attributes 'key', 'foo'
    
    assert_equal 1, @domain.uris.length
    assert_in_url_query({'Action' => 'DeleteAttributes', 'DomainName' => @domain.name, 'ItemName' => 'key'}, @domain.uris.first)
    assert_in_url_query({'Attribute.0.Name' => 'foo'}, @domain.uris.first)        
  end
  
  def test_delete_attributes_name_value
    @domain.responses << generic_response('DeleteAttributes')
    
    @domain.delete_attributes 'key', {'foo' => 'bar'}
    
    assert_equal 1, @domain.uris.length
    assert_in_url_query({'Action' => 'DeleteAttributes', 'DomainName' => @domain.name, 'ItemName' => 'key'}, @domain.uris.first)
    assert_in_url_query({'Attribute.0.Name' => 'foo', 'Attribute.0.Value' => 'bar'}, @domain.uris.first)    
  end
  
  def test_query_all
    @domain.responses << QUERY_RESPONSE
    
    results = @domain.query
      
    assert_equal 1, @domain.uris.length
    assert_in_url_query({'Action' => 'Query', 'DomainName' => @domain.name}, @domain.uris.first)
    assert_not_in_url_query('QueryExpression', @domain.uris.first)
    
    assert_instance_of(Amazon::SDB::ResultSet, results)
    
    assert_equal 3, results.items.size
    assert_equal ['item1', 'item2', 'item3'], results.keys
  end
  
  def test_query_max_results
    @domain.responses << QUERY_RESPONSE
    
    @domain.query :max_results => 3
    assert_equal 1, @domain.uris.length
    assert_in_url_query({'MaxNumberOfItems' => '3'}, @domain.uris.first)    
  end
  
  def test_query_next_token
    @domain.responses << QUERY_RESPONSE
    
    @domain.query :next_token => 'FOOBAR'
    assert_equal 1, @domain.uris.length
    assert_in_url_query({'NextToken' => 'FOOBAR'}, @domain.uris.first)
  end
  
  def test_query_expr
    @domain.responses << QUERY_RESPONSE
    
    @domain.query :expr => "['last_name' = 'Harris']"
    
    assert_equal 1, @domain.uris.length
    assert_in_url_query({'QueryExpression' => "['last_name' = 'Harris']"}, @domain.uris.first)
  end
  
  def test_list_items_load
    @domain.responses << <<-EOF
    <QueryResponse xmlns="http://sdb.amazonaws.com/doc/2007-11-07"> 
    <QueryResult> 
    <ItemName>item1</ItemName> 
    </QueryResult> 
    <ResponseMetadata> 
    <RequestId>c74ef8c8-77ff-4d5e-b60b-097c77c1c266</RequestId> 
    <BoxUsage>0.0000219907</BoxUsage> 
    </ResponseMetadata> 
    </QueryResponse> 
    EOF
        
    @domain.responses << GET_ATTRIBUTES_RESPONSE
    
    results = @domain.query :load_attrs => true
    
    assert_equal 2, @domain.uris.length
    assert_in_url_query({'Action' => 'GetAttributes', 'DomainName' => @domain.name, 'ItemName' => 'item1'}, @domain.uris.last)
    
    assert_equal 1, results.items.size
    assert_equal 'Blue', results.items.first["Color"]
  end
end