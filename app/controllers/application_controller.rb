class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  def sign_out_current_user
    sign_out(current_user)
    redirect_to root_path
  end
end
