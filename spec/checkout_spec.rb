require_relative '../checkout'
require 'pry'

Product = Struct.new(:name, :product_code, :price)

RSpec.describe Checkout do
  let(:green_tea) { Product.new('Green Tea', 'GR1', 3.11) }
  let(:strawberries) { Product.new('Strawberries', 'SR1', 5) }
  let(:coffee) { Product.new('Coffee', 'CF1', 11.23) }
  let(:pricing_rules) { [] }

  subject { described_class.new(pricing_rules:) }

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

  describe '#total' do
    let(:green_tea_rule) do
      DiscountRule.new(
        product: green_tea,
        rule: Rules::BuyOneGetOneFree
      )
    end

    let(:strawberries_rule) do
      Rules::AbsolutePrice
    end

    let(:pricing_rules) do
      [green_tea_rule]
    end

    context 'with no items' do
      it 'equals 0' do
        expect(subject.total).to eq(0)
      end
    end

    context 'with 1 Green Tea' do
      before { subject.scan(product_code: green_tea.product_code) }

      it 'equals 3.11' do
        expect(subject.total).to eq(3.11)
      end

      context 'with 2 Green Teas' do
        it 'still equals 3.11 (Buy 1 Get 1 Free)' do
          subject.scan(product_code: green_tea.product_code)
          expect(subject.items['GR1']).to eq(2)
          expect(subject.total).to eq(3.11)
        end
      end
    end
  end
end
