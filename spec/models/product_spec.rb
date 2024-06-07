require 'rails_helper'

RSpec.describe Product, type: :model do
  before(:all) do
    @category = Category.create(name: 'Electronics')
  end

  describe 'validations' do
    it 'validates presence of name' do
      product = Product.new(name: nil, price: 10, quantity: 5, category: @category)
      expect(product).not_to be_valid
      expect(product.errors[:name]).to include("can't be blank")
    end

    it 'validates presence of price' do
      product = Product.new(name: 'Product Name', price_cents: nil, quantity: 5, category: @category)
      expect(product).not_to be_valid
      expect(product.errors[:price_cents]).to include("is not a number")
    end

    it 'validates presence of quantity' do
      product = Product.new(name: 'Product Name', price: 10, quantity: nil, category: @category)
      expect(product).not_to be_valid
      expect(product.errors[:quantity]).to include("can't be blank")
    end

    it 'validates presence of category' do
      product = Product.new(name: 'Product Name', price: 10, quantity: 5, category: nil)
      expect(product).not_to be_valid
      expect(product.errors[:category]).to include("can't be blank")
    end
  end
end
