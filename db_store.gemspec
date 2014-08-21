$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "db_store/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "db_store"
  s.version     = DbStore::VERSION
  s.authors     = ["Lance Olsen"]
  s.email       = ["olsen.lance@gmail.com"]
  s.homepage    = "https://github.com/AnselAtoms/db_store"
  s.summary     = "Allow frontend testers to back up and restore the database from any page"
  s.description = "Allow frontend testers to back up and restore the database from any page"

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["rspec/**/*"]

  s.add_dependency "rails", "~> 3.2.19"
  s.add_dependency "jquery-rails"

  s.add_development_dependency "mysql"
end
