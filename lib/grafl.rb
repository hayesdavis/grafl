require 'json'
require 'net/http'
require 'net/https'
require 'uri'

require 'grafl/version'
require 'grafl/uri_utils'
require 'grafl/graph'
require 'grafl/node'
require 'grafl/auth'

module Grafl

  def root(options={})
    Node.new(Graph.new(options))
  end
  
  def auth(options={})
    Auth.new(Graph.new,options)
  end
  
  extend self

end