class Friend < ApplicationRecord

	#===== Userモデルをsenderとreceiverいう名前の擬似モデルとして分けて使えるように設定 =====
	belongs_to :sender,   class_name: "User"
	belongs_to :receiver, class_name: "User"
	#================================================================================


	#===== 申請する前を0、申請した後を1、承認されて友達になった後を2と設定して状態を分ける =====
	enum request_status: {unfriend: 0, waiting_for_allow: 1, friend: 2}
	#================================================================================


	validates :sender_id, 	presence: true
	validates :receiver_id, presence: true

end