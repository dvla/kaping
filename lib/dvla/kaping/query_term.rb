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

      def exists(field, value)
        current_operation << {
          exists: { "#{field}": value },
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
