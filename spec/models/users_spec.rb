class User < ApplicationRecord
  has_secure_password

  validates :email, presence: true, uniqueness: { case_sensitive: false }
  validates :first_name, :last_name, presence: true
  validates :password, length: { minimum: 8 }, on: :create

  before_save :downcase_email

  def self.authenticate_with_credentials(email, password)
    user = User.find_by('lower(email) = ?', email.strip.downcase)
    user && user.authenticate(password) ? user : nil
  end

  private

  def downcase_email
    self.email = email.downcase
  end
end

RSpec.describe User, type: :model do
  describe 'Validations' do
    it 'requires a password and password_confirmation when creating a user' do
      user = User.new(first_name: 'Test', last_name: 'User', email: 'test@test.com', password: 'password123', password_confirmation: '')
      expect(user).to_not be_valid
      expect(user.errors[:password_confirmation]).to include("can't be blank")
    end

    it 'requires password and password_confirmation to match' do
      user = User.new(first_name: 'Test', last_name: 'User', email: 'test@test.com', password: 'password123', password_confirmation: 'different')
      expect(user).to_not be_valid
      expect(user.errors[:password_confirmation]).to include("doesn't match Password")
    end

    it 'requires email to be unique, case insensitive' do
      User.create!(first_name: 'Test', last_name: 'User', email: 'test@test.com', password: 'password123', password_confirmation: 'password123')
      user = User.new(first_name: 'Test', last_name: 'User', email: 'TEST@TEST.COM', password: 'password123', password_confirmation: 'password123')
      expect(user).to_not be_valid
      expect(user.errors[:email]).to include('has already been taken')
    end

    it 'requires email to be present' do
      user = User.new(first_name: 'Test', last_name: 'User', email: nil)
      expect(user).to_not be_valid
      expect(user.errors[:email]).to include("can't be blank")
    end

    it 'requires first name to be present' do
      user = User.new(first_name: nil, last_name: 'User', email: 'test@test.com')
      expect(user).to_not be_valid
      expect(user.errors[:first_name]).to include("can't be blank")
    end

    it 'requires last name to be present' do
      user = User.new(first_name: 'Test', last_name: nil, email: 'test@test.com')
      expect(user).to_not be_valid
      expect(user.errors[:last_name]).to include("can't be blank")
    end

    it 'requires password to have a minimum length' do
      user = User.new(first_name: 'Test', last_name: 'User', email: 'test@test.com', password: 'short', password_confirmation: 'short')
      expect(user).to_not be_valid
      expect(user.errors[:password]).to include('is too short (minimum is 8 characters)')
    end
  end

  describe '.authenticate_with_credentials' do
    before do
      @user = User.create!(
        first_name: 'Test',
        last_name: 'User',
        email: 'test@example.com',
        password: 'password123',
        password_confirmation: 'password123'
      )
    end

    it 'authenticates with correct credentials' do
      authenticated_user = User.authenticate_with_credentials('test@example.com', 'password123')
      expect(authenticated_user).to eq(@user)
    end

    it 'returns nil with incorrect password' do
      authenticated_user = User.authenticate_with_credentials('test@example.com', 'wrongpassword')
      expect(authenticated_user).to be_nil
    end

    it 'authenticates even with leading/trailing spaces in email' do
      authenticated_user = User.authenticate_with_credentials('  test@example.com  ', 'password123')
      expect(authenticated_user).to eq(@user)
    end

    it 'authenticates even with wrong case in email' do
      authenticated_user = User.authenticate_with_credentials('TEST@EXAMPLE.COM', 'password123')
      expect(authenticated_user).to eq(@user)
    end
  end
end



