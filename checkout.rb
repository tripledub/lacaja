require_relative 'discount_rule'

class Checkout
  attr_reader :items, :pricing_rules

  def initialize(pricing_rules: [])
    @items = {}
    @pricing_rules = pricing_rules
  end

  def scan(product_code:)
    items[product_code] ||= 0
    items[product_code] += 1
  end

  def total
    items.inject(0) do |subtotal, (product_code, quantity)|
      subtotal + rule_for(product_code:).price_for(quantity:)
    end
  end

  private

  def rule_for(product_code:)
    pricing_rules.find { |rule| rule.handles?(product_code:) }
  end
end
