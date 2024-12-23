class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def discord
    omniauth_login = request.env["omniauth.auth"]
    @user = User.from_omniauth(omniauth_login)

    if @user.persisted?
      is_libcrafter = DISCORD_SERVICE.is_libcrafter?(@user, omniauth_login.credentials.token)
      if is_libcrafter
        sign_in_and_redirect @user, event: :authentication
        set_flash_message(:notice, :success, kind: "Discord") if is_navigational_format?
      else
        redirect_to access_denied_path
      end
    else
      session["devise.discord_data"] = request.env["omniauth.auth"]
      redirect_to unauthenticated_root_path, alert: "Failed to authenticate via Discord."
    end
  end

  def failure
    redirect_to unauthenticated_root_path, alert: "Failed to authenticate via Discord."
  end
end
