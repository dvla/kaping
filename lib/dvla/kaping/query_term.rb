# assumes @operation exists
# assumes @last_operation exists

module DVLA
  module Kaping
    module Constants
      ALLOWED_PARAMS = :minimum_should_match
    end

    module QueryTerm
      def match_phrase(field, value, **kwargs)
        current_operation << {
          match_phrase: { "#{field}": value },
        }
        current_params(kwargs)
        self
      end

      def match(field, value)
        current_operation << {
          match: { "#{field}": value },
        }
        self
      end

      # Checks that a field exists. Per the OpenSearch `exists` query the shape
      # is { "exists": { "field": "<name>" } }.
      #
      #   q.must_not.exists('drivingLicence.migrationErrors')
      #
      # The legacy two-argument form exists('field', '<name>') is still accepted
      # for backward compatibility and reproduces its original output.
      def exists(field, value = nil)
        clause = value.nil? ? { field: field } : { "#{field}": value }
        current_operation << {
          exists: clause,
        }
        self
      end

      def wildcard(field, value)
        current_operation << {
          wildcard: { "#{field}": value },
        }
        self
      end

      def term(field, value)
        current_operation << {
          term: { "#{field}": value },
        }
        self
      end

      def prefix(field, value)
        current_operation << {
          prefix: { "#{field}": value },
        }
        self
      end

      def regex(field, value)
        current_operation << {
          regex: { "#{field}": value },
        }
        self
      end

      def between(field, *args)
        fragment = case args
                   in [Range]
                     { gte: args.first.first, lte: args.first.last }
                   in [String, String]
                     { gte: args.first, lte: args.last }
                   in [Hash]
                     args.first
                   else
                     raise ArgumentError, "Expected either a range or a upper and lower bounds, got #{args}"
                   end
        current_operation << {
          range: { "#{field}": fragment },
        }
        self
      end

      # Wrap one or more conditions in a nested query, for fields mapped as the
      # OpenSearch `nested` type. See
      # https://docs.opensearch.org/latest/query-dsl/joining/nested/
      #
      # The block yields an inner builder. Conditions added via `must` (the
      # default context) are combined so they must all match the SAME nested
      # object. The inner builder also supports `should`/`must_not`/`filter`
      # for more complex nested conditions (e.g. "any of these codes").
      #
      #   q.must.nested('entitlement') { |n| n.match_phrase('entitlement.categoryStatus', 'Valid') }
      #
      #   q.must.nested('entitlement') do |n|
      #     n.match_phrase('entitlement.categoryStatus', 'Valid')
      #     n.should.
      #       match_phrase('entitlement.categoryCode', 'C').
      #       match_phrase('entitlement.categoryCode', 'D')
      #   end
      #
      # Optional OpenSearch parameters (score_mode, ignore_unmapped, inner_hits)
      # may be passed as keyword arguments and are included only when provided.
      def nested(path, score_mode: nil, ignore_unmapped: nil, inner_hits: nil)
        raise ArgumentError, 'nested requires a block to build the inner query' unless block_given?

        inner = DVLA::Kaping::Query.new('bool')
        yield inner.must
        inner_ops = inner.send(:operations).reject { |_op, clauses| clauses.respond_to?(:empty?) && clauses.empty? }

        raise ArgumentError, 'nested block produced no conditions' if inner_ops.empty?

        inner_query =
          if inner_ops.keys == [:must] && inner_ops[:must].size == 1
            inner_ops[:must].first
          else
            { bool: inner_ops }
          end

        clause = { path: path, query: inner_query }
        clause[:score_mode] = score_mode unless score_mode.nil?
        clause[:ignore_unmapped] = ignore_unmapped unless ignore_unmapped.nil?
        clause[:inner_hits] = inner_hits unless inner_hits.nil?

        current_operation << { nested: clause }
        self
      end

      def current_operation
        operations[last_operation]
      end

      def current_params(value)
        if value.key?(Constants::ALLOWED_PARAMS)
          operations.merge!(value)
        end
      end
    end
  end
end
