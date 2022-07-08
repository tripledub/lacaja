module Rules
  class RationalPrice
    def self.price_for(price:, quantity:, discount_at:, new_price:)
      return price * quantity unless new_price.is_a?(Rational)

      (
        (
          quantity >= discount_at ? (price.to_f / new_price) : price
        ) * quantity
      ).round(2)
    end
  end
end
