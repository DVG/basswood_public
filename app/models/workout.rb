class Workout < ActiveRecord::Base
  validates_presence_of :name
  validates_presence_of :show_date
  validates_presence_of :time
  validates_presence_of :maximum_size
  validates_presence_of :trainer
  validates_numericality_of :maximum_size, :greater_than_or_equal_to => 0
  has_and_belongs_to_many :users
  belongs_to :trainer, :class_name => 'User', :foreign_key => "trainer_id"
  
  attr_accessor :show_date
  
  def show_date
    date ? date.strftime('%m/%d/%Y') : ''
  end
  
  
  def self.for_week_starting(day=Date.today.beginning_of_week(:sunday))
    sunday = day.beginning_of_week(:sunday)
    saturday = day.end_of_week(:sunday)
    where(:date => sunday..saturday)
  end
  
  def at_capacity?
    if self.maximum_size == 0
      false
    else
      self.users.size < self.maximum_size ? false : true
    end
  end
  
  def slots_remaining
    if maximum_size == 0
      nil
    else
      self.maximum_size - self.users.size
    end
  end
  
  def join_workout(user)
    unless at_capacity? || self.trainer == user
      self.users << user
    end
  end
  
  def assign_trainer(user)
    self.trainer = user
  end
end
