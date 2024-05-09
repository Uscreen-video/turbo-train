# frozen_string_literal: true

require_relative 'lib/turbo/train/version'

Gem::Specification.new do |spec|
  spec.name        = 'turbo-train'
  spec.version     = Turbo::Train::VERSION
  spec.authors     = ['Nick Savrov', 'Dima Bondarenko']
  spec.email       = ['nick@uscreen.tv', 'dmitry@uscreen.tv']
  spec.homepage    = 'https://github.com/Uscreen-video/turbo-train'
  spec.summary     = 'Rails Turbo Stream broadcasting over SSE instead of WebSockets. Uses Mercure server.'
  spec.license     = 'MIT'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/goodsign/turbo-train-test'

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.md']
  end

  spec.add_dependency 'jwt'
  spec.add_dependency 'rails', '>= 6.1'
  spec.add_dependency 'turbo-rails'
end
