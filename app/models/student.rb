class Student < ActiveRecord::Base  
  has_many :preferences
  accepts_nested_attributes_for :preferences
  has_many :timeslots, :through => :preferences

  validates_associated :preferences, :message => "must not be blank and the ranking number must be unique"

end
