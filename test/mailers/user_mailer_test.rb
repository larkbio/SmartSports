require 'test_helper'

class UserMailerTest < ActionMailer::TestCase
  setup do
    @user = users(:one)
  end

  test "reset_password_email_en" do
    mail = UserMailer.reset_password_email(
        InfoMailJob.new(nil, @user.email, "en", {reset_password_token: "abcd"}))
    assert_equal "SmartDiab password reset", mail.subject
    assert_equal [@user.email], mail.to
    assert_equal ["info@smartdiab.com"], mail.from
    assert_match "Hello, "+@user.email, mail.body.encoded
  end

  test "reset_password_email_hu" do
    mail = UserMailer.reset_password_email(
        InfoMailJob.new(nil, @user.email, "hu", {reset_password_token: "abcd"}))
    assert_equal "SmartDiab jelszó visszaállítás", mail.subject
    assert_equal [@user.email], mail.to
    assert_equal ["info@smartdiab.com"], mail.from
    assert_match "Tisztelt "+@user.email, mail.body.encoded
  end

end
