class User < ActiveRecord::Base

  has_many :cities

  has_secure_password
  before_save :encrypt_password

  validates_uniqueness_of :name
  validates_presence_of :name

  def self.authenticate(name, password)
  	user = find_by_name(name)
  	if user && user.password_hash == BCrypt::Engine.hash_secret(password, user.password_salt)
  	  user
  	else
  	  nil
  	end
  end

  def encrypt_password
  	if password.present?
  	  self.password_salt = BCrypt::Engine.generate_salt
  	  self.password_hash = BCrypt::Engine.hash_secret(password, password_salt)
  	end
  end

end