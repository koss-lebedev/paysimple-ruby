module Paysimple
  module Util

    def self.underscore(str)
      str.gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
          gsub(/([a-z\d])([A-Z])/,'\1_\2').
          tr('-', '_').
          downcase
    end

    def self.camelize(str)
      str.split('_').collect(&:capitalize).join
    end

    def self.camelize_and_symbolize_keys(object)
      transform_names object do |key|
        camelize(key.to_s).to_sym
      end
    end

    def self.underscore_and_symbolize_names(object)
      transform_names object do |key|
        underscore(key).to_sym
      end
    end

    def self.transform_names(object, &block)
      case object
        when Hash
          new_hash = {}
          object.each do |key, value|
            key = block.call(key) || key
            new_hash[key] = transform_names(value, &block)
          end
          new_hash
        when Array
          object.map { |value| transform_names(value, &block) }
        else
          object
      end
    end

    def self.flatten_params(params, parent_key=nil)
      result = []
      params.each do |key, value|
        calculated_key = parent_key ? "#{parent_key}[#{url_encode(key)}]" : url_encode(key)
        calculated_key = camelize(calculated_key)
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

    def self.url_encode(key)
      URI.escape(key.to_s, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))
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