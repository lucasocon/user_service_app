require 'rails_helper'

RSpec.describe Api::UsersController, type: :controller do
  render_views

  let(:valid_session) { {} }
  let(:response_json) { JSON.parse(response.body).deep_symbolize_keys }

  describe "GET #index" do
    context 'without params' do
      describe 'get list' do
        let!(:user) { create(:user, full_name: 'John', phone_number: '123456') }
        let(:response_user) { response_json[:users][0] }

        it "returns a success response" do
          get :index, params: {}, session: valid_session, format: :json
          expect(response).to be_success

          expect(response_user[:full_name]).to eq('John')
        end
      end

      describe 'records order' do
        let!(:user1) { create(:user) }
        let!(:user2) { create(:user, phone_number: '12342') }

        let(:response_user) { response_json[:users][0] }
        let(:response_user2) { response_json[:users][1] }

        it "returns a success response" do
          get :index, params: {}, session: valid_session, format: :json
          expect(response).to be_success

          expect(response_user[:full_name]).to eq(user2.full_name)
          expect(response_user2[:full_name]).to eq(user1.full_name)
        end
      end
    end

    context 'with params' do
      let!(:user_with_email) { create(:user, phone_number: '12342', email: 'me@me.com') }
      let!(:user_with_meta) { create(:user, metadata: 'other') }

      describe 'search with email' do
        it "returns a success response" do
          get :index, params: { query: { email: 'me@me.com' }}, session: valid_session, format: :json
          expect(response).to be_success

          expect(response_json[:users][0][:full_name]).to eq(user_with_email.full_name)
          expect(response_json[:users].length).to eq(1)
        end
      end

      describe 'search with metadata' do
        it "returns a success response" do
          get :index, params: { query: { metadata: 'other' }}, session: valid_session, format: :json
          expect(response).to be_success

          expect(response_json[:users][0][:full_name]).to eq(user_with_meta.full_name)
          expect(response_json[:users].length).to eq(1)
        end
      end
    end
  end


  describe "POST #create" do
    context "with valid params" do
      let(:last_user) { User.last }

      it "creates a new User" do
        expect {
          post :create, params: { user: attributes_for(:user) }, session: valid_session, format: :json
        }.to change(User, :count).by(1)
      end

      it "renders a JSON response with the new user" do
        post :create, params: { user: attributes_for(:user) }, session: valid_session, format: :json
        expect(response).to have_http_status(:created)
        expect(response.content_type).to eq('application/json')
        expect(response_json[:full_name]).to eq(last_user.full_name)
      end

      it "sets key for the user" do
        post :create, params: { user: attributes_for(:user) }, session: valid_session, format: :json
        expect(response).to have_http_status(:created)

        expect(last_user.key).to be_present
      end

      it "sets password for the user" do
        post :create, params: { user: attributes_for(:user) }, session: valid_session, format: :json
        expect(response).to have_http_status(:created)

        expect(last_user.password_digest).to be_present
        expect(last_user.password_digest).not_to eq('123456')
      end

      context 'obtain account key' do
        it "calls job to get an account key" do
          expect(GetAccountKeyJob).to receive(:perform_later).with(an_instance_of(User)).once

          post :create, params: { user: attributes_for(:user) }, session: valid_session, format: :json
          expect(response).to have_http_status(:created)
        end
      end
    end

    context "with invalid params" do
      before { create(:user) }

      it "renders a JSON response with errors for the new user" do
        post :create, params: { user: attributes_for(:user) }, session: valid_session, format: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to eq('application/json')
      end
    end
  end
end
