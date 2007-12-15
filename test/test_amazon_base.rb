require 'test_sds_harness'

class TestAmazonBase < Test::Unit::TestCase
  def setup
    @sds = Amazon::SDS::Base.new 'API_KEY', 'SECRET_KEY' 
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

    signature = Amazon::SDS::Base.sign('secret_key', options)
    assert_equal 'xlrD17jnkGk6E3nVVOV3Qon3Nwg=', signature
  end
  
  def test_domains
    @sds.responses << <<-EOF
    <?xml version="1.0" encoding="utf-8" ?>
    <ListDomainsResponse xmlns="https://sds.amazonaws.com/doc/2006-08-11/"> <Domains> 
    <Domain><Name>foo</Name></Domain> <Domain><Name>bar</Name></Domain> 
    <Domain><Name>baz</Name></Domain> </Domains>
    </ListDomainsResponse>
    EOF
    
    domains = @sds.domains

    assert_equal 1, @sds.uris.length
    #assert_uri_param    @sds.uris.first

    assert_equal 3, domains.size
    %w(foo bar baz).each_with_index do |name, index|
      assert_equal name, domains[index].name
    end
  end
  
  def test_domains_more
    @sds.responses << <<-EOF
    <?xml version="1.0" encoding="utf-8" ?>
    <ListDomainsResponse xmlns="https://sds.amazonaws.com/doc/2006-08-11/"> <Domains> 
    <Domain><Name>foo</Name></Domain><Domain><Name>bar</Name></Domain> 
    <MoreToken>FOOBAR</MoreToken></Domains>
    </ListDomainsResponse>    
    EOF
    
    @sds.responses << <<-EOF
    <?xml version="1.0" encoding="utf-8" ?>
    <ListDomainsResponse xmlns="https://sds.amazonaws.com/doc/2006-08-11/"> <Domains> 
    <Domain><Name>baz</Name></Domain></Domains>
    </ListDomainsResponse>    
    EOF
    
    domains = @sds.domains
    
    assert_equal 2, @sds.uris.length, "Should make 2 requests to SDS"
    assert_in_url_query({'MoreToken' => 'FOOBAR'}, @sds.uris.last)
    
    assert_equal 3, domains.size, "Should return 3 domains"
    %w(foo bar baz).each_with_index do |name, index|
      assert_equal name, domains[index].name
    end    
  end
  
  def test_domains_fail
  end
  
  def test_create_domain
    @sds.responses << <<-EOF
    <?xml version="1.0" encoding="utf-8" ?>
    <CreateDomainResponse xmlns="https://sds.amazonaws.com/doc/2006-08-11/"><Success/></CreateDomainResponse>
    EOF

    domain = @sds.create_domain('foobar')
    assert_equal 1, @sds.uris.length
    assert_in_url_query({'Action' => 'Create', 'Name' => 'foobar'}, @sds.uris.first)
    
    assert_equal 'foobar', domain.name
  end
  
  def test_create_domain_fail
  end
end

