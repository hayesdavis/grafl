module Grafl
  
  class Graph
    attr_accessor :access_token
    
    def initialize(options={})
      self.access_token = options[:access_token]
    end
    
    def request(method,path,params={})
      params ||= {}
      if access_token
        params[:access_token] = access_token
      end
      uri = build_uri(method,path,params)
      conn = Net::HTTP.new(uri.host,uri.port)
      conn.use_ssl = true
      conn.verify_mode = OpenSSL::SSL::VERIFY_NONE
      conn.start do |http|
        req = request_class(method).new(uri.request_uri)
        add_form_data(req,params)
        http.request(req)
      end
    end
    
    def build_uri(method,path,params={})
      uri_parts = ["https://graph.facebook.com",path]
      if method == :get && !params.empty?
        uri_parts << to_query_string(params)
      end
      URI.join(*uri_parts)
    end
    
    private
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
          URI.encode(value.to_s)
        end
      end
      
      def request_class(method)
        Net::HTTP.const_get(method.to_s.capitalize)
      end
      
      def request_body_permitted?(req)
        req.request_body_permitted? || req.kind_of?(Net::HTTP::Delete)
      end

      def add_form_data(req,params)
        if request_body_permitted?(req) && params
          req.set_form_data(params)
        end
      end
  end
  
end