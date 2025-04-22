# frozen_string_literal: true

load 'lib/dvla/kaping/version.rb'
GEMFILE_VERSION = DVLA::Kaping::VERSION
DVLA::Kaping.send(:remove_const, :VERSION)

Gem::Specification.new do |spec|
  spec.name = 'dvla-kaping'
  spec.version = GEMFILE_VERSION
  spec.authors = ['Driver and Vehicle Licensing Agency (DVLA)', 'Kevin Upstill']
  spec.email = ['Kevin.Upstill@dvla.gov.uk']

  spec.summary = 'Idiomatic way to create DSL openSearch definitions'
  spec.description = 'Wrapper for the AWS elastic search API to create an idiomatic way to build complex search queries'
  spec.homepage = 'https://github.com/dvla/kaping'
  spec.required_ruby_version = '>= 3'
  spec.license = 'MIT'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  # spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git appveyor Gemfile])
    end
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = %w[lib]

  spec.add_dependency 'nokogiri', '~> 1.18', '>= 1.18.4'
end
