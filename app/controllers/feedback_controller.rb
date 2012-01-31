# Feedback controller base class is included in the Blacklight plugin
# Overriding from plugin to include reCaptcha validation for feedback submission.
require "#{Blacklight.controllers_dir}/feedback_controller"

class FeedbackController < ApplicationController

  def show
    @errors=[]
    if request.post?
      if validate
        Notifier.deliver_feedback(params)
        redirect_to feedback_complete_path
      end
    end
  end

  protected
  
  # validates the incoming params
  # returns either an empty array or an array with error messages
  def validate
    unless verify_recaptcha(:model => @post)
      @errors << 'Text validation did not match'
    end
    unless params[:name] =~ /\w+/        
      @errors << 'A valid name is required'
    end
    unless params[:email] =~ /\w+@\w+\.\w+/
      @errors << 'A valid email address is required'
    end
    unless params[:message] =~ /\w+/
      @errors << 'A message is required'
    end
    #unless simple_captcha_valid?
    #  @errors << 'Captcha did not match'
    #end
    @errors.empty?
  end
  
end