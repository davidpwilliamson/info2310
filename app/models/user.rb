class User < ActiveRecord::Base
  attr_accessor :password
  attr_accessible :email, :name, :password, :avatar
  has_attached_file :avatar, :styles => { :medium => "300x300>", :thumb => "100x100>" },
							:default_url => "/images/:style/missing.png"
  
  validates :password, presence: true, if: "hashed_password.blank?"
  
  validates :name, presence: true,
                      length: { minimum: 4, maximum: 50 }

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true,
                        format: { with: VALID_EMAIL_REGEX },
                      uniqueness: { case_sensitive: false }
  
  has_many :microposts

  before_save :encrypt_password
                
  def encrypt_password
    self.salt ||= Digest::SHA256.hexdigest("--#{Time.now.to_s}- -#{email}--")
    self.hashed_password = encrypt(password)
  end

  def encrypt(raw_password)
    Digest::SHA256.hexdigest("--#{salt}--#{raw_password}--")
  end
  
  def self.authenticate(email, plain_text_password)
	user = User.find_by_email(email)
	if (user && user.hashed_password && user.hashed_password == user.encrypt(plain_text_password) ) then user else nil end
  end
end