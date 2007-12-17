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
      # - key - a string key for the attribute set
      # - multimap - an collection of attributes for the set in a Multimap object. If nothing, creates an empty set.
      def put_attributes(key, multimap=nil, options = {})
        options = {'Action' => 'PutAttributes', 'DomainName' => name, 'ItemName' => key}
        
        unless multimap.nil?
          options.merge! case multimap
          when Hash, Array
            Multimap.new(multimap).to_sdb
          when Multimap
            multimap.to_sdb
          else
            raise ArgumentError, "The second argument must be a multimap, hash, or array"
          end
        end
        
#        if mode == :replace
#          options.merge!({'Replace' => 'true'})
#        end
        
        sdb_query(options) do |h|
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
      # Not implemented yet.
      def delete_attributes(key, multimap=nil)
        options = {'Action' => 'Delete'}
        
        unless multimap.nil?
        
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
      # - <tt>max_results</tt> = the max items to return for a listing (top/default is 100)
      # - <tt>:more_token</tt> = to retrieve a second or more page of results, the more token should be provided
      # - <tt>:load_attrs</tt> = this query normally returns just a list of names, the attributes have to be retrieved separately. To load the attributes for matching results automatically, set to true (normally false)
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
