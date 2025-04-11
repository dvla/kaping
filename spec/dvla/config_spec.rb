require 'dvla/kaping'

RSpec.describe DVLA::Kaping::Config do
  let(:config) { DVLA::Kaping::Config.new }
  let(:yaml_path) { './spec/config/kaping.yml' }
  let(:yaml_override_path) { 'spec/config/kaping-override.yml' }

  it 'should warn when an object not of type Logger is passed' do
    expect(config).to receive(:warn).with("[WARN] Custom logger is not an instance of Logger: 'String'")
    config.logger = 'blah'
  end

  context 'initialize' do
    it 'should contain default attributes' do
      expect(config.logger).to be_a(Logger)
      expect(config.yaml).to be_a(Hash)
    end
  end

  it 'should warn when the new_logger is not an instance of Logger' do
    expect(config).to receive(:warn).with('[WARN] Custom logger is not an instance of Logger: \'String\'')
    config.logger = 'blah'
    expect(config.logger).to be_a(Logger)
  end

  it 'should override key/values that are the same in the existing yaml' do
    config.yaml_override_path = yaml_override_path
    expect(config.yaml[:kaping_host]).to eq('override_host')
    expect(config.yaml[:kaping_index]).to eq('override_index')
  end

  it 'should be able to set logging level' do
    log_level = config.log_level
    expect(config.yaml[:kaping_level]).to eq(log_level)
  end

  it 'should be a Logger' do
    log_new = config.logger
    expect(log_new.class).to eq(Logger)
  end
end
