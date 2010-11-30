module Grafl
  
  class Graph
    
    SITE = "https://graph.facebook.com"
    
    include UriUtils
    
    attr_accessor :access_token, :debug
    
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
      res = conn.start do |http|
        req = request_class(method).new(uri.request_uri)
        add_headers(req)
        add_form_data(req,params)
        dump_request(req) if debug
        http.request(req)
      end
      dump_response(res) if debug
      res
    end
    
    def build_uri(method,path,params={})
      uri_parts = [SITE,path]
      if method == :get && !params.empty?
        uri_parts << to_query_string(params)
      end
      URI.join(*uri_parts)
    end
    
    private
      def dump_request(req)
        puts "Sending Request"
        puts"#{req.method} #{req.path}"
        dump_headers(req)
        if req.body_exist?
          puts
          puts req.body
        end
        puts
      end
      
      def dump_response(res)
        puts "Response"
        puts "#{res.code} #{res.message}"
        dump_headers(res)
        puts
        puts res.body
      end
      
      def dump_headers(msg)
        msg.each_header do |key, value|
          puts "#{key}=#{value}"
        end
      end
      
      def add_headers(req)
        req["User-Agent"] = "graphl/#{Grafl::VERSION}"  
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