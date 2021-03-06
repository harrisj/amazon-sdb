require 'delegate'

module Amazon
  module SDB
    ##
    # An item from SimpleDB. This basically is a key for the item in the domain and a Multimap of the attributes. You should never
    # call Item#new, instead it is returned by various methods in Domain and ResultSet
    class Item < DelegateClass(Multimap)
      include Enumerable
      attr_accessor :key, :attributes
      
      def initialize(domain, key, multimap=nil)
        @domain = domain
        @key = key
        
        multimap = Multimap.new if multimap.nil?
        @attributes = multimap
        super(@attributes)
      end
      
      ##
      # Reloads from the domain
      def reload!
        item = @domain.get_attributes(@key)
        @attributes = item.attributes
      end
    
      
      ##
      # Deletes the item in SimpleDB
      def destroy!
        @domain.delete_attributes(@key)
      end
      
      ##
      # Saves the item back (like a put_attributes with :replace => :all
      def save
        @domain.put_attributes(@key, @attributes, :replace => :all)
      end
      
      ##
      # Reloads the item if necessary
      def get(key)
        reload! if empty?
        @attributes.get(key)
      end
      
      def [](key)
        get(key)
      end
      
      # def each
      #   @attributes.each
      # end
      # 
      # def each_pair
      #   @attributes.each_pair
      # end
    end
  end
end