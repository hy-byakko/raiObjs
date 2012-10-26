class Client < User
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
                  :property => 'bumons.bumon_mei',
                  :joins => 'bumon'
              }
          }
      }
  )
end