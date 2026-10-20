# BODYMAKE — Flutter prototype

筋トレ・体型管理アプリの、Flutter側だけで動く仮実装です。
MVVM + DDD + Clean Architectureで構成しています。

## 起動

```sh
flutter pub get
flutter run -d chrome
```

Flutter 3.24.2 / Dart 3.5.2で開発。Android/iOSは対象端末の開発環境を整えてから`flutter run`を実行してください。

プロフィール → サンプルプランの編集・採用 → セット記録 → 体重・写真 → カレンダー → 週次レビューを操作できます。
認証・AIは仮実装で、入力データは外部へ送信しません。
**メモリ保存のため、再起動・ブラウザの再読み込みで記録は消えます。**

## 構成と学習ガイド

- [仮実装の操作方法・アーキテクチャの理由・コードの読み順](docs/flutter-prototype.md)
- [アーキテクチャ](docs/architecture.md)
- [実装状況と次の作業](docs/roadmap.md)
- [要件](docs/requirements.md)

```sh
flutter analyze
flutter test
```
# muscle_memory
# muscle_memory
