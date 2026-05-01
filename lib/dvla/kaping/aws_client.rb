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
        @region = Kaping.yaml.dig(:aws, :region) || 'eu-west-2'
        Kaping.logger.debug { "AWS Client | base_url: '#{@base_url}'" }
      end

      def select_credentials
        case Kaping.yaml.dig(:aws, :credential_type)
        when 'profile'
          assume_role_profile(@aws_account_id, @role)
        when 'env'
          assume_role_env(@aws_account_id, @role)
        when 'credentials'
          Aws::CredentialProviderChain.new.resolve
        else
          logger.warn { 'Credential type not recognised, please set an option: profile, env or credentials' }
        end
      end

      def connect
        credentials = select_credentials

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
        resp = sts.assume_role(role_arn: role_arn, role_session_name: 'kaping')
        Aws::Credentials.new(resp.credentials.access_key_id, resp.credentials.secret_access_key,
                             resp.credentials.session_token)
      rescue Aws::STS::Errors::ServiceError => e
        raise "#{__method__}: AWS Profile Credentials Issue: #{e.message}  #{e.class.name}"
      end

      # via ENV settings - these are pick up directly
      def assume_role_env(aws_account_id, role)
        role_arn = "arn:aws:iam::#{aws_account_id}:role/#{role}"
        sts = Aws::STS::Client.new(region: @region)
        resp = sts.assume_role(role_arn: role_arn, role_session_name: 'kaping')
        Aws::Credentials.new(resp.credentials.access_key_id, resp.credentials.secret_access_key,
                             resp.credentials.session_token)
      rescue Aws::STS::Errors::ServiceError => e
        raise "#{__method__}: AWS ENV Credentials Issue: #{e.message}  #{e.class.name}"
      end
    end
  end
end
