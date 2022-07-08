require_relative 'rules/buy_one_get_one_free'

class DiscountRule
  def initialize(product:, rule:)
    @product = product
    @rule = rule
  end

  def price_for(quantity:)
    rule.price_for(
      price: product.price,
      quantity:
    )
  end

  private

  attr_reader :product, :rule
end
