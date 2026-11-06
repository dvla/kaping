module DVLA
  module Kaping
    module Search
      # Connected OpenSearch client, built once and reused across searches.
      # Building a client resolves credentials and constructs a SigV4 signer,
      # so doing it per query is wasteful. The credentials provider resolved
      # for the `credentials` type is self-refreshing, so a reused client stays
      # valid as the underlying session refreshes.
      def search(body)
        search_client.search(
          index: Kaping.yaml[:kaping_index],
          body: body,
          size: Kaping.yaml[:kaping_result_size],
        )
      end

      # The memoised connected client. Pass an explicit client to use your own,
      # or call reset_client! to force a rebuild (e.g. after config changes).
      def search_client(client = nil)
        @search_client = client if client
        @search_client ||= DVLA::Kaping::AWSClient.new.connect
      end

      def reset_client!
        @search_client = nil
      end
    end
  end
end
