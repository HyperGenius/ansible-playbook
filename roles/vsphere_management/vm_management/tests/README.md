# vSphere VM Management Role - Tests

このディレクトリには、vSphere VM管理ロールのテストファイルとテスト実行スクリプトが含まれています。

## テストファイル

- `test-load-credentials.yml` - 認証情報の読み込みテスト
- `test-create.yml` - VM作成テスト
- `test-update.yml` - VM更新テスト
- `test-delete.yml` - VM削除テスト

## テスト実行スクリプト

### 1. run_all_tests.sh
すべてのテストを一括で実行するためのスクリプトです。  
以下のオプションをサポートしています：

```bash
# ヘルプの表示
./run_all_tests.sh --help

# Vaultパスワードを対話的に入力してテスト実行
./run_all_tests.sh --vault-pass

# Vaultパスワードファイルを使用してテスト実行
./run_all_tests.sh --vault-file /path/to/vault_password

# チェックモード（ドライラン）でテスト実行
./run_all_tests.sh --vault-pass --check

# 特定のテストをスキップ
./run_all_tests.sh --vault-pass --skip-delete

# 詳細出力付きでテスト実行
./run_all_tests.sh --vault-pass --verbose
```

### 2. 簡易テストランナー (`quick_test.sh`)
簡易的なテスト実行スクリプトです。  
以下のオプションをサポートしています：

```bash
# Vaultパスワードを対話的に入力してテスト実行
./quick_test.sh --vault-pass

# Vaultパスワードファイルを使用してテスト実行
./quick_test.sh --vault-file /path/to/vault_password

# チェックモード（ドライラン）でテスト実行
./quick_test.sh --vault-pass --check

# Vaultを使用せずにテスト実行
./quick_test.sh

# ヘルプの表示
./quick_test.sh --help
```

## 個別テストの実行

各テストファイルを個別に実行することも可能です：

```bash
# 認証情報読み込みテスト
ansible-playbook test-load-credentials.yml --ask-vault-pass

# VM作成テスト
ansible-playbook test-create.yml --ask-vault-pass

# VM更新テスト
ansible-playbook test-update.yml --ask-vault-pass

# VM削除テスト
ansible-playbook test-delete.yml --ask-vault-pass
```

## テスト前の準備

### 1. 認証情報ファイルの設定

以下のファイルを実際の環境に合わせて設定してください：

- `test_vars/vcenter_credentials.yml` - vCenter認証情報
- `test_vars/test_create_vars.yml` - VM作成テスト用変数
- `test_vars/test_update_vars.yml` - VM更新テスト用変数
- `test_vars/test_delete_vars.yml` - VM削除テスト用変数

### 2. テンプレート認証情報の設定

`../vars/`ディレクトリ内のテンプレート認証情報ファイルを設定し、ansible-vaultで暗号化してください：

```bash
# 認証情報ファイルの編集
ansible-vault edit ../vars/vm-template-redhat-credentials.yml
ansible-vault edit ../vars/vm-template-windows_server-credentials.yml

# vCenter認証情報ファイルの編集
ansible-vault edit ../vars/vcenter-01-credentials.yml
```

### 3. ネットワーク・インフラ設定

実際のvSphere環境に合わせて以下の設定を確認してください：

- データセンター名
- クラスター名
- ネットワークポートグループ名
- IPアドレス範囲
- DNS設定
- ドメイン設定

## テスト実行順序

テストは以下の順序で実行されることを想定しています：

1. **認証情報読み込みテスト** - 必要な認証情報ファイルが読み込めることを確認
2. **VM作成テスト** - テンプレートからVMを作成
3. **VM更新テスト** - 作成したVMのリソースを更新
4. **VM削除テスト** - VMを削除してクリーンアップ

## 注意事項

- テスト実行前にVMが電源オフになっていることを確認してください（更新・削除テスト）
- テストで作成されるVMは実際にvSphere環境に作成されます
- テスト完了後は削除テストでクリーンアップされますが、失敗した場合は手動で削除してください
- 本番環境では実行しないでください

## トラブルシューティング

### よくあるエラー

1. **Vault password required**
   - `--vault-pass`または`--vault-file`オプションを指定してください

2. **VM already exists**
   - 既存のVMを削除するか、`test_vars`ファイルでVM名を変更してください

3. **Template not found**
   - vSphere環境にテンプレートが存在することを確認してください
   - テンプレート名が`test_vars`ファイルと一致することを確認してください

4. **Network not found**
   - ネットワークポートグループ名が正しいことを確認してください

### ログの確認

詳細なログが必要な場合は、`-v`オプションを使用してください：

```bash
ansible-playbook test-create.yml --ask-vault-pass -v
```
