class User < ActiveRecord::Base
  belongs_to :role
  has_and_belongs_to_many :workouts
  has_many :classes, :class_name => 'Workout'
  validates_presence_of :email, :full_name
  validates_uniqueness_of :email
  validate :avatar_is_a_image, :avatar_is_less_than_five_megabytes
    
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :full_name, :bio, :favorite_workout, :avatar, :hide_me
  attr_accessible :email, :password, :password_confirmation, :remember_me, :full_name, :bio, :favorite_workout, :avatar, :hide_me, :role_id, :as => :admin
  
  #avatar
  has_attached_file :avatar, :styles => { :medium => "300x300>", :thumb => "100x100>", :tiny => "25x25>" }
  
  def role_symbols
    [self.role.name.to_sym]
  end
  
  def admin?
    if self.role_symbols == [:admin]
      true
    else
      false
    end
  end
  
  def trainer?
    if self.role_symbols == [:trainer]
      true
    else
      false
    end
  end
  
  def self.trainers
    trainer_role = Role.find_by_name('trainer')
    admin_role = Role.find_by_name('admin')
    where(:role_id => [trainer_role.id, admin_role.id])
  end
  
  private
  def avatar_is_a_image
    if self.avatar?
      if !self.avatar.content_type.match(/image/)
        errors.add(:avatar, "Avatar must be an image")
      end
    end
  end
  
  def avatar_is_less_than_five_megabytes
    if self.avatar?
      if self.avatar.size > 5.megabytes
        errors.add(:avatar, "Avatar must be less than 5 megabytes in size")
      end
    end
  end
end
