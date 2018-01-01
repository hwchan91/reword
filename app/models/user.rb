class User < ApplicationRecord
  validates :name, presence: true, length: { maximum: 20 }, uniqueness: { case_sensitive: false }, on: :update
  has_secure_password :validations => false
  validates :password, length: { minimum: 5 }, on: :update, if: lambda{ |attr| attr.password.present? }
  validate :password_is_not_default, on: :update

  private
  def password_is_not_default
    if self.authenticate(ENV['DEFAULT_PW'])
      self.errors.add(:password, "must be set the first time")
    end
  end
end
