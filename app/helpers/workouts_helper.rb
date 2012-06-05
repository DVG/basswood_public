module WorkoutsHelper
  def join_link(workout)
    if workout.at_capacity?
      render :partial => 'join_enabled', :locals => {:workout => workout} 
    else
      render :partial => 'join_disabled', :locals => {:workout => workout} 
    end
  end
end