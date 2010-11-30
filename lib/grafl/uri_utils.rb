module Grafl
  
  module UriUtils
 
    # See "unreserved" in RFC 3986
    UNSAFE = /[^a-zA-Z0-9\-._]/ 
    
    def parse_query_string(query)
      params = {}
      query.split(/&/).each do |kv| 
        key, value = kv.split(/=/)
        params[URI.decode(key)] = URI.decode(value)
      end
      params
    end      
    
    def to_query_string(params)
      encoded_params = params.map do |key,value| 
        "#{uri_encode(key)}=#{uri_encode(value)}"
      end.join("&")
      "?#{encoded_params}"
    end      
    
    def uri_encode(value)
      if value.kind_of?(Array)
        value.map {|v| uri_encode(v) }.join(",")
      elsif value.kind_of?(Hash)
        uri_encode(value.to_json)
      else
        URI.encode(value.to_s,UNSAFE)
      end
    end
    
    def uri_decode(value)
      URI.decode(value)
    end
    
    extend self
    
  end
  
end