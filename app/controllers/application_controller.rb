class ApplicationController < ActionController::Base
  filter_parameter_logging :fb_sig_friends

  #before_filter :require_login
  before_filter :add_stylesheets

  helper :all
  helper_method :current_user

private

  def current_user_session
    return @current_user_session if defined?(@current_user_session)
    @current_user_session = nil
  end

  def current_user
    return @current_user if defined?(@current_user)
    @current_user = login_from_fb || login_from_other
  end

  def login_from_other
    return User.first if ENV['IGNORE_CONNECT'] == 'true'
  end

  def require_logout
    redirect_to root_path if (UserSession.find.user rescue false)
  end

  def require_login
    cookies[:redirect] = request.path
    redirect_to login_path unless current_user
  end

  def login_from_fb
    Rails.logger.info("Trying to log in from FB session")
    Rails.logger.info(facebook_graph_session.inspect)
    if facebook_graph_session
      u = User.find_by_facebook_uid(facebook_graph_session.user_id)
      u ||= User.create_from_graph_api(facebook_graph_session)
      if u.access_token != facebook_graph_session.access_token
        u.access_token = facebook_graph_session.access_token
        u.save
      end
      self.current_user = u
    end
  end

  def add_stylesheets
    @stylesheets = ['application']
  end

end
