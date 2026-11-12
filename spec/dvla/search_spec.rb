# frozen_string_literal: true

require 'dvla/kaping'

RSpec.describe DVLA::Kaping::Search do
  before do
    allow(DVLA::Kaping).to receive(:search).and_return([{ _index: 'index', _id: '0000001111122222', _score: 3.1183596 }])
    allow_any_instance_of(DVLA::Kaping::AWSClient).to receive(:connect).and_return(:con)
  end

  describe '#search' do
    it 'can do a search' do
      body = '{"query":{"bool":{"must":[{"match_phrase":{"foo.type":"bar"}}]}}}'
      result = DVLA::Kaping.search(body)
      expect(result[0][:_id]).to eq('0000001111122222')
    end
  end

  describe '#search_client memoisation' do
    before { DVLA::Kaping.reset_client! }
    after { DVLA::Kaping.reset_client! }

    it 'builds the client once and reuses it across searches' do
      fake_client = instance_double('OpenSearch::Aws::Sigv4Client')
      allow(fake_client).to receive(:search).and_return([])
      # unstub the top-level search so the real body runs
      allow(DVLA::Kaping).to receive(:search).and_call_original
      allow(DVLA::Kaping).to receive(:yaml).and_return({ kaping_index: 'i', kaping_result_size: 10 })

      expect(DVLA::Kaping::AWSClient).to receive(:new).once.and_return(
        instance_double(DVLA::Kaping::AWSClient, connect: fake_client),
      )

      DVLA::Kaping.search('{}')
      DVLA::Kaping.search('{}')

      expect(fake_client).to have_received(:search).twice
    end

    it 'uses an injected client when provided' do
      injected = instance_double('OpenSearch::Aws::Sigv4Client')
      expect(DVLA::Kaping::AWSClient).not_to receive(:new)
      expect(DVLA::Kaping.search_client(injected)).to eq(injected)
    end

    it 'rebuilds after reset_client!' do
      first = instance_double(DVLA::Kaping::AWSClient, connect: :first_con)
      second = instance_double(DVLA::Kaping::AWSClient, connect: :second_con)
      allow(DVLA::Kaping::AWSClient).to receive(:new).and_return(first, second)

      expect(DVLA::Kaping.search_client).to eq(:first_con)
      expect(DVLA::Kaping.search_client).to eq(:first_con)
      DVLA::Kaping.reset_client!
      expect(DVLA::Kaping.search_client).to eq(:second_con)
    end
  end
end
