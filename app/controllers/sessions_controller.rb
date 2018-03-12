class SessionsController < ApplicationController

  def destroy
    self.current_user = nil
    redirect_to "/#{ENV['RAILS_RELATIVE_URL_ROOT']}", notice: "See you later!"
  end

end
