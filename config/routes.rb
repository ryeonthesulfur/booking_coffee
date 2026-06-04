Rails.application.routes.draw do
  root "stores#index"

  devise_for :users, controllers: {
    sessions: "users/sessions",
    passwords: "users/passwords"
  }

  resources :stores, only: [ :index, :show ] do
    resources :seats, only: [ :show ] do
      resources :reservations, only: [ :create ] do
          collection do
            post "confirm"
          end
          member do
            get "complete"
          end
      end
    end
  end

  resources :reservations, only: [ :index ]
end




=begin

私が構築したポートフォリオでは、ユーザー認証にDeviseを使用していますが、
最新のRails 8.1環境で開発を進める中で、Deviseとフレームワーク間の2つの互換性問題に直面しました。
どちらもDeviseのデフォルトの挙動をカスタマイズすることで解決しています。
内容が難しかったので、Claudeさんに相談しながら、原因分析と解決策をまとめました。


（バグ①：パスワード再設定について） 「1つ目は、パスワード再設定機能が正常に動作しない問題です。

【問題】 パスワード再設定のフォームを送信しても、画面遷移が起きず、無反応になるという症状でした。

【原因分析】
調査の結果、Devise内部でレスポンス形式を自動判別する respond_with メソッドが、
Rails 8.1環境で ActionController::UnknownFormat エラーを発生させていることを特定しました。
これは、パスワード更新成功後にHTMLのリダイレクトを行うべきか、API用のJSONを返すべきかの判断に失敗していたためです。

【解決策】
Devise公式で推奨されているカスタマイズ方法に則り、Devise::PasswordsController を継承した独自のコントローラーを作成しました。
そして、問題が発生していた update アクションのみをオーバーライドし、respond_with による自動判別に頼るのではなく、
成功時に redirect_to で直接ログインページへリダイレクトするよう明示的に実装し、問題を解決しました。




（バグ②：ログイン失敗時のエラー表示について） 「2つ目は、ログイン失敗時にエラーメッセージが表示されない問題です。

【問題】 メールアドレスやパスワードを間違えても、ユーザーに何のエラーも通知されない状態でした。

【原因分析】
これは、Rails 7から標準となった Turbo と、Railsの伝統的なメッセージ機能である flash の間の非同期処理における相性問題が原因でした。
Deviseはログイン失敗時に flash にエラーメッセージを格納してリダイレクトしますが、Turboによる高速な画面書き換えの過程で、
その flash メッセージがレンダリングされる前に失われていました。

【解決策】
こちらも同様に Devise::SessionsController を継承したカスタムコントローラーを作成しました。
ログイン失敗時の処理を変更し、flash を使うのをやめて、resource.errors オブジェクトに直接エラーメッセージを追加する方法に切り替えました。
これにより、Turboの挙動に依存せず、フォームの再描画時に確実にエラーメッセージを表示できるようになりました。」


（まとめ）
「これらの経験から、便利なライブラリであっても、依存するフレームワークのバージョンアップによって意図しない動作をすることがあると学びました。
その際には、ライブラリの内部実装を読み解いて原因を特定し、公式ドキュメントに沿った最小限のカスタマイズで問題を解決する能力が重要だと考えています。」

=end
