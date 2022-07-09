require_relative '../../rules/buy_one_get_one_free'

RSpec.describe Rules::BuyOneGetOneFree do
  let(:price) { 10 }
  let(:quantity) { 1 }

  subject do
    described_class.price_for(price:, quantity:, discount_at: nil, new_price: nil)
  end

  describe 'when quantity is 1 the price is the same' do
    it { is_expected.to eq(price) }
  end

  describe 'when quantity is 2 the second item is free' do
    let(:quantity) { 2 }
    it { is_expected.to eq(price) }
  end

  describe 'when quantity is 3 the 1 item is free' do
    let(:quantity) { 3 }
    it { is_expected.to eq(price * 2) }
  end

  describe 'when quantity is 5, half are free + 1 items' do
    let(:quantity) { 5 }
    it { is_expected.to eq(30) }
  end
end
