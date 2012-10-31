require 'time'
class Timeslot < ActiveRecord::Base

  #From the client's perspective, all times are relative to this
  #week. This is hacky, but also essentially the way Rails handles the
  #time fields. In general, one should NOT use the time fields of this model to retrieve
  #any information about days; use the day field instead.
  CUR_YEAR = 2000
  CUR_MONTH = 1
  CUR_DAY = 3

  WEEK_START = Time.gm(CUR_YEAR, CUR_MONTH, CUR_DAY)

  DAYS = [:sunday, :monday, :tuesday, :wednesday, :thursday, :friday, :saturday]
  WEEK_DAYS = DAYS - [:sunday, :saturday]

  attr_protected #none

  #Associations
  has_many :preferences
  has_many :students, :through => :preferences
  belongs_to :mentor_teacher

  #Validations
  validates :day, :presence => true
  validates :start_time, :presence => true
  validates :end_time, :presence => true

  def self.day_list
    DAYS
  end

  def self.weekdays
    WEEK_DAYS
  end

  def self.day_index(value)
    DAYS.index(value)
  end

  def day
    index = read_attribute(:day)
    DAYS[index] unless index.nil?
  end

  def day=(value)
    write_attribute(:day, DAYS.index(value))
  end  


  def self.from_cal_event_json(json_str)
    from_cal_event_hash(JSON.parse(json_str))  
  end

  #Build or update a timeslot based on cal_event_hash. Does NOT save
  #the resulting Timeslot. Attributes passed in attrs override those from event.
  def self.from_cal_event_hash(event, attrs = {}) 
    timeslot = Timeslot.find_by_id(event["db_id"]) || Timeslot.new

    start_time = Time.parse(event["start"])
    end_time = Time.parse(event["end"])

    timeslot.assign_attributes(:class_name => event["title"], 
                               :start_time => start_time,
                               :end_time => end_time,
                               :day => DAYS[start_time.wday],
                               :num_assistants => event["num_assistants"]
                               )
    timeslot.assign_attributes(attrs)
    return timeslot

  end

  #Return a time on the given day in the week of Timeslot::WEEK_START
  def self.time_in_week(time_obj, day) 
    Time.gm(Timeslot::WEEK_START.year,
               Timeslot::WEEK_START.month,
               Timeslot::WEEK_START.day + Timeslot::WEEK_DAYS.index(day),
               time_obj.hour,
               time_obj.min
               )
  end

  #Convert this timeslot into something understood by jquery
  #weekcalendar (after serialization to json)  
  def to_cal_event_hash
    def to_js_time(time, day)
      Timeslot.time_in_week(time, day).utc.iso8601
    end

    { 'id' => self.id,
      'db_id' => self.id,
      'start' => to_js_time(self.start_time, self.day),
      'end' => to_js_time(self.end_time, self.day),
      'title' => self.class_name,
      'num_assistants' => self.num_assistants
    }
  end
  
  def selected?(student_id)
    Preference.where(["student_id = ?", student_id]).where(:timeslot_id => id).size > 0
  end



  
end
