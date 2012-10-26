class Client < User
  self.mapping_override(
      {
          :user_cd => {
              :set => 'user_cd',
              :get => 'user_cd',
              :query => {
                  :seek_by => :similar
              }
          },
          :password => {
              :type => :persist,
              :lazy => true
          }
      }
  )
end