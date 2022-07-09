require_relative 'rules/absolute_price'
require_relative 'rules/buy_one_get_one_free'
require_relative 'rules/rational_price'

class DiscountRule
  def initialize(product:, rule:, discount_at: nil, new_price: nil)
    @product = product
    @rule = rule
    @discount_at = discount_at
    @new_price = new_price
  end

  def price_for(quantity:)
    rule.price_for(
      price: product.price,
      quantity:,
      discount_at:,
      new_price:
    )
  end

  def handles?(product_code:)
    product.product_code == product_code
  end

  private

  attr_reader :product, :rule, :discount_at, :new_price
end
