# ServiceNow Create Incident Record

このAnsibleロールは、ServiceNOW上のインシデントテーブルにインシデントレコードを作成するためのものです。

## 概要

このロールは以下の処理を行います：

1. インシデント詳細の情報を所定のJSONファイル(変数名:`remote_filepath_incident_description`)から読み込み、変数として設定します。
2. ServiceNOWのインシデントテーブルにレコードを作成します。

## 想定する使い方
このロールは、ServiceNowのインシデント管理機能と連携して使用することを想定しています。  
具体的には、以下のようなシナリオで使用されます：

- システム監視ツールで検出された問題を自動的にServiceNowのインシデントとして登録する
- 定期的なメンテナンス作業をインシデントとして記録する
- ユーザーからの問い合わせを構造化されたフォーマットでServiceNowに登録する

## 前提条件
- インシデント詳細ファイルとincident_ticket.j2が一対一になっている
  - incident_ticket.j2のキー名とインシデントテーブルのフィールド名は一致している必要があります

## 要件

- ServiceNOWインスタンスへのアクセス権限
- ServiceNOWのユーザー名とパスワード
- ansible.builtin.uriモジュールの使用

## ロール変数

### 必須変数

- `servicenow_user`: ServiceNOWのユーザー名
- `servicenow_password`: ServiceNOWのパスワード
- `servicenow_instance_url`: ServiceNOWのインスタンスURL
- `remote_filepath_incident_description`: インシデント詳細の情報が格納されたJSONファイルのパス（例: "/tmp/sample_incident_description.json"）

### デフォルト変数

以下の変数はデフォルト値が設定されていますが、必要に応じて上書きできます:

- `short_description`: インシデントの簡潔な説明（デフォルト: ""）
- `description`: インシデントの詳細な説明（デフォルト: ""）
- `category`: インシデントのカテゴリ（デフォルト: "Inquiry/Help"）
- `impact_as_integer`: 影響度（1: 高, 2: 中, 3: 低）（デフォルト: 3）
- `urgency_as_integer`: 緊急度（1: 高, 2: 中, 3: 低）（デフォルト: 3）
- `state_as_integer`: 状態（1: 新規, 2: 進行中, 3: 保留中, 4: 解決済み, 5: 終了, 6: キャンセル）（デフォルト: 1）


**インシデントの管理(ServiceNOW)**:
- https://www.servicenow.com/docs/ja-JP/bundle/yokohama-it-service-management/page/product/incident-management/concept/incident-configuration.html


### インシデント詳細に関する変数
テンプレートファイル`./templates/incident_ticket.j2`を参照してください。

## 依存関係
このロールには依存関係はありません。

## 使用例

```yaml
# use with --vault-password-file .vault_pass.txt or --ask-vault-pass
---
- hosts: localhost
  gather_facts: yes
  roles:
    - role: servicenow/create_incident_record
```

## ライセンス

MIT

## 作者情報

このロールはServiceNOWとの連携を簡素化するために作成されました。
