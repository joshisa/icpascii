class SessionsController < ApplicationController

  def destroy
    self.current_user = nil
    redirect_to "/asciinema", notice: "See you later!"
  end

end
