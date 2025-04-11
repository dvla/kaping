# frozen_string_literal: true

RSpec.describe DVLA::Kaping do
  let(:yaml_path) { './spec/config/kaping.yml' }


  it 'has a version number' do
    expect(DVLA::Kaping::VERSION).not_to be nil
  end

  it 'sets up the logger' do
    logger = DVLA::Kaping.logger
    expect(logger).to be_a(Logger)
  end

  it 'sets up the yaml path' do
    yaml = DVLA::Kaping.yaml
    expect(yaml).not_to be nil
  end

  it 'sets up the yaml path' do
    config = DVLA::Kaping.configure { |attr| attr.yaml_override_path = './spec/config/kaping.yml' }
    expect(config).not_to be nil
  end
end
