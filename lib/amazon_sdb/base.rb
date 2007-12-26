module Amazon
  module SDB
    SIGNATURE_VERSION = '1'
    API_VERSION = '2007-11-07'
    
    ##
    # The Amazon::SDS::Base class is the top-level interface class for your SDS interactions. It allows you to set global
    # configuration settings, to manage Domain objects. If you are working within a particular domain you can also just use
    # the domain initializer directly for that domain.
    class Base
      ##
      # The base is initialized with 2 parameters from your Amazon Web Services account:
      # * +aws_access_key+ - Your AWS Access Key
      # * +aws_secret_key+ - Your AWS Secret Key
      def initialize(aws_access_key, aws_secret_key)
        @access_key = aws_access_key
        @secret_key = aws_secret_key
      end

      ##
      # Since all SDS supports only lexical comparisons, it's necessary to pad numbers with extra digits when saving them to SDS. 
      # Under lexical matching, 23 > 123. But if we pad it sufficiently 000000023 < 000000123. By default, this is set to the 
      # ungodly large value of 32 digits, but you can adjust it lower if this is too much. On reading from SDS, such numbers are
      # auto-coerced back, so it's probably not necessary to change.
      def self.number_padding
        return @@number_padding
      end

      ##
      # Change the number padding
      def self.number_padding=(num)
        @@number_padding = num
      end
      
      def self.float_precision
        return @@float_precision
      end
      
      def self.float_precision=(num)
        return @@float_precision
      end

      ##
      # Retrieves a list of domains in your SDS database. Each entry is a Domain object.
      def domains
        domains = []
        nextToken = nil
        base_options = {:Action => 'ListDomains'}
        continue = true
        
        while continue
          options = base_options.dup
          options[:NextToken] = nextToken unless nextToken.nil?
          
          sdb_query(options) do |h|
            h.search('//DomainName').each {|e| domains << Domain.new(@access_key, @secret_key, e.innerText)}
            mt = h.at('//NextToken')
            if mt
              nextToken = mt.innerText
            else
              continue = false
            end
          end
        end
        
        domains
      end

      ##
      # Returns a domain object for SDS. Assumes the domain already exists, so errors might occur if you didn't create it.
      def domain(name)
        Domain.new(@access_key, @secret_key, name)
      end

      def raise_errors(hpricot)
        errnode = hpricot.at('//Errors/Error')
        return unless errnode
        
        code = errnode.at('Code').innerText
        msg = "#{code}: #{errnode.at('Message').innerText}"

        if AUTH_ERROR_CODES.include? code
          raise AuthError, msg
        elsif ACCESS_ERROR_CODES.include? code
          raise AccessError, msg
        elsif PARAMETER_ERROR_CODES.include? code
          raise ParameterError, msg
        elsif QUERY_ERROR_CODES.include? code
          raise QuerySyntaxError, msg
        elsif LIMIT_ERROR_CODES.include? code
          raise LimitError, msg
        elsif REQUEST_ERROR_CODES.include? code
          raise RequestError, msg
        elsif SERVER_ERROR_CODES.include? code
          raise ServerError, msg
        elsif TIMEOUT_ERROR_CODES.include? code
          raise TimeoutError, msg
        elsif VERSION_ERROR_CODES.include? code
          raise VersionError, msg
        else
          raise UnknownError, msg
        end
      end
      
      def create_domain(name)
        sdb_query({:Action => 'CreateDomain', 'DomainName' => name}) do |h|
          domain(name)
        end
      end

      ##
      # Deletes a domain. This operation is currently not supported by SDS.
      def delete_domain!(name)
        sdb_query({:Action => 'DeleteDomain', 'DomainName' => name})
      end

      def timestamp
        Time.now.iso8601
      end

      def self.hmac(key, msg) 
        Base64.encode64(OpenSSL::HMAC.digest(OpenSSL::Digest::Digest.new('sha1'), key, msg))
      end

      def cgi_encode(options) 
        options.map do |k, v| 
          case v
          when Array
            v.map{|i| Base.uriencode(k)+'='+Base.uriencode(i)}.join('&')
          else
            Base.uriencode(k)+'='+Base.uriencode(v)
          end
        end.join('&')
      end

      def sdb_query(options = {})
        options.merge!({'AWSAccessKeyId' => @access_key,
          'SignatureVersion'             => SIGNATURE_VERSION,
          'Timestamp'                    => timestamp,
          'Version'                      => API_VERSION })
        options['Signature'] = Base.sign(@secret_key, options)

        # send to S3
        url = BASE_PATH + '?' + cgi_encode(options)

        # puts "Requesting #{url}" #if $DEBUG
        open(url) do |f|
          h = Hpricot.XML(f)

          raise_errors h
          yield h if block_given?
        end
      end

      def self.uriencode(str)
        CGI.escape str.to_s
      end

      def self.sign(key, query_options)
        option_array = query_options.to_a.map {|pair| [pair[0].to_s, pair[1].to_s]}.sort {|a, b| a[0].downcase <=> b[0].downcase }
        return hmac(key, option_array.map {|pair| pair[0]+pair[1]}.join('')).chop
      end

    private
      @@number_padding                 = 32
      @@float_precision                = 8

      BASE_PATH = 'http://sdb.amazonaws.com/'
    end
  end
end