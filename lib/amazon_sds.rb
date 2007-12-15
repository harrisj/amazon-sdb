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
    $:.unshift(File.dirname(__FILE__) + "/../../amazon_sds/lib")
    require 'amazon_sds'  
  rescue LoadError
    require 'rubygems'
    gem 'amazon_sds'
  end
end

require 'amazon_sds/multimap'
require 'amazon_sds/base'
require 'amazon_sds/domain'
require 'amazon_sds/item'
require 'amazon_sds/resultset'

module Amazon
  module SDS
    VERSION = '0.5.0'    
  end
end

