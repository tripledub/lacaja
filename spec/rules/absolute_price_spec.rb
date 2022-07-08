require_relative '../../rules/absolute_price'

RSpec.describe Rules::AbsolutePrice do
  let(:price) { 5 }
  let(:quantity) { 3 }
  let(:discount_at) { 3 }
  let(:new_price) { 4.5 }

  subject { described_class.price_for(price:, quantity:, discount_at:, new_price:) }

  describe 'when number of items in cart reaches a specific quantity' do
    it 'reduces the price per item' do
      expect(subject).to eq(new_price * quantity)
    end
  end

  describe 'when number of items in cart is below a specific quantity' do
    let(:quantity) { 2 }

    it 'no reducton is applied' do
      expect(subject).to eq(price * quantity)
    end
  end
end
