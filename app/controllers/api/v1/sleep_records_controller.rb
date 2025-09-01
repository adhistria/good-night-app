class Api::V1::SleepRecordsController < ApplicationController
  def clock_in
    result = ClockInService.new(@user).call

    if result[:success]
      render json: { sleep_records: result[:sleep_records] }, status: :ok
    else
      render json: { errors: result[:errors] }, status: :unprocessable_entity
    end
  end

  def clock_out
    result = ClockOutService.new(@user, params[:id]).call

    if result[:success]
      render json: { sleep_records: result[:message] }, status: :ok
    else
      render json: { errors: result[:errors] }, status: :unprocessable_entity
    end
  end

end
