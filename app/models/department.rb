class Department < Bumon
  self.mapping_override(
      {

          :query => {
              :query => {
                  :field => "bumon_mei",
                  :seek_by => :similar
              }
          }
      }
  )
end