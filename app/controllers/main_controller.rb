# encoding: utf-8
#系统登录跳转主页面
class MainController < ApplicationController
  #filter_access_to :all
  #before_filter :authorize, :except => :login
  #protect_from_forgery :except => :login

  def menu
    tree_panel = [ext_tree_store({
                                     :title => '自售机销售管理',
                                     :children => [
                                         {:text => '自售机销售相关基础信息管理', :leaf => false, :singleClickExpand => true, :children => [
                                             {:text => '部门基础信息管理', :leaf => true, :model => 'Bumon'},
                                             {:text => '用户基础信息管理', :leaf => true, :controller => 'users'},
                                             {:text => '客户基础信息管理', :leaf => true, :controller => 'customs'},
                                             {:text => '商品基础信息管理', :leaf => true, :controller => 'syohins'},
                                             {:text => '制造商基础信息管理', :leaf => true, :controller => 'makers'},
                                             {:text => '经销商基础信息管理', :leaf => true, :controller => 'franchisers'},
                                             {:text => '自售机基础信息管理', :leaf => true, :controller => 'vms'},
                                             {:text => '系统分类基础信息管理', :leaf => true, :controller => 'kinds'}
                                         ]},
                                         {:text => '自售机设置信息管理', :leaf => false, :singleClickExpand => true, :children => [
                                             {:text => '点位基础信息管理', :leaf => true, :controller => 'basyos'}
                                         ]},
                                         {:text => '自售机销售信息管理', :leaf => false, :singleClickExpand => true, :children => [
                                             {:text => '全项服务作业信息管理', :leaf => true, :controller => 'uriagefulls'}
                                         ]},
                                         {:text => '商品销售统计', :leaf => false, :singleClickExpand => true, :children => [
                                             {:text => '点位月度商品销售明细表作成', :leaf => true, :controller => 'productsales'},
                                             {:text => '商品销售统计表作成', :leaf => true, :controller => 'syohinhanbaisus'}
                                         ]}
                                     ]
                                 }),
                  ext_tree_store({
                                     :title => '自售机商品销售情况管理',
                                     :children => [
                                         {:text => '自售机商品销售信息管理', :leaf => true, :controller => 'salesachievement'},
                                         {:text => '客户行业分类的商品销售统计', :leaf => true, :controller => 'customkindsalesachievement'},
                                         {:text => '巡回者各担当点位的商品销售统计', :leaf => true, :controller => 'syohinsales'},
                                         {:text => '巡回者商品销售统计', :leaf => true, :controller => 'drinkssales'}
                                     ]
                                 }),
                  ext_tree_store({
                                     :title => '自售机货道分配优化分析',
                                     :children => [
                                         {:text => '自售机货道分配优化分析', :leaf => true, :controller => 'koramusankos'}
                                     ]
                                 }),
                  ext_tree_store({
                                     :title => '机内在库管理',
                                     :children => [
                                         {:text => '机内商品在库信息检索', :leaf => true, :controller => 'zaikosus'}
                                     ]
                                 }),
                  ext_tree_store({
                                     :title => '自售机销售信息统计',
                                     :children => [
                                         {:text => '销售日报作成', :leaf => true, :controller => 'salesdaily'},
                                         {:text => '销售月报作成', :leaf => true, :controller => 'eigyomonths'},
                                         {:text => '赊销销售统计', :leaf => true, :controller => 'salescredits'},
                                         {:text => '自售机月报', :leaf => true, :controller => 'vmmonthlysales'},
                                         {:text => '自售机种别平均销售数一览', :leaf => true, :controller => 'vmavgsales'}
                                     ]
                                 }),
                  ext_tree_store({
                                     :title => '销售月度结算管理',
                                     :children => [
                                         {:text => '销售月度结算', :leaf => true, :controller => 'settlements'}
                                     ]
                                 }),
                  ext_tree_store({
                                     :title => '车辆在库管理',
                                     :children => [
                                         {:text => '车辆基础信息管理', :leaf => true, :controller => 'cars'},
                                         {:text => '车辆商品入库信息管理', :leaf => true, :controller => 'carnyukos'},
                                         {:text => '车辆商品出库信息管理', :leaf => true, :controller => 'carsyukos'},
                                         {:text => '车辆在库信息管理', :leaf => true, :controller => 'carzaikos'},
                                         {:text => '车辆在库盘点信息管理', :leaf => true, :controller => 'carzaikotanas'}
                                     ]
                                 }),
                  ext_tree_store({
                                     :title => '仓库在库管理',
                                     :children => [
                                         {:text => '仓库基础信息管理', :leaf => true, :controller => 'sokos'},
                                         {:text => '仓库货位基础信息管理', :leaf => true, :controller => 'sokookibas'},
                                         {:text => '仓库商品入库信息管理', :leaf => true, :controller => 'sokonyukos'},
                                         {:text => '仓库商品出库信息管理', :leaf => true, :controller => 'sokosyukos'},
                                         {:text => '仓库货位商品入库信息管理', :leaf => true, :controller => 'sokookibanyukos'},
                                         {:text => '仓库货位商品出库信息管理', :leaf => true, :controller => 'sokookibasyukos'},
                                         {:text => '仓库在库信息管理', :leaf => true, :controller => 'sokozaikos'},
                                         {:text => '仓库在库盘点信息管理', :leaf => true, :controller => 'sokozaikotanas'},
                                         {:text => '仓库货位在库信息管理', :leaf => true, :controller => 'sokookibazaikos'},
                                         {:text => '仓库货位在库盘点信息管理', :leaf => true, :controller => 'sokookibatanas'}
                                     ]
                                 }),
                  ext_tree_store({
                                     :title => 'GPRS信息管理',
                                     :children => [
                                         {:text => 'GPRS自售机状态信息管理', :leaf => true, :controller => 'vw_vm_gprsjoutaijouhous'},
                                         {:text => 'GPRS数据与系统分类的对应信息', :leaf => true, :controller => 'gprskinds'},
                                         {:text => 'GPRS信息收集的自售机销售信息', :leaf => true, :controller => 'gprsuricolinfos'}
                                     ]
                                 }),
                  ext_tree_store({
                                     :title => 'USB信息管理',
                                     :children => [
                                         {:text => 'USB设备基础信息', :leaf => true, :controller => 'usbinfos'},
                                         {:text => 'USB自售机状态信息管理', :leaf => true, :controller => 'vw_vm_usbjoutaijouhous'},
                                         {:text => 'USB数据与系统分类的对应信息', :leaf => true, :controller => 'usbkinds'},
                                         {:text => 'USB信息收集的自售机销售信息', :leaf => true, :controller => 'gprsuricolinfos'},
                                         {:text => 'USB设定用文件管理', :leaf => true, :controller => 'settingusbfiles'},
                                         {:text => 'USB设定文件信息管理', :leaf => true, :controller => 'settingfileinfos'},
                                         {:text => 'USB文件设定自售机信息管理', :leaf => true, :controller => 'settingfiles'},
                                         {:text => '设置文件信息管理', :leaf => true, :controller => 'vmsettingfiles'},
                                         {:text => '数据获取USB初始化', :leaf => true, :controller => 'usbinit'}
                                     ]
                                 }),
                  ext_tree_store({
                                     :title => '角色信息管理',
                                     :children => [
                                         {:text => '角色基础信息', :leaf => true, :controller => 'roles'},
                                         {:text => '用户角色基础信息', :leaf => true, :controller => 'userroles'}
                                     ]
                                 })
    ]

    render :json => {
        :root => tree_panel
    }.merge(
        {
            :success => true
        }
    )
  end

  def ext_current_user
    render :json => current_user.ext_current_user.merge(
        {
            :success => true
        }
    )
  end

  def login #登录验证
    if request.post?
      if current_user.login(params[:ParamUser_cd], params[:ParamPassword])
        render :json => {:success => true}
      else
        # render :json => {:success => false,:flag => 2}
        error_report("admin.m0001")
      end

    end
  end

  def logout
    #session[:user_cd] = nil
    #session.clear
    current_user.logout
    redirect_to "/index"
  end

  def alter_password
    user = current_user.instance
    current_user = ActiveSupport::JSON.decode(params[:current_user])
    if current_user['password'] == user.password
      user.password = current_user['alterPassword']
      user.save()
      render :json => {:success => true}
    else
      render :json => {:success => false, :errors => {password: '初始密码不正确，请重新填写！'}}
      #error_report("admin.m0002")
    end
  end
end
