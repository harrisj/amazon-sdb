module Amazon
  module SDS
    ##
    # A multimap is like a hash or set, but it only requires that key/value pair is unique (the same key may have multiple values).
    # Multimaps may be created by the user to send into Amazon SDS or they may be read back from SDS as the attributes for an object.
    #
    # For your convenience, multimap's initializer can take several types of input parameters:
    # - A hash of key/value pairs (for when you want keys to be unique)
    # - An array of key/value pairs represented as 2-member arrays
    # - Another multimap
    # - Or nothing at all (an empty set)
    class Multimap
      include Enumerable
      
      ##
      # To be honest, floats are difficult for SDS. In order to work with lexical comparisons, you need to save floats as strings padded to the same size.
      # The problem is, automatic conversion can run afoul of rounding errors if it has a larger precision than the original float, 
      # so for the short term I've provided the numeric helper method for saving floats as strings into the multimap (when read back from
      # SDS they will still be converted from floats). To use, specify the precision you want to represent as well as the total size (pick something large like 32 to be safe)
      def self.numeric(float, size, precision)
        sprintf "%0#{size}.#{precision}f", float
      end
      
      def initialize(init=nil)
        @mset = {}

        clear_size!

        if init.nil?
          # do nothing
        elsif init.is_a? Hash
          init.each {|k, v| put(k, v) }
        elsif init.is_a? Array
          # load from array
          if init.any? {|v| ! v.is_a? Array || v.size != 2 }
            raise ArgumentError, "Array must be of key/value pairs only"
          end

          init.each {|v| self.put(v[0], v[1])}
        elsif init.is_a? Multimap
          @mset = init.mset.dup
        else
          raise ArgumentError, "Wrong type passed as initializer"
        end
      end

      def clear_size!
        @size = nil
      end
      
      ##
      # Returns the size of the multimap. This is the total number of key/value pairs in it.
      def size
        if @size.nil?
          @size = @mset.inject(0) do |total, pair|
            value = pair[1]
            if value.is_a? Array
              total + value.size
            else
              total + 1
            end
          end
        end

        @size
      end

      ##
      # Save a key/value attribute into the multimap. Takes additional options
      # - <tt>:replace => true</tt> remove any attributes with the same key before insert (otherwise, appends)
      def put(key_arg, value, options = {})
        key = key_arg.to_s

        if options[:before_cast]
          key = "#{key}_before_cast"
        end

        k = @mset[key]
        clear_size!

        if k.nil? || options[:replace]
          @mset[key] = value
        else
          @mset[key] = @mset[key].to_a + [value]
        end
      end
      
      ##
      # Returns all the values that match a key. Normally, if there is only a single value entry 
      # returns just the value, with an array for multiple values, and nil for no match. If you want
      # to always return an array, pass in <tt>:force_array => true</tt> in the options
      def get(key_arg, options = {})
        key = key_arg.to_s

        if options[:before_cast]
          key = "#{key}_before_cast"
        end

        k = @mset[key]

        if options[:force_array]
          return [] if k.nil?
          k.to_a
        else
          k
        end
      end

      ##
      # Shortcut for #get
      def [](key)
        get(key)
      end
      
      ##
      # Shortcut for put(key, value, :replace => true)
      def []=(key, value)
        put(key, value, :replace => true)
      end

      ##
      # Support for Enumerable. Yields each key/value pair as an array of 2 members.
      def each
        @mset.each_pair do |key, group| 
          group.to_a.each do |value|
            yield [key, value]
          end
        end    
      end

      ##
      # Yields each key/value pair as separate parameters to the block.
      def each_pair
        @mset.each_pair do |key, group|
          case group
          when Array 
            group.each do |value|
              yield key, value
            end
          else
            yield key, group
          end
        end
      end

      ##
      # Yields each pair as separate key/value plus an index.
      def each_pair_with_index
        index = 0
        self.each_pair do |key, value|
          yield key, value, index
          index += 1
        end
      end

      def string_escape(str)
        str.gsub("\\", "\\\\").gsub("'", "\\'")
      end
      
      def sds_key_escape(key)
        case key
        when String
          string_escape(key)
        else
          key.to_s
        end
      end

      def sds_value_escape(value)
        case value
        when Fixnum
          sprintf("%0#{Base.number_padding}d", value)
        when Float
          numeric(value, Base.number_padding, Base.float_precision)
        when String
          string_escape(value)
        when Time
          value.iso8601
        else
          string_escape(value.to_s)
        end
      end

      ##
      # Outputs a multimap to SDS using Amazon's query-string notation (and doing auto-conversions of int and date values)
      def to_sds
        out = {}
        self.each_pair_with_index do |key, value, index|
          out["Name#{index}"] = sds_key_escape(key)
          out["Value#{index}"] = sds_value_escape(value)
        end

        out
      end

      def coerce(value)
        case value
        when /^0+\d+$/
          value.to_i
        when /^0+\d*.\d+$/
          value.to_f
        when /^\d{4}-\d{2}-\d{2}(T\d{2}:\d{2}:\d{2}([+\-]\d{2}:\d{2})?)?$/
          Time.parse(value)
        else
          value
        end
      end
      
      def from_sds(values)
        @mset = {}
        clear_size!

        if values.nil?
          # do nothing
        elsif values.is_a? Array
          # load from array
          if values.any? {|v| ! v.is_a? Array || v.size != 2 }
            raise ArgumentError, "Array must be of key/value pairs only"
          end

          values.each do |v|
            self.put(v[0], v[1], :before_cast => true)
            self.put(v[0], coerce(v[1]))
          end
        else
          raise ArgumentError, "Wrong type passed as initializer"
        end
      end
      
      ##
      # Returns the multimap as an array of 2-item arrays, one for each key-value pair
      def to_a
        out = []
        each_pair {|k, v| out << [k, v] }
        out
      end
      
      ##
      # Returns the multimap as a hash. In cases where there are multiple values for a key, it puts all the values into an array. 
      def to_h
        @mset.dup
      end
      
      def method_missing(method_symbol, *args)
        name = method_symbol.to_s
        if name =~ /^\w+$/
          if @mset.key? name
            get(name)
          else
            super
          end
        else
          super
        end
      end
    end
  end
end