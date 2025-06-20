# Connectivity Test

このAnsibleロールは、ターゲットサーバへの接続確認を行うためのシンプルなロールです。

## 概要

このロールは、Ansibleの`ping`モジュールを使用して、インベントリに定義されたホストへの接続が可能かどうかを確認します。接続テストの結果は`ping_result`変数に格納されます。

## 要件

特別な要件はありません。Ansibleのコア機能のみを使用しています。

## ロール変数

このロールには設定可能な変数はありません。

## 依存関係

このロールには依存関係はありません。

## 使用例

以下は、このロールを使用するプレイブックの例です：

```yaml
- hosts: all
  gather_facts: no
  roles:
    - role: connectivity-test
```

このプレイブックを実行すると、インベントリに定義されたすべてのホストに対して接続テストが実行されます。

## 技術的な詳細

このロールは以下の処理を行います：

1. `ansible.builtin.ping`モジュールを使用してターゲットホストへの接続を確認
2. 接続結果を`ping_result`変数に格納
3. 接続エラーが発生しても処理を継続（`ignore_errors: true`）

## ライセンス

MIT-0

## 作者情報

このロールはAnsibleの基本機能を使用した接続確認用のシンプルなロールです。
