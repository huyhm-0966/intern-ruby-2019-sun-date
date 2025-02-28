class Conversation < ApplicationRecord
  has_many :messages, dependent: :destroy
  belongs_to :sender, foreign_key: :sender_id, class_name: User.name
  belongs_to :recipient, foreign_key: :recipient_id, class_name: User.name

  validates :sender_id, uniqueness: { scope: :recipient_id }

  scope :between, -> (sender_id, recipient_id) do
    where(sender_id: [sender_id, recipient_id],
      recipient_id: [sender_id, recipient_id])
  end

  scope :find_current_user, -> (current_user) do
    where(sender_id: current_user).or(where recipient_id: current_user)
  end

  def self.get(sender_id, recipient_id)
    conversation = between(sender_id, recipient_id).first
    return conversation if conversation.present?

    create(sender_id: sender_id, recipient_id: recipient_id)
  end

  def opposed_user(user)
    user == recipient ? sender : recipient
  end
end
