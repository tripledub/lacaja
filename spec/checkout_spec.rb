require_relative '../checkout'

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
      DiscountRule.new(
        product: strawberries,
        rule: Rules::AbsolutePrice,
        discount_at: 3,
        new_price: 4.5
      )
    end

    let(:coffee_rule) do
      DiscountRule.new(
        product: coffee,
        rule: Rules::RationalPrice,
        discount_at: 3,
        new_price: Rational(3, 2)
      )
    end

    let(:pricing_rules) do
      [
        green_tea_rule,
        strawberries_rule,
        coffee_rule
      ]
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

      context 'with 3 Green Teas' do
        it 'equals 6.22 (Buy 1 Get 1 Free + 1 at normal price)' do
          subject.scan(product_code: green_tea.product_code)
          subject.scan(product_code: green_tea.product_code)
          expect(subject.items['GR1']).to eq(3)
          expect(subject.total).to eq(6.22)
        end
      end
    end

    context 'with 1 Strawberries' do
      before { subject.scan(product_code: strawberries.product_code) }

      it 'equals 5' do
        expect(subject.total).to eq(5)
      end

      context 'with 2 Strawberries' do
        it 'equals 10, price break not met' do
          subject.scan(product_code: strawberries.product_code)
          expect(subject.items['SR1']).to eq(2)
          expect(subject.total).to eq(10)
        end
      end

      context 'with 3 Strawberries' do
        it 'equals 13.5, threshold met and price drops to 4.50' do
          subject.scan(product_code: strawberries.product_code)
          subject.scan(product_code: strawberries.product_code)
          expect(subject.items['SR1']).to eq(3)
          expect(subject.total).to eq(13.5)
        end
      end
    end

    context 'with 1 Coffee' do
      before { subject.scan(product_code: coffee.product_code) }

      it 'equals 11.23' do
        expect(subject.total).to eq(11.23)
      end

      context 'with 2 Coffees' do
        it 'equals 22.46, price break not met' do
          subject.scan(product_code: coffee.product_code)
          expect(subject.items['CF1']).to eq(2)
          expect(subject.total).to eq(22.46)
        end
      end

      context 'with 3 Coffees' do
        it 'equals 22.46, threshold met and price drops to 2/3 of original' do
          subject.scan(product_code: coffee.product_code)
          subject.scan(product_code: coffee.product_code)
          expect(subject.items['CF1']).to eq(3)
          expect(subject.total).to eq(22.46)
        end
      end
    end

    describe 'combinations of items' do
      before do
        basket.each do |item|
          subject.scan(product_code: item)
        end
      end

      describe '3 Green Teas, 1 strawberry and 1 Coffee' do
        let(:basket) { %w[GR1 SR1 GR1 GR1 CF1] }

        it 'equals 22.45' do
          expect(subject.total).to eq(22.45)
        end
      end

      describe '2 Green Teas' do
        let(:basket) { %w[GR1 GR1] }

        it 'equals 3.11, Buy 1 - Get 1 Free' do
          expect(subject.total).to eq(3.11)
        end
      end

      describe '3 Strawberries and 1 Green Tea' do
        let(:basket) { %w[SR1 SR1 GR1 SR1] }

        it 'equals 16.61' do
          expect(subject.total).to eq(16.61)
        end
      end

      describe '3 Coffees, 1 Strawberry and 1 Green Tea' do
        let(:basket) { %w[GR1 CF1 SR1 CF1 CF1] }

        it 'equals 30.57' do
          expect(subject.total).to eq(30.57)
        end

        context 'the items can be added in any order' do
          let(:basket) { %w[GR1 CF1 SR1 CF1 CF1].shuffle }

          it 'still equals 30.57' do
            expect(subject.total).to eq(30.57)
          end
        end
      end
    end
  end
end
