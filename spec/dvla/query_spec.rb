# frozen_string_literal: true

require 'dvla/kaping/query'

RSpec.describe DVLA::Kaping::Query do
  let(:bool_query) { DVLA::Kaping::Query.new('bool') }

  describe '#query' do
    it 'boolean query type' do
      q = DVLA::Kaping::Query.new('bool')
      expect(q.query_type).to eq 'bool'
    end

    it 'match query type' do
      q = DVLA::Kaping::Query.new('match')
      expect(q.query_type).to eq 'match'
    end

    # this is a valid query
    # https://opensearch.org/docs/latest/query-dsl/full-text/match-phrase/
    #     {
    #   "query": {
    #     "match_phrase": {
    #       "foo": "BAR"
    #     }
    #   }
    # }
    it ' match_phrase query' do
      q = DVLA::Kaping::Query.new('match_phrase', foo: 'Bar')
      test_query = '{"query":{"match_phrase":{"foo":"Bar"}}}'
      expect(q.to_json).to eq(test_query)
    end

    it ' match_phrase query' do
      q = DVLA::Kaping::Query.new('match_phrase', foo: 'Bar', bar: 'Foo')
      test_query = '{"query":{"match_phrase":{"foo":"Bar","bar":"Foo"}}}'
      expect(q.to_json).to eq(test_query)
    end

    it ' match query' do
      q = DVLA::Kaping::Query.new('match', foo: 'Bar')
      test_query = '{"query":{"match":{"foo":"Bar"}}}'
      expect(q.to_json).to eq(test_query)
    end

    it 'match_all query' do
      q = DVLA::Kaping::Query.new('match_all')
      test_query = '{"query":{"match_all":{}}}'
      expect(q.to_json).to eq(test_query)
    end

    it 'query boolean filter' do
      q = DVLA::Kaping::Query.new('bool')
      q.filter.term('bar.status', 'Valid').
        between('foo.dob', '1958-08-21', '1970-08-21')
      test_query = '{"query":{"bool":{"filter":[{"term":{"bar.status":"Valid"}},{"range":{"foo.dob":{"gte":"1958-08-21","lte":"1970-08-21"}}}]}}}'
      expect(q.to_json).to eq(test_query)
    end

    it 'query term match_phrase' do
      q = DVLA::Kaping::Query.new('bool')
      q.must.match_phrase('bar.type', 'Full')
      test_query = '{"query":{"bool":{"must":[{"match_phrase":{"bar.type":"Full"}}]}}}'
      expect(q.to_json).to eq(test_query)
    end

    it 'query term exists' do
      q = DVLA::Kaping::Query.new('bool')
      q.must.exists('bar.type', 'Full')
      test_query = '{"query":{"bool":{"must":[{"exists":{"bar.type":"Full"}}]}}}'
      expect(q.to_json).to eq(test_query)
    end

    it 'query term exists with a single field name' do
      q = DVLA::Kaping::Query.new('bool')
      q.must_not.exists('drivingLicence.migrationErrors')
      test_query = '{"query":{"bool":{"must_not":[{"exists":{"field":"drivingLicence.migrationErrors"}}]}}}'
      expect(q.to_json).to eq(test_query)
    end

    it 'query term wildcard' do
      q = DVLA::Kaping::Query.new('bool')
      q.must.wildcard('bar.type', 'Full*')
      test_query = '{"query":{"bool":{"must":[{"wildcard":{"bar.type":"Full*"}}]}}}'
      expect(q.to_json).to eq(test_query)
    end

    it 'query term filter with term' do
      q = DVLA::Kaping::Query.new('bool')
      q.filter.term('foo.type', 'Bar')
      test_query = '{"query":{"bool":{"filter":[{"term":{"foo.type":"Bar"}}]}}}'
      expect(q.to_json).to eq(test_query)
    end

    it 'query term filter with range' do
      DateTime.now.strftime('%Y-%m-%d')
      q = DVLA::Kaping::Query.new('bool')
      q.must.between('foo.bar', 1..10)
      test_query = '{"query":{"bool":{"must":[{"range":{"foo.bar":{"gte":1,"lte":10}}}]}}}'
      expect(q.to_json).to eq(test_query)
    end

    it 'query term filter with range of strings' do
      q = DVLA::Kaping::Query.new('bool')
      q.must.between('foo.bar', '1958-08-21', 'string')
      test_query = '{"query":{"bool":{"must":[{"range":{"foo.bar":{"gte":"1958-08-21","lte":"string"}}}]}}}'
      expect(q.to_json).to eq(test_query)
    end

    #  could just be gte: or lte:
    it 'query term filter with range of hash' do
      q = DVLA::Kaping::Query.new('bool')
      q.must.between('foo.bar', gte: '1958-08-21')
      test_query = '{"query":{"bool":{"must":[{"range":{"foo.bar":{"gte":"1958-08-21"}}}]}}}'
      expect(q.to_json).to eq(test_query)
    end

    it 'query term filter with range of hash' do
      q = DVLA::Kaping::Query.new('bool')
      q.must.between('foo.bar', lte: '1958-08-21')
      test_query = '{"query":{"bool":{"must":[{"range":{"foo.bar":{"lte":"1958-08-21"}}}]}}}'
      expect(q.to_json).to eq(test_query)
    end

    it 'query term filter with valid ranges' do
      args = DateTime.now.strftime('%Y-%m-%d')
      q = DVLA::Kaping::Query.new('bool')
      expect { q.must.between('foo.bar', args) }
        .to raise_error(ArgumentError)
    end

    it 'match query term' do
      q = DVLA::Kaping::Query.new('bool')
      q.must.match('foo.type', 'bar')
      test_query = '{"query":{"bool":{"must":[{"match":{"foo.type":"bar"}}]}}}'
      expect(q.to_json).to eq(test_query)
    end

    it 'match query type - must not' do
      q = DVLA::Kaping::Query.new('bool')
      q.must_not.match('foo.type', 'bar')
      test_query = '{"query":{"bool":{"must_not":[{"match":{"foo.type":"bar"}}]}}}'
      expect(q.to_json).to eq(test_query)
    end

    it 'match query type - filter' do
      q = DVLA::Kaping::Query.new('bool')
      q.filter.match('foo.type', 'bar')
      test_query = '{"query":{"bool":{"filter":[{"match":{"foo.type":"bar"}}]}}}'
      expect(q.to_json).to eq(test_query)
    end

    it 'match query type - should' do
      q = DVLA::Kaping::Query.new('bool')
      q.should.match_phrase('foo.type', 'bar')
      test_query = '{"query":{"bool":{"should":[{"match_phrase":{"foo.type":"bar"}}]}}}'
      expect(q.to_json).to eq(test_query)
    end

    it 'match query type - prefix' do
      q = DVLA::Kaping::Query.new('bool')
      q.must.prefix('foo', 'bar')
      test_query = '{"query":{"bool":{"must":[{"prefix":{"foo":"bar"}}]}}}'
      expect(q.to_json).to eq(test_query)
    end

    #  not testing regex - just the query format
    it 'match query type - regex' do
      q = DVLA::Kaping::Query.new('bool')
      q.must.regex('foo', '[a-zA-Z]amlet')
      test_query = '{"query":{"bool":{"must":[{"regex":{"foo":"[a-zA-Z]amlet"}}]}}}'
      expect(q.to_json).to eq(test_query)
    end

    #  to be implemented - ability to pass in parameters
    it 'match query type - should, with minimum match' do
      q = DVLA::Kaping::Query.new('bool')
      q.should.match_phrase('foo.type', 'bar soup baz bing', minimum_should_match: 1)
      test_query = '{"query":{"bool":{"should":[{"match_phrase":{"foo.type":"bar soup baz bing"}}],"minimum_should_match":1}}}'
      expect(q.to_json).to eq(test_query)
    end

    # https://docs.opensearch.org/latest/query-dsl/joining/nested/
    it 'nested query with a single condition' do
      q = DVLA::Kaping::Query.new('bool')
      q.must.nested('entitlement') { |n| n.match_phrase('entitlement.categoryStatus', 'Valid') }
      test_query = '{"query":{"bool":{"must":[{"nested":{"path":"entitlement","query":{"match_phrase":{"entitlement.categoryStatus":"Valid"}}}}]}}}'
      expect(q.to_json).to eq(test_query)
    end

    it 'nested query with multiple conditions matching the same object' do
      q = DVLA::Kaping::Query.new('bool')
      q.must.nested('entitlement') do |n|
        n.match_phrase('entitlement.categoryCode', 'C').
          match_phrase('entitlement.categoryStatus', 'Valid')
      end
      test_query = '{"query":{"bool":{"must":[{"nested":{"path":"entitlement","query":{"bool":{"must":[{"match_phrase":{"entitlement.categoryCode":"C"}},{"match_phrase":{"entitlement.categoryStatus":"Valid"}}]}}}}]}}}'
      expect(q.to_json).to eq(test_query)
    end

    it 'nested query used as a must_not exclusion' do
      q = DVLA::Kaping::Query.new('bool')
      q.must_not.nested('entitlement') { |n| n.match_phrase('entitlement.categoryCode', 'D') }
      test_query = '{"query":{"bool":{"must_not":[{"nested":{"path":"entitlement","query":{"match_phrase":{"entitlement.categoryCode":"D"}}}}]}}}'
      expect(q.to_json).to eq(test_query)
    end

    it 'nested query chaining multiple nested clauses' do
      q = DVLA::Kaping::Query.new('bool')
      q.must_not.
        nested('entitlement') { |n| n.match_phrase('entitlement.categoryCode', 'C') }.
        nested('entitlement') { |n| n.match_phrase('entitlement.categoryCode', 'D') }
      test_query = '{"query":{"bool":{"must_not":[{"nested":{"path":"entitlement","query":{"match_phrase":{"entitlement.categoryCode":"C"}}}},{"nested":{"path":"entitlement","query":{"match_phrase":{"entitlement.categoryCode":"D"}}}}]}}}'
      expect(q.to_json).to eq(test_query)
    end

    it 'nested query with optional parameters' do
      q = DVLA::Kaping::Query.new('bool')
      q.must.nested('entitlement', score_mode: 'max', ignore_unmapped: true) do |n|
        n.match_phrase('entitlement.categoryStatus', 'Valid')
      end
      test_query = '{"query":{"bool":{"must":[{"nested":{"path":"entitlement","query":{"match_phrase":{"entitlement.categoryStatus":"Valid"}},"score_mode":"max","ignore_unmapped":true}}]}}}'
      expect(q.to_json).to eq(test_query)
    end

    it 'nested query with an inner should (any-of) alongside a must' do
      q = DVLA::Kaping::Query.new('bool')
      q.must.nested('entitlement') do |n|
        n.match_phrase('entitlement.categoryStatus', 'Valid')
        n.should.
          match_phrase('entitlement.categoryCode', 'C').
          match_phrase('entitlement.categoryCode', 'D')
      end
      test_query = '{"query":{"bool":{"must":[{"nested":{"path":"entitlement","query":{"bool":{"must":[{"match_phrase":{"entitlement.categoryStatus":"Valid"}}],"should":[{"match_phrase":{"entitlement.categoryCode":"C"}},{"match_phrase":{"entitlement.categoryCode":"D"}}]}}}}]}}}'
      expect(q.to_json).to eq(test_query)
    end

    it 'nested query raises without a block' do
      q = DVLA::Kaping::Query.new('bool')
      expect { q.must.nested('entitlement') }.to raise_error(ArgumentError)
    end

    it 'nested query raises when the block produces no conditions' do
      q = DVLA::Kaping::Query.new('bool')
      expect { q.must.nested('entitlement') { |_n| } }.to raise_error(ArgumentError) # rubocop:disable Lint/EmptyBlock
    end
  end
end
