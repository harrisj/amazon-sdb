require "test_sdb_harness"

class TestUsage < Test::Unit::TestCase
  include Amazon::SDB
  
  def setup
    @sdb = Amazon::SDB::Base.new 'API_KEY', 'SECRET_KEY' 
  end
  
  def test_accumulate
    u = Amazon::SDB::Usage.new
    
    u << 0.50
    u << 0.25
    
    assert_in_delta(0.75, u.box_usage, 2 ** -20)
  end
  
  def test_reset
    u = Amazon::SDB::Usage.new
    
    u << 0.50
    u << 0.25
    
    u.reset!
    
    assert_in_delta(0.0, u.box_usage, 2 ** -20)
  end
  
  def test_request_usage
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
    <BoxUsage>0.00777</BoxUsage> 
    </ResponseMetadata> 
    </ListDomainsResponse> 
    EOF
     
    @sdb.domains
    
    assert_in_delta(0.00777, @sdb.box_usage, 2 ** -20)
  end
  
  def test_error_usage
    @sdb.responses << error_response('RequestTimeout')

    assert_raise(Amazon::SDB::TimeoutError) { @sdb.domains }
    assert_in_delta(0.0000219907, @sdb.box_usage, 2 ** -20)
  end
  
  def test_block_usage
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
    <BoxUsage>0.50</BoxUsage> 
    </ResponseMetadata> 
    </ListDomainsResponse> 
    EOF
    
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
    <BoxUsage>0.25</BoxUsage> 
    </ResponseMetadata> 
    </ListDomainsResponse> 
    EOF
    
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
    <BoxUsage>0.01</BoxUsage> 
    </ResponseMetadata> 
    </ListDomainsResponse> 
    EOF
    
    @sdb.domains
    
    usage = @sdb.box_usage do
      @sdb.domains
      @sdb.domains
    end
    
    assert_in_delta(0.26, usage, 2 ** -20)
  end
end