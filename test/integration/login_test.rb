class LoginTest < ActionDispatch::IntegrationTest
  setup do
    Capybara.current_driver = Capybara.javascript_driver # :selenium by default
  end

  test 'show login page if not logged in' do
    visit '/'
    page.must_have_content('Sign in to SmheartRehab')
  end

  test 'successful login should take to dashboard page' do
    visit '/'
    within('body') do
      fill_in 'email', :with => 'balint@abc.de'
      fill_in 'password', :with => 'testpw'
    end

    click_button 'Login'
    page.must_have_content('SmheartRehab - intelligent')
  end

  test 'failed login should show error popup' do
    visit '/'

    within('body') do
      popup = find("#errorPopup", :visible=>false)
      assert !popup.visible?

      fill_in 'email', :with => 'balint@abc.de'
      fill_in 'password', :with => 'wrongpw'
    end

    click_button 'Login'

    within('body') do
      popup = find("#errorPopup")
      assert popup.visible?
    end
  end


  test 'can enter blood glucose after successful login' do
    visit '/'
    within('body') do
      fill_in 'email', :with => 'balint@abc.de'
      fill_in 'password', :with => 'testpw'
    end

    click_button 'Login'
    page.must_have_content('SmheartRehab - intelligent')

    click_link 'health-link'
    within('#health_2') do
      fill_in 'measurement[blood_sugar]', :with => '5.7'
      click_button 'Add'
    end

    within('#recentMeasTable') do
      page.must_have_content('Blood Glucose: 5.7 mmol/L')
    end
  end

end

