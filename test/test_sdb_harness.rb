require "test/unit"
require 'cgi'
require "amazon_sdb"

module Amazon
  module SDB
    # little mock override of open for base (technique from Eric Hodel)
    class Base
      attr_accessor :uris, :responses

      def initialize(aws_access_key, aws_secret_key)
        @access_key = aws_access_key
        @secret_key = aws_secret_key
        @usage = Amazon::SDB::Usage.new
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
    
    class Domain
      def uris
        @base.uris
      end
      
      def responses
        @base.responses
      end
    end
  end
end

class Test::Unit::TestCase
  def error_response(code, msg=nil)
    msg ||= "ERROR MESSAGE"
    
    "<Response> 
    <Errors> 
    <Error> 
    <Code>#{code}</Code> 
    <Message>#{msg}</Message> 
    <BoxUsage>0.0000219907</BoxUsage> 
    </Error> 
    </Errors> 
    <RequestID> 
    1e6265c5-f1f2-4a4b-afef-1448cac0f065 
    </RequestID> 
    </Response>"
  end
  
  GENERIC_RESPONSE_USAGE = "0.0000219907"
  
  def generic_response(method)
    "<#{method}Response xmlns=\"http://sdb.amazonaws.com/doc/2007-11-07\"> 
    <ResponseMetadata> 
    <RequestId>490206ce-8292-456c-a00f-61b335eb202b</RequestId> 
    <BoxUsage>#{GENERIC_RESPONSE_USAGE}</BoxUsage> 
    </ResponseMetadata> 
    </#{method}Response>"
  end
  
  def assert_in_url_query(hash, uri)
    query_str = uri.gsub(/^.+\?/, '')
    query_hash = CGI.parse query_str
    
    hash.each_pair do |key, value|
      case value
      when Array
        assert_equal value, query_hash[key], "Query #{query_str} includes #{key}=#{query_hash[key]}, expected #{value.inspect}"
      else
        assert_equal [value], query_hash[key], "Query #{query_str} includes #{key}=#{query_hash[key]}, expected #{value}"
      end
    end
  end
  
  def assert_url_path(path, uri)
    test_path = uri.dup
    test_path.gsub!(/^http:\/\/[^\/]+\//, '/')
    test_path.gsub!(/\?.+$/, '')
    
    assert_equal path, test_path
  end
  
  
  def assert_attr_pairs_in_query(attr_hash, uri)
    attr_hash.each_pair do |k, v|
      assert_attr_pair_in_query k, v, uri
    end
  end
  
  def assert_attr_pair_in_query(key, value, uri)
    query_str = uri.gsub(/^.+\?/, '')
    query_hash = CGI.parse query_str
    
    key_found = false
    value_found = false
    
    query_hash.each_pair do |cgi_key, cgi_value|
      if cgi_key =~ /Attribute\.\d+\.Name/
        key_found ||= cgi_value.any? {|k| k == key}
      elsif cgi_key =~ /Attribute\.\d+\.Value/
        value_found ||= cgi_value.any? {|k| k == value}
      end
      
      return if key_found and value_found
    end
    
    if key_found and not value_found
      fail "Key '#{key}' found but not with value '#{value}' found in #{query_str}"
    elsif value_found and not key_found
      fail "Key '#{key}' not found but value '#{value}' found in #{query_str}"
    else
      fail "Neither key '#{key}' or value '#{value}' found in #{query_str}"
    end
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