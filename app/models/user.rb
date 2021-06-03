class User < ApplicationRecord
  has_many :posts, dependent: :destroy
  has_many :active_relationships,
              class_name: "Relationship",
              dependent: :destroy,
              foreign_key: "follower_id"
  has_many :passive_relationships,
              class_name: "Relationship",
              dependent: :destroy,
              foreign_key: "followed_id"
  # 本来ならfollowdsと指定し、単数系＋idのfollowed_idを探させるが、英語的に正しくないのでsoureを用いて上書きする
  has_many :following, through: :active_relationships, source: :followed
  has_many :followers, through: :passive_relationships, source: :follower

  def follow(other_user)
    active_relationships.create!(followed_id: other_user.id)
  end

  def unfollow(other_user)
    active_relationships.find_by(followed_id: other_user.id).destroy
  end

  def following?(other_user)
    following.include?(other_user)
  end
end
