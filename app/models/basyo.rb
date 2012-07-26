# encoding: utf-8
class Basyo < ActiveRecord::Base
  validates :customer_id,:basyo_cd,:rireki_kaisi_dtm,:bumon_id,:basyo_name,:sagyotanto_id,:vm_id,:presence=>true  #验证非空
  validates_uniqueness_of :rireki_kaisi_dtm, :scope => [:basyo_cd], :case_sensitive => false,:message =>"和现有点位履历的开始时刻相同"
  #validates_uniqueness_of :basyo_cd, :scope => [ :basyo_name,:customer_id], :case_sensitive => false
  validates_length_of :basyo_cd, :maximum => 8
  validates_length_of :basyo_name, :maximum => 40
  validates_length_of :turikin, :maximum => 8
  validates_length_of :vmanzenzaikosu, :maximum => 5
  #validate :rireki_kaisi_dtm, :validate_rireki_kaisi_dtm,:on => :create
  
  belongs_to :custom, :foreign_key => "customer_id"
  belongs_to :bumon
  belongs_to :vm
  belongs_to :gyomukind, :foreign_key => "gyomukind_id"
  belongs_to :rirekikind, :foreign_key => "rirekikind_id"
  belongs_to :eigyotanto, :class_name => 'User', :foreign_key => "eigyotanto_id"
  belongs_to :sagyotanto, :class_name => 'User', :foreign_key => "sagyotanto_id"
  belongs_to :datacollectwaykind, :foreign_key => "datacollectway_id"

  has_many :uriagefulls
  has_many :vmcnts, :dependent => :destroy
  has_many :vmcolumns , :dependent => :destroy

  #20120511 added start
  belongs_to :persyohindayuris,:foreign_key => "basyo_cd"
  #has_many :persyohindayuris, :primary_key => "basyo_cd",:foreign_key => "basyo_cd"
  #20120511 added end

  def rireki_kaisi_dtm
    DateTime.parse(read_attribute(:rireki_kaisi_dtm)).to_time.strftime('%Y/%m/%d %H:%M:%S')
  end

  def rireki_syuryo_dtm
    DateTime.parse(read_attribute(:rireki_syuryo_dtm)).to_time.strftime('%Y/%m/%d %H:%M:%S')
  end
  # 
  def culist(flag=true)
    if flag
       custom && custom.customer_name
    else
       {:include=>[:custom],:order=>"customs.customer_name"}
    end
  end
  # bulis
  def bulist(flag=true)
    if flag
      bumon && bumon.bumon_mei
    else
       {:include=>[:bumon],:order=>"bumons.bumon_mei"}
    end
  end
  # vlist
  def vlist(flag=true)
    if flag
      vm && vm.vm_cd
    else
       {:include=>[:vm],:order=>"vms.vm_cd"}
    end
  end
  # gylist
  def gylist(flag=true)
    if flag
      gyomukind && gyomukind.kind_name
    else
       {:joins=>"left outer join (select id,kind_name from kinds) style_kinds  on gyomukind_id =style_kinds.id  ",:order=>"style_kinds.kind_name"}
    end
  end

  # eilist
  def eilist(flag=true)
    if flag
      eigyotantouser && eigyotantouser.user_name
    else
       {:joins=>"left outer join (select id,user_name from users) style_users  on eigyotanto_id = style_users.id  ",:order=>"style_users.user_name"}
    end
  end
  # salist
  def salist(flag=true)
    if flag
      sagyotantouser && sagyotantouser.user_name
    else
       {:joins=>"left outer join (select id,user_name from users) style_users  on sagyotanto_id = style_users.id  ",:order=>"style_users.user_name"}
    end
  end
   # salist
  def dalist(flag=true)
    if flag
      datacollectwaykind && datacollectwaykind.kind_name
    else
       {:joins=>"left outer join (select id,kind_name from kinds) style_kinds  on datacollectway_id = style_kinds.id  ",:order=>"style_kinds.kind_name"}
    end
  end
 
   #根据履历开始日，验证履历开始日重叠的记录有没有
	def  self.check_start_date(rireki_kaisi_dtm,customer_id,basyo_cd)

	  if rireki_kaisi_dtm.blank? ||customer_id.blank? || basyo_cd.blank?
		 return false
	  end
     # rireki_kaisi_dtm = DateTime.parse(rireki_kaisi_dtm).strftime("%Y%m%d")



	  basyo = self.find(:all,:conditions=>["rireki_kaisi_dtm =:rireki_kaisi_dtm and basyo_cd = :basyo_cd and customer_id = :customer_id",
	                     {:rireki_kaisi_dtm=>rireki_kaisi_dtm,:basyo_cd=>basyo_cd,:customer_id=>customer_id}])
	  #日期重复的信息
	  basyo.blank?  
  end

  def vmcolumn(column_no)
    Vmcolumn.where(["column_no = :column_no AND basyo_id = :basyo_id", {:column_no => column_no, :basyo_id => self.id}]).first
  end

  protected
  def validate_rireki_kaisi_dtm
    unless self.rireki_kaisi_dtm.blank? ||self.customer_id.blank? || self.basyo_cd.blank?
      unless self.class.check_start_date(self.rireki_kaisi_dtm,self.customer_id,self.basyo_cd)
        self.errors.add(:rireki_kaisi_dtm, "和现有点位履历的开始日期或终了日期相同" )
      end
    end
  end
end
