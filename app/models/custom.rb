# encoding: utf-8
class Custom < ActiveRecord::Base
 belongs_to:customkind,:primary_key => "id", :foreign_key => "gyosyu_id"
  #20120511 added start
 has_many :basyos,:foreign_key =>"customer_id"
 has_many :persyohindayuris,:foreign_key =>"customer_id"
#20120511 added end



  def customlist(flag=true)
    if flag
      customkind && customkind.kind_name
    else
      {:joins=>"left outer join (select id,kind_name from kinds) custom_kinds  on gyosyu_id = custom_kinds.id  ",:order=>"custom_kinds.kind_name"}
    end
  end
 
  validates :customer_cd,:customer_name,:gyosyu_id,:presence=>true
  validates_uniqueness_of :customer_cd
  validates_format_of :yubin_no, :with => /^\d{0,6}$/,:message => "由6位以内数字组成"#匹配不是/\d{6}/的格式
  #validates_format_of :tel_no, :with => /^((\d+)-?(\d+)){0,20}$/,:message => "由半角数字和'-'组成"#-?:0或1个-,{0,20}:0-20位
  #validates_format_of :fax_no, :with => /^((\d+)-?(\d+)){0,20}$/,:message => "由半角数字和'-'组成"#^:以^不在表达式内
  validates_format_of :tel_no, :with =>  /^$|(\d+-?)+$/,:message => "由半角数字和'-'组成"#-?:0或1个-,{0,20}:0-20位
  validates_format_of :fax_no, :with =>  /^$|(\d+-?)+$/,:message => "由半角数字和'-'组成"#^:以^不在表达式内
  validates_format_of :tantotel1, :with =>  /^$|(\d+-?)+$/,:message => "由半角数字和'-'组成"#窗口负责人联系电话1
  validates_format_of :tantotel2, :with =>  /^$|(\d+-?)+$/,:message => "由半角数字和'-'组成"#窗口负责人联系电话2

  validates_length_of :customer_cd, :maximum=>4
  validates_length_of :customer_name, :maximum=>40
  validates_length_of :jusyo, :maximum=>100#地址
  validates_length_of :yubin_no, :maximum=>6#邮编
  validates_length_of :tel_no, :maximum=>20#电话
  validates_length_of :fax_no, :maximum=>20#传真
  validates_length_of :tantobumonmei, :maximum=>30#窗口负责人所属部门
  validates_length_of :tantomei, :maximum=>20#窗口负责人
  validates_length_of :tantotel1, :maximum=>20#窗口负责人联系电话1
  validates_length_of :tantotel2, :maximum=>20#窗口负责人联系电话2
  validate :combo_must_gyosyu_id
  def combo_must_gyosyu_id
      errors.add(:gyosyu_id, "不能为空字符" ) if gyosyu_id == 0#数据库默认gyosyu_id = 0
  end

end
