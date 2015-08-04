class HomeController < ApplicationController
  def index
    gon.profiles = BridgeFactoryAndCage::FactoryBridge.instance.get_profiles
  end
end
