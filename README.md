# booking_coffee

喫茶店の席予約システム

---

## テーブル設計

### users（ユーザー）

| カラム名        　  | 型       | 制約               | 説明                 |
|-------------------|----------|--------------------|----------------------|
| id                | bigint   | PK                 |                      |
| name              | string   | NOT NULL           | 氏名                 |
| email             | string   | NOT NULL, UNIQUE   | メールアドレス      　 |
| encrypted_password | string   | NOT NULL           | パスワード（暗号化） 　　|
| created_at        | datetime | NOT NULL           |                      |
| updated_at        | datetime | NOT NULL           |                      |

---

### seats（席）

| カラム名    　 　 | 型        | 制約               | 説明          　 |
|-----------------|-----------|--------------------|----------------|
| id          　  | bigint    | PK                 |                |
| seat_number     | integer   | NOT NULL, UNIQUE   | 席番号           |
| capacity        | integer   | NOT NULL           | 最大収容人数      |
| price_per_hour  | integer   | NOT NULL           | 1時間あたりの料金 |
| created_at      | datetime  | NOT NULL           |                  |
| updated_at      | datetime  | NOT NULL           |                  |

---

### reservations（予約）

| カラム名     　| 型       | 制約          | 説明                     　  |
|--------------|----------|---------------|----------------------------|
| id           | bigint   | PK            |                            |
| user_id      | bigint   | FK, NOT NULL  | どの客か                   |
| seat_id      | bigint   | FK, NOT NULL  | どの席か                   |
| start_time   | datetime | NOT NULL      | 予約開始日時               |
| num_people   | integer  | NOT NULL      | 人数                       |
| status       | string   | NOT NULL      | 予約中・キャンセル・完了    |
| created_at   | datetime | NOT NULL      |                            |
| updated_at   | datetime | NOT NULL      |                            |

---

## リレーション

- User has many Reservations
- Seat has many Reservations
- Reservation belongs to User
- Reservation belongs to Seat

