# encoding: utf-8
require_dependency 'web_user'
require_dependency 'customize_exception'
module CoreExtension
  module ActionController
    module Base

      def index
        case params[:dispatch]
          when NilClass
            result = self.send :search
          else
            result = self.send params[:dispatch].to_sym
        end
        render extjs_struct(result)
      end

      def show
        render extjs_struct(self.class.major.find(params[:id]).mapping_exec(
        {
            :motion => [:get],
            :greedy => true,
            :mapping => self.class.mapping
        }))
      end

      def create
        self.class.major.new.mapping_attr({
            :params => params,
            :greedy => true,
            :mapping => self.class.mapping
        }).save!
        render extjs_struct
      end

      def update
        self.class.major.find(params[:id]).mapping_attr({
            :params => params,
            :greedy => true,
            :mapping => self.class.mapping
        }).save!
        render extjs_struct
      end

      def destroy
        self.class.major.find(params[:id]).destroy
        render extjs_struct
      end

      def search
        self.class.mapping.struct_exec(search_condition, {
            :params => params
        })
      end

# 为Relation提供映射内的查询条件
      def search_condition(condition = nil)
        condition_struct = (condition || self.class.major)
        condition_struct = self.class.mapping.add_condition(
            {
                :condition_struct => condition_struct,
                :params => params
            }
        )

        if params[:sort]
          sort_params = JSON.parse(params[:sort], :symbolize_names => true)
        end
        self.class.mapping.add_sort(
            {
                :condition_struct => condition_struct,
                :params => params,
                :sort_params => sort_params
            }
        )
      end

# 为Relation提供query内容的查询条件
      def query_condition(condition = nil, fields = [])
        condition_struct = (condition || self.class.major)
        unless params[:query].blank?
          condition_collection = []
          0.upto(fields.size - 1) { |i|
            condition_collection << "`#{fields[i]}` LIKE :query"
          }
          condition_struct = condition_struct.where([condition_collection.join(' OR '), {:query => (params[:query].to_s + '%')}])
        end
        condition_struct
      end

      def extjs_struct(source = nil)
        ext_respond = {
            :json => {
                :success => true
            }
        }
        case source
          when Hash
            ext_respond[:json].merge!(
                source[:total_length] ?
                    {
                        :totalLength => source[:total_length],
                        :root => source[:source]
                    } : {
                    :root => [
                        source
                    ]}
            )
          when NilClass
          else
            raise 'Unexpected source type.'
        end
        ext_respond
      end

# 与RecordMapping中同名函数返回相同结构的结果集, 但组装方式由传入的代码块/Proc来决定.
      def struct_exec(condition_struct, options = {})
        total_length = condition_struct.count
        total_length = total_length.size if total_length.is_a?(Hash)

        condition_struct = condition_struct.limit(params[:limit].to_i) if params[:limit]
        condition_struct = condition_struct.offset(params[:start].to_i) if params[:start]

        instances = condition_struct.all

        if options[:handle]
          data_source = instances.inject([]) { |source, instance|
            source << (options[:handle].call(instance))
            source
          }
        else
          data_source = instances.inject([]) { |source, instance|
            source << (yield instance)
            source
          }
        end

        {
            :total_length => total_length,
            :source => data_source
        }
      end

#
# 当第一个参数为String或者由String所组成的数组时
# exception_report('common.m0001')
# exception_report('common.m0001', :count => 3, :name => 'test')
# exception_report('common.m0001', :params => {:count => 3, :name => 'test'})
# exception_report('common.m0001', :standard_replace => 'Some messages')
# exception_report('common.m0001', :count => 3, :standard_replace => 'Total is %{count}')
# exception_report('common.m0001', :params => {:count => 3}, :standard_replace => 'Total is %{count}')
# exception_report('common.m0001', :count => 3, :type => :warning, :render => {:action =>:show})
# exception_report('common.m0001', :params => {:count => 3}, :type => :warning, :render => {:action =>:show})
#
#  Full params: exception_report('common.m0001', :params => {:count => 3}, :standard_replace => 'Total is %{count}', :type => :warning, :information => {:name => 'Warning'}})
#
# 第一个参数为ActiveRecord实例或者由ActiveRecord实例所组成的数组时
# exception_report(@bumon) #=>"部门名称不能为空, 不能为数字并且不能大于6位; 部门编号不能为空"
# exception_report([@bumons[0], @bumons[1], @bumons[2]]]) #=>"第1行: 部门名称不能为空, 不能为数字并且不能大于6位; 部门编号不能为空\n第3行: 部门名称不能为空, 不能为数字并且不能大于6位; 部门编号不能为空"
#                               ^此实例无错误
#
      def exception_report(source, options = {})
        exception_type = options.delete(:type)
        exception_information = options.delete(:information) || options

        if source.is_a?(Array)
          msg_combo = []
          column_list = (options.delete(:column_list) || [])
          0.upto(source.size - 1).each { |i|
            msg_unit = exception_msg_struct(source[i], options)
            msg_combo << s_t('general.base.sort', {:i => (column_list.shift || (i + 1)).to_s}) + msg_unit if msg_unit != ''
          }
          message = msg_combo.join("\n")
        else
          message = exception_msg_struct(source, options)
        end

        raise 'None error message is generated.' if message == ''
        exception = (exception_type && exception_type == :warning) ?
            WarningException.new(message, exception_information) :
            ErrorException.new(message, exception_information)
        raise exception if options[:fatal].nil? || options[:fatal] == true
      end

      def exception_msg_struct(unit, options = {})
        if unit.is_a?(ActiveRecord::Base)
          msg_list = []
          unit.errors.to_hash.each { |key, invalids|
            invalid_list = []
            invalids.each { |invalid|
              invalid_list << invalid
            }
            case invalid_list.size
              when 0
                next
              when 1
                invalid_msg = t(unit.class.to_s.downcase + '.' + key.to_s) + invalid_list[0]
              else
                last_invalid = invalid_list.pop
                invalid_msg = t(unit.class.to_s.downcase + '.' + key.to_s) + invalid_list.join(', ') + t('general.base.and') + last_invalid
            end
            msg_list << invalid_msg
          }
          return '' if msg_list.empty?
          msg_list.join('; ')
        elsif unit.is_a?(String)
          if options[:standard_replace]
            message = options.delete(:standard_replace)
          else
            message =I18n.t "general.errors.#{unit}" #message_store[code.to_s] I18n.t
          end
          param_list = options[:params] ? options[:params] : options
          stuff_message(message, param_list)
        else
          raise 'Not supported type in array for exception_report.'
        end
      end

      def stuff_message(message, param_list)
        param_list.each { |reg, value|
          reg = '%{' + reg.to_s + '}'
          message.gsub!(/#{reg}/, value.to_s)
        }
        message
      end

#
# s_t('messages.common.m0001', {:detail_error_message => 'Here is message.'})
#
      def s_t(translate, param_list)
        message = t(translate)
        stuff_message(message, param_list)
      end

      def exception_render(exception)
        exception_unit = {
            :success => false,
            :exceptionMessage => exception.to_s
        }

        case exception
          when WarningException
            exception_unit[:exceptionType] = t('general.warnings.title.common') # 警告提示
            exception_unit.merge!(exception.info)
          when ErrorException
            exception_unit[:exceptionType] = t('general.errors.title.common') # 错误提示
            exception_unit.merge!(exception.info)
          when 'ActiveRecord::RecordInvalid'.constantize
            exception_unit[:exceptionType] = t('general.errors.title.record') # 保存记录出错
            exception_unit[:exceptionMessage] = t('general.errors.messages.record_invalid') # 字段映射

            exception_unit[:errors] = exception.record.invalid_struct(:mapping => self.class.mapping)
          else
            exception_unit[:exceptionType] = t('general.errors.title.uncatched') # 系统未捕获错误提示
        end

        render :json => exception_unit
      end

      def authorize
        unless current_user.authorize?
          raise
        end
      end

      def current_user
        @current_user ||= WebUser.new(self)
      end

#  shime_tree = {
#      ext_tree_store({
#            :title => '销售月度结算管理',        #title表示treepanel的标题
#            :id => 6,                           #id表示treepanel中root的id
#            :children => [                      #children表示treepanel的子节点或叶子，其中参数有text，id，leaf，src.
#                    {:text => '销售月度结算', :id => 61, :leaf => true, :controller => '/settlements'}
#            ]
#      })
#  };
      def ext_tree_store(config)
        config[:TreeStore] = {
            :root => {
                :expand => false,
                :children => child_tree(config.delete(:children))
            }
        }
        config
      end


#{:text => '自售机设置信息管理', :id => 12, :leaf => false, :singleClickExpand => true, :children => [
#    {:text => '点位基础信息管理', :id => 121, :leaf => true, :controller => 'basyos'}
#]},

      def child_tree(children)
        if children
          children.inject([]) { |filtered_children, child|
            if child[:leaf]
              child[:layout] ||= 'Standard'
              privilege = (child[:privilege] || 'show')
              permit = (child[:permit] || child[:controller] || child[:model].downcase.pluralize)
              next if permit && !(permitted_to? privilege.to_sym, permit.to_sym)
            else
              sub_children = child_tree(child.delete(:children))
              next if sub_children.empty?
              child[:children] = sub_children
            end
            filtered_children << child
          }
        end
      end

# This method return whether current_user permitted.
      def permitted_to?(privilege, permit)
        true
      end

      def catch_exception
        begin
          yield
        rescue Exception => exception
          exception_render(exception)
        end
      end

# 废弃:
# 根据远程model来形成本次返回格式(废弃)
#    def remote_model_map
#      self.class.mapping.inject({}){|remote_map, map_attr|
#        remote_map[map_attr[0].to_sym] = map_attr[1] if params.has_key?(map_attr[0].to_sym)
#        remote_map
#      }
#    end

# Static Method
      def self.included(active_controller)
        active_controller.before_filter :authorize
        active_controller.around_filter :catch_exception

        def active_controller.major=(major_class)
          @major_class = major_class
        end

        def active_controller.major
          @major_class ||= self.controller_name.singularize.classify.constantize
        end

#
# self.mapping = {
#     :id => 'id',
#     :bumon_cd => 'bumonCd',
#     :bumon_mei => 'bumonMei',
#     :bumonlevel_id => 'bumonlevelId',
#     :yubin_no => 'yubinNo',
#     :tel_no => 'telNo',
#     :fax_no => 'faxNo',
#     :jusyo => 'jusyo'
# }
        def active_controller.mapping=(mapping)
          @mapping = RecordMapping::Base.new(
              :mapping => mapping,
              :container => self
          )
        end

        def active_controller.mapping
          @mapping ||= RecordMapping::Base.new(
              :container => self
          )
        end

# 废弃
#       def active_controller.default_mapping=(default_mapping)
#         default_mapping_build if default_mapping
#       end
#
#       def active_controller.default_mapping_build
#         unless @mapping
#           @mapping = ExtMapping.new(
#               :controller => self
#           )
#         end
#       end

        def active_controller.mapping_override(new_mapping)
          mapping.mapping_override(new_mapping)
        end
      end
    end
  end
end