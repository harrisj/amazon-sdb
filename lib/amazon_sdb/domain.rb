module Amazon
  module SDB
    
    ##
    # Each sdb account can have up to 100 domains. This class represents a single domain and may be instantiated either indirectly
    # from the Amazon::sdb::Base class or via the Domain#initialize method. This class is what you can use to directly set attributes
    # on domains. Be aware that the following limits apply:
    # - 100 attributes per each call 
    # - 256 total attribute name-value pairs per item 
    # - 250 million attributes per domain 
    # - 10 GB of total user data storage per domain 
    class Domain < Base
      attr_reader :name
      
      ##
      # Creates a new Domain object. 
      def initialize(aws_access_key, aws_secret_key, name)
        super(aws_access_key, aws_secret_key)
        @name = name
      end
      
      ##
      # Sets attributes for a given key in the domain. If there are no attributes supplied, it creates an empty set.
      # Takes the following arguments:
      # - <tt>key</tt> - a string key for the attribute set
      # - <tt>multimap</tt> - an collection of attributes for the set in a Multimap object (can convert a Hash and Array too). If nothing, creates an empty set.
      # - <tt>options</tt> - for put options. Currently the only option is :replace, which either takes an array of attribute names to replace or :all for all of them
      def put_attributes(key, multimap=nil, options = {})
        req_options = {'Action' => 'PutAttributes', 'DomainName' => name, 'ItemName' => key}
        
        unless multimap.nil?
          req_options.merge! case multimap
          when Hash, Array
            Multimap.new(multimap).to_sdb(options)
          when Multimap
            multimap.to_sdb(options)
          else
            raise ArgumentError, "The second argument must be a multimap, hash, or array"
          end
        end
        
        sdb_query(req_options) do |h|
          # check for success?
          if h.search('//Success').any?
            return Item.new(self, key, multimap)
          else
           # error?
          end
        end
      end
      
      ##
      # Gets the attribute list for a key. Arguments:
      # - <tt>key</tt> - the key for the attribute set
      # - <tt>attr_list</tt> - by default, this function returns all the attributes of an item. If you wanted to limit the response to only a few named attributes, you can pass them here.
      def get_attributes(key, *attr_list)
        options = {'Action' => 'GetAttributes', 'DomainName' => name, 'ItemName' => key}
        
        unless attr_list.nil? or attr_list.empty?
          options["AttributeName"] = attr_list.map {|x| x.to_s }
        end
        
        sdb_query(options) do |h|
          attr_nodes = h.search('//GetAttributesResult/Attribute')
          attr_array = []
          attr_nodes.each do |a|
            attr_array << [a.at('Name').innerText, a.at('Value').innerText]
          end
          
          if attr_array.any?
            return Item.new(self, key, Multimap.new(attr_array))
          else
            raise RecordNotFoundError, "No record was found for key=#{key}"
          end
        end
      end

      ##
      # Deletes the attributes associated with a particular item. If the optional <tt>multimap</tt> argument is nil, deletes the entire
      # object. Otherwise, the optional multimap argument can be used to delete specific key/value pairs in the object (also accepts
      # a String or Symbol for a single name, an Array for multiple keys or a Hash for key/value pairs)
      def delete_attributes(key, multimap=nil)
        options = {'Action' => 'DeleteAttributes', 'DomainName' => name, 'ItemName' => key}
        
        unless multimap.nil?
          case multimap
          when String, Symbol
            options.merge! "Attribute.0.Name" => multimap.to_s
          when Array
            multimap.each_with_index do |k, i|
              options["Attribute.#{i}.Name"] = k
            end
          when Hash
            options.merge! Multimap.new(multimap).to_sdb
          when Multimap
            options.merge! multimap.to_sdb
          else
            raise ArgumentError, "Bad input paramter for attributes"
          end
        end
        
        sdb_query(options) do |h|
          if h.search('//Success').any?
            return true
          end
        end
      end
      
      ##
      # Returns a list of matching items that match a filter
      # Options include:
      # - <tt>:expr</tt> - a query expression to evaluate (see the Amazon SimpleDB documentation for details)
      # - <tt>:max_results</tt> - the max items to return for a listing (top/default is 100)
      # - <tt>:next_token</tt> - to retrieve a second or more page of results, the more token should be provided
      # - <tt>:load_attrs</tt> - this query normally returns just a list of names, the attributes have to be retrieved separately. To load the attributes for matching results automatically, set to true (normally false). Be aware this will lead to N additional requests to SimpleDB.
      def query(query_options = {})
        req_options = {'Action' => 'Query', 'DomainName' => name}
        
        unless query_options[:expr].nil?
          req_options['QueryExpression'] = query_options[:expr]
        end
        
        if query_options[:next_token]
          req_options['NextToken'] = query_options[:next_token]
        end
        
        if query_options[:max_results]
          req_options['MaxNumberOfItems'] = query_options[:max_results]
        end
        
        sdb_query(req_options) do |h|
          more_token = nil
          results = h.search('//QueryResponse/QueryResult/ItemName')

          items = results.map {|n| Item.new(self, n.innerText) }
  
          if query_options[:load_attrs]
            items.each {|i| i.reload! }
          end
          
          mt = h.search('//NextToken')
          more_token = mt.inner_text unless mt.nil?
        
          return ResultSet.new(self, items, more_token)
        end
      end
    end
  end
end
