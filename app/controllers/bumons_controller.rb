# encoding: utf-8
class BumonsController < ApplicationController
  #before_filter :find_bumon, :only => [ :show, :edit, :update, :destroy ]
  #before_filter :get_combox_store, :only => [:new, :show, :edit]

  # GET /bumons
  # GET /bumons.ext_json
  def index
    #@bumonkbnlist = get_combo_list_by_conditions(Kind, {:conditions => 'kindcategory_cd = 32'}, 'id', 'kind_name')
    #if return_id = params[:return_id]
    #  bumons = Bumon.find_by_sql "select * from bumons order by #{sort_params()}"
    #  0.upto(bumons.size - 1){|i|
    #    if bumons[i].id == return_id.to_i
    #      @offset = i/20*20            #开始显示的记录编号，传到index
    #      break
    #    end
    #  }
    #end
    #respond_to do |format|
    #  format.html     # index.html.erb (no data required)
    #  format.ext_json { render :json => find_bumons.to_ext_json(:methods => [:syozokubumonlist, :bumonlevellist], :class => Bumon, :count => Bumon.count(options_from_search(Bumon))) }
    #end
    super
  end

  self.mapping_override(
      {
          :bumon_cd => {
              :seek_by => :similar
          },
          :bumon_mei => {
              :seek_by => :similar
          },
          :parent_id => {
              :set_method => 'ignore_me',
              :get_method => 'cyokuzoku_bumon'
          },
          :parent => {
              :get => 'syozokubumonlist'
          },
          :kind => {
              :get => 'kind.kind_name'
          }
      }
  )

  def ignore_me(instance)

  end

  def cyokuzoku_bumon(bumon)
    cyokuzoku = bumon.bumonsyozokus.select { |bumonsyozoku|
      bumonsyozoku.syozokulevel == 1
    }[0]
    cyokuzoku ? cyokuzoku.id : ''
  end

  def get_bumon_data
    struct_exec(query_condition(Kind.where(:kindcategory_cd => 32), ['kind_name'])) { |instance|
      [
          instance.id,
          instance.kind_name
      ]
    }
  end

  def get_parent_data
    conditions = Bumon
    unless params[:id].blank?
      self_kakyuu_ids = Bumon.find(params[:id]).bumonkakyuus.collect { |bumonkakyuu|
        bumonkakyuu.bumon_id
      }
      conditions.where('id NOT IN (?)', self_kakyuu_ids)
    end
    struct_exec(query_condition(conditions, ['bumon_mei'])) { |instance|
      [
          instance.id,
          instance.bumon_mei
      ]
    }
  end

# GET /bumons/1
  def show
    super
  end

# GET /bumons/new
  def new
    super
  end

# GET /bumons/1/edit
  def edit
    super
  end

# POST /bumons
  def create
    #@bumon = Bumon.new(params[:bumon])
    #bumonsyozoku = Bumonsyozoku.new
    #
    #respond_to do |format|
    #  if @bumon.save
    #    bumonsyozoku.bumon_id = @bumon.id
    #    bumonsyozoku.syozokbumon_id = @bumon.id
    #    bumonsyozoku.syozokulevel = 0
    #    bumonsyozoku.save
    #    flag = params[:bumonsyozoku]["syozokubumon_id"]
    #    if flag !=nil && flag !=""
    #      parent_bumon = Bumonsyozoku.find(:all, :conditions => "bumon_id = #{flag}")
    #      parent_bumon.each { |x| y=Bumonsyozoku.new; y.bumon_id = @bumon.id; y.syozokulevel = x.syozokulevel + 1; y.syozokbumon_id=x.syozokbumon_id; y.save }
    #    end
    #    flash[:notice] = 'Bumon was successfully created.'
    #    format.ext_json { render :json => @bumon.to_ext_json(:success => true) }
    #  else
    #    format.ext_json { render :json => @bumon.to_ext_json(:success => false) }
    #  end
    #end
    super
  end

  def update
    super
  end

  # PUT /bumons/1
  def update_bk
    respond_to do |format|
      if @bumon.update_attributes(params[:bumon])
        direct_parent_bumon = Bumonsyozoku.find(:first, :conditions => "bumon_id = #{@bumon.id} and syozokulevel = 1")
        before_flag = direct_parent_bumon.syozokbumon_id.to_s if direct_parent_bumon #修改前的上级部门id
        flag = params[:bumonsyozoku]["syozokubumon_id"] #修改后的上级部门id
        before_parent_bumon = Bumonsyozoku.find(:all, :conditions => "bumon_id = #{@bumon.id} and syozokulevel > 0") #部门修改前的所有上级部门
        after_parent_bumon = Bumonsyozoku.find(:all, :conditions => "bumon_id = #{flag}") if flag != nil && flag !="" #部门修改后的所有上级部门
        child_bumon = Bumonsyozoku.find(:all, :conditions => "syozokbumon_id = #{@bumon.id}") #修改的部门的所有下级部门
        if before_parent_bumon.empty? #修改前该部门没有上级部门
          if flag != "" && flag != nil #修改后有上级部门
            child_bumon.each { |x|
              after_parent_bumon.each { |y|
                z=Bumonsyozoku.new
                z.bumon_id = x.bumon_id
                z.syozokulevel = x.syozokulevel + y.syozokulevel + 1
                z.syozokbumon_id = y.syozokbumon_id
                z.save
              }
            }
          end
        else #修改前部门有上级部门
          if flag != before_flag
            child_bumon.each { |x|
              before_parent_bumon.each { |y|
                bumonsyozokus = Bumonsyozoku.find_by_sql "select * from bumonsyozokus where bumon_id = #{x.bumon_id} and syozokbumon_id = #{y.syozokbumon_id}"
                bumonsyozokus.each { |z| z.destroy }
              }
            }
            if flag != nil && flag != "" #修改后有上级部门
              child_bumon.each { |x|
                after_parent_bumon.each { |y|
                  z=Bumonsyozoku.new
                  z.bumon_id = x.bumon_id
                  z.syozokulevel = x.syozokulevel + y.syozokulevel + 1
                  z.syozokbumon_id = y.syozokbumon_id
                  z.save
                }
              }
            end
          end
        end
        flash[:notice] = 'Bumon was successfully updated.'
        format.ext_json { render :json => @bumon.to_ext_json(:success => true) }
      else
        format.ext_json { render :json => @bumon.to_ext_json(:success => false) }
      end
    end
  end

# DELETE /bumons/1
  def destroy
    raise

    bumonsyozokus = Bumonsyozoku.find(:all, :conditions => "bumon_id = #{@bumon.id}")
    has_child_bumon = Bumonsyozoku.find(:all, :conditions => "syozokbumon_id = #{@bumon.id} and syozokulevel > 0") #判断删除的部门是否有子部门
    bumonsyozokus.each { |x| x.destroy } if has_child_bumon.empty?
    begin
      @bumon.destroy
    rescue Exception => exception
      if exception.message =~ /^Mysql2::Error: Cannot delete or update a parent row/
        error_log(exception)
        error_report("common.m0002", :params => {:detail_error_message => exception, :object_name => '部门', :info => "部门编号:#{@bumon.bumon_cd}"})
      else
        raise(exception)
      end
    end
    respond_to do |format|
      format.ext_json { render :json => {:success => true}.to_json }
    end
  end


#获得修改画面时的上级部门下拉框
  def get_syozokubumon_data(package)
    condition_struct = Bumon
    if package["instance"]
      condition_struct = condition_struct.where(["id = (select syozokbumon_id from bumonsyozokus where syozokulevel = 1 and bumon_id =?)", package["instance"].id])
    else
      condition_struct = condition_struct.where(["id not in (select bumon_id from bumonsyozokus where syozokbumon_id =?)", package['bumon_id']])
    end
    condition_struct.auto_complete_struct(package, ['bumon_mei']) { |instance, result|
      result << instance.id
      result << instance.bumon_mei
    }
  end

  def get_combox_store
    @syozokubumonList = data_provide(:instance => @bumon, :method => :get_syozokubumon_data, :type => :autoCombox)
  end

  protected

  def find_bumon
    @bumon = Bumon.find(params[:id])
  end

  def find_bumons

    pagination_state = update_pagination_state_with_params!(Bumon)
    condition = options_from_pagination_state(pagination_state).merge(options_from_search(Bumon))

    if params[:sort].nil?
      condition[:order] = sort_params
    elsif params[:sort] =~ /^virtual_attributes\[(\w+)\]$/
      sort_field = params[:sort].sub!(/(\A[^\[]*)\[([^\]]*)\]/, '\2')
      order_conditon = Bumon.new().send(sort_field.to_sym, false)
      order_conditon[:order] = order_conditon[:order] + " " + params[:dir]
      condition = condition.merge(order_conditon)
    end
    @bumons = Bumon.find(:all, condition)
  end

  def sort_params()
    "bumon_cd ASC"
  end
end
