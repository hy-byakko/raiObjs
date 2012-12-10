# encoding: utf-8
class Userrole < ActiveRecord::Base
  belongs_to :user
  belongs_to :role
  belongs_to :bumon

  def get_user_name
    user_name = []
    username = User.find(:all,:conditions => ["id = :user_id", {:user_id => self.user_id}])
    if !username.empty?
      username.each { |item|
        user_name << item.user_name
      }
    end
    user_name.join(',')
  end

   def get_role_name
    role_name = []
    rolename = Userrole.find(:all,:conditions => ["user_id = :user_id", {:user_id => self.user_id}])
    if !rolename.empty?
      rolename.each { |item|
        role_name << Role.find(item.role_id).role_name
      }
    end
    role_name.join(',')
  end

end