require_relative '../discount_rule'
require 'pry'

Product = Struct.new(:name, :product_code, :price)

module Rules
  class FakeRule
    def self.price_for(price:, quantity:)
      price * quantity
    end
  end
end

RSpec.describe DiscountRule do
  let(:product) { Product.new('Green Tea', 'GR1', 3.11) }
  let(:quantity) { 2 }

  subject { described_class.new(product:, rule: Rules::FakeRule) }

  describe '.price_for' do
    it 'queries the associated rule for any discounted price' do
      expect(
        Rules::FakeRule
      ).to receive(:price_for).with(price: product.price, quantity:)
      subject.price_for(quantity:)
    end

    describe 'simple FakeRule returns correct value' do
      it 'in this case price * quantity' do
        expect(
          subject.price_for(quantity:)
        ).to eq(product.price * quantity)
      end
    end
  end

  describe '#handles' do
    context 'returns true when product_code matches associated product' do
      let(:product_code) { product.product_code }

      it 'returns true' do
        expect(subject.handles?(product_code:)).to be_truthy
      end
    end
  end
end
