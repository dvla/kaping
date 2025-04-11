module DVLA
  module Kaping
    module Search
      #  could pass in a home rolled client
      def search(body)
        client = DVLA::Kaping::AWSClient.new
        con = client.connect
        con.search(
          index: Kaping.yaml[:kaping_index],
          body: body,
          size: Kaping.yaml[:kaping_result_size],
        )
      end
    end
  end
end
