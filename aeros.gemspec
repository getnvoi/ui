require_relative "lib/aeros/version"

Gem::Specification.new do |spec|
  spec.name        = "aeros"
  spec.version     = Aeros::VERSION
  spec.authors     = [ "Ben" ]
  spec.email       = [ "ben@dee.mx" ]
  spec.homepage    = "https://github.com/getnvoi/ui"
  spec.summary     = "Rails engine providing reusable UI components with Tailwind CSS and Stimulus"
  spec.description = "A Rails engine providing ViewComponent-based UI components with Tailwind CSS styling and Stimulus controllers. Includes convenience helpers for easy integration into Rails engines."
  spec.license     = "MIT"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/getnvoi/ui"
  spec.metadata["changelog_uri"] = "https://github.com/getnvoi/ui/blob/main/CHANGELOG.md"
  spec.metadata["rubygems_mfa_required"] = "true"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  end

  spec.add_dependency "rails", ">= 8.0.3"
  spec.add_dependency "importmap-rails", "~> 2.2.2"
  spec.add_dependency "turbo-rails", "~> 2.0"
  spec.add_dependency "stimulus-rails", "~> 1.3"
  spec.add_dependency "tailwindcss-rails", ">= 4.3", "< 4.5"
  spec.add_dependency "view_component", "~> 4.0"
  spec.add_dependency "view_component-contrib", "~> 0.2.5"
  spec.add_dependency "dry-effects", "~> 0.5.0"

  spec.add_development_dependency "tailwind_merge", "~> 1.3"
end
