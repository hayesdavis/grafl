module Grafl
  
  class Error < StandardError
    attr_accessor :method, :uri, :status, :body, :raw_body, :response_headers
  
    def initialize(uri, request, response, body, msg=nil)
      self.method = request.method
      self.uri = uri
      self.status = response.code.to_i
      self.body = body
      self.raw_body = response.body
      self.response_headers = {}
      response.each_header do |key,value|
        self.response_headers[key] = value
      end
      super(msg||"#{self.method} #{self.uri.path} => #{self.status}")
    end
  end
  
end