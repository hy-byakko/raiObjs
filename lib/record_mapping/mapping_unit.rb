# encoding: utf-8
module RecordMapping
  class MappingUnit
    MOTION = [
# 本地模型数据映射为远程模型的数据时取值的方法
        :get,
        # 远程数据映射为对应模型上的字段时调用的方法
        :set,
        # 以自身作为查询条件
        :query,
        # 以自身作为排序条件
        :sort
    ]

# 当:type在option中被指定时, 将依照:type来定义动作(motion), 未定义的动作将会被默认行为指定,
# 仅当:type未被指定时, 未指定的动作不会指定默认行为
    TYPE = {
        :persist => [:get, :set, :query, :sort], # 持续型:参与所有的行为
        :grid => [:get, :sort], # 列表型:仅参与get/sort
        :accessor => [:get, :set], # 存取器
        :logic => [:query], # 逻辑型:不参与get/set/sort
        :ignore => [] # 忽略型:不参与所有的映射
    }

# require option :name
    def initialize(options = {})
      @name = options[:name]
      @lazy = true if options[:lazy]

# 远程模型的字段名, 取值/赋值时皆调用此字段
      @ref = (options[:ref] || (options[:change_style] ? change_style(options[:name]) : options[:name]))
      @motion = {}
      motion_init(options)
    end

    def override(options)
      @ref = options[:ref] if options[:ref]
      @lazy = options[:lazy] if options[:lazy]
      motion_init(options)
    end

    def change_style(str)
      return str if str.blank?
      camelize_str = str.camelize
      camelize_str[0] = camelize_str[0].downcase
      camelize_str
    end

    def available(options = {})
      return false if (@lazy && !options[:greedy])
      options[:motion].all? { |motion_unit|
        @motion.has_key?(motion_unit)
      }
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
            :field => motion_value,
            :seek_by => :equal
        } : motion_value
        @motion[:query] = query_build(motion_value)
      elsif key == :sort
        @motion[:sort] = motion_value.is_a?(String) ? {
            :field => motion_value
        } : motion_value
      else
        @motion[key] = motion_value
      end
    end

# query将会尝试调用model内相应名称的方法, 并认为该方法的返回值即为搜索条件.where()内的参数
# 或者以seek_by定义预设规则 当两者配置都不存在的情况下会默认使用equal的方法
    def query_build(options)
      return options if options[:method]
      query_params = {}
      motion_field = (options[:field] || @motion[:get])
      case options[:seek_by]
        when :similar
          query_params[:pre_cond] = "#{motion_field} LIKE :#{motion_field}"
          query_params[:suf_cond] = "%:depend%"
        when :pre_similar
          query_params[:pre_cond] = "#{motion_field} LIKE :#{motion_field}"
          query_params[:suf_cond] = ":depend%"
        when :suf_similar
          query_params[:pre_cond] = "#{motion_field} LIKE :#{motion_field}"
          query_params[:suf_cond] = "%:depend"
        when :bigger
          query_params[:pre_cond] = "#{motion_field} > :#{motion_field}"
        when :smaller
          query_params[:pre_cond] = "#{motion_field} < :#{motion_field}"
        when :bigger_equal
          query_params[:pre_cond] = "#{motion_field} >= :#{motion_field}"
        when :smaller_equal
          query_params[:pre_cond] = "#{motion_field} <= :#{motion_field}"
        when :not_equal
          query_params[:pre_cond] = "#{motion_field} <> :#{motion_field}"
      end
      {
          :field => motion_field,
          :query_params => query_params
      }
    end

    attr_accessor :name, :ref
  end
end