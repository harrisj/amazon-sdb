require 'test_sds_harness'

class TestAmazonDomain < Test::Unit::TestCase
  def setup
    @domain = Amazon::SDS::Domain.new 'API_KEY', 'SECRET_KEY', 'testdb'
  end
  
  def test_get_attributes
    domain = @sds
  end
  
  def test_list_items    
    @domain.responses << LIST_ITEMS_RESPONSE
    
    results = @domain.list_items # eg, a list all command
    
    assert_equal 1, @domain.uris.length
    assert_in_url_query({'Action' => 'List'}, @domain.uris.first)
    assert_not_in_url_query('Filter', @domain.uris.first)
    
    assert_equal 3, results.items.size
    assert_equal ['item1', 'item2', 'item3'], results.keys
  end
  
  def test_list_items_max_results
    @domain.responses << LIST_ITEMS_RESPONSE
    
    @domain.list_items :max_results => 3
    assert_equal 1, @domain.uris.length
    assert_in_url_query({'MaxResults' => '3'}, @domain.uris.first)    
  end
  
  def test_list_items_load
    @domain.responses << '<ListItemsResponse xmlns="https://sds.amazonaws.com/doc/2006-08-11/"><Items><Item><Name>item1</Name></Item></Items></ListItemsResponse>'
    @domain.responses << GET_ATTRIBUTES_RESPONSE
    
    @domain.list_items :load_attrs => true
    assert_equal 2, @domain.uris.length
    assert_url_path('/testdb/item1', @domain.uris.last)
    assert_in_url_query({'Action' => 'Get'}, @domain.uris.last)
  end
end