# frozen_string_literal: true

require 'erb'
require 'yaml'
require 'logger'
require 'active_support/core_ext/hash/deep_merge'


module DVLA
  module Kaping
    class Config
      attr_accessor :yaml
      attr_reader :logger, :yaml_override_path

      ATTRIBUTES = %w[host index result_size log_level].freeze
      attr_accessor(*ATTRIBUTES)

      # Maps the configured log level (symbol/string) to a Logger severity.
      LOG_LEVELS = {
        'debug' => Logger::DEBUG,
        'info' => Logger::INFO,
        'warn' => Logger::WARN,
        'error' => Logger::ERROR,
        'fatal' => Logger::FATAL,
        'unknown' => Logger::UNKNOWN,
      }.freeze

      def initialize
        @yaml = load_yaml(Dir["#{Dir.pwd}/**/kaping.yml"].first)

        # Allow KAPING_* environment variables to override the loaded values,
        # but only when the variable is actually set.
        ATTRIBUTES.each do |attr|
          env_value = ENV.fetch("KAPING_#{attr.upcase}", nil)
          instance_variable_set(:"@#{attr}", env_value) unless env_value.nil?
        end

        @result_size ||= 100

        @logger = Logger.new($stdout)
        @logger.level = resolved_log_severity
      end

      #   step 1 - find kaping.yml
      def load_yaml(path)
        if path.nil?
          warn('[WARN] No kaping.yml found')
          return nil
        end

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
          @logger.level = resolved_log_severity
        else
          warn("[WARN] Custom logger is not an instance of Logger: '#{new_logger.class}'")
        end
      end

      # The configured log level. Precedence: KAPING_LOG_LEVEL env var (captured
      # into @log_level during initialize) > the loaded YAML > 'INFO'.
      def log_level
        @log_level || (@yaml && @yaml[:kaping_log_level]) || 'INFO'
      end

    private

      # The configured log level mapped to a Logger severity, defaulting to INFO
      # for anything not recognised.
      def resolved_log_severity
        LOG_LEVELS.fetch(log_level.to_s.downcase, Logger::INFO)
      end
    end
  end
end
