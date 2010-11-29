module Grafl
  
  class Auth
    
    attr_accessor :graph, :client_id, :client_secret, :redirect_uri
    
    def initialize(graph,options={})
      self.graph = graph
      self.client_id = options[:client_id]
      self.client_secret = options[:client_secret]
      self.redirect_uri = options[:redirect_uri]
    end
    
    def authorize_url(other_params={})
      params = {
        :client_id=>client_id,:redirect_uri=>redirect_uri
      }.merge(other_params)
      graph.build_uri(:get,"oauth/authorize",params).to_s
    end
    
    def authorize!(code)
      response = graph.request(
        :get, "oauth/access_token",
        :client_id=>client_id, :redirect_uri=>redirect_uri,
          :client_secret=>client_secret, :code=>code
      )
      process_response(response)
    end
    
    def authorize_application!
      response = graph.request(
        :get, "oauth/access_token",
        :client_id=>client_id, :client_secret=>client_secret, 
          :grant_type=>:client_credentials
      )
      process_response(response)      
    end
    
    private
      def process_response(response)
        auth_node = Node.new(graph)
        response.body.split("&").inject({}) do |h,kv|
          key,value = kv.split("=")
          auth_node[key] = value
        end
        graph.access_token = auth_node.access_token
        auth_node
      end    
    
  end
  
end