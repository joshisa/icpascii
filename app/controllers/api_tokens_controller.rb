class ApiTokensController < ApplicationController

  before_filter :ensure_authenticated!

  def destroy
    api_token = ApiToken.find(params[:id])
    authorize api_token
    api_token.revoke!
    redirect_to "/#{ENV['RAILS_RELATIVE_URL_ROOT']}".concat(edit_user_path), notice: "Token revoked."
  end

end
