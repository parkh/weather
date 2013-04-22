require 'spec_helper'

describe User do
  describe "#authentication" do
    let(:user) { FactoryGirl.create(:user, name: 'neo', password: 'matrix') }
    
    it "should authenticate with matching name and password" do
      user
      User.authenticate('neo', 'matrix').should == user
    end

    it "should not authenticate with incorrect name" do
    	User.authenticate('smith', 'matrix').should be_nil
    end
  
    it "should not authenticate with incorrect password" do
    	User.authenticate('neo', 'trinity').should be_nil
    end
  
    it "should log in and log out" do
    	visit log_in_path
    	fill_in "name", with: user.name
    	fill_in "password", with: user.password
    	click_button "Залогиниться"
      current_path.should eq(root_path)
      page.should have_content('Залогинились!')
      visit log_out_path
      current_path.should eq(root_path)
      page.should have_content('Отлогинились...')
    end
  end
  
  describe "#searching the city" do
    let(:user) { FactoryGirl.create(:user, name: 'neo', password: 'matrix') }
    before { visit log_in_path
             fill_in "name", with: user.name
             fill_in "password", with: user.password
             click_button "Залогиниться"
           }

    it "should find the correct city" do
      fill_in "search", with: "Zion"
      click_button "sinoptik"
      current_path.should eq(root_path)
      page.should have_content('Город найден и добавлен в базу данных.')
    end
    
    it "should not find the incorrect city" do
      fill_in "search", with: "abrakadabra"
      click_button "sinoptik"
      current_path.should eq(root_path)
      page.should have_content('Город abrakadabra еще не построили, либо парсируемый сайт пока не знает о нем.')
    end
  end
end