authorization do
  role :admin do
    has_permission_on :workouts, to: :manage
    has_permission_on :workouts, to: :participate do
      if_attribute :trainer_id => is_not { user.id } #cannot join their own workout
    end
    has_permission_on :users, to: [:update, :show, :index]
  end
  role :trainer do
    has_permission_on :workouts, to: [:create, :read]
    has_permission_on :workouts, to: [:update, :delete] do
      if_attribute :trainer_id => is { user.id } #can manage their own workouts
   end
    has_permission_on :workouts, to: :participate do
      if_attribute :trainer_id => is_not { user.id } #can join another trainers workout
    end
    has_permission_on :users, :to => [:update] do
      if_attribute :id => is { user.id } #can manage their own profiles
    end
    has_permission_on :users, :to => [:show, :index]
  end
  role :registered do
    has_permission_on :workouts, :to => [:read, :participate]
    has_permission_on :users, :to => [:index, :show]
    has_permission_on :users, :to => [:update] do
      if_attribute :id => is { user.id } #can manage their own profiles
    end
  end
  role :guest do
    has_permission_on :workouts, :to => :read
  end
end
privileges do
  privilege :manage, :includes => [:create, :read, :update, :delete]
  privilege :participate, :includes => [:join, :cancel]
  privilege :read, :includes => [:index, :show]
  privilege :create, :includes => [:new, :quick_add]
  privilege :update, :includes => :edit
  privilege :delete, :includes => :destroy
end