class FriendsController < ApplicationController

  def index
    # サイドバーもどきに必要な情報
    if params[:user].present?
      @user = User.find(params[:user])
      @friend = params[:id]
    end

  	@status = params[:status]
  	# こちらから申請を送って、まだ承認前のユーザー
  	if @status == "wait_self"
  		@title = "承認待ち"
  		@users = Friend.where(sender_id: current_user.id, request_status: "waiting_for_allow")

  	# 申請を送ってくれてこちらがまだ承認していないユーザー
  	elsif @status == "waiting_user"
  		@title = "受け取った申請"
  		@users = Friend.where(receiver_id: current_user.id, request_status: "waiting_for_allow")

  	# 友達になっているユーザー
  	else
  		@title = "友達"
  		@users = Friend.where(sender_id: current_user.id, request_status: "friend")
  	end
  end


  def create
  	# 申請を送った時点では送った側のユーザーのみ情報を保存
  	sender = Friend.new(friend_params)
  	sender.save
  	# 申請中一覧ページにとぶ
  	redirect_to user_friends_path(user_id: current_user.id, status: "wait_self")
  end


  def update
  	sender = Friend.find(params[:id])
  	# 承認するときに承認側のユーザーの情報も保存してステータスを友達として保存
  	receiver = Friend.new(sender_id: sender.receiver_id, receiver_id: sender.sender_id, request_status: "friend")
  	receiver.save
  	# 申請した側のユーザーもステータスを友達に変更
  	sender.update(request_status: "friend")
  	# 友達一覧ページにとぶ
  	redirect_to user_friends_path(user_id: current_user.id, status: "friend")
  end


  def destroy
  	# 削除ボタンを押したページと同じページに遷移するために定義
  	status = params[:status]
  	# 削除ボタンを押した側
  	sender = Friend.find(params[:id])
  	# 削除を押された側
  	receiver = Friend.find_by(sender_id: sender.receiver_id, receiver_id: sender.sender_id)

    sender.destroy
  	# 場合によっては相手は情報が保存されていないためここで確認する
  	if receiver.present?
  		receiver.destroy
  	end

  	redirect_to user_friends_path(user_id: current_user.id, status: status)
  end


  private

  def friend_params
  	params.permit(:sender_id, :receiver_id, :request_status)
  end
end
