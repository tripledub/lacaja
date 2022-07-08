module Rules
  class AbsolutePrice
    def self.price_for(price:, quantity:, discount_at:, new_price:)
      (quantity >= discount_at ? new_price : price) * quantity
    end
  end
end
