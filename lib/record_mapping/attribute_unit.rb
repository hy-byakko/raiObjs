# encoding: utf-8
require_dependency File.expand_path(File.join('..', 'mapping_unit'), __FILE__)

module RecordMapping
  class AttributeUnit < MappingUnit

    def override(options)
      @motion = {} unless options[:type]
      super(options)
    end

    def struct_value(target, options = {})
      value = options[:instance].value_with_string(@motion[:get])
      target[@ref.to_sym] = value if value
    end

    def mapping_to_model(options = {})
      options[:instance].send((@motion[:set].to_s + '=').to_sym, options[:params][@ref.to_sym]) if options[:params].has_key?(@ref.to_sym)
    end

    def add_sort(condition, options)
      # 判断由客户端上传的参数中是否有本属性对应的字段
      sort_param = options[:sort_params].select { |sort_unit|
        sort_unit[:property] == @ref
      }[0]
      return condition unless sort_param

      if @motion[:sort][:method]
        options[:container].send(@motion[:sort][:method].to_sym, options)
      else
        condition = condition.order(@motion[:sort][:field] + ' ' + sort_param[:direction])
        @motion[:sort][:joins] ? condition.joins(@motion[:sort][:joins]) : condition
      end
    end

    def add_condition(condition, options = {})
      # 默认无数据回传的查询条件不起效
      filter_param = options[:filter_params] && options[:filter_params].select { |filter_unit|
        filter_unit[:property] == @ref
      }[0]
      condition_params = filter_param ? filter_param[:value] : options[:params][@ref.to_sym]
      return condition if condition_params.blank?
      if @motion[:query][:method]
        options[:container].send(@motion[:query][:method].to_sym, condition, options)
      else
        motion_field = @motion[:query][:field]
        depend_on = {
            motion_field.to_sym => condition_params
        }
        pre_cond = @motion[:query][:query_params][:pre_cond]
        suf_cond = @motion[:query][:query_params][:suf_cond]
        depend_on[motion_field.to_sym] = suf_cond.gsub(/:depend/, depend_on[motion_field.to_sym]) if suf_cond
        pre_cond ? condition.where([pre_cond, depend_on]) : condition.where(depend_on)
      end
    end
  end
end