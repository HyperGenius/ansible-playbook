# ServiceNow Upload Job Result

このAnsibleロールは、ServiceNOW上のカスタムテーブルに他のroleを組み合わせて実行した結果とログをアップロードするためのものです。

## 概要

このロールは以下の処理を行います：

1. ジョブ結果の情報を所定のJSONファイル(変数名:`remote_filepath_job_result`)から読み込み、変数として設定します。
2. ServiceNOWのカスタムテーブルにレコードを作成します。
3. ログファイルの指定がある場合、該当のファイルをアップロードします。
4. アップロードしたログファイルのsys_idをレコードに関連付けます。

## 想定する使い方
このロールは、他のAnsibleロールと組み合わせて使用することを想定しています。  
具体的には、以下のようなシナリオで使用されます：

- 他のroleで実行したジョブの結果をServiceNOWにアップロードする
- ログファイルをServiceNOWのカスタムテーブルに関連付けて保存する

## 前提条件
- カスタムテーブルとcreate_record_body.j2が一対一になっている
  - create_record_body.j2のキー名とカスタムテーブルのsys_idは一致している必要があります

## 要件

- ServiceNOWインスタンスへのアクセス権限
- ServiceNOWのユーザー名とパスワード
- ansible.builtin.uriモジュールの使用

## ロール変数

### 必須変数

- `servicenow_user`: ServiceNOWのユーザー名
- `servicenow_password`: ServiceNOWのパスワード
- `servicenow_instance_url`: ServiceNOWのインスタンスURL
- `servicenow_target_table_name`: ターゲットテーブル名
- `remote_filepath_job_result`: ジョブ結果の情報が格納されたJSONファイルのパス（例: "{{ __workflowdir__ }}/{{ inventory_hostname }}/job_result.json"）
- `remote_filepath_upload_log`: アップロードするログファイルのパス（例: "/var/log/exastro/exec.log"）

### デフォルト変数

以下の変数はデフォルト値が設定されていますが、必要に応じて上書きできます：

- `create_record_body_j2_file`: レコード作成用のテンプレートファイル（デフォルト: "create_record_body.j2"）
- `patch_record_body_j2_file`: レコード更新用のテンプレートファイル（デフォルト: "patch_record_body.j2"）

### ジョブ結果に関する変数
テンプレートファイル`./templates/create_record_body.j2`を参照してください。

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

## ライセンス

MIT

## 作者情報

このロールはServiceNOWとの連携を簡素化するために作成されました。
