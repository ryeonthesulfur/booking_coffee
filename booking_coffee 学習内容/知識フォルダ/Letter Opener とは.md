## Letter Opener とは

開発環境で送信されるメールを、実際に外部へ送信せずにブラウザでプレビューするためのgem（Rubyのライブラリ）です。

**【なぜ必要？】**
開発中にユーザー登録の確認メールやパスワード再設定メールなどをテストする際、
- 実際にメールを送信すると、設定が面倒。
- テストのために大量のメールアドレスを用意したくない。
- 誤って実際のユーザーにメールを送ってしまう事故を防ぎたい。
といった課題があります。Letter Openerは、これらの課題を解決し、開発中のメール機能を安全かつ簡単に確認できるようにしてくれます。

LaravelフレームワークにおけるMailHogやMailpitと同様の役割を果たします。

---

## セットアップ手順

### 1. Gemfileに追加
プロジェクトで使用するgemを管理する `Gemfile` の `:development` グループ内に、`letter_opener` を追記します。
`:development` グループに記述することで、本番環境（実際にサービスが動く環境）にはインストールされず、開発環境でのみ有効になります。

```ruby
group :development do
  gem "letter_opener"
end
```

`Gemfile` を編集したら、以下のコマンドを実行してgemをインストールします。
bundle install

---

### 2. config/environments/development.rb に追記
開発環境の設定ファイルである `config/environments/development.rb` に、メールの送信方法 (`delivery_method`) を `:letter_opener` に指定する設定を追記します。
これにより、開発環境で `ActionMailer`（Railsのメール送信機能）がメールを送信しようとすると、実際の送信処理の代わりにLetter Openerが動作するようになります。

config.action_mailer.delivery_method = :letter_opener

---

## Deviseのメール認証機能（:confirmable）との連携

`devise` は、Railsで簡単に認証機能を実装できる人気のgemです。
その多機能の一つである `:confirmable` モジュールは、ユーザー登録時にメールを送信し、そのメール内のリンクをクリックすることで本人確認を完了させる「メールアドレス確認機能」を追加します。

**【なぜ必要？】**
- ユーザーが誤ったメールアドレスで登録してしまうのを防ぐ。
- なりすましやスパムボットによる不正な登録を防ぐ。

### :confirmable の有効化
`app/models/user.rb` ファイルを開き、`devise` メソッドの引数に `:confirmable` を追加します。

```ruby
devise :database_authenticatable, :registerable,
       :recoverable, :rememberable, :validatable, :confirmable
```

---

## confirmable 用のマイグレーション

`:confirmable` モジュールを有効にしたら、機能に必要なカラムを `users` テーブルに追加する必要があります。
マイグレーションは、データベースの構造（テーブルやカラム）を変更・管理するための仕組みです。

まず、以下のコマンドを実行して、マイグレーションファイルを生成します。
`AddConfirmableToUsers` という名前はRailsが自動で判断し、`users` テーブルへの変更用ファイルを作成してくれます。

rails g migration AddConfirmableToUsers

`db/migrate/` ディレクトリに生成されたマイグレーションファイル（例: `20231027000000_add_confirmable_to_users.rb`）を開き、`change` メソッド内に以下を記述します。

```ruby
def change
  add_column :users, :confirmation_token, :string
  add_column :users, :confirmed_at, :datetime
  add_column :users, :confirmation_sent_at, :datetime
  add_index :users, :confirmation_token, unique: true
end
```

ファイルを保存したら、`rails db:migrate` コマンドを実行して、データベースにこの変更を適用します。

---

## 各カラムの意味

- **confirmation_token**
  - **役割**: メールに記載される、本人確認用のランダムな文字列（トークン）。ユーザーがメール内のリンクをクリックした際、このトークンを使って正しいユーザーからのアクセスかを確認します。
  - `add_index` で `unique: true` を設定することで、このトークンが他のユーザーと重複しないことを保証し、検索も高速化します。

- **confirmed_at**
  - **役割**: ユーザーがメール内のリンクをクリックして、本人確認が完了した日時を記録します。このカラムに日時が入っているユーザーのみ、ログインが許可されるようになります。

- **confirmation_sent_at**
  - **役割**: 確認メールを送信した日時を記録します。トークンの有効期限を管理したり、確認メールを再送する際に利用されたりします。

---

## 動作の流れ

1. **ユーザーが新規登録**
   - ユーザーがサイトの登録フォームに情報を入力して送信します。

2. **確認トークンの生成とメール送信処理**
   - バックグラウンドで`devise`が、そのユーザー専用のユニークな `confirmation_token` を生成してデータベースに保存します。
   - 同時に、そのトークンを含んだ確認メールを送信する処理（`ActionMailer`）を呼び出します。

3. **Letter Openerによるメールの表示**
   - 開発環境では、設定によって `ActionMailer` の送信処理が `letter_opener` に置き換えられています。
   - そのため、メールは外部に送信されず、自動的に新しいブラウザのタブが開き、送信されるはずだったメールの内容が表示されます。

4. **ユーザーが確認リンクをクリック**
   - 開発者は、ブラウザに表示されたメール内の「アカウントを有効にする」などのリンクをクリックします。このリンクには `confirmation_token` が含まれています。

5. **アカウントの有効化**
   - リンクがクリックされると、アプリケーションは受け取った `confirmation_token` をもとにデータベースを検索し、該当するユーザーを見つけます。
   - トークンが正しければ、そのユーザーの `confirmed_at` カラムに現在日時を記録します。
   - これでアカウントの本人確認が完了し、ユーザーはログインできるようになります。
