module Rules
  class BuyOneGetOneFree
    def self.price_for(price:, quantity:)
      ((quantity / 2) + (quantity % 2)) * price
    end
  end
end
