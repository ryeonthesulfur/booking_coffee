# production.rb の設定：EC2再起動時のIPアドレス更新とSMTP設定

---

## EC2再起動でIPが変わると何が起きるか

AWSのEC2は、**再起動するたびにパブリックIPアドレスが変わる**（Elastic IPを使っていない場合）。

`production.rb` にIPアドレスをハードコードしている箇所は、EC2を再起動するたびに手動で書き換える必要がある。

---

## 変更が必要な箇所

### 1. `config.action_mailer.default_url_options`（61行目あたり）

```ruby
# 変更前（古いIP）
config.action_mailer.default_url_options = { host: "35.77.45.25" }

# 変更後（新しいIP）
config.action_mailer.default_url_options = { host: "52.199.88.113" }
```

**なぜここを変えるのか**

Deviseが送る「メールアドレス確認メール」や「パスワードリセットメール」には、クリック用のリンクURLが含まれている。そのURLのホスト部分に、ここで指定したIPアドレスが使われる。

古いIPのままだと、メール内のリンクが `http://35.77.45.25/users/confirmation?token=...` のような古いアドレスになり、クリックしても開けない。

EC2再起動後は、ここを新しいパブリックIPに更新する。

---

### 2. SMTP設定の追加

> **⚠️ これはEC2再起動のたびにやる作業ではない。最初に一度だけ設定すれば以後は変更不要。**

---

#### SMTPとは何か

**SMTP（Simple Mail Transfer Protocol）** は、メールを送信するときに使われる通信の規格（プロトコル）。

Railsはデフォルトではメールを直接送る機能を持っていない。そのため「どのメールサーバーを使って送るか」を設定する必要がある。このアプリでは **SendGrid** というメール配信サービスを経由して送る。

この設定は **`config/environments/production.rb`** に追加する。本番環境専用の設定ファイルで、「本番環境でメールを送るときはSendGridを使う」という内容をここに書く。

SendGrid経由でメールを送るための設定。

```ruby
config.action_mailer.delivery_method = :smtp
config.action_mailer.smtp_settings = {
  user_name: "apikey",                        # SendGridのSMTP認証はユーザー名が全員 "apikey" 固定
  password: ENV["SENDGRID_API_KEY"],          # EC2に設定した環境変数からAPIキーを読む
  address: "smtp.sendgrid.net",               # SendGridのメールサーバー
  port: 587,                                  # SMTPの標準ポート
  authentication: :plain,
  enable_starttls_auto: true                  # 通信の暗号化
}
```

**各設定の意味**

| キー | 値 | 説明 |
|---|---|---|
| `delivery_method` | `:smtp` | メール送信にSMTPプロトコルを使う |
| `address` | `"smtp.sendgrid.net"` | SendGridのメールサーバーのアドレス |
| `user_name` | `"apikey"` | SendGridのSMTP認証はユーザー名が全員この固定値 |
| `password` | `ENV["SENDGRID_API_KEY"]` | EC2の環境変数に設定したSendGridのAPIキー |
| `port` | `587` | SMTPで使う標準的なポート番号 |
| `enable_starttls_auto` | `true` | 通信を暗号化する |

**メールが届くまでの流れ**

```
Rails（EC2）→ SendGrid（smtp.sendgrid.net）→ ユーザーのメールアドレス
```

RailsがSendGridのサーバーにメールを渡し、SendGridが実際にユーザーへ届ける。

---

## EC2再起動時の手順まとめ

> SMTP設定はここには含まれない。最初の一度だけ設定すれば以後は変更不要。

1. AWSコンソールで新しいパブリックIPを確認する
2. `config/environments/production.rb` の `default_url_options` の `host:` を新しいIPに書き換える
3. EC2上で `git pull` して変更を反映する
4. Pumaを再起動する
