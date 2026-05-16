class AddConfirmableToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :confirmation_token, :string
    add_column :users, :confirmed_at, :datetime
    add_column :users, :confirmation_sent_at, :datetime
    add_index :users, :confirmation_token, unique: true
  end
end


=begin

deviseの:confirmableが使うカラムで：

confirmation_token → メールに送る確認用のランダムな文字列
confirmed_at → 確認が完了した日時
confirmation_sent_at → 確認メールを送った日時
これがないとdeviseがメール認証できない。

=end
