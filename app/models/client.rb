class Client < User
  belongs_to :department, :foreign_key => 'bumon_id'

  self.mapping_override(
      {
          :user_cd => {
              :type => :persist,
              :query => {
                  :seek_by => :similar
              }
          },
          :user_name => {
              :type => :persist,
              :query => {
                  :seek_by => :similar
              }
          },
          :password => {
              :type => :persist,
              :lazy => true
          },
          :department_name => {
              :type => :grid,
              :get => 'bumon.bumon_mei',
              :sort => {
                  :field => 'bumons.bumon_mei',
                  :joins => :bumon
              }
          },
          :department => {
              :association => :department,
              :ref => 'vmoss.model.major.department',
              :lazy => :true
          },
          :roles => {
              :association => :roles,
              :ref => 'vmoss.model.major.roles',
              :lazy => true
          }
      }
  )
end