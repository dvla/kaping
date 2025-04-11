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
end
