class User < ApplicationRecord
  has_secure_password
  has_secure_token :key

  validates_length_of :email, :full_name, maximum: 200
  validates_length_of :password, :key, :account_key, maximum: 100
  validates_length_of :phone_number, maximum: 20
  validates_length_of :metadata, maximum: 2000
  validates_presence_of :email, :phone_number
  validates_presence_of :password, on: :create
  validates_presence_of :password_digest, on: :update
  validates_uniqueness_of :email, :phone_number, :key, :account_key, allow_nil: true

  after_create :enqueue_account_key

  scope :search_by, -> (search_params) { where(search_params).order(created_at: :desc) }

  private

  def enqueue_account_key
    GetAccountKeyJob.perform_later(self)
  end
end
