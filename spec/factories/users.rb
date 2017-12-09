FactoryBot.define do
  factory :user do
    email { FFaker::Internet.email }
    phone_number { 'ABC123456' }
    full_name { FFaker::Name.name }
    password "password"
    key { SecureRandom.hex }
    account_key { SecureRandom.hex }
    metadata { FFaker::Lorem.words }
  end
end
