class City < ActiveRecord::Base
  
  belongs_to :user

  serialize :min_t
  serialize :max_t
  serialize :precip_chance

  validates_presence_of :name

end
