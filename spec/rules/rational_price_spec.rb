require_relative '../../rules/rational_price'

RSpec.describe Rules::RationalPrice do
  let(:price) { 11.23 }
  let(:quantity) { 3 }
  let(:discount_at) { 3 }
  let(:new_price) { price }

  subject { described_class.price_for(price:, quantity:, discount_at:, new_price:) }

  describe 'when number of items in cart reaches a specific quantity' do
    let(:new_price) { Rational(3, 2) }

    it 'reduces the price per item by 2/3' do
      expect(subject).to eq(22.46)
    end
  end

  describe 'when number of items in cart is below a specific quantity' do
    let(:quantity) { 2 }

    it 'no reducton is applied' do
      expect(subject).to eq(price * quantity)
    end
  end
end
