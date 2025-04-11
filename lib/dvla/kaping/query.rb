require_relative 'query_term'

module DVLA
  module Kaping
    class Query
      include QueryTerm

      BOOL = 'bool'.freeze
      MATCH = 'match'.freeze

      attr_reader :query_type, :kwargs
      protected attr_reader :operations, :parameters
      protected attr_accessor :last_operation

      def initialize(type, **kwargs)
        super()
        @last_operation = nil
        @query_type = type
        @operations ||= {}
        @kwargs = kwargs
      end

      #  associated with Boolean query
      %i[must must_not should filter].each do |op|
        define_method(op) do
          @last_operation = op
          operations[op] ||= []
          self
        end
      end

      def to_json(*_args)
        if kwargs.empty?
          { query: { "#{query_type}": operations } }.to_json
        else
          { query: { "#{query_type}": kwargs } }.to_json
        end
      end
    end
  end
end
