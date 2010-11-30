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
      req = request_class(method).new(uri.request_uri)
      res = conn.start do |http|
        add_headers(req)
        add_form_data(req,params)
        dump_request(req) if debug
        http.request(req)
      end
      dump_response(res) if debug
      process_response(uri,req,res)
    end
    
    def build_uri(method,path,params={})
      uri_parts = [SITE,path]
      if method == :get && !params.empty?
        uri_parts << to_query_string(params)
      end
      URI.join(*uri_parts)
    end
    
    private
      def process_response(uri,request,response)
        body = process_response_body(uri,request,response)
        status = response.code.to_i
        if status >= 400
          msg = body.error.message rescue nil
          raise Error.new(uri,request,response,body,msg)
        end
        if body.kind_of?(Node) && body.error
          raise Error.new(uri,request,response,body,body.error.message)
        end
        body
      end
      
      def process_response_body(uri,request,response)
        if response.content_type =~ /javascript|json/
          node = build_node(JSON.parse(response.body))
          path = uri.path
          if node.id.nil? && path && path.length > 0
            node.id = path
          end
          node
        else
          response.body
        end
      rescue => e
        raise Error.new(uri,request,response,response.body,
          "Unexpected error processing response: #{e}")
      end
      
      def build_node(value)
        if value.class == Hash
          value.inject(Node.new(self)) do |node, (key,v)|
            node[key] = build_node(v)
            node
          end
        elsif value.class == Array
          value.map{|v| build_node(v)}
        else
          value
        end
      end
    
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