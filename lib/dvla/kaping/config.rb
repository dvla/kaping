# frozen_string_literal: true

require 'yaml'
require 'active_support/core_ext/hash/deep_merge'


module DVLA
  module Kaping
    class Config
      attr_accessor :yaml
      attr_reader :logger, :yaml_override_path

      ATTRIBUTES = %w[host index result_size log_level].freeze
      attr_accessor(*ATTRIBUTES)

      def initialize
        @yaml = load_yaml(Dir["#{Dir.pwd}/**/kaping.yml"].first)

        ATTRIBUTES.each do |attr|
          instance_variable_set(:"@#{attr}", ENV.fetch(attr.to_s.upcase, nil))
        end

        @logger = Logger.new($stdout)
        @log_level ||= 'INFO'
        @result_size ||= 100
      end

      #   step 1 - find kaping.yml
      def load_yaml(path)
        path = "#{path}.yml" unless %w[.yaml .yml].include?(File.extname(path))

        if File.exist?(path)
          YAML.safe_load(ERB.new(File.read(path)).result, symbolize_names: true, aliases: true)
        else
          warn("[WARN] YAML file not found at: '#{path}'")
          nil
        end
      end

      def yaml_override_path=(path)
        unless path == @yaml_override_path
          @yaml_override_path = path

          merge_yaml(@yaml_override_path)
        end
      end

      def merge_yaml(path)
        config = load_yaml(path)

        @yaml = @yaml.deep_merge(config) unless config.nil?
      end

      def logger=(new_logger)
        if new_logger.is_a?(Logger)
          @logger = new_logger
          @logger.level = @yaml[kaping_log_level]
        else
          warn("[WARN] Custom logger is not an instance of Logger: '#{new_logger.class}'")
        end
      end

      def log_level(_log_level = @yaml.dig(:kaping, :log_level))
        @log
      end
    end
  end
end
