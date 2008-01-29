require 'test_sdb_harness'

class TestAmazonBase < Test::Unit::TestCase
  def setup
    @sdb = Amazon::SDB::Base.new 'API_KEY', 'SECRET_KEY' 
  end
    
  def test_sign
    # this example is given by Amazon
    options = {
      "Timestamp" => '2004-02-12T15:19:21+00:00',
      'adc' => 1,
      'aab' => 2,
      'AWSAccessKeyId' => 'my_access_id',
      'SignatureVersion' => 1,
      'Action' => 'Get',
      'Version' => '2006-08-11'
    }

    signature = Amazon::SDB::Base.sign('secret_key', options)
    assert_equal 'xlrD17jnkGk6E3nVVOV3Qon3Nwg=', signature
  end
  
  def test_cgi_encode
    options = {'foo' => 'bar'}
  
    assert_equal 'foo=bar', @sdb.send(:cgi_encode, options)
  end
  
  def test_cgi_encode_array
    options = {"foo" => ["bar", "baz"]}
    assert_equal 'foo=bar&foo=baz', @sdb.send(:cgi_encode, options)
  end
  
  def test_domains
    @sdb.responses << <<-EOF
    <?xml version="1.0" encoding="utf-8" ?>
    <ListDomainsResponse xmlns="http://sdb.amazonaws.com/doc/2007-11-07"> 
    <ListDomainsResult> 
    <DomainName>foo</DomainName> 
    <DomainName>bar</DomainName>
    <DomainName>baz</DomainName> 
    </ListDomainsResult> 
    <ResponseMetadata> 
    <RequestId>eb13162f-1b95-4511-8b12-489b86acfd28</RequestId> 
    <BoxUsage>0.0000219907</BoxUsage> 
    </ResponseMetadata> 
    </ListDomainsResponse> 
    EOF
    
    domains = @sdb.domains

    assert_equal 1, @sdb.uris.length
    assert_in_url_query({'Action' => 'ListDomains'}, @sdb.uris.first)

    assert_equal 3, domains.size
    %w(foo bar baz).each_with_index do |name, index|
      assert_equal name, domains[index].name
    end
  end
  
  def test_domains_more
    @sdb.responses << <<-EOF
    <?xml version="1.0" encoding="utf-8" ?>
    <ListDomainsResponse xmlns="http://sdb.amazonaws.com/doc/2007-11-07"> 
    <ListDomainsResult> 
    <DomainName>foo</DomainName> 
    <DomainName>bar</DomainName>
    <NextToken>FOOBAR</NextToken> 
    </ListDomainsResult> 
    <ResponseMetadata> 
    <RequestId>eb13162f-1b95-4511-8b12-489b86acfd28</RequestId> 
    <BoxUsage>0.0000219907</BoxUsage> 
    </ResponseMetadata> 
    </ListDomainsResponse> 
    EOF
    
    @sdb.responses << <<-EOF
    <?xml version="1.0" encoding="utf-8" ?>
    <ListDomainsResponse xmlns="http://sdb.amazonaws.com/doc/2007-11-07"> 
    <ListDomainsResult> 
    <DomainName>baz</DomainName> 
    </ListDomainsResult> 
    <ResponseMetadata> 
    <RequestId>eb13162f-1b95-4511-8b12-489b86acfd28</RequestId> 
    <BoxUsage>0.0000219907</BoxUsage> 
    </ResponseMetadata> 
    </ListDomainsResponse> 
    EOF
    
    domains = @sdb.domains
    
    assert_equal 2, @sdb.uris.length, "Should make 2 requests to sdb"
    assert_in_url_query({'NextToken' => 'FOOBAR'}, @sdb.uris.last)
    
    assert_equal 3, domains.size, "Should return 3 domains"
    %w(foo bar baz).each_with_index do |name, index|
      assert_equal name, domains[index].name
    end    
  end
  
  def test_domains_fail
  end
  
  def test_create_domain
    @sdb.responses << generic_response('CreateDomain')

    domain = @sdb.create_domain('foobar')
    assert_equal 1, @sdb.uris.length
    assert_in_url_query({'Action' => 'CreateDomain', 'DomainName' => 'foobar'}, @sdb.uris.first)
    
    assert_equal 'foobar', domain.name
  end
  
  def test_create_domain_invalid_param
    @sdb.responses << error_response('InvalidParameterValue', 'Value (X) for parameter DomainName is invalid.')

    assert_raise(Amazon::SDB::ParameterError) { @sdb.create_domain('(X)') }
    assert_equal 1, @sdb.uris.length
  end
  
  def test_create_domain_limit_error
    @sdb.responses << error_response('NumberDomainsExceeded', 'Domain Limit reached')
    
    assert_raise(Amazon::SDB::LimitError) { @sdb.create_domain('foo') }
  end
  
  def test_delete_domain
    @sdb.responses << generic_response('DeleteDomain')
    
    @sdb.delete_domain!('foo')
    assert_equal 1, @sdb.uris.length
    assert_in_url_query({'Action' => 'DeleteDomain', 'DomainName' => 'foo'}, @sdb.uris.first)
  end
end
