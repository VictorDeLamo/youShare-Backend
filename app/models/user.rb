class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, omniauth_providers: [:google_oauth2, :github]
  # Relaciones
  has_many :hilos, dependent: :destroy
  has_many :suscripciones, dependent: :destroy
  has_many :magazines, through: :suscripciones
  has_many :magazines, dependent: :destroy
  has_many :boosts, dependent: :destroy
  has_many :boosted_hilos, through: :boosts, source: :hilo
  has_many :comments, dependent: :destroy
  has_many :comment_boosts, dependent: :destroy
  has_one_attached :avatar
  has_one_attached :cover
  def self.from_omniauth(auth)
    where(email: auth.info.email).first_or_create do |user|
      if auth.provider == "github"
        user.username = auth.info.nickname
      elsif auth.provider == "google_oauth2"
        user.username = auth.info.name.gsub(/\s+/, "")
      end
      user.email = auth.info.email
      user.password = Devise.friendly_token[0, 20]
    end
  end
end
