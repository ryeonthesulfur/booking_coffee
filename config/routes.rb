Rails.application.routes.draw do
  root "stores#index"

  devise_for :users, controllers: {
    passwords: "users/passwords"
  }

  resources :stores, only: [ :index, :show ] do
    resources :seats, only: [] do   # どの座席の予約内容かをURLで渡すためだけに記述。
      resources :reservations, only: [ :new, :create ] do
          collection do
            post "confirm"
          end
          member do
            get "complete"
          end
      end
    end
  end

  resources :reservations, only: [ :index, :show, :destroy ] do
    member do
      patch :check_in
    end
  end
end




=begin

私が構築したポートフォリオでは、ユーザー認証にDeviseを使用していますが、
最新のRails 8.1環境で開発を進める中で、Deviseに関する2つの問題に直面しました。
内容が難しかったので、Claudeさんに相談しながら、原因分析と解決策をまとめました。


（バグ①：パスワード再設定について） 「1つ目は、パスワード再設定機能が正常に動作しない問題です。

【問題】 パスワード再設定のフォームを送信しても、画面遷移が起きず、無反応になるという症状でした。

【原因分析】
バージョン不一致でページ遷移の判断ができなくなっていました。
調査の結果、Devise内部でレスポンス形式を自動判別する respond_with メソッドが、
依存している responders gem と Rails 8.1 の組み合わせでエラーを発生させていました。
これは、パスワード更新成功後にリダイレクトを行うべきか、API用のJSONを返すべきかの判断に失敗していたためです。

【解決策】
Devise の PasswordsController を継承したカスタムコントローラーを作って、問題が起きていた箇所をAIに特定してもらい、そこだけを書き直しました。
respond_with による自動判別をやめて、成功時は redirect_to でログイン画面へ直接移動するように変更し、解決しました。




（バグ②：ログイン失敗時にエラーが出ない問題）

【問題】
メールアドレスやパスワードを間違えても、何のエラーも表示されませんでした。

【原因】
Railsには、エラーを画面に表示する仕組みが2種類あります。（仕様の問題）

- 新規登録や編集の失敗 → <%= render "devise/shared/error_messages", resource: resource %>　という場所に「_error_messages.html.erb」が入る
- ログインの失敗 → flash[:alert] という別の場所にエラーが入る

ログイン画面は resource.errors しか表示しないようになっていました。
そのため、flash[:alert] の方に入っていたログイン失敗のメッセージは、表示される場所が無く、見えなくなっていました。

【解決策】
最初は、Devise::SessionsController をカスタムし、エラーを resource.errors の方に入れ直すことで解決しました。

しかしその後、予約キャンセルなどの通知のために、共通レイアウト（application.html.erb）に flash[:alert] を表示する仕組みを追加しました。
これにより、Devise標準のままでもflashが表示できるとわかったので、カスタムコントローラーは不要と判断し削除しました。
また、ログイン時のエラーメッセージ自体は config/locales/devise.en.yml の方で日本語に変更しています。

この見直しの中で、もう1つ別のバグも見つけました。
ログイン画面のフォームに `user_session_path(resource_name)` という記述があり、
本来不要な引数によって送信先URLが `/users/sign_in.user` という壊れた形になっていました。
これが原因でDevise内部のエラー処理が正しく動いていなかったため、引数を外して修正しました。


（まとめ）
便利なライブラリでも、フレームワークのバージョンアップで動かなくなることがあると学びました。
原因を1つずつ調べて特定し、必要最小限のカスタマイズで直す、という対応を心がけました。
また、一度直した問題でも、後から状況が変わった際に「もっとシンプルなやり方に戻せないか」を見直す視点も大事だと感じました。

=end


=begin

元々、seats コントローラーのshow アクションに予約内容の新規作成を任せていたが、
後から考えて「reservations#new」の方が適切だと気づき、移行した。

移行後、seats コントローラーは不要となり、ルーティングの方も、「resources :seats, only: [ :show ] do」と記述していたが、
実質URL生成のためだけあるようなものになってしまった。

そこで、このルーティングも消した方がいいのかをClaude と相談したところ、
URL構造が変化し、全体的に、データをビューへ渡すコントローラーの各アクション内の記述にまで影響するため、
「:show」は消して、「resources :seats, only: [] do」にして残しておいた方がいいという判断になりました。

そうしないと、reservationsで管理してるビューへのURLを一つ一つ個別に「:seat_id」を含めた専用URLを手動で書かなくてはならなくなるからです。


=end
