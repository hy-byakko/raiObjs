# encoding: utf-8
class MappingUnit
# 默认映射动作, 对应的值为未指定时的默认值
  MOTION = [
# 远程数据映射为对应模型上的字段时调用的方法/set_method为远程数据映射到本地时, 调用本地controller相应的方法名
      :set,
# 本地模型数据映射为远程模型的数据时取值的方法/get_method为本地数据映射到远程时, 调用本地controller相应的方法名
      :get
  ]

  TYPE = [
      :persist,        # 持续型:参与所有的行为
      :expand,         # 展开型:仅参与与bench相关映射
      :logic,          # 逻辑型:不参与set/get
      :ignore          # 忽略型:不参与所有的映射
  ]

# require option :name
  def initialize(options = {})
    @name = options[:name]

# 远程模型的字段名, 取值/赋值时皆调用此字段
    @ref = (options[:ref] || to_ext_name(options[:name]))
# 默认类型为持续型
    @type = (options[:type] || :persist)

    motion_init(options)
    condition_init(options)
  end

  def override(options)
    @ref = options[:ref] if options[:ref]
    motion_init(options)
    condition_init(options)
  end

  def motion_init(options)
    MOTION.each { |key|
      if options.has_key?(key)
        motion_build(key, options[key], :model)
      elsif options.has_key?((key.to_s + '_method').to_sym)
        motion_build(key, options[(key.to_s + '_method').to_sym], :controller)
      else
# 仅在该动作不存在时为其配置默认
        motion_build(key, options[:name], :model) unless self.send(key)
      end
    }
  end

# conditions将会尝试调用controller内相应名称的方法, 并认为该方法的返回值即为搜索条件.where()内的参数
# 或者以seek_by定义预设规则 当两者配置都不存在的情况下会默认使用equal的方法
  def condition_init(options)
    return unless options[:conditions] || options[:seek_by]

# 初始化condition配置
    @pre_cond &&= nil
    @suf_cond &&= nil
    @conditions &&= nil

    if options[:conditions]
      @conditions = (options[:conditions] || to_ext_name(options[:name]))
    elsif options[:seek_by]
      case options[:seek_by]
        when :similar
          @pre_cond = "#{@get} LIKE :#{@get}"
          @suf_cond = "%:depend%"
        when :pre_similar
          @pre_cond = "#{@get} LIKE :#{@get}"
          @suf_cond = ":depend%"
        when :suf_similar
          @pre_cond = "#{@get} LIKE :#{@get}"
          @suf_cond = "%:depend"
        when :bigger
          @pre_cond = "#{@get} > :#{@get}"
        when :smaller
          @pre_cond = "#{@get} < :#{@get}"
        when :bigger_equal
          @pre_cond = "#{@get} >= :#{@get}"
        when :smaller_equal
          @pre_cond = "#{@get} <= :#{@get}"
        when :not_equal
          @pre_cond = "#{@get} <> :#{@get}"
      end
    end
  end

  def motion_build(key, value, scope)
    motion_value = (value || key).to_s
    self.send((key.to_s + '=').to_sym, motion_value)
    self.send((key.to_s + '_scope=').to_sym, scope)
  end

  def to_ext_name(str)
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

    case @get_scope
      when :model
        value = options[:model].value_with_string(@get)
      when :controller
        value = options[:controller].send(@get.to_sym, options[:model])
    end

    target[@ref.to_sym] = value if value
  end

  def mapping_to_model(options = {})
    source = options[:controller].params
    case @set_scope
      when :model
        options[:model].send((@set.to_s + '=').to_sym, source[@ref.to_sym])
      when :controller
        options[:controller].send(@set.to_sym, options[:model])
    end
  end

  def add_condition(condition, options = {})
    if @conditions
      condition.where(
          options[:controller].send(@conditions.to_sym)) if @conditions
    else
      depend_on = {
          @get.to_sym => options[:controller].params[@ref.to_sym]
      }
      depend_on[@get.to_sym] = @suf_cond.gsub(/:depend/, depend_on[@get.to_sym]) if @suf_cond
      @pre_cond ? condition.where([@pre_cond, depend_on]) : condition.where(depend_on)
    end
  end

  def available(options = {})
    case @type
      when :persist
# 仅当以index动作进入(查询)并且查询内容为空时, persist类型无效
        !(options[:controller].action_name == 'index' && options[:controller].params[@ref.to_sym].blank?)
      when :expand
# 仅当以show, create, update动作进入时, expand类型起效
        ['show', 'create', 'update'].include? options[:controller].action_name
      when :logic
# 仅当以index动作进入并且非set/get时, logic类型起效
        options[:controller].action_name == 'index' && !MOTION.include?(options[:motion])
      else
# 其余默认无效
        false
    end
  end

  attr_accessor :name, :set, :get, :ref, :conditions, :set_scope, :get_scope
end