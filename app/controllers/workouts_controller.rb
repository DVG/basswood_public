class WorkoutsController < ApplicationController
  filter_access_to :show, :edit, :update, :destroy, :join, :cancel, :attribute_check => true
  filter_access_to :index, :new, :create, :quick_add
  #filter_resource_access
  def index
    unless params[:date].nil?
      start_date = params[:date].to_date
    end
    start_date = start_date.nil? ? Date.today : start_date
    @week = (start_date.beginning_of_week(:sunday)..start_date.end_of_week(:sunday))
    @workouts = Workout.for_week_starting(@week.first).group_by(&:date)
    respond_to do |format|
      format.html # index.html.erb
    end
  end
  
  def show
  end

  def new
    @workout = Workout.new(params[:workout])
    @workout.maximum_size = 10
    @workout.assign_trainer(current_user)

    respond_to do |format|
      format.html # new.html.erb
    end
  end

  def edit
  end

  def create
    @workout = Workout.new(params[:workout])
    respond_to do |format|
      if @workout.save
        format.html { redirect_to @workout, notice: 'Workout was successfully created.' }
      else
        format.html { render action: "new" }
      end
    end
  end
  
  def update
    respond_to do |format|
      if @workout.update_attributes(params[:workout])
        format.html { redirect_to @workout, notice: 'Workout was successfully updated.' }
      else
        format.html { render action: "edit" }
      end
    end
  end
  
  def destroy
    #@workout = Workout.find(params[:id])
    @workout.destroy

    respond_to do |format|
      format.html { redirect_to workouts_url, alert: 'The workout has been cancelled' }
      format.js
    end
  end
  
  def quick_add
    timeslot = params[:timeslot].to_sym
    date = params[:date].to_date
    time = Time.now
    @workout = Workout.new do |w|
      w.assign_trainer(current_user)
      w.name = "#{timeslot.to_s.capitalize} Workout!"
      w.date = date
      w.maximum_size = 10
      w.assign_trainer(current_user)
      case timeslot
      when :morning
        time = Time.new(date.year, date.month, date.day, 6, nil, nil, 0)
      when :noon
        time = Time.new(date.year, date.month, date.day, 12, nil, nil, 0)
      when :evening
        time = Time.new(date.year, date.month, date.day, 18, 15, nil, 0)
      else
        #do nothing
      end
      w.time = time
    end
    respond_to do |format|
      if @workout.save
        format.html { redirect_to workouts_date_path(@workout.date) }
      else
        format.html { redirect_to workouts_url, alert: 'Workout was not created.' }
      end
    end
  end
  
  def join
    @workout.join_workout(current_user)
    redirect_to workout_path(@workout)
  end
  
  def cancel
    @workout.users.delete(current_user)
    redirect_to workout_path(@workout)
  end
end
