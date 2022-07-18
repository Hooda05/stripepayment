class WebhooksController < ApplicationController
    skip_before_action :authenticate_user!
    skip_before_action :verify_authenticity_token

    def create
        payload = request.body.read
        sig_header = request.env['HTTP_STRIPE_SIGNATURE']
        event = nil

        begin
            event = Stripe::Webhook.construct_event(
                payload, sig_header, Rails.application.credentials[:stripe][:webhook]
            )
        rescue JSON::ParserError => e
            status 400
            return
        rescue Stripe::SignatureVerificationError => e
            puts 'Signature error'
            puts e
            return
        end

        # handle the event
        case event.type
        when 'checkout.session.completed'
            session = event.data.object
            session = Stripe::Checkout::Session.retrieve({
                id: session.id,
                expand: ["line_items"]
            })
            @line_items = session.line_items
            @line_items.each do |line_item|
                product = Product.find_by(stripe_product_id: line_item.price.product)
                product.increment!(:sales_count)
            end
        end

        render json: { message: 'success' }
    end
end
