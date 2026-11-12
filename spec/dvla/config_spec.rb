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

  it 'should return the configured log level from the yaml' do
    expect(config.log_level).to eq('debug')
  end

  it 'should apply the configured log level to the default logger' do
    expect(config.logger.level).to eq(Logger::DEBUG)
  end

  it 'should let KAPING_LOG_LEVEL override the yaml log level' do
    allow(ENV).to receive(:fetch).and_call_original
    allow(ENV).to receive(:fetch).with('KAPING_LOG_LEVEL', nil).and_return('warn')
    expect(config.log_level).to eq('warn')
    expect(config.logger.level).to eq(Logger::WARN)
  end

  it 'should fall back to INFO for an unrecognised level' do
    allow(ENV).to receive(:fetch).and_call_original
    allow(ENV).to receive(:fetch).with('KAPING_LOG_LEVEL', nil).and_return('verbose')
    expect(config.logger.level).to eq(Logger::INFO)
  end

  it 'should set the logger severity from the configured log level' do
    custom = Logger.new($stdout)
    config.logger = custom
    expect(config.logger).to be(custom)
    expect(config.logger.level).to eq(Logger::DEBUG)
  end

  it 'should be a Logger' do
    log_new = config.logger
    expect(log_new.class).to eq(Logger)
  end
end
