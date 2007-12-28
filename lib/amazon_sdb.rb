require 'rubygems'
require "net/http"
require "uri"
require "cgi"
require "digest/md5"
require "digest/sha1"

# HMAC Digest doesn't require TLS/SSL, but we do need the OpenSSL::HMAC class
require "openssl"
require 'base64'
require 'open-uri'
require 'hpricot'

$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

unless defined?(Amazon::SDS)
  begin
    $:.unshift(File.dirname(__FILE__) + "/../../amazon_sdb/lib")
    require 'amazon_sdb'  
  rescue LoadError
    require 'rubygems'
    gem 'amazon_sdb'
  end
end

require 'amazon_sdb/multimap'
require 'amazon_sdb/base'
require 'amazon_sdb/domain'
require 'amazon_sdb/item'
require 'amazon_sdb/resultset'
require 'amazon_sdb/exceptions'

module Amazon
  module SDB
    VERSION = '0.6.0'    
  end
end

