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

  protected
  def validate_rireki_kaisi_dtm
    unless self.rireki_kaisi_dtm.blank? ||self.customer_id.blank? || self.basyo_cd.blank?
      unless self.class.check_start_date(self.rireki_kaisi_dtm,self.customer_id,self.basyo_cd)
        self.errors.add(:rireki_kaisi_dtm, "和现有点位履历的开始日期或终了日期相同" )
      end
    end
  end
end
