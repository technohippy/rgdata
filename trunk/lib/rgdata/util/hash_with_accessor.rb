require 'rgdata/util/array_with_delegation_to_first'

module RGData
  module Util
    class HashWithAccessor < Hash
      instance_methods.each do |name|
        if name =~ /^[a-z]\w*[!?]?$/
          alias :"__hash__#{name}" :"#{name}"
          undef :"#{name}"
        end
      end

      def self.from_hash(hash)
        convert = lambda do |v|
          case v
          when Hash
            self.from_hash v
          when Array
            #v.map{|e| convert.call e}
            ArrayWithDelegationToFirst.from_array(v.map{|e| convert.call e})
          else
            v
          end
        end

        ret = self.new
        hash.each{|k, v| ret[k] = convert.call v}
        ret
      end

      def [](key)
        unless key.to_s[0] == ?/
          super
        else
          ret = self
          next_should_be_num = false
          key[1..-1].split(%r{[/@]}).each do |k|
            if next_should_be_num
              if k =~ /^\d+$/
                ret = ret[k.to_i]
                next_should_be_num = false
              else
                ret = ret[0][k]
              end
            else
              if  k =~ /^(\w+)\[(\d+)\]$/
                ret = ret[$1][$2.to_i]
              else
                ret = ret[k]
                next_should_be_num = true
              end
            end
          end
          ret
        end
      end

      def method_missing(name, *args, &block)
        self[name.to_s] or super
      end
    end
  end
end
