require 'rgdata/util/array_with_delegation_to_first'

module RGData
  module Util
    class HashWithAccessor < Hash
      #important_methods = ['class', 'to_s', 'inspect']
      #(instance_methods - important_methods).each do |name|
      (instance_methods(false) + ['type']).each do |name|
        if name =~ /^[a-z]\w*[!?]?$/
          alias :"__hash__#{name}" :"#{name}"
          undef :"#{name}"
        end
      end

      def self.from_hash(hash, client)
        convert = lambda do |v|
          case v
          when Hash
            self.from_hash v, client
          when Array
            if v.size == 1 and v.first.is_a? String
              v.first
            else
              ArrayWithDelegationToFirst.from_array(v.map{|e| convert.call e})
            end
          else
            v
          end
        end

        ret = self.new
        ret[:client] = client
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
