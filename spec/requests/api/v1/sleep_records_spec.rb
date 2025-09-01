require 'rails_helper'

RSpec.describe "Api::V1::SleepRecords", type: :request do
  let(:user) { create(:user) }
  let(:headers) { { 'X-User-ID' => user.id.to_s } }
  let(:sleep_record) { create(:sleep_record, user: user, clock_in: 1.hour.ago, clock_out: nil) }

  describe 'POST /api/v1/sleep_records/clock_in' do
    context 'when successful' do
      it 'returns sleep records' do
        post api_v1_clock_in_path, headers: headers

        expect(response).to have_http_status(:ok)
        expect(json_response['sleep_records']).to be_an(Array)
      end
    end

    context 'when user has active clock-in' do
      before do
        create(:sleep_record, user: user, clock_in: 1.hour.ago, clock_out: nil)
      end

      it 'returns error' do
        post api_v1_clock_in_path, headers: headers

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response['errors']).to be_present
      end
    end
  end

  describe 'POST /api/v1/sleep_records/clock_out' do
    context 'when successful' do
      it 'returns success message' do
        patch api_v1_clock_out_path(id: sleep_record.id), headers: headers

        expect(response).to have_http_status(:ok)
        expect(json_response['sleep_records']).to include('successful')
      end
    end

    context 'when sleep record not found' do
      it 'returns error' do
        patch api_v1_clock_out_path(id: 999), headers: headers

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response['errors']).to be_present
      end
    end

    context 'when already clocked out' do
      before do
        sleep_record.update(clock_out: 30.minutes.ago)
      end

      it 'returns error' do
        patch api_v1_clock_out_path(id: sleep_record.id), headers: headers

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response['errors']).to be_present
      end
    end
  end

  describe 'GET /api/v1/sleep_records' do
    context 'with followed users having sleep records' do
      let(:following_user) { create(:user) }

      before do
        user.following << following_user
        create(:sleep_record, user: following_user, clock_in: 3.days.ago, clock_out: 2.days.ago)
      end

      it 'returns paginated sleep records' do
        get api_v1_sleep_records_path, headers: headers, params: { page: 1, per_page: 5 }

        expect(response).to have_http_status(:ok)
        expect(json_response['data']).to be_an(Array)
        expect(json_response['meta']).to be_a(Hash)
        expect(json_response['meta']).to include('current_page', 'total_pages', 'total_count')
      end
    end

    context 'with pagination parameters' do
      it 'passes parameters to service' do
        expect(FetchSleepRecordService).to receive(:new)
                                             .with(user, '2', '5')
                                             .and_return(double(call: { data: [], meta: {} }))

        get api_v1_sleep_records_path, headers: headers, params: { page: 2, per_page: 5 }
      end
    end
  end


  def json_response
    JSON.parse(response.body)
  end

end
