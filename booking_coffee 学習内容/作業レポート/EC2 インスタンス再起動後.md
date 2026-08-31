【EC2 インスタンス再起動後】


手順はこうなります。

① AWSコンソールでEC2を起動
まず起動して、新しいパブリックIPアドレスを確認してください。

② production.rbのIPアドレスを更新
新しいIPに書き換える必要があります。

③ SSH接続



ssh -i ~/.ssh/booking-coffee-key.pem ubuntu@（新しいパブリック IPv4 アドレス）

パブリック IPv4 アドレス：54.199.120.29



git add config/environments/production.rb
git commit -m "Update production IP address to 54.199.120.29"
git push origin main

--------
git add config/environments/production.rb
変更したproduction.rbだけを「コミットする対象」としてステージングに追加する。

git commit -m "Update production IP address to 54.199.120.29"
ステージングに追加したファイルをgitの履歴として保存する。-m "..." はコミットメッセージ（何を変えたかの説明）。

git push origin main
ローカルのコミットをGitHub（origin）のmainブランチに送る。これでEC2側でgit pullできるようになる。

--------