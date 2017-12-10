class GetAccountKeyJob < ApplicationJob
  queue_as :default
  retry_on ::AccountKeyServiceError

  KEY_SERVICE_HOST = 'https://account-key-service.herokuapp.com'
  ACCOUNT_ENDPOINT = '/v1/account'

  def perform(user)
    conn = Faraday.new(url: KEY_SERVICE_HOST)

    req = conn.post do |req|
      req.url ACCOUNT_ENDPOINT
      req.headers['Content-Type'] = 'application/json'
      req.body = { email: user.email, key: user.key }.to_json
    end

    payload = JSON.parse(req.body)

    raise ::AccountKeyServiceError unless req.success?
    raise ::AccountKeyServiceError if payload["account_key"].nil?

    user.update_attributes(account_key: payload["account_key"])
  end
end
