module ObjectsService
  class RestfulObjectsController < ApplicationController
    def restful_class
      @restful_class ||= params[:restful_class].classify.constantize
    end

    def index
      render extjs_struct(restful_class.query(params))
    end

    def show
      render extjs_struct(restful_class.find(params[:id]).mapping_exec(:greedy => true))
    end

    def create
      restful_class.new.mapping_attr(params, :greedy => true).save!
      render extjs_struct
    end

    def update
      restful_class.find(params[:id]).mapping_attr(params, :greedy => true).save!
      render extjs_struct
    end

    def destroy
      restful_class.find(params[:id]).destroy
      render extjs_struct
    end
  end
end