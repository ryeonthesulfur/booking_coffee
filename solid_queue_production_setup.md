# Solid Queue 本番環境セットアップ

## 概要
EC2 上で Solid Queue を systemd に登録し、サーバー再起動後も自動起動するようにした。
これにより `recurring.yml` に設定した `CancelNoShowReservationsJob`（15分リミット自動キャンセル）が本番環境でも動作する。

## 手順

### 1. サービスファイルを作成
```bash
sudo nano /etc/systemd/system/solid_queue.service
```

### 2. 以下の内容を記述
```
[Unit]
Description=Solid Queue Worker
After=network.target

[Service]
Type=simple
User=ubuntu
WorkingDirectory=/home/ubuntu/booking_coffee
Environment=RAILS_ENV=production
EnvironmentFile=/etc/environment
ExecStart=/usr/local/bin/bundle exec rails solid_queue:start
Restart=always

[Install]
WantedBy=multi-user.target
```

### 3. 登録・起動
```bash
sudo systemctl daemon-reload
sudo systemctl enable solid_queue
sudo systemctl start solid_queue
```

### 4. 確認
```bash
sudo systemctl status solid_queue
```

`active (running)` になっていれば成功。
