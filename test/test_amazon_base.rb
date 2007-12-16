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
  
  def test_domains
    @sdb.responses << <<-EOF
    <?xml version="1.0" encoding="utf-8" ?>
    <ListDomainsResponse xmlns="https://sdb.amazonaws.com/doc/2006-08-11/"> <Domains> 
    <Domain><Name>foo</Name></Domain> <Domain><Name>bar</Name></Domain> 
    <Domain><Name>baz</Name></Domain> </Domains>
    </ListDomainsResponse>
    EOF
    
    domains = @sdb.domains

    assert_equal 1, @sdb.uris.length
    #assert_uri_param    @sdb.uris.first

    assert_equal 3, domains.size
    %w(foo bar baz).each_with_index do |name, index|
      assert_equal name, domains[index].name
    end
  end
  
  def test_domains_more
    @sdb.responses << <<-EOF
    <?xml version="1.0" encoding="utf-8" ?>
    <ListDomainsResponse xmlns="https://sdb.amazonaws.com/doc/2006-08-11/"> <Domains> 
    <Domain><Name>foo</Name></Domain><Domain><Name>bar</Name></Domain> 
    <MoreToken>FOOBAR</MoreToken></Domains>
    </ListDomainsResponse>    
    EOF
    
    @sdb.responses << <<-EOF
    <?xml version="1.0" encoding="utf-8" ?>
    <ListDomainsResponse xmlns="https://sdb.amazonaws.com/doc/2006-08-11/"> <Domains> 
    <Domain><Name>baz</Name></Domain></Domains>
    </ListDomainsResponse>    
    EOF
    
    domains = @sdb.domains
    
    assert_equal 2, @sdb.uris.length, "Should make 2 requests to sdb"
    assert_in_url_query({'MoreToken' => 'FOOBAR'}, @sdb.uris.last)
    
    assert_equal 3, domains.size, "Should return 3 domains"
    %w(foo bar baz).each_with_index do |name, index|
      assert_equal name, domains[index].name
    end    
  end
  
  def test_domains_fail
  end
  
  def test_create_domain
    @sdb.responses << <<-EOF
    <?xml version="1.0" encoding="utf-8" ?>
    <CreateDomainResponse xmlns="http://sdb.amazonaws.com/doc/2007-11-07"> 
    <ResponseMetadata> 
    <RequestId>2a1305a2-ed1c-43fc-b7c4-e6966b5e2727</RequestId> 
    <BoxUsage>0.0000219907</BoxUsage> 
    </ResponseMetadata> 
    </CreateDomainResponse>
    EOF

    domain = @sdb.create_domain('foobar')
    assert_equal 1, @sdb.uris.length
    assert_in_url_query({'Action' => 'Create', 'Name' => 'foobar'}, @sdb.uris.first)
    
    assert_equal 'foobar', domain.name
  end
  
  def test_create_domain_fail
  end
end

