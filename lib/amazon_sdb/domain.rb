module Amazon
  module SDS
    
    ##
    # Each SDS account can have up to 100 domains. This class represents a single domain and may be instantiated either indirectly
    # from the Amazon::SDS::Base class or via the Domain#initialize method.
    class Domain < Base
      attr_reader :name
      
      ##
      # Creates a new Domain object. 
      def initialize(aws_access_key, aws_secret_key, name)
        super(aws_access_key, aws_secret_key)
        @name = name
      end

      def base_path
        'http://sds.amazonaws.com/' + @name + '/'
      end
      
      def item_path(key)
        base_path + URI.encode(key.to_s)
      end
      
      ##
      # Sets attributes for a given key in the domain. If there are no attributes supplied, it creates an empty set.
      # Takes the following arguments:
      # - key - a string key for the attribute set
      # - multimap - an collection of attributes for the set in a Multimap object. If nothing, creates an empty set.
      # - mode - can be either <tt>:append</tt> or <tt>:replace</tt> (controls what to do when adding new attributes with the same names). Defaults to append
      def put_attributes(key, multimap=nil, mode=:append)
        options = {'Action' => 'Put'}
        
        unless mode == :append || mode == :replace
          raise ArgumentError, "Mode must be :replace or :append"
        end
        
        unless multimap.nil?
          options.merge! multimap.to_sds
        end
        
        if mode == :replace
          options.merge!({'Replace' => 'true'})
        end
        
        sds_query(item_path(key), options) do |h|
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
      # - <tt>*attr_list</tt> - if you are only interested in specifically named attributes you can specify them here. Otherwise returns all attributes
      # Attributes are returned in a multimap.
      def get_attributes(key, *attr_list)
        options = {'Action' => 'Get'}
        
        unless attr_list.nil?
          attr_list.each_with_index do |name, index| 
            options["Name#{index}"] = name
          end
        end
        
        sds_query(item_path(key), options) do |h|
          attr_nodes = h.search('//Attributes/Attribute')
          attr_array = []
          attr_nodes.each do |a|
            attr_array << [a.at('Name').innerText, a.at('Value').innerText]
          end
          
          if attr_array.any?
            return Item.new(self, key, Multimap.new(attr_array))
          else
            
          end
        end
      end

      ##
      # Not implemented yet.
      def delete_attributes(key, multimap=nil)
        options = {'Action' => 'Delete'}
        
        unless multimap.nil?
        
        end
        
        sds_query(item_path(key), options) do |h|
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
      def list_items(list_options = {})
        req_options = {'Action' => 'List'}
        
        unless list_options[:filter].nil?
          req_options['Filter'] = list_options[:filter]
        end
        
        if list_options[:more_token]
          req_options['MoreToken'] = list_options[:more_token]
        end
        
        if list_options[:max_results]
          req_options['MaxResults'] = list_options[:max_results]
        end
        
        sds_query(base_path, req_options) do |h|
          more_token = nil
          results = h.search('/ListItemsResponse/Items/Item/Name')
          items = results.map {|n| Item.new(self, n.innerText) }
          if list_options[:load_attrs]
            items.each {|i| i.reload! }
          end
          
          mt = h.search('//MoreToken')
          more_token = mt.inner_text unless mt.nil?
        
          return ResultSet.new(items, more_token)
        end
      end
    end
  end
end
