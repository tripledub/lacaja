require_relative '../checkout'

Product = Struct.new(:name, :product_code, :price)

RSpec.describe Checkout do
  let(:green_tea) { Product.new('Green Tea', 'GR1', 3.11) }
  let(:strawberries) { Product.new('Strawberries', 'SR1', 5) }
  let(:coffee) { Product.new('Coffee', 'CF1', 11.23) }

  subject { described_class.new(pricing_rules: []) }

  describe 'scanning products' do
    context 'when checkout is initialized' do
      it 'items are an empty hash' do
        expect(subject.items).to eq({})
      end
    end

    context 'adding a new Green Tea' do
      it 'adds a new item to the cart' do
        subject.scan(product_code: green_tea.product_code)
        expect(subject.items.size).to eq(1)
      end
    end

    context 'adding a new Coffee and a Green tea' do
      it 'adds 2 new items to the cart' do
        subject.scan(product_code: green_tea.product_code)
        subject.scan(product_code: coffee.product_code)
        expect(subject.items.size).to eq(2)
      end
    end

    context 'adding a new Coffee and two Green teas' do
      before do
        subject.scan(product_code: green_tea.product_code)
        subject.scan(product_code: coffee.product_code)
        subject.scan(product_code: green_tea.product_code)
      end

      it 'only adds 2 new items to the cart' do
        expect(subject.items.size).to eq(2)
      end

      it 'increments the Green Tea count' do
        expect(subject.items[green_tea.product_code]).to eq(2)
      end

      it 'does not increment the Coffee count' do
        expect(subject.items[coffee.product_code]).to eq(1)
      end
    end
  end
end
