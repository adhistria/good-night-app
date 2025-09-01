require 'rails_helper'

RSpec.describe "Api::V1::SleepRecords", type: :request do
  let(:user) { create(:user) }
  let(:headers) { { 'X-User-ID' => user.id.to_s } }
  let(:sleep_record) { create(:sleep_record, user: user, clock_in: 1.hour.ago, clock_out: nil) }

  describe 'POST /api/v1/sleep_records/clock_in' do
    context 'when successful' do
      it 'returns sleep records' do
        post clock_in_api_v1_sleep_records_path, headers: headers

        expect(response).to have_http_status(:ok)
        expect(json_response['sleep_records']).to be_an(Array)
      end
    end

    context 'when user has active clock-in' do
      before do
        create(:sleep_record, user: user, clock_in: 1.hour.ago, clock_out: nil)
      end

      it 'returns error' do
        post clock_in_api_v1_sleep_records_path, headers: headers

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response['errors']).to be_present
      end
    end
  end

  describe 'POST /api/v1/sleep_records/clock_out' do
    context 'when successful' do
      it 'returns success message' do
        post clock_out_api_v1_sleep_records_path, params: { id: sleep_record.id }, headers: headers

        expect(response).to have_http_status(:ok)
        expect(json_response['sleep_records']).to include('successful')
      end
    end

    context 'when sleep record not found' do
      it 'returns error' do
        post clock_out_api_v1_sleep_records_path, params: { id: 999 }, headers: headers

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response['errors']).to be_present
      end
    end

    context 'when already clocked out' do
      before do
        sleep_record.update(clock_out: 30.minutes.ago)
      end

      it 'returns error' do
        post clock_out_api_v1_sleep_records_path, params: { id: sleep_record.id }, headers: headers

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response['errors']).to be_present
      end
    end
  end

  def json_response
    JSON.parse(response.body)
  end

end
