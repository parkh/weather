class City < ActiveRecord::Base
  
  serialize :min_t
  serialize :max_t
  serialize :precip_chance

  validates_presence_of :name

end
