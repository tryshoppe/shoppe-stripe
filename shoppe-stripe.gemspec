$:.push File.expand_path("../lib", __FILE__)

require "shoppe/stripe/version"

Gem::Specification.new do |s|
  s.name        = "shoppe-stripe"
  s.version     = Shoppe::Stripe::VERSION
  s.authors     = ["Adam Cooke"]
  s.email       = ["adam@niftyware.io"]
  s.homepage    = "http://tryshoppe.com"
  s.summary     = "A Stripe module for Shoppe."
  s.description = "A Stripe module to assist with the integration of Stripe."

  s.files = Dir["{lib,vendor}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]

  s.add_dependency "shoppe", "> 0.0.9", "< 1.1.0"
  s.add_dependency "stripe", "~> 1.8.7"
  s.add_dependency "coffee-rails", "~> 4.0.0"
end
