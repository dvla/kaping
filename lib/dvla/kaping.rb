# frozen_string_literal: true

require 'json'
require_relative 'kaping/version'
require_relative 'kaping/config'
require_relative 'kaping/aws_client'
require_relative 'kaping/query'
require_relative 'kaping/query_term'
require_relative 'kaping/search'

module DVLA
  module Kaping
    extend DVLA::Kaping::Search

    CONFIG = "#{Gem::Specification.find_by_name('dvla-kaping').gem_dir.freeze}/config".freeze

    def self.config
      @config ||= DVLA::Kaping::Config.new
    end

    def self.configure
      yield config
    end

    def self.logger
      config.logger
    end

    def self.yaml
      logger.warn { 'Environment not set!'.red } unless config.yaml
      config.yaml || {}
    end
  end
end
