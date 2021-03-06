class ApplicationController < ActionController::Base
  protect_from_forgery with: :null_session

  def json_response(object, status = :ok)
    render json: object, status: status
  end
end
