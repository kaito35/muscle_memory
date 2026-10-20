# Flutter仮実装・実装理由と読み方

更新日：2026-10-01

## 体験できる流れ

1. 「デモをはじめる」→プロフィール入力。入力欄の値は編集可能なデモ用初期値。
2. 「サンプルプランを作成」→予定負荷・回数・セット数を編集→「このプランを採用する」。
3. 今週のメニューを開始→各セットを記録→疲労度とメモを添えて完了。
4. 「からだ」で体重の追加・修正・削除。測定日時、体脂肪率、メモも入力できる。
5. 写真タブから1枚ずつ画像を選択。撮影方向・日付・メモを保存し、拡大・削除できる。
6. カレンダーで、同じ日の体重・写真・トレーニングを確認。
7. レビュー作成→来週の提案を確認・編集→明示的に採用。
8. 設定画面で全データを削除すると開始画面へ戻る。

## アーキテクチャの意図

MVVMは画面周辺の責務分担、DDDは業務モデルの表現、Clean Architectureは依存の方向を決める。
3つは競合する方式ではなく、別の問題を扱う。

```text
app/                         構成・テーマ・ルート・依存注入
core/
  domain/                    業務エラー、日付関数、仮ID
  presentation/              非同期操作、フォーム、共通Widget
features/
  account/                   プロフィールと全データ削除
  training/                  プラン、セッション、セット実績
  body_record/               体重と写真の記録
  ai_review/                 記録の集計と来週案
  home/presentation/         各機能の状態をまとめる読み取り用ViewModelとView
  calendar/presentation/     日付別の読み取り用ViewModelとView
```

書き込みのある4機能は、次の4層を持つ。

```text
View (Widget)
  → ViewModel (Riverpod AsyncNotifier)
      → UseCase (application)
          → Entity / Value Object / Repository interface (domain)
                                              ↑ 実装する
                                MemoryRepository / Gallery adapter (data)
```

- **View**：表示、フォームの一時入力、ダイアログ、ナビゲーション。保存処理を知らない。
- **ViewModel**：ロード中・成功・エラーの状態と操作窓口。保存失敗時は直前のデータを保持する。
- **UseCase**：操作の順序。例：体重入力を有効な値に変換し、測定日時を確認して保存。
- **Domain**：有効な値と業務上の意味。Flutter、Riverpod、image_picker、data層をimportしない。
- **Data**：仮保存や端末API。domainのインターフェースを実装する。
- **Composition root**：`app/dependencies.dart`が具象クラスを生成し、UseCaseへ渡す。ViewModelは具象Repositoryをimportしない。

Repositoryを画面から直接呼ばない理由は、UIの変更と保存方式の変更を独立させ、画面を起動せず業務ルールをテストするため。
ホームとカレンダーは書き込み専用のEntityやRepositoryを増やさず、既存ViewModelから読み取り用の状態を合成する。

## DDDで表現したこと

- `Weight`：等価性を持つValue Object。無効な値（0以下、NaN、無限大など）を生成時に拒否。
- `WeightEntry`：IDのあるEntity。同日の複数記録を許容し、修正時は同じIDで置換。
- `TrainingSession`：集約ルート。予定のスナップショットと実績を別に持つ。同じ種目・セット番号の再記録は置換し、二重計上しない。
- `TrainingPlan`：週・トレーニング日・予定種目。提案の編集は新しい不変オブジェクトを返す。
- プラン採用後も過去版を残し、その週の最後の採用版を有効にする。過去セッションが参照する予定は変化しない。
- 集約内のリストは外部から変更できない。変更は意味のある操作（`record`、`complete`、`adopt`）を通す。

DDDを使うことは、すべての数値にクラスを作ることではない。今回は保護すべき値と業務ルールに限定した。
`TrainingData`全体の読み書きはメモリ用の簡略化であり、将来APIの1つの巨大なDTOとして送る契約ではない。

## まず読むコード

体重保存を例に、以下の順序で読む。

1. `lib/features/body_record/presentation/record_dialogs.dart`：ユーザー入力。
2. `lib/features/body_record/presentation/body_record_view_model.dart`：画面の操作窓口。
3. `lib/core/presentation/command_view_model.dart`：二重送信の防止、成功・失敗時の状態。
4. `lib/features/body_record/application/body_record_use_cases.dart`：日時チェックと保存の手順。
5. `lib/features/body_record/domain/body_records.dart`：体重・体脂肪率のルール。
6. `lib/features/body_record/domain/body_record_repository.dart`：保存方法の契約。
7. `lib/features/body_record/data/memory_body_record_repository.dart`：今回の保存実装。
8. `lib/app/dependencies.dart`：契約と実装を接続する場所。

## 仮実装の範囲と制限

| 項目 | 現在の動作 | 将来の作業 |
|---|---|---|
| 認証 | ゲストのプロフィール入力で開始 | Firebase Authとサーバー側トークン検証 |
| 保存 | 実行中のメモリのみ。再起動・再読込で消える | API Repository、永続化と失敗時の整合性 |
| 初期プラン | 週回数・場所・時間を固定テンプレートへ反映。負荷0は自重/未設定 | 年齢、経験、目標、器具、制限等を扱う実AIと検証 |
| レビュー | 今週の完了回数、セット、体重の初回→最新差。疲労8以上なら次週のセット数を1減らすサンプル | 継続率・負荷・回数・きつさ・体重傾向の本格分析と利用枠 |
| プラン編集 | 提案の負荷・回数・セット数 | 種目の追加・代替、曜日編集、採用済みプランの編集動線 |
| 写真 | 画像選択、1枚ずつ5MBまで、方向・日付・メモ、拡大・削除 | GCS、署名付きURL、圧縮・永続化・Android選択中のプロセス終了対応 |
| プロフィール | 年齢・身長・体重・目標・頻度・時間・場所・経験・制限 | 個別編集、性別、器具、目標体重/期日等の追加 |
| 日付 | 端末ローカル時間・月曜開始 | APIとのUTC変換とユーザーのタイムゾーン設定 |
| その他 | ホーム・カレンダー・全データ削除 | 休憩タイマー、通知、Crashlytics等 |

写真のバイト列をDomainオブジェクトに保持するのは、この非永続デモだけの簡略化。
本番はメタデータと画像本体を分離し、Repository/画像アクセス契約から期限付きの参照を取得する。
認証のルートガードはデモの画面制御であり、本番のアクセス制御の代わりにならない。
仮実装をそのまま実データ向けに公開しない。

## API化するとき

1. DTO・認証・エラー・ページング・更新の冪等性をAPI設計で確定。
2. data層にHTTP RepositoryとDTO→Domain変換を追加。
3. `app/dependencies.dart`でメモリ実装からAPI実装へ差し替える。
4. 保存成功後の読込失敗、部分失敗、通信再送、写真アップロードの整合性を扱う。
5. Go側でも所有権・入力値・採用ルールを検証。Flutterの検証だけを信用しない。

現在の同期的なメモリ実装を前提とした全データ削除は、本番ではサーバー側ワークフローとして設計し直す。

## 開発・検証

2026-10-01の最終確認結果：

- `dart format lib test`：適用済み。
- `flutter analyze --no-pub`：指摘なし。
- `flutter test --no-pub --reporter expanded`：14件成功。
- `flutter build web --no-pub`：成功。出力先は`build/web`。
- 幅320pxで主要画面を検証。テスト用の画面画像でホーム・体重・トレーニングのレイアウトも確認。
- iOS/Androidビルド、実機での写真選択・権限・ライフサイクルの検証は未実施。

```sh
flutter pub get
flutter run -d chrome
flutter analyze
flutter test
```

Flutter 3.24.2 / Dart 3.5.2で依存関係を解決。採用したパッケージの資料：
[Riverpod 2.6.1](https://pub.dev/packages/flutter_riverpod/versions/2.6.1)、
[go_router 14.6.2](https://pub.dev/packages/go_router/versions/14.6.2)、
[image_picker 1.1.2](https://pub.dev/packages/image_picker/versions/1.1.2)。

テスト対象は、不正入力、同日複数記録、提案の明示採用、セット重複、予定スナップショット、
完了済み実績の保護、疲労を反映した次週案、全データ削除、保存失敗時の再試行、画面操作と小さい画面の表示。
画像ピッカーの実機操作は自動テストで代替できないため、端末で別途確認する。
iOSには写真ライブラリの用途説明を追加。iOS/Androidビルドと実機確認には、前回確認したCocoaPods未導入・Androidライセンス未承認の解消が必要。
