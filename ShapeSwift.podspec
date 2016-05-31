Pod::Spec.new do |s|
  s.name         = "ShapeSwift"
  s.version      = "0.0.1"
  s.summary      = "A Swift framework for reading shape files"
  #TODO: improve
  s.description  = "A Swift framework for reading shape files"

  s.homepage     = "http://EXAMPLE/ShapeSwift"
  s.license      = { :type => "MIT", :file => "LICENSE" }

  s.authors            = { "Ben Asher" => "benasher44@gmail.com",
                           "Noah Gilmore" => "noah.w.gilmore@gmail.com" }

  #TODO: audit
  s.ios.deployment_target = "8.0"
  s.osx.deployment_target = "10.10"
  s.watchos.deployment_target = "2.0"
  s.tvos.deployment_target = "9.0"

  s.source       = { :git => "https://github.com/benasher44/ShapeSwift", :tag => "#{s.version}" }


  s.source_files  = "ShapeSwift/*.swift"
  s.dependency "proj4"

end
