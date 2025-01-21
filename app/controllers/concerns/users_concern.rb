module UsersConcern
  extend ActiveSupport::Concern

  def confirm_user(user)
    user.confirm
    user.update_column(:confirmation_token, nil)
  end
end
