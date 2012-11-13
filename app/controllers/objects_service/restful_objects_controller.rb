module ObjectsService
  class RestfulObjectsController < ApplicationController
# 默认所有controller都继承了restful服务提供方式, 但只有RestfulObject服务不同, 是目前唯一一个拥有无意义mapping的controller
    self.mapping = :phantom

    def restful_class
      @restful_class ||= params[:restful_class].classify.constantize
    end

    def index
      options = {
          :params => params
      }
      options[:sort_params] = JSON.parse(params[:sort], :symbolize_names => true) if params[:sort]
      options[:filter_params] = JSON.parse(params[:filter], :symbolize_names => true) if params[:filter]
      render extjs_struct(restful_class.query(options))
    end

    def show
      render extjs_struct(restful_class.find(params[:id]).mapping_exec(:greedy => true))
    end

    def create
      restful_class.new.mapping_attr({
          :params => params,
          :greedy => true
      }).save!
      render extjs_struct
    end

    def update
      restful_class.find(params[:id]).mapping_attr({
          :params => params,
          :greedy => true
      }).save!
      render extjs_struct
    end

    def destroy
      restful_class.find(params[:id]).destroy
      render extjs_struct
    end
  end
end