# frozen_string_literal: true

require "./lib/sf_symbol_converter/version"

Gem::Specification.new do |s|
  s.required_ruby_version = '>= 2.7.0'
  s.name        = 'sf_symbol_converter'
  s.version     = SFSymbolConverter::VERSION
  s.summary     = 'Convert SVG icon to SFSymbol'
  s.description = 'Given a SVG icon with viewBox that respect [material icon principles](https://m3.material.io/styles/icons/designing-icons), generate appropriate SFSymbol'
  s.authors     = ['Yang Liu', 'Tycho Tatitscheff']
  s.email       = ['yangl@bam.tech', 'tychot@bam.tech']
  s.homepage    = 'https://github.com/tychota/SfSymbolExporter'
  s.license     = 'MIT'

  s.files       = Dir["lib/*"] + Dir["bin/*"] + Dir["assets/*"] + Dir['lib/**/*.rb'] + ['LICENSE', 'README.md']
  s.bindir      = 'bin'
  s.executables   = s.files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_runtime_dependency 'nokogiri', '~> 1.16', '>= 1.16.3'
  s.add_runtime_dependency 'thor', '~> 1.1', '>= 1.1.0'
end
