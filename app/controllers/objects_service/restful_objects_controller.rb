class ObjectsService::RestfulObjectsController < ApplicationController
  def index
    render :text => 'I am here'
  end

  def show
    render :text => 'I am here' + params[:id].to_s
  end
end