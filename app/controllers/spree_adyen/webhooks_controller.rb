module SpreeAdyen
  class WebhooksController < ApplicationController
    skip_before_action :verify_authenticity_token

    def create
      SpreeAdyen::Webhooks::HandleEvent.new(raw_data: request.body.read).call

      head :ok
    end
  end
end
