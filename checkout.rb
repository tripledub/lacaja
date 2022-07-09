class Checkout
  attr_reader :items

  def initialize
    @items = {}
  end

  def scan(product_code:)
    items[product_code] ||= 0
    items[product_code] += 1
  end
end
