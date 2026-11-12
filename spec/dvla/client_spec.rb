require 'dvla/kaping/aws_client'

RSpec.describe DVLA::Kaping::AWSClient do
  let(:logger) { instance_double(Logger) }
  before do
    @sts_client = Aws::STS::Client.new(stub_responses: true)
    @signer = Aws::Sigv4::Signer.new(stub_responses: true, region: 'eu-west-2', service: 'es', credentials_provider: @sts_client)
    @stub_client = OpenSearch::Aws::Sigv4Client.new({ stub_responses: true, region: 'eu-west-2' }, @signer)
  end

  context '#connect ' do
    it 'connects to a OpenSeach Client' do
      allow(DVLA::Kaping::AWSClient).to receive(:new).and_return(@client)
      allow(@client).to receive(:connect).and_return(@stub_client)
      stub = DVLA::Kaping::AWSClient.new
      con = stub.connect
      expect(con.class).to eql OpenSearch::Aws::Sigv4Client
    end
  end

  it 'catch error' do
    error = 'assume_role_profile: AWS credentials Issue: The security token included in the request is expired  Aws::STS::Errors::ExpiredToken'
    allow(DVLA::Kaping::AWSClient).to receive(:new).and_return(@client)
    allow(@client).to receive(:connect).and_return(@stub_client).and_raise(error)
    stub = DVLA::Kaping::AWSClient.new
    expect { stub.connect }.to raise_error(an_instance_of(RuntimeError).and(having_attributes(message: error)))
  end

  context '#select_credentials' do
    it 'raises a clear error for an unrecognised credential_type' do
      allow(DVLA::Kaping).to receive(:yaml).and_return({ aws: { credential_type: 'bogus' } })
      client = DVLA::Kaping::AWSClient.new
      expect { client.select_credentials }
        .to raise_error(ArgumentError, /Unrecognised aws.credential_type: "bogus"/)
    end

    it 'resolves credentials via the default chain for the credentials type' do
      allow(DVLA::Kaping).to receive(:yaml).and_return({ aws: { credential_type: 'credentials' } })
      expect_any_instance_of(Aws::CredentialProviderChain).to receive(:resolve).and_return(:creds)
      client = DVLA::Kaping::AWSClient.new
      expect(client.select_credentials).to eq(:creds)
    end
  end

  context '#connect credential guard' do
    it 'raises a clear error when credentials cannot be resolved' do
      allow(DVLA::Kaping).to receive(:yaml).and_return({ aws: { credential_type: 'credentials' } })
      allow_any_instance_of(Aws::CredentialProviderChain).to receive(:resolve).and_return(nil)
      client = DVLA::Kaping::AWSClient.new
      expect { client.connect }.to raise_error(/Unable to resolve AWS credentials/)
    end
  end


  # it 'initializes with correct config settings' do
  #   client = DVLA::Kaping::AWSClient.new
  #   expect(client.instance_variable_get(:@role)).to eql 'QE'
  #   expect(client.instance_variable_get(:@base_url)).to eq 'test'
  #   expect(client.instance_variable_get(:@aws_account_id)).to eq 0
  # end
end
