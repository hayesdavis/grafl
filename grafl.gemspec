$LOAD_PATH.unshift './lib'
require 'grafl/version'

Gem::Specification.new do |s|
  s.name              = "grafl"
  s.version           = Grafl::VERSION
  s.date              = Time.now.strftime('%Y-%m-%d')
  s.summary           = "Grafl is a handy way to talk to the Facebook Graph API"
  s.homepage          = "http://github.com/hayesdavis/grafl"
  s.email             = "hayes@appozite.com"
  s.authors           = [ "Hayes Davis" ]
  
  #s.files             = %w()
  s.files            += Dir.glob("lib/**/*")

  #s.extra_rdoc_files  = [ "LICENSE", "README.md" ]

  s.add_dependency "json", "> 1.0"

  s.description = <<-description
    An easy and lightweight way to Facebook's Graph API.
    
    CAVEAT EMPTOR: Oh so alpha

  description
end
