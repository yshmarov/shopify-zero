class SyncStripeProductsJob < ApplicationJob
  queue_as :default

  def perform(*args)
    Stripe::Product.list(
      expand: [ "data.default_price" ]
    ).each do |stripe_product|
      product = Product.find_or_initialize_by(stripe_product_id: stripe_product.id)
      product.name = stripe_product.name
      product.stripe_product = stripe_product
      product.save!

      prices = Stripe::Price.list(product: stripe_product.id)
      prices.each do |stripe_price|
        price = Price.find_or_initialize_by(stripe_price_id: stripe_price.id)
        price.product = product
        price.stripe_price = stripe_price
        price.save!
      end
    end
  end
end
