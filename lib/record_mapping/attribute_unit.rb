# encoding: utf-8
class AttributeUnit
# 默认映射动作, 对应的值为未指定时的默认值
  MOTION = [
# 本地模型数据映射为远程模型的数据时取值的方法/get_method为本地数据映射到远程时, 调用本地controller相应的方法名
      :get,
# 远程数据映射为对应模型上的字段时调用的方法/set_method为远程数据映射到本地时, 调用本地controller相应的方法名
      :set,
#
      :query

#      :sort
  ]

# 当:type在option中被指定时, 将依照:type来定义动作(motion), 未定义的动作将会被默认行为指定,
# 仅当:type未被指定时, 未指定的动作不会指定默认行为
  TYPE = {
      :persist => [:get, :set, :query], # 持续型:参与所有的行为
      :logic => [:query],   # 逻辑型:不参与get/set
      :ignore => []  # 忽略型:不参与所有的映射
  }

# require option :name
  def initialize(options = {})
    @name = options[:name]
    @motion = {}
    @lazy = true if options[:lazy]

# 远程模型的字段名, 取值/赋值时皆调用此字段
    @ref = (options[:ref] || (options[:change_style] ? change_style(options[:name]) : options[:name]))

    if options[:association]
      @association = options[:association]
      if options[:mapping] || options[:mapping_override]
        @association_mapping = RecordMapping.new(
            :mapping => options[:mapping],
            :container => options[:container],
            :entity_class => options[:container].entity_class.reflect_on_association(options[:association]).class_name.constantize
        )
        @association_mapping.mapping_override(options[:mapping_override])
      end
    else
      motion_init(options)
    end
  end

  def override(options)
    @ref = options[:ref] if options[:ref]
    @lazy = options[:lazy] if options[:lazy]
    @motion = {} unless options[:type]
    motion_init(options)
  end

  def motion_init(options)
    MOTION.each { |key|
      if options.has_key?(key)
        motion_build(key, options[key])
      else
# 仅当动作的为该类型所允许, 并且是非read_only情况下的set时
        if options[:type] && TYPE[options[:type]].include?(key) && !(key == :set && options[:read_only])
# 仅在该动作不存在时为其配置默认
          motion_build(key, options[:name]) unless @motion[key]
        end
      end
    }
  end

  def motion_build(key, motion_value)
    if key == :query
      motion_value = motion_value.is_a?(String) ? {
          :seek_by => :equal
      } : motion_value
      @motion[:query] = query_build(motion_value)
    else
      @motion[key] = motion_value
    end
  end

# query将会尝试调用model内相应名称的方法, 并认为该方法的返回值即为搜索条件.where()内的参数
# 或者以seek_by定义预设规则 当两者配置都不存在的情况下会默认使用equal的方法
  def query_build(options)
    return options if options[:method]
    query_params = {}
    motion_get = @motion[:get]
    case options[:seek_by]
      when :similar
        query_params[:pre_cond] = "#{motion_get} LIKE :#{motion_get}"
        query_params[:suf_cond] = "%:depend%"
      when :pre_similar
        query_params[:pre_cond] = "#{motion_get} LIKE :#{motion_get}"
        query_params[:suf_cond] = ":depend%"
      when :suf_similar
        query_params[:pre_cond] = "#{motion_get} LIKE :#{motion_get}"
        query_params[:suf_cond] = "%:depend"
      when :bigger
        query_params[:pre_cond] = "#{motion_get} > :#{motion_get}"
      when :smaller
        query_params[:pre_cond] = "#{motion_get} < :#{motion_get}"
      when :bigger_equal
        query_params[:pre_cond] = "#{motion_get} >= :#{motion_get}"
      when :smaller_equal
        query_params[:pre_cond] = "#{motion_get} <= :#{motion_get}"
      when :not_equal
        query_params[:pre_cond] = "#{motion_get} <> :#{motion_get}"
    end
    {
        :query_params => query_params
    }
  end

  def change_style(str)
    return str if str.blank?
    camelize_str = str.camelize
    camelize_str[0] = camelize_str[0].downcase
    camelize_str
  end

# options = {
#   :model => model实例
#   :controller => controller实例
# }
  def struct_value(target, options = {})
    value = nil

    if @association
      association = options[:model].send(@association.to_sym)
      if association
        value = association.is_a?(Array) ? association.inject([]) { |result, association_unit|
          result << @association_mapping.default_struct(association_unit, :scope => options[:controller])
        } : [@association_mapping.default_struct(association, :scope => options[:controller])]
      end
    else
      value = options[:instance].value_with_string(@motion[:get])
    end

    target[@ref.to_sym] = value if value
  end

  def mapping_to_model(options = {})
    options[:instance].send((@motion[:set].to_s + '=').to_sym, options[:params][@ref.to_sym]) if options[:params].has_key?(@ref.to_sym)
  end

  def add_condition(condition, options = {})
# 默认无数据回传的查询条件不起效
    return condition if options[:params][@ref.to_sym].blank?
    if @motion[:query][:method]
      options[:container].send(@motion[:query][:method].to_sym, options[:params])
    else
      motion_get = @motion[:get]
      depend_on = {
          motion_get.to_sym => options[:params][@ref.to_sym]
      }
      pre_cond = @motion[:query][:query_params][:pre_cond]
      suf_cond = @motion[:query][:query_params][:suf_cond]
      depend_on[motion_get.to_sym] = suf_cond.gsub(/:depend/, depend_on[motion_get.to_sym]) if suf_cond
      pre_cond ? condition.where([pre_cond, depend_on]) : condition.where(depend_on)
    end
  end

  def available(options = {})
    return false if (@lazy && !options[:greedy])
    options[:motion].all?{|motion_unit|
      @motion.has_key?(motion_unit)
    }
  end

  attr_accessor :name, :ref
end