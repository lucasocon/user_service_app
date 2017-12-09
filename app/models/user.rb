class User < ApplicationRecord
  has_secure_password

  validates_length_of :email, :full_name, maximum: 200
  validates_length_of :password, :key, :account_key, maximum: 100
  validates_length_of :phone_number, maximum: 20
  validates_length_of :metadata, maximum: 2000
  validates_presence_of :email, :phone_number, :password
  validates_uniqueness_of :email, :phone_number, :key, :account_key
end
