require 'spec_helper'

describe "lecture 6" do
  
  before do
    @user = User.create! name: "Matt", email: "goggin13@gmail.com", password: "foobar"
  end
    
  def user_login(user)
    visit new_session_path
    fill_in "Email", with: @user.email
    fill_in "Password", with: @user.password
    click_button "Login" 
  end

  def should_be_on_home_page
    page.should have_selector('h1', text: 'INFO 2310 Microposter')
  end

  def should_have_error(msg)
    page.should have_selector('div.alert-error', text: msg)
  end

  def should_have_notice(msg)
    page.should have_selector('div.alert-notice', text: msg)
  end

  def should_be_on_home_page_with_error(msg)
    should_be_on_home_page
    should_have_error msg
  end

  describe "login form" do

    describe "unauthenticated" do

      before do
        visit new_session_path
      end

      it "should show you the login form" do
        page.should have_selector('h1', text: 'Login')  
      end
    end

    describe "authenticated" do

      before do
        user_login @user
        visit new_session_path
      end

      it "should show you the home page" do
        page.should_not have_selector('h1', text: 'Login')
        should_be_on_home_page 
      end
    end
  end

  describe "registration form" do

    describe "unauthenticated" do

      before do
        visit new_user_path
      end

      it "should show you the registration form" do
        page.should have_selector('h1', text: 'New user')  
      end
    end

    describe "authenticated" do

      before do
        user_login @user
        visit new_user_path
      end

      it "should show you the home page" do
        page.should_not have_selector('h1', text: 'New user')
        should_be_on_home_page 
      end
    end
  end  

  describe "user access control" do
    
    describe "an unauthenticated user" do
      
      it "should not be able to edit a user" do
        visit edit_user_path(@user)
        should_be_on_home_page_with_error "You are not authorized to edit that user"
      end
      
      it "should not be able to destroy a user" do
        visit users_path
        expect {
          click_link "Destroy"
        }.to change(User, :count).by(0)
        should_be_on_home_page_with_error "You are not authorized to edit that user"
      end
    end

    describe "an authenticated user" do

      before { user_login @user }
      
      it "should be able to edit a user" do
        visit edit_user_path(@user)
        page.should have_selector('h1', text: 'Editing user')
        fill_in 'Name', with: 'Matthew'
        click_button 'Update User'
        should_have_notice 'User was successfully updated.'
      end
      
      it "should be able to destroy a user" do
        visit users_path
        expect {
          click_link "Destroy"
        }.to change(User, :count).by(-1)
      end
    end    
  end

  describe "micropost access control" do
    
    before do
      @my_micropost = @user.microposts.create! content: "hello world" 
    end

    describe "an unauthenticated user" do
      
      it "should not be able to edit a micropost" do
        visit edit_micropost_path(@my_micropost)
        should_be_on_home_page_with_error "You are not authorized to edit that Micropost"
      end
      
      it "should not be able to destroy a micropost" do
        visit microposts_path
        click_link 'Destroy'
        should_be_on_home_page_with_error "You are not authorized to edit that Micropost"
      end
    end

    describe "an authenticated user" do

      before do 
        other_user = User.create! email: "example-2@example.com", 
                                 name: "example", 
                                 password: "password"
        @their_micropost = other_user.microposts.create! content: "hello world" 
        user_login @user 
      end
      
      it "should be able to edit their own micropost " do
        visit edit_micropost_path(@my_micropost)
        page.should have_selector('h1', text: 'Editing micropost')
        fill_in 'Content', with: 'Hello world'
        click_button 'Update Micropost'
        should_have_notice 'Micropost was successfully updated.'
      end

      it "should not be able to edit someone else's  micropost " do
        visit edit_micropost_path(@their_micropost)
        should_be_on_home_page_with_error "You are not authorized to edit that Micropost"
      end      
      
      it "should be able to destroy their own microposts " do
        visit microposts_path 
        expect {
          find("a[href='#{micropost_path(@my_micropost)}'][data-method='delete']").click
        }.to change(Micropost, :count).by(-1)
      end

      it "should not be able to destroy someone else's microposts " do
        visit microposts_path 
        expect {
          find("a[href='#{micropost_path(@their_micropost)}'][data-method='delete']").click
        }.to change(Micropost, :count).by(0)
        should_be_on_home_page_with_error "You are not authorized to edit that Micropost"
      end
    end    
  end  

  describe "users link" do
    
    before { visit root_path }

    it "should appear in the header" do
      page.should have_link('Users', href: users_path)
    end
  end

  describe "paginating users" do
    
    before do
      @users = (0..99).map do |i|
        User.create name: "user-#{i}",
                    email: "user-#{i}@example.com",
                    password: "foobar"
      end
      @users << @user
    end

    it "should display 30 users at a time" do
      visit users_path
      @users[0..28].each do |user|
        page.should have_content user.name
      end
    end
    
    it "should display the second 30 users on page 2" do
      visit users_path(page: 2)
      @users[29..48].each do |user|
        page.should have_content user.name
      end
    end

    it "should have a link to the next page" do
      visit users_path
      page.should have_selector('a', href: users_path(page:2))
    end
  end

  describe "paginating microposts" do
    
    before do
      @microposts = (0..99).map do |i|
        @user.microposts.create! content: "hello world, #{i}"
      end
    end

    it "should display 30 microposts at a time" do
      visit user_path(@user)
      @microposts[0..29].each do |post|
        page.should have_content post.content
      end
    end
    
    it "should display the second 30 users on page 2" do
      visit user_path(@user, page: 2)
      @microposts[30..48].each do |post|
        page.should have_content post.content
      end
    end

    it "should have a link to the next page" do
      visit user_path(@user)
      page.should have_selector('a', href: user_path(@user, page:2))
    end
  end

  describe "paperclip" do

    it "should include avatar in attr_accessible" do
      lambda do
        @user.update_attributes! avatar: nil
      end.should_not raise_exception
    end

    it "should have the attached file on the user model" do
      @user.should respond_to :avatar
    end

    it "should have a file field on the user edit form" do
      user_login @user
      visit edit_user_path(@user)
      page.should have_css('input[name="user[avatar]"][type="file"]')
    end 

    it "should display a medium sized image on the user profile" do
      visit user_path(@user)
      page.should have_selector('img', src: @user.avatar.url(:medium))
    end

    it "should display an thumb sized image on the user index page" do
      visit user_path(@user)
      page.should have_selector('img', src: @user.avatar.url(:thumb))
    end
  end
end