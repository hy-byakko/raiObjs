# encoding: utf-8
class BasyosController < ApplicationController
  #before_filter :find_basyo, :only => [:show, :edit, :update, :destroy]
  #before_filter :set_for_copy_basyo, :only => [:new]
  #before_filter :get_combox_store, :only => [:index, :new, :edit, :show]

  self.mapping_override(
      {
          :basyo_cd => {
              :seek_by => :similar
          },
          :basyo_name => {
              :seek_by => :similar
          },
          :customer_name => {
              :get => 'custom.customer_name'
          },
          :vm_cd => {
              :get => 'vm.vm_cd'
          },
          :bumon_name => {
              :get => 'bumon.bumon_mei'
          },
          :eigyotanto_name => {
              :get => 'eigyotanto.user_name'
          },
          :sagyotanto_name => {
              :get => 'sagyotanto.user_name'
          },
          :rireki_dtm => {
              :type => :logic,
              :conditions => 'in_rireki'
          },
          :turikin => {
              :type => :ignore
          },
          :vmanzenzaikosu => {
              :type => :ignore
          },
          :vmcolumns => {
              :association => :vmcolumns,
              :type => :expand,
              :mapping_override => {
                  :group_no => {
                      :type => :ignore
                  }
              }
          }
      }
  )

  def in_rireki
    [
        'rireki_kaisi_dtm <= :rireki_dtm AND rireki_syuryo_dtm >= :rireki_dtm',
        {
            :rireki_dtm => Date.parse(params[:rirekiDtm]).to_s(:number)
        }
    ]
  end

  def get_customer
      struct_exec(query_condition(Custom, ['customer_name'])) { |instance|
        [
            instance.id,
            instance.customer_name
        ]
      }
  end

  def get_bumon
      struct_exec(query_condition(Bumon, ['bumon_mei'])) { |instance|
        [
            instance.id,
            instance.bumon_mei
        ]
      }
  end

  def get_vm
      struct_exec(query_condition(Vm, ['vm_cd'])) { |instance|
        [
            instance.id,
            instance.vm_cd
        ]
      }
  end

  def get_eigyotanto
      struct_exec(query_condition(User, ['user_name'])) { |instance|
        [
            instance.id,
            instance.user_name
        ]
      }
  end

  def get_sagyotanto
      struct_exec(query_condition(User, ['user_name'])) { |instance|
        [
            instance.id,
            instance.user_name
        ]
      }
    end

# GET /basyos
# GET /basyos.ext_json
  def index
    ##现在时间取得
    #@date =Date.today.to_s
    #@vmList = data_provide(:instance => @basyo, :method => :get_index_vm_data, :type => :autoCombox)
    #
    #unless params[:return_id].blank?
    #  return_id = params[:return_id]
    #  @basyos = Basyo.find_by_sql "select * from basyos  order by #{sort_params()} "
    #  0.upto(@basyos.size - 1) { |i|
    #    if @basyos[i].id == return_id.to_i
    #      @offset = i/$page_size * $page_size
    #      break
    #    end
    #  }
    #end
    #respond_to do |format|
    #  format.html # index.html.erb (no data required)
    #  format.ext_json { render :json => find_basyos.to_ext_json(:methods => [:culist, :bulist, :vlist, :gylist, :eilist, :salist, :dalist], :class => Basyo, :count => Basyo.count(options_from_search(Basyo))) }
    #end
    super
  end

  # GET /basyos/1
  def show
    #@basyo_id = @basyo.id
    #@gymuid =Gyomukind.find(:all).first.id
    #getPaykind
    #
    #@datacollectwaykindList = get_combo_list(Datacollectwaykind, 'id', 'kind_name')
    super
  end

  #复制添加的场合
  def set_for_copy_basyo
    unless params[:id].blank? #复制添加的场合
      @basyo_id = params[:id]
      @basyo = Basyo.find(@basyo_id)

      #履历开始日
      @basyo["rireki_kaisi_dtm"] = set_datetime_format(seachrirekikaisidtm(@basyo["basyo_cd"], @basyo["customer_id"]))
                              #履历结束日
                              #@basyo["rireki_syuryo_dtm"] =set_datetime_format(@basyo["rireki_syuryo_dtm"])

    else
      @basyo_id=""
      @basyo = Basyo.new(params[:basyo])
    end
  end

  # GET /basyos/new
  def new
    @date =(Date.today+1.day).strftime("%Y%m%d")
    #履历结束日
    @basyo["rireki_syuryo_dtm"] ="9999/12/31 23:59:59"
    #获取支付方式
    getPaykind

    #20120327 added start
    @vmsettingfile_id = ""
    @settingfileinfo_id = ""
    @settingfile_vm_id = ""
    unless params[:param].blank?
      @vmsettingfile_id = params[:param][:vmsettingfile_id] #用于更新到vmsettingfile表
      @settingfileinfo_id= params[:param][:settingfileinfo_id] #用于从settingfileinfo表取文件流
      @settingfile_vm_id = params[:param][:vm_id]
      @basyo.vm_id = params[:param][:vm_id]
    end
    #20120327 added end

    @gymuid =Gyomukind.find(:all).first.id
    @datacollectwaykindList = get_combo_list(Datacollectwaykind, 'id', 'kind_name')

  end

  # GET /basyos/1/edit
  def edit
    # edit.html.erb
    @basyo_id = @basyo.id
    getPaykind
    @gymuid =Gyomukind.find(:all).first.id
    @datacollectwaykindList = get_combo_list(Datacollectwaykind, 'id', 'kind_name')

    unless Uriagefull.find(:all, :conditions => ["basyo_id= :id ", {:id => params[:id]}]).blank?
      error_report("common.m0017", :type => :warning, :render => {:action => :show})
    end
  end

  # POST /basyos
  def create
    @basyo = Basyo.new(params[:basyo])
    return render :json => @basyo.to_ext_json(:success => false) if !@basyo.valid?

    #获取终了日大于当前设定开始日的履历信息
    start_date = @basyo["rireki_kaisi_dtm"]
    basyo = Basyo.find(:all, :conditions => ["customer_id=:customer_id and basyo_cd = :basyo_cd and rireki_syuryo_dtm >:startDate",
                                             {:customer_id => @basyo["customer_id"], :basyo_cd => @basyo["basyo_cd"], :startDate => datetime_tostring(@basyo["rireki_kaisi_dtm"])}], :order => 'rireki_kaisi_dtm ASC').first
    rireki_action(basyo, @basyo, start_date, params[:vmsettingfile_id])

    respond_to do |format|
      format.ext_json { render :json => @basyo.to_ext_json(:success => true) }

    end
  end

  # PUT /basyos/1
  def update
    params[:basyo]["rireki_kaisi_dtm"]= datetime_tostring(@basyo["rireki_kaisi_dtm"])
    params[:basyo]["rireki_syuryo_dtm"]= datetime_tostring(@basyo["rireki_syuryo_dtm"])
    respond_to do |format|
      if @basyo.update_attributes(params[:basyo])
        #先删除子表和子子表
        @basyo.vmcolumns.each { |y| y.destroy }
        #插入子表和子子表
        insertcolumn(@basyo)

        format.ext_json { render :json => @basyo.to_ext_json(:success => true) }
      else
        format.ext_json { render :json => @basyo.to_ext_json(:success => false) }
      end
    end
  end

  # DELETE /basyos/1
  def destroy
    unless Uriagefull.find(:all, :conditions => ["basyo_id= :id ", {:id => params[:id]}]).blank?
      error_report("common.m0027", :type => :warning, :render => {:action => :show})
    end

    @basyo.relation_destroy({:id => @basyo.id})

    respond_to do |format|
      format.ext_json { render :json => {:success => true}.to_json }
    end
  end


  def rireki_action(modelInstance, savemodel, startdate, vmsettingfile_id)
    #输入的日期大于最大的履历终了日的日期的条件
    if modelInstance.blank?
      #之后的日期里没有履历记录
      enddate = "99991231235959"
    elsif  modelInstance.rireki_kaisi_dtm.to_s < datetime_tostring(startdate) and modelInstance.rireki_syuryo_dtm.to_s > datetime_tostring(startdate)
      #交叉的履历
      enddate = modelInstance.rireki_syuryo_dtm
      updatevalue(modelInstance, (time_tostring(Time.at(Time.parse(startdate).to_i-1).to_s[0, 19])))
    end
    insertvalue(savemodel, datetime_tostring(startdate), enddate, vmsettingfile_id)
  end

  #新追加的履历
  def insertvalue(model_instance, startdate, enddate, vmsettingfile_id)
    #父表
    model_instance.rireki_kaisi_dtm =startdate
    model_instance.rireki_syuryo_dtm =enddate

    if model_instance.save
      insertcolumn(model_instance)
      unless vmsettingfile_id.blank?
        updatesettingfile(vmsettingfile_id, model_instance.id)
      end
    else
      error_report(model_instance)
      #render :json => newinstance.to_ext_json(:success => false)
    end
  end

  #将从配置文件中读取的记录生成的basyo_id更新到vmsettingfiles表。
  def updatesettingfile(id, basyo_id)
    Vmsettingfile.update(id, :synchronized => 2, :basyo_id => basyo_id, :sync_dtm => Time.now.to_s(:db))
  end

  def insertcolumn(newinstance)
    col_parsed_json_hash = ActiveSupport::JSON.decode(params[:col_grid_data])
    aryvmcolumns = []
    colnum_list = []
    errorflag = false
    aryvmprice = []
    colnum_list_price = []
    errorflag_price = false
    col_parsed_json_hash["root"].each { |product_hash|
      #商品，温度，满仓数，补货基准数为空，则整条记录不插入数据库
      unless product_hash['syohin_id'].blank? && product_hash['ondo'].blank? && product_hash['fullsyohinsu'] == 0 && product_hash['setteisu'] == 0
        #货道子表
        vmcolumn = newinstance.vmcolumns.new()
        vmcolumn.match_attr(product_hash)
        aryvmcolumns << vmcolumn
        unless vmcolumn.save
          colnum_list << product_hash['column_no'] #记录错误行号
          errorflag = true
          next
        end
        #价格子子表
        product_hash.select { |key, value|
          if key[0...7]=="payKind"
            vmcolumnprice =vmcolumn.vmcolumnprices.new()
            vmcolumnprice.kaisyukbn_id = key[8...key.length]
            vmcolumnprice.price = value
            aryvmprice << vmcolumnprice
            unless vmcolumnprice.save
              colnum_list_price << product_hash['column_no']
              errorflag_price = true
            end
          end
        }
      end
    }
    error_report(aryvmcolumns, :colnum_list => colnum_list) if errorflag
    error_report(aryvmprice, :colnum_list => colnum_list_price) if errorflag_price
  end


  #需要更新的履历
  def updatevalue(updateinstance, enddate)

    updateinstance[:rireki_syuryo_dtm]=enddate

    unless updateinstance.save
      error_report(updateinstance)
    end
  end

  def grid_data_col
    return_data = Hash.new()
    unless params[:basyo_id].blank?
      hasharrry=[]
      tbasyo = Basyo.find(params[:basyo_id])
      tbasyo.vmcolumns.collect { |x|
        columnpricekey = ""
        hashColumn = x.attributes.dup
        hashColumn[:flgno] = 1
        x.vmcolumnprices.collect { |y|
          columnpricekey="payKind_"+ y.kaisyukbn_id.to_s
          hashColumn[columnpricekey.to_sym] = y.price
        }
        hasharrry << hashColumn
      }
      #20120405 added by cl start
      hasharrry.sort! { |beforeitem, nextitem| beforeitem['column_no'].to_i <=> nextitem['column_no'].to_i }
      columncnt = tbasyo.vm.columncnt #获取该自售机的最大货道数
      if hasharrry.empty? #该条点位在数据库中没有相应的有效货道记录，但是在vms表中有货道数，则生成货道记录
        columncnt.times { |index|
          column_no = index + 1
          item_hash = {}
          item_hash['column_no'] = column_no
          item_hash['fullsyohinsu'] = 0
          item_hash['setteisu'] = 0
          item_hash['group_no'] = 0
          item_hash['flgno'] = 0
          hasharrry << item_hash
        }
      else
        hasharrry.length < columncnt #该条点位记录的货道记录条数小于自售机的货道记录条数，则生成货道记录，但是货道上没有设置相应值
        compare_index = 0
        compare_column_no = hasharrry[compare_index]['column_no']
        columncnt.times { |index|
          column_no = index + 1
          if ((column_no < compare_column_no) || column_no > compare_column_no)
            #只生成货道号这条记录,货道上未录入商品，满仓数等任何值，按从小到大的顺序
            item_hash = hasharrry[0].clone
            item_hash.keys.each { |key| item_hash[key] = '' }
            item_hash['column_no'] = column_no
            item_hash['fullsyohinsu'] = 0
            item_hash['setteisu'] = 0
            item_hash['group_no'] = 0
            item_hash['flgno'] = 0
            hasharrry << item_hash
          else
            compare_index = compare_index + 1
            compare_column_no = hasharrry[compare_index]['column_no'] unless hasharrry[compare_index].blank?
          end
        }
      end
      hasharrry.sort! { |beforeitem, nextitem| beforeitem['column_no'].to_i <=> nextitem['column_no'].to_i } #按column_no从小到大
      #20120405 added by cl end

      return_data[:basyoColumns] = hasharrry
    else
      return_data[:basyoColumns]={}
    end

    #20120327 added start
    unless params[:settingfileinfo_id].blank?
      file_id = params[:settingfileinfo_id]
      vm_id = params[:settingfile_vm_id]
      return_data[:basyoColumns] = getdatafromconfigfile(file_id, vm_id)
    end
    #20120327 added end

    render :text => return_data.to_json, :layout => false
  end

  #20120327 added start
  def getdatafromconfigfile(file_id, vm_id)
    @returndata = {} #返回的数据集
    begin
      #从数据库表settingfileinfos取得文件流生成到tmp_file文件
      settingfileinfo = Settingfileinfo.find(file_id)
      user_cd = ''
      user_cd = session[:user_cd] + '_' unless session[:user_cd].blank?
      tmp_filename = user_cd + Time.now.to_i.to_s + '_tmp.dat'
      tmp_filedir = File.join("#{Rails.root.to_s}", 'tmp', tmp_filename)
      tmp_file = File.open(tmp_filedir, "wb")
      tmp_file.write settingfileinfo.filecontent
      tmp_file.close
      #从tmp_file读数据流
      f = File.open(tmp_file, "rb")
      f.sysread(22).unpack('H*') #读取头部22各字节
      while true
        begin
          datakind = f.sysread(1).unpack('H*') #16进制
          if (datakind[0] == '80') #开始读取循环数据(设定 = 0x80, 保存 = 0x20)
            sebanngou = f.sysread(2).unpack("v")[0] #背番号，读2个字节，高低位互换。如果不互换用"n"
            datacount = f.sysread(1).unpack('C*')[0] #データ個数 return Integer | 8-bit unsigned integer
            bytecount = f.sysread(2).unpack('v*')[0] #構造バイト数,short型还是long型,高低位互换
            if (sebanngou == 3071) # 設定価格,short型
              itemarray = Array.new()
              datacount.times { |index|
                item = f.sysread(bytecount).unpack('v*')[0].fdiv(10) #v:16-bit高低位互换,价格除以10，比如:25->2.5
                itemarray << item
              }
              @returndata[:setprice] = itemarray
            elsif (sebanngou == 4046) # カード設定価格,short型
              itemarray = Array.new()
              datacount.times { |index|
                item = f.sysread(bytecount).unpack('v*')[0].fdiv(10)
                itemarray << item
              }
              @returndata[:cardsetprice] = itemarray
            elsif (sebanngou == 6398) # プリンタ商品コード,long型
              itemarray = Array.new()
              datacount.times { |index|
                item = f.sysread(bytecount).unpack('V*')[0] #V:32-bit 高低位互换
                itemarray << item
              }
              @returndata[:printergoodsnameset] = itemarray
            elsif (sebanngou == 8697) # 満杯収容本数,short型
              itemarray = Array.new()
              datacount.times { |index|
                item = f.sysread(bytecount).unpack('v*')[0] #v:16-bit高低位互换
                itemarray << item
              }
              @returndata[:fullcupnumset] = itemarray
            end
          end
        rescue
          break
        end
      end
      f.close
      File.delete(tmp_file)
    rescue Exception => e
      File.delete(tmp_file)
      puts e.message
    end

    #从数据库中查询支付方式的id,kind_cd
    cash_id = 0
    precard_id = 0
    creditcard_id = 0
    kinds = Kind.find(:all, :conditions => "kindcategory_cd in ('33','34')")
    kinds.each_with_index { |kind, i|
      cash_id = kind.id if kind.kindcategory_cd == '33' && kind.kind_cd == '01' # 现金
      precard_id = kind.id if kind.kindcategory_cd == '33' && kind.kind_cd == '02' #预付卡
      creditcard_id = kind.id if kind.kindcategory_cd == '34' && kind.kind_cd == '01' #信用卡
    }
    #从数据库中查询从vmsettingfiles页面传递过来的自售机的最大货道数
    vm = Vm.find(vm_id)
    columncnt = vm.columncnt #货道数 
    #开始组装从.dat文件中读取的数据返回到页面上
    lastindex = 0
    recordarray = []
    keys = @returndata.keys #=> ["setprice", "cardsetprice", "printergoodsnameset","fullcupnumset"]
    if keys.include?(:fullcupnumset)
      #记录从.dat文件中读取的数据从lastindex行后，所有的行的数据为0的无效数据
      @returndata[:fullcupnumset].each_with_index { |item, index|
        fullcupnumset = item
        setprice = @returndata[:setprice][index] #設定価格
        cardsetprice = @returndata[:cardsetprice][index] #カード設定価格
        printergoodsnameset = @returndata[:printergoodsnameset][index] #満杯収容本数
        lastindex = (fullcupnumset != 0 || setprice != 0 || cardsetprice != 0 || printergoodsnameset != 0) ? index : lastindex
      }
      #获取截取数组时截取的length
      lastindex = lastindex + 1 #lastindex下标号从0开始,length从1开始
      lastindex = columncnt if columncnt < lastindex
      #截取无效的数据或是超过该自售机的最大货道数的数据
      fullcupnumsetarray = @returndata[:fullcupnumset][0, lastindex]
      setpricearray = @returndata[:setprice][0, lastindex]
      cardsetpricearray = @returndata[:cardsetprice][0, lastindex]
      printergoodsnamesetarray = @returndata[:printergoodsnameset][0, lastindex]
      #组装数据
      key_card = "payKind_" + cash_id.to_s
      key_precard = "payKind_" + precard_id.to_s
      fullcupnumsetarray.each_with_index { |item, index| # 満杯収容本数
        recordhash = Hash.new
        recordhash[:fullsyohinsu] = item #满仓数
        recordhash[:setteisu] = item #补货数
        recordhash[:column_no] = index + 1 #货道号
        recordhash[:group_no] = 0
        recordhash[:flgno] = 1
        recordarray << recordhash
      }
      setpricearray.each_with_index { |item, index| # 設定価格  现金
        recordarray[index][key_card.to_sym] = item
      }
      cardsetpricearray.each_with_index { |item, index| # カード設定価格 预付卡
        recordarray[index][key_precard.to_sym] = item
      }
      printergoodsnamesetarray.each_with_index { |item, index| # プリンタ商品コード
        recordarray[index][:syohin_id] = item
      }
    end
    #返回数据
    return_data = {}
    return_data[:basyoColumns] = recordarray
    return return_data[:basyoColumns]
  end

  #20120327 added end

  #获取支付方式
  def getPaykind
    @PayKind = get_combo_list_by_conditions(Kind, {:conditions => "kindcategory_cd in ('33','34')"}, 'id', 'kind_name')
    #删除['',''],
    @PayKind = @PayKind[8...@PayKind.length] unless @PayKind.blank?
  end


  #获得各下拉框的Store(index, new,edit,show)
  def get_combox_store
    skip_filter = false
    if action_name =="new" && (!@basyo.blank?)
      #复制添加的场合，走edit的路
      skip_filter = true
    end


    @bumonList = data_provide(:instance => @basyo, :method => :get_bumon_data, :type => :autoCombox, :skip_filter => skip_filter)
    @vmList = data_provide(:instance => @basyo, :method => :get_vm_data, :type => :autoCombox, :skip_filter => skip_filter, :structure => ['id', 'content', 'columncnt'])
    @customList = data_provide(:instance => @basyo, :method => :get_custom_data, :type => :autoCombox, :skip_filter => skip_filter)
    @eigyotantouserList = data_provide(:instance => @basyo, :method => :get_eigyotantouser_data, :type => :autoCombox, :skip_filter => skip_filter)
    @sagyotantouserList = data_provide(:instance => @basyo, :method => :get_sagyotantouser_data, :type => :autoCombox, :skip_filter => skip_filter)
    #商品记录
    @productList = data_provide(:instance => @basyo, :method => :get_product_data, :type => :autoCombox, :mode => 'local')
  end

  #获得部门下拉框数据源
  def get_bumon_data(package)
    condition_struct = Bumon
    if package["instance"]
      condition_struct = condition_struct.where(["id = ?", package["instance"].bumon_id])
    else
      unless package["eigyotanto_id"].blank?
        condition_struct = condition_struct.where(["id = ?", User.find(package["eigyotanto_id"]).bumon_id])
      else
        condition_struct = condition_struct.where(["id = ?", User.find(package["sagyotanto_id"]).bumon_id]) unless package["sagyotanto_id"].blank?
      end
    end
    condition_struct = condition_struct.where(:id => current_user.visible_bumon_ids)
    condition_struct.auto_complete_struct(package, ['bumon_mei']) { |instance, result|
      result << instance.id
      result << instance.bumon_mei
    }
  end

  #获取商品记录
  def get_product_data(package)
    condition_struct = Syohin
    condition_struct.auto_complete_struct(package, ['syohin_name']) { |instance, result|
      result[:id] = instance.id
      result[:content] = instance.syohin_name + "【" + instance.syohinstyle.kind_name + "】"
      result[:price] = instance.referenceprice
    }
  end

  #获得客户下拉框数据源
  def get_custom_data(package)
    condition_struct = Custom
    if package["instance"]
      condition_struct = condition_struct.where(["id = ?", package["instance"].customer_id])
    end
    condition_struct.auto_complete_struct(package, ['customer_name']) { |instance, result|
      result << instance.id
      result << instance.customer_name
    }
  end

  #获得index画面自售机下拉框
  def get_index_vm_data(package)
    condition_struct = Vm
    condition_struct.auto_complete_struct(package, ['vm_cd']) { |instance, result|
      result << instance.id
      result << instance.vm_cd
    }
  end

  #获得自售机下拉框数据源
  def get_vm_data(package)
    condition_struct = Vm
    if package["instance"]
      condition_struct = condition_struct.where(["id = ?", package["instance"].vm_id])
    elsif !params[:param].blank? #vmsettingfiles页面穿过来的vm_id
      if !params[:param][:vm_id].blank?
        condition_struct = condition_struct.where(["id = ?", params[:param][:vm_id]])
      end
    else

      #客户，点位，履历开始日为空的情况下，不做请求
      work_dtm = package["rireki_kaisi_dtm"]
      work_dtm_e = package["rireki_syuryo_dtm"]
      customer_id = package["customer_id"]
      basyo_cd = package["basyo_cd"]
      work_dtm = datetime_tostring(work_dtm) unless work_dtm.blank?
      work_dtm_e = datetime_tostring(work_dtm_e) unless work_dtm.blank?

      if work_dtm.blank? ||customer_id.blank? || basyo_cd.blank?
        return
      end

      #work_dtm = DateTime.parse(work_dtm).strftime("%Y%m%d")
      #履历终了日取得
      #work_dtm_e = selectenddate(work_dtm,customer_id,basyo_cd)


      #sql ="((rireki_kaisi_dtm <= "+"'" +work_dtm+"'"+" and rireki_syuryo_dtm >= "+"'" +work_dtm+"')"+
      sql ="(rireki_kaisi_dtm <= "+"'" +work_dtm_e+"'"+" and rireki_syuryo_dtm >= "+"'" +work_dtm+"')"+
          #" or ( rireki_kaisi_dtm <= "+"'" +work_dtm_e+"'" +" and rireki_syuryo_dtm >= "+"'" +work_dtm_e+"')"+
          #" or (rireki_kaisi_dtm >= "+"'" +work_dtm+"'" +" and rireki_syuryo_dtm <= "+"'" +work_dtm_e+"'))"+
          #" or (rireki_kaisi_dtm <= "+"'" +work_dtm+"'" +" and rireki_syuryo_dtm >= "+"'" +work_dtm_e+"'))"+
          "and (basyo_cd <> "+"'"+basyo_cd+"' or customer_id <>'#{customer_id}')"
      #sql ="(basyos.rireki_kaisi_dtm > "+"'" +work_dtm_e.gsub("-", "")+"'" +" or basyos.rireki_syuryo_dtm < "+"'" +work_dtm.gsub("-", "")+"')"+ "and (basyos.basyo_cd <> "+"'"+basyo_cd+"' and basyos.customer_id <>'#{customer_id}')"
      usedVmid = Basyo.find(:all, :conditions => sql).collect { |x|
        "'" + x.vm_id.to_s + "'"
      }.join(",")

      unless usedVmid.blank?
        condition_struct = condition_struct.where("id not in (#{usedVmid})")
      end
    end
    vmhash = condition_struct.auto_complete_struct(package, ['vm_cd']) { |instance, result|
      result << instance.id
      result << instance.vm_cd
      #自售机货道数
      result << instance.columncnt
    }

    unless work_dtm_e.blank?
      vmhash[:rireki_syuryo_dtm] = DateTime.parse(work_dtm_e).strftime("%Y-%m-%d")
    else
      vmhash[:rireki_syuryo_dtm] = ""
    end
    vmhash
  end

  #根据部门下拉框获得营业担当者数据源
  def get_eigyotantouser_data(package)
    condition_struct = User
    if package["instance"]
      condition_struct = condition_struct.where(["id = ?", package["instance"].eigyotanto_id])
    else
      condition_struct = condition_struct.where(["bumon_id = ?", package["bumon_id"]]) unless package["bumon_id"].blank?
      condition_struct = condition_struct.where(["bumon_id = ?", User.find(package["sagyotanto_id"]).bumon_id]) unless package["sagyotanto_id"].blank?
    end
    condition_struct = condition_struct.where("id IN ?", current_user.visable_user_ids)
    condition_struct.auto_complete_struct(package, ['user_name']) { |instance, result|
      result << instance.id
      result << instance.user_name
    }
  end

  #根据部门下拉框获得巡回担当者数据源
  def get_sagyotantouser_data(package)
    condition_struct = User
    if package["instance"]
      condition_struct = condition_struct.where(["id = ?", package["instance"].sagyotanto_id])
    else
      condition_struct = condition_struct.where(["bumon_id = ?", package["bumon_id"]]) unless package["bumon_id"].blank?
      condition_struct = condition_struct.where(["bumon_id = ?", User.find(package["eigyotanto_id"]).bumon_id]) unless package["eigyotanto_id"].blank?
    end
    condition_struct = condition_struct.where("id IN ?", current_user.visable_user_ids)
    condition_struct.auto_complete_struct(package, ['user_name']) { |instance, result|
      result << instance.id
      result << instance.user_name
    }
  end


  protected
  def find_basyo
    @basyo = Basyo.find(params[:id])

    #履历开始日
    @basyo["rireki_kaisi_dtm"] = set_datetime_format(@basyo["rireki_kaisi_dtm"])
    #@basyo["rireki_kaisi_dtm"] =@basyo["rireki_kaisi_dtm"].to_s[0..3]+"-"+@basyo["rireki_kaisi_dtm"].to_s[4..5]+"-"+@basyo["rireki_kaisi_dtm"].to_s[6..7]
    #履历结束日
    @basyo["rireki_syuryo_dtm"] = set_datetime_format(@basyo["rireki_syuryo_dtm"])
    #@basyo["rireki_syuryo_dtm"] =@basyo["rireki_syuryo_dtm"].to_s[0..3]+"-"+@basyo["rireki_syuryo_dtm"].to_s[4..5]+"-"+@basyo["rireki_syuryo_dtm"].to_s[6..7]
    #机内备用零钱
    @basyo["turikin"] = "" if @basyo["turikin"].blank?
    @basyo["vmanzenzaikosu"] = "" if @basyo["vmanzenzaikosu"].blank?

  end

  def find_basyos
    pagination_state = update_pagination_state_with_params!(Basyo)

    condition = options_from_pagination_state(pagination_state).merge(options_from_search(Basyo))

    if params[:sort].nil?
      condition[:order] = sort_params
    elsif params[:sort] =~ /^virtual_attributes\[(\w+)\]$/
      sort_field = params[:sort].sub!(/(\A[^\[]*)\[([^\]]*)\]/, '\2')
      order_conditon = Basyo.new().send(sort_field.to_sym, false)
      order_conditon[:order] = order_conditon[:order] + " " + params[:dir]
      condition = condition.merge(order_conditon)
    end

    @basyos = Basyo.find(:all, condition)
  end

  def sort_params()
    "customer_id ASC,basyo_cd ASC,rireki_kaisi_dtm DESC"
  end

  #验证履历开始日重叠的记录，并且取得履历终了日
  def check_get_date(package)
    #履历开始日
    customer_id = package["customer_id"]
    basyo_cd = package["basyo_cd"]
    rireki_kaisi_dtm = seachrirekikaisidtm(basyo_cd, customer_id)

    unless Basyo.check_start_date(rireki_kaisi_dtm, customer_id, basyo_cd)
      return {:checkflag => false, :method_kind => "check_get_date", :startday => set_datetime_format(rireki_kaisi_dtm)}
    end
    return {:checkflag => true, :method_kind => "check_get_date", :startday => set_datetime_format(rireki_kaisi_dtm)}
  end

  #履历开始时刻
  def seachrirekikaisidtm(basyocd, customid)
    new_uri = Uriagefull.joins(:basyo).where(["basyos.basyo_cd = :basyo_cd and basyos.customer_id = :customer_id", {:basyo_cd => basyocd, :customer_id => customid}]).order("work_dtm desc").first
    if new_uri.blank?
      rireki_kaisi_dtm = time_tostring(Time.now.to_s[0, 19])
    else
      rireki_kaisi_dtm = time_tostring(Time.at(Time.parse(new_uri.work_dtm).to_i+1).to_s[0, 19])
    end
    return rireki_kaisi_dtm;
  end

  def sort_params() #默认排序方式
    "basyo_cd ASC"
  end

  #根据履历开始日和点位编号，客户编号取得履历终了日
=begin	def selectenddate(rireki_kaisi_dtm,customer_id,basyo_cd)
	  basyoasd = Basyo.find(:all,:conditions=>["rireki_syuryo_dtm>=:rireki_kaisi_dtm  and basyo_cd = :basyo_cd and customer_id = :customer_id",
	                     {:rireki_kaisi_dtm=>rireki_kaisi_dtm,:basyo_cd=>basyo_cd,:customer_id=>customer_id}],:order=>"rireki_syuryo_dtm ASC").first
      
      enddate=""
      if basyoasd.blank?
        enddate ='99991231'
    elsif basyoasd.rireki_kaisi_dtm < rireki_kaisi_dtm and  basyoasd.rireki_syuryo_dtm > rireki_kaisi_dtm
       enddate =basyoasd.rireki_syuryo_dtm
    else
        enddate = (DateTime.parse(basyoasd.rireki_kaisi_dtm)-1.day).strftime("%Y%m%d")
      end
=end
end
