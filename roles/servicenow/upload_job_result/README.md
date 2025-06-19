# ServiceNow Upload Job Result

このAnsibleロールは、ServiceNOW上のカスタムテーブルに他のroleを組み合わせて実行した結果とログをアップロードするためのものです。

## 概要

このロールは以下の処理を行います：

1. ジョブ結果の情報を収集
2. ServiceNOWのカスタムテーブルにレコードを作成
3. ログファイルをアップロード
4. アップロードしたログファイルのsys_idをレコードに関連付け

## 想定する使い方

- カスタムテーブルとcreate_record_body.j2が一対一になっている
- create_record_body.j2のパラメータは他のroleで設定される

## 要件

- ServiceNOWインスタンスへのアクセス権限
- ServiceNOWのユーザー名とパスワード
- ansible.builtin.uriモジュールの使用

## ロール変数

### 必須変数

- `servicenow_user`: ServiceNOWのユーザー名
- `servicenow_password`: ServiceNOWのパスワード

### デフォルト変数

以下の変数はデフォルト値が設定されていますが、必要に応じて上書きできます：

- `servicenow_instance`: ServiceNOWのインスタンスURL
- `target_table_name`: ターゲットテーブル名
- `create_record_body_j2_file`: レコード作成用のテンプレートファイル（デフォルト: "create_record_body.j2"）
- `patch_record_body_j2_file`: レコード更新用のテンプレートファイル（デフォルト: "patch_record_body.j2"）
- `upload_log_filepath`: アップロードするログファイルのパス（デフォルト: "{{ role_path }}/tests/test_files/sample_log_file.log"）

### ジョブ結果に関する変数

以下の変数は、ServiceNOWのカスタムテーブルに格納される情報です：

- `exastro_hostname`: Exastroのホスト名
- `operation_id`: 操作ID
- `operation_name`: 操作名
- `conductor_id`: コンダクターID
- `conductor_name`: コンダクター名
- `target_host_s`: ターゲットホスト（デフォルト: "{{ inventory_hostname }}"）
- `execution_date_time`: 実行日時（デフォルト: 現在時刻）
- `status`: ステータス（デフォルト: "Success"）
- `conductor_result_link`: コンダクター結果へのリンク
- `execution_time_seconds`: 実行時間（秒）
- `error_message`: エラーメッセージ
- `root_cause`: 根本原因
- `resolution`: 解決策
- `requester`: 要求者
- `comments`: コメント

## 依存関係

このロールには依存関係はありません。

## 使用例

```yaml
# use with --vault-password-file .vault_pass.txt or --ask-vault-pass
---
- hosts: localhost
  gather_facts: yes
  roles:
    - role: servicenow/upload_job_result
```

## 技術的な詳細

このロールは以下の処理を順番に実行します：

1. ジョブ結果の情報を収集（01_gather_job_result.yml）
   - ServiceNOWの認証情報を読み込み
   - 必要な変数を設定

2. ServiceNOWのカスタムテーブルにレコードを作成（02_create_record_to_servicenow.yml）
   - create_record_body.j2テンプレートを使用してリクエストボディを生成
   - ServiceNOW APIを使用してレコードを作成
   - 作成されたレコードのsys_idを保存

3. ログファイルをアップロード（03_upload_log_file_to_created_record.yml）
   - ServiceNOW APIを使用してログファイルをアップロード
   - アップロードされたファイルのsys_idを保存

4. アップロードしたログファイルのsys_idをレコードに関連付け（04_patch_record_with_log_file_sys_id.yml）
   - patch_record_body.j2テンプレートを使用してリクエストボディを生成
   - ServiceNOW APIを使用してレコードを更新

## ライセンス

MIT

## 作者情報

このロールはServiceNOWとの連携を簡素化するために作成されました。
