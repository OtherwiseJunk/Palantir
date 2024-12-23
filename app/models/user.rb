class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
  :recoverable, :rememberable, :validatable, :omniauthable, omniauth_providers: [ :discord ]

  def self.from_omniauth(auth)
    user = where(id: auth.uid).first_or_initialize do |user|
      user.email = auth.info.email
      user.password = Devise.friendly_token[0, 20]
    end

    user.profile_picture = auth.info.image
    user.display_name = auth.info.name

    user.save

    user
  end
end
