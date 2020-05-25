class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  #===== ユーザーのグループ ==================================
  has_many :group_users, dependent: :destroy
  # group_userモデルを通して、groupモデルを参照できるように設定
  has_many :groups, through: :group_users
  #========================================================

  #===== ユーザーのメモ =====================================
  has_many :memos, dependent: :destroy
  #========================================================

  #===== ユーザーの日記 =====================================
  has_many :diaries, dependent: :destroy
  #========================================================

  #===== ユーザーが投稿した日記へのコメント ====================
  has_many :diary_comments, dependent: :destroy
  #========================================================


  #===== ユーザーのダイレクトメッセージとルーム ================
  has_many :entries, dependent: :destroy
  has_many :rooms, through: :entries
  has_many :direct_messages, dependent: :destroy
  #========================================================


  #===== 自分が申請したユーザー(receiver)との関連 =======================
  # 申請したユーザー(sender)から見て、承認する側のユーザー(receiver)を(中間テーブルを介して)集める。なので親は、sender_id(申請を送る側)
  has_many :sender_friends, foreign_key: :sender_id, class_name: "Friend", dependent: :destroy
  # 中間テーブルを介してreceiverモデルのユーザー(申請したユーザー)を集めることをsendersと定義
  has_many :senders, through: :sender_friends, source: :receiver
  # 自分が申請を送った人たち
  #========================================================


  #===== 自分に申請してきたユーザー(sender)との関連 ====================
  # 承認する側のユーザー(receiver)から見て、申請してくるユーザー(sender)を(中間テーブルを介して)集める。なので親は、receiver_id(承認する側)
  has_many :receiver_friends, foreign_key: :receiver_id, class_name: "Friend", dependent: :destroy
  # 中間テーブルを介してsenderモデルのユーザー(承認する側)を集めることをreceiversと定義
  has_many :receivers, through: :receiver_friends, source: :sender
  # 自分が申請受け取った人(自分に申請を送った人)たち
  #================================================================


  mount_uploader :image, ImageUploader

  # deviseがログイン時に呼び出しているメソッドをオーバーライドして、バリデーションを追加して、valid_statusがactiveなuserのみログイン可能にする。
  def active_for_authentication?
    super && valid_status == "active"
  end

  # すでに友達になっているユーザー
  def friend?(other_user)
    senders.find_by(id: other_user.id) && receivers.find_by(id: other_user.id)
  end

  # こちらの反応を待っているユーザー
  def waiting_other_user?(other_user)
    receivers.find_by(id: other_user.id) && (senders.find_by(id: other_user.id)).nil?
  end

  #　こちらが申請を送ったユーザー
  def wait_self?(other_user)
    senders.find_by(id: other_user.id) && (receivers.find_by(id: other_user.id)).nil?
  end

  enum valid_status: {active: 0, is_deleted: 1}


  validates :name,    presence: true
  validates :self_id, presence: true

end
