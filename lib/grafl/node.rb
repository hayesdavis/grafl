module Grafl
  
  # An OpenStruct-like class that doesn't suffer from OpenStruct's horrible 
  # memory issues.
  class Node
    
    attr_accessor :graph
    
    def initialize(graph)
      self.graph = graph
      @attributes = {}
    end
    
    def [](name)
      @attributes[name.to_sym]
    end
    
    def []=(name,value)
      @attributes[name.to_sym] = value
    end
    
    def method_missing(name,*args)
      if name.to_s =~ /(.*)=$/
        self[$1] = args.first
      else
        self[name]
      end
    end

    def respond_to?(name)
      true
    end
    
    def marshal_dump
      @attributes
    end
    
    def marshal_load(obj)
      @attributes = obj
    end
    
    def id
      self[:id]
    end
    
    def id=(value)
      self[:id] = value
    end
    
    def each(&block)
      @attributes.each(&block)
    end
    
    def /(*args)
      get(*args.flatten)
    end
    
    def get(*args)
      request(:get,*args)      
    end
    
    def post!(*args)
      request(:post,*args)
    end
    
    def delete!(*args)
      request(:delete,*args)
    end
    
    def request(method,*args)
      object_id, params = extract_request_args(*args)
      object_id = absolutize_object_id(object_id)
      response = graph.request(method,object_id,params)
      process_response(object_id,response)
    end
    
    def to_s
      "<Grafl::Node@#{_uri} #{@attributes}>"
    end
    
    def _uri
      graph.build_uri(:get,id||'').to_s
    end

    def _metadata
      get(:metadata=>1)
    end
    
    def _attributes
      @attributes
    end
        
    protected
      def extract_request_args(*args)
        arg = args.shift
        if arg.kind_of?(Hash)
          [nil,arg]
        else
          [arg.to_s,args.shift]
        end
      end
      
      def absolutize_object_id(object_id)
        [id,object_id].compact.join("/")
      end

      def process_response(object_id,response)
        node = build_response_recursive(JSON.parse(response.body))
        if node.id.nil? && object_id && object_id.length > 0
          node.id = object_id
        end
        node
      end
      
      def build_response_recursive(value)
        if value.class == Hash
          build_node(value)
        elsif value.class == Array
          value.map{|v| build_response_recursive(v)}
        else
          value
        end
      end
    
      def build_node(hash)
        node = Node.new(self.graph)
        hash.each do |key,v|
          node[key] = build_response_recursive(v)
        end
        node
      end 
 
  end  
  
end