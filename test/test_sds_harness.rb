require "test/unit"
require 'cgi'
require "amazon_sds"

GET_ATTRIBUTES_RESPONSE = <<-EOF
<GetAttributesResponse xmlns="https://sds.amazonaws.com/doc/2006-08-11/"> <Attributes> 
<Attribute><Name>name1</Name><Value>value1</Value></Attribute> 
<Attribute><Name>name2</Name><Value>value2</Value></Attribute> 
<Attribute><Name>name2</Name><Value>value3</Value></Attribute> 
<Attribute><Name>name3</Name><Value>value4</Value></Attribute> </Attributes> 
</GetAttributesResponse> 
EOF

DELETE_ATTRIBUTES_RESPONSE = <<-EOF
<DeleteAttributesResponse xmlns="https://sds.amazonaws.com/doc/2006-08-11/"> <Success/> 
</DeleteAttributesResponse>
EOF

PUT_ATTRIBUTES_RESPONSE = <<-EOF
<PutAttributesResponse xmlns="https://sds.amazonaws.com/doc/2006-08-11/"> <Success/> 
</PutAttributesResponse>
EOF

LIST_ITEMS_RESPONSE = <<-EOF
<ListItemsResponse xmlns="https://sds.amazonaws.com/doc/2006-08-11/"><Items> 
<Item><Name>item1</Name></Item> <Item><Name>item2</Name></Item> 
<Item><Name>item3</Name></Item></Items> 
</ListItemsResponse>     
EOF

# little mock override of open for base (technique from Eric Hodel)
class Amazon::SDS::Base
  attr_accessor :uris, :responses
  
  def initialize(aws_access_key, aws_secret_key)
    @access_key = aws_access_key
    @secret_key = aws_secret_key
    @responses = []
    @uris = []  
  end
  
  def open(uri)
    @uris << uri
    
    if @responses.size == 0
      fail "Unexpected HTTP request #{uri}"
    end
    
    yield StringIO.new(@responses.shift)
  end
end

class Test::Unit::TestCase
  def assert_in_url_query(hash, uri)
    query_str = uri.gsub /^.+\?/, ''
    query_hash = CGI.parse query_str
    
    hash.each_pair do |key, value|
      assert_equal [value], query_hash[key], "Query #{query_str} includes #{key}=#{query_hash[key]}, expected #{value}"
    end
  end
  
  def assert_url_path(path, uri)
    test_path = uri.dup
    test_path.gsub!(/^http:\/\/[^\/]+\//, '/')
    test_path.gsub!(/\?.+$/, '')
    
    assert_equal path, test_path
  end
  
  def assert_not_in_url_query(args, uri)
    arg_array = case args
      when String
        args.to_a
      when Array
        args
      else
        raise ArgumentError, "Should be a string or array"
      end
    
    query_str = uri.gsub /^.+\?/, ''
    query_hash = CGI.parse query_str

    arg_array.each do |key|
      assert_equal [], query_hash[key], "The key #{key} should not be in the URL argument string"
    end
  end
end