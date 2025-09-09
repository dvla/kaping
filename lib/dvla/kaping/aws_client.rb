# frozen_string_literal: true

require 'opensearch-aws-sigv4'
require 'aws-sigv4'
require 'aws-sdk-sts'

module DVLA
  module Kaping
    class AWSClient
      def initialize
        @base_url = Kaping.yaml[:kaping_host]
        @aws_account_id = Kaping.yaml.dig(:aws, :account_id)
        @role = Kaping.yaml.dig(:aws, :role)
        @region = Kaping.yaml.dig(:aws, :region)
        Kaping.logger.info { "Kaping Client | base_url: '#{@base_url}'" }
      end

      def connect
        credentials = if Kaping.yaml.dig(:aws, :credential_type) == 'profile'
                        assume_role_profile(@aws_account_id, @role)
                      else
                        assume_role_env(@aws_account_id, @role)
                      end

        signer = Aws::Sigv4::Signer.new(service: 'es',
                                        region: @region,
                                        credentials_provider: credentials)

        OpenSearch::Aws::Sigv4Client.new({
                                      host: @base_url,
                                      log: false,
                                    }, signer)
      end

    private

      # @returns aws credentials using a profile
      def assume_role_profile(aws_account_id, role)
        role_arn = "arn:aws:iam::#{aws_account_id}:role/#{role}"
        sts = Aws::STS::Client.new(region: @region, profile: Kaping.yaml.dig(:aws, :profile))
        sts.assume_role(role_arn: role_arn, role_session_name: 'kaping')
      rescue Aws::STS::Errors::ServiceError => e
        raise "#{__method__}: AWS Profile Credentials Issue: #{e.message}  #{e.class.name}"
      end

      # via ENV settings - these are pick up directly
      def assume_role_env(aws_account_id, role)
        role_arn = "arn:aws:iam::#{aws_account_id}:role/#{role}"
        sts = Aws::STS::Client.new(region: @region)
        sts.assume_role(role_arn: role_arn, role_session_name: 'kaping')
      rescue Aws::STS::Errors::ServiceError => e
        raise "#{__method__}: AWS ENV Credentials Issue: #{e.message}  #{e.class.name}"
      end
    end
  end
end
