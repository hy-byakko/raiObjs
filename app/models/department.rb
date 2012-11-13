class Department < Bumon
  self.mapping = {
          :id => :persist,
          :bumon_mei => :persist,
          :query => {
              :query => {
                  :field => "bumon_mei",
                  :seek_by => :similar
              }
          }
  }
end