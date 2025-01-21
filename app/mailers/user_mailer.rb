class UserMailer < ApplicationMailer
  def confirmation_instructions(user, otp)
    @user = user
    @otp = otp
    email = @user.email.presence || @user.unconfirmed_email
    mail(to: email, subject: 'PlayerU - Your OTP')
  end

  def contact_support(from, text, subject, username)
    @text = text
    @username = username
    @email = from
    to = 'PlayerU Team<2016n0575@gmail.com>'
    mail from: from, to: to, subject: subject, reply_to: from
  end

  def send_reset_otp(user)
    @user = user
    @otp = user.reset_otp
    mail(to: @user.email, subject: 'Password Reset OTP')
  end
end
