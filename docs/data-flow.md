flowchart LR
  %% ===== 外部実体 =====
  user([ユーザー]):::ext

  %% ===== プロセス（機能単位） =====
  P1([Plan 学習予定を作成/編集]):::proc
  P2([Check 学習を記録]):::proc
  P3([Review 振り返り閲覧/メモ]):::proc
  P4([Aggregate 月次集計]):::proc

  %% ===== データストア =====
  D1[(Materials)]:::store
  D2[(Daily Records)]:::store
  D3[(Monthly Records)]:::store

  %% ===== Plan：教材登録・予定作成 =====
  user -->|教材を登録/編集| P1
  P1 -->|教材を保存| D1
  P1 -->|登録済み教材一覧を表示| user

  user -->|日別の教材と予定時刻を設定| P1
  P1 -->|予定を保存| D2
  P1 -->|登録済み教材/予定を表示| user

  %% ===== Check：当日の学習を記録 =====
  user -->|今日の学習を入力| P2
  P2 -->|実績を保存| D2
  P2 -->|今日の予定/実績を表示| user

  %% ===== Review：振り返りの表示・入力 =====
  user -->|振り返り画面を開く(表示要求)| P3
  P3 -->|日別/月別データを参照| D2
  P3 -->|月次集計データを参照| D3
  user -->|振り返りを入力| P3
  P3 -->|メモを保存| D2
  P3 -->|結果を表示| user

  %% ===== Aggregate：実績→月次集計 =====
  D2 -->|対象データ| P4
  P3 -->|集計要求| P4        
  P4 -->|集計を保存| D3

  %% ===== スタイル =====
  classDef ext fill:#f8f8ff,stroke:#666,stroke-width:1px;
  classDef proc fill:#e6f7ff,stroke:#333,stroke-width:1.5px;
  classDef store fill:#fffbe6,stroke:#999,stroke-width:1.5px;

