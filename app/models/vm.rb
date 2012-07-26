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

  def vmmakerlist(flag=true)
    if flag
      maker && maker.maker_name
    else
      {:include => [:maker], :order => "makers.maker_name"}
    end
  end

  def franchiserlist(flag=true)
    if flag
      franchiser && franchiser.franchiser_name
    else
      {:include => [:franchiser], :order => "franchisers.franchiser_name"}
    end
  end

  def bumonlist(flag=true)
    if flag
      bumon && bumon.bumon_mei
    else
      {:include => [:bumon], :order => "bumons.bumon_mei"}
    end
  end

  def vmkindlist(flag=true)
    if flag
      vmkind && vmkind.kind_name
    else
      {:joins => "left outer join (select id,kind_name from kinds) vm_kinds  on vmkind_id = vm_kinds.id  ", :order => "vm_kinds.kind_name"}
    end
  end

  def vmkindmeisailist(flag=true)
    if flag
      kind && kind.kind_name
    else
      {:include => [:kind], :order => "kinds.kind_name"}
    end
  end

  def syutokukindlist(flag=true)
    if flag
      syutokukind && syutokukind.kind_name
    else
      {:joins => "left outer join (select id,kind_name from kinds) syutoku_kinds  on syutokukind_id = syutoku_kinds.id  ", :order => "syutoku_kinds.kind_name"}
    end
  end

  def commkindlist(flag=true)
    if flag
      commkind && commkind.kind_name
    else
      {:joins => "left outer join (select id,kind_name from kinds) comm_kinds  on commkind_id = comm_kinds.id  ", :order => "comm_kinds.kind_name"}
    end
  end

  def removekindlist(flag=true)
    if flag
      removekind && removekind.kind_name
    else
      {:joins => "left outer join (select id,kind_name from kinds) remove_kinds  on removekind_id = remove_kinds.id  ", :order => "remove_kinds.kind_name"}
    end
  end

  def basyo(current_time)
    current_time = current_time[0..7]
    Basyo.where(["rireki_kaisi_dtm <= :current_time AND rireki_syuryo_dtm >= :current_time AND vm_id = :vm_id", {:current_time => current_time, :vm_id => self.id}]).first
  end

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
