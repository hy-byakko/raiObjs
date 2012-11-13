# encoding: utf-8
module RecordMapping
  class MappingUnit
# require option :name
    def initialize(options = {})
      @name = options[:name]
      @lazy = true if options[:lazy]

# 远程模型的字段名, 取值/赋值时皆调用此字段
      @ref = (options[:ref] || (options[:change_style] ? change_style(options[:name]) : options[:name]))
    end
  end

  def override(options)
    @ref = options[:ref] if options[:ref]
    @lazy = options[:lazy] if options[:lazy]
  end
end