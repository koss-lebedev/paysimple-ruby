module Paysimple
  module Util

    # class ::Hash
    #   def method_missing(name)
    #     return self[name] if key? name
    #     self.each { |k,v| return v if k.to_s.to_sym == name }
    #     super.method_missing name
    #   end
    # end

    def self.underscore(key)
      key.gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
          gsub(/([a-z\d])([A-Z])/,'\1_\2').
          tr('-', '_').
          downcase
    end

    def self.symbolize_names(object)
      case object
        when Hash
          new_hash = {}
          object.each do |key, value|
            key = underscore(key)
            key = (key.to_sym rescue key) || key
            new_hash[key] = symbolize_names(value)
          end
          new_hash
        when Array
          object.map { |value| symbolize_names(value) }
        else
          object
      end
    end

    def self.flatten_params(params, parent_key=nil)
      result = []
      params.each do |key, value|
        calculated_key = parent_key ? "#{parent_key}[#{url_encode(key)}]" : url_encode(key)
        if value.is_a?(Hash)
          result += flatten_params(value, calculated_key)
        elsif value.is_a?(Array)
          result += flatten_params_array(value, calculated_key)
        else
          result << [calculated_key, value]
        end
      end
      result
    end

    def self.flatten_params_array(value, calculated_key)
      result = []
      value.each do |elem|
        if elem.is_a?(Hash)
          result += flatten_params(elem, calculated_key)
        elsif elem.is_a?(Array)
          result += flatten_params_array(elem, calculated_key)
        else
          result << ["#{calculated_key}[]", elem]
        end
      end
      result
    end

  end
end