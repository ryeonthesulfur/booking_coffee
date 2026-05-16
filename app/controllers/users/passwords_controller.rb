class Users::PasswordsController < Devise::PasswordsController
  def update
    self.resource = resource_class.reset_password_by_token(resource_params)
    yield resource if block_given?

    if resource.errors.empty?
      resource.unlock_access! if unlockable?(resource)
      flash[:notice] = "パスワードが変更されました。ログインしてください。"
      redirect_to new_user_session_path
    else
      set_minimum_password_length
      render :edit, status: :unprocessable_entity
    end
  end
end
