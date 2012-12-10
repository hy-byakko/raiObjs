# encoding: utf-8
class Vm < ActiveRecord::Base
  belongs_to :maker, :foreign_key => 'vmmaker_id'
  belongs_to :franchiser
  belongs_to :bumon, :foreign_key => 'bumon_id'
  belongs_to :vmkind, :primary_key => "id", :foreign_key => "vmkind_id"
  belongs_to :syutokukind, :foreign_key => "syutokukind_id"
  belongs_to :commkind, :foreign_key => "commkind_id"
  belongs_to :removekind, :foreign_key => "removekind_id"
  belongs_to :kind, :primary_key => "id", :foreign_key => "vmkindmeisai_id", :conditions => 'kindcategory_cd = 03'
  has_many :vmgprsterminalinfos
  has_one :gprsuricolinfos, :through => :vmgprsterminalinfos

  has_many :basyos

  validates_uniqueness_of :vm_cd, :case_sensitive => false
  validates :vm_cd, :bumon_id, :syutokukind_id, :franchiser_id, :columncnt, :presence => true #验证非空
  validates :vm_cd, :length => {:maximum => 8} #验证自售机编号唯一性和长度小于8
  validates :columncnt, :length => {:maximum => 2}, :numericality => true #验证货道数是数字，长度小于5
#  validates :power_kwh,:inclusion => {:in => 0.00..9.99, :message => '必须是0.00到9.99之间的数字'} #耗电量在0-9.99
  validates :power_kwh, :format =>{:with => /^$|^\d{1}\.?\d{1,2}?$/, :message=> '耗电量必须是0.00到9.99之间的数字'}
#  validates :kounyukin, :baikyakukin, :inclusion => {:in => 0.00..99999.99, :message => '必须是0.00到99999.99之间的数字'}
  validates :kounyukin, :baikyakukin,:format =>{:with => /^$|^\d{1,5}\.?\d{1,2}?$/, :message=> '金额必须是0.00到99999.99之间的数字'}
  validates :make_dtm, :syutoku_dtm, :remove_dtm, :length => {:maximum => 8}
  validates :bumon_id, :vmmaker_id, :vmkind_id, :vmkindmeisai_id, :syutokukind_id, :franchiser_id, :commkind_id, :removekind_id, :key_cd, :length => {:maximum => 10}

end
