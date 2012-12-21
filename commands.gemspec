Gem::Specification.new do |s|
  s.name    = 'commands'
  s.version = '0.0.3'
  s.author  = 'David Heinemeier Hansson'
  s.email   = 'david@37signals.com'
  s.summary = 'Run Rake/Rails commands through the console'

  s.add_dependency 'rails', '>= 3.0.0'
  s.add_dependency 'm', '~> 1.3'

  s.files = Dir["#{File.dirname(__FILE__)}/**/*"]
end
