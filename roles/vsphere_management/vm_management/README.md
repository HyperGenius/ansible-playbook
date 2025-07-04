# Ansible Role: vSphere VM管理

このロールは、VMware vSphere上の仮想マシンを管理（作成・変更・削除）します。

## 概要

`vm_action`変数に指定された値に応じて、以下の処理を実行します。

- **create**: テンプレートから新しい仮想マシンをクローンし、プロビジョニングします。
- **update**: 既存の仮想マシンのリソース（CPU, メモリ, ディスク）やネットワーク設定を部分的に変更します。
- **delete**: 仮想マシンをvSphereのインベントリから削除します（論理削除）。

### 前提条件
- `update`および`delete`アクションを実行する前に、対象の仮想マシンが**パワーオフ**されている必要があります。パワーオン状態の場合はエラー終了します。

## ロールの構造

このロールは、`vm_action`の値に応じて、`tasks`ディレクトリ内の対応するタスクファイルを動的に読み込みます。

- `tasks/main.yml`: `vm_action`の値を検証し、`create.yml`, `update.yml`, `delete.yml`のいずれかをインクルードするディスパッチャーです。
- `tasks/create.yml`: 仮想マシンの新規作成に関するタスクを定義します。
- `tasks/update.yml`: 既存の仮想マシンの変更に関するタスクを定義します。
- `tasks/delete.yml`: 仮想マシンの削除に関するタスクを定義します。
- `tasks/common.yml`: `update`と`delete`で共通して使用される、VMの存在確認と電源状態のチェックタスクを定義します。

## 要件

- `community.vmware`コレクションがインストールされていること (`ansible-galaxy collection install community.vmware`)。
- AnsibleコントローラーにPythonライブラリ`PyVmomi`がインストールされていること (`pip install PyVmomi`)。
- VMware vCenter Serverへのアクセスが可能であること。
- （作成時）Red HatおよびWindows用のVMテンプレートが事前に構成されていること。

## ロール変数

### アクション制御
- `vm_action`: (必須) 実行するアクション。`create`, `update`, `delete`のいずれかを指定。デフォルトは`create`。

### vCenter接続情報
- `vcenter_hostname`: (必須) vCenter Serverのホスト名またはIPアドレス。
- `vcenter_username`: (必須) vCenter認証用のユーザー名。
- `vcenter_password`: (必須) vCenter認証用のパスワード。
- `vcenter_validate_certs`: (任意) vCenterのSSL証明書を検証するかどうか。デフォルトは`false`。

### VM共通設定
- `vm_name`: (必須) 対象の仮想マシンの名前。
- `vm_datacenter`: (必須) VMが所属するデータセンターの名前。

### 作成時 (`create`) の設定
- `vm_os_family`: (必須) VMのOSファミリー。`RedHat`または`Windows`をサポート。デフォルトは`RedHat`。
- `vm_cluster`: (必須) VMを作成するクラスターの名前。
- `vm_folder`: (任意) VMを配置するフォルダのパス。デフォルトは`/vm`。
- `vm_template_redhat`: Red Hat系VMに使用するテンプレートの名前。
- `vm_template_windows`: Windows系VMに使用するテンプレートの名前。

### 変更時 (`update`) の設定
- `vm_cpu_cores`: 変更後のCPUコア数。
- `vm_memory_mb`: 変更後のメモリ量（MB）。
- `vm_disk_size_gb`: 変更後のプライマリディスクのサイズ（GB）。ディスクの縮小はできません。
- `vm_network_portgroup`: 変更後のポートグループ名。
- `vm_ip_address`: 変更後の静的IPアドレス。
- `vm_netmask`: 変更後のサブネットマスク。
- `vm_gateway`: 変更後のデフォルトゲートウェイ。

## 依存関係

なし

## Playbookの例

### VMの作成
```yaml
- hosts: localhost
  connection: local
  gather_facts: no
  vars:
    vm_action: "create"
    vm_name: "my-new-server"
    # ... その他の作成に必要な変数を指定 ...
  roles:
    - role: vsphere_management/vm_management
```

### VMの変更 (メモリを8GBに増設)
```yaml
# Note: updateアクションでは、指定した変数のみが変更されます。
- hosts: localhost
  connection: local
  gather_facts: no
  vars:
    vm_action: "update"
    vm_name: "my-new-server"
    vm_datacenter: "MyDatacenter"
    vm_memory_mb: 8192
  roles:
    - role: vsphere_management/vm_management
```

### VMの削除
```yaml
- hosts: localhost
  connection: local
  gather_facts: no
  vars:
    vm_action: "delete"
    vm_name: "my-new-server"
    vm_datacenter: "MyDatacenter"
  roles:
    - role: vsphere_management/vm_management
```

## 重要な注意事項

### API実行の委譲について

このロールは、VMware vSphere APIを実行するため、すべてのタスクが自動的に`delegate_to: localhost`で実行されます。これにより、リモートホストに対してプレイブックを実行する場合でも、実際のvSphere API呼び出しはAnsibleコントローラー（localhost）から実行されます。

そのため、プレイブック側では以下のような設定が可能です：

```yaml
- hosts: all  # 複数のホストに対してVM作成を実行
  vars:
    vm_name: "{{ inventory_hostname }}"  # ホスト名をVM名として使用
  roles:
    - role: vsphere_management/vm_management
```

### 前提条件
- `update`および`delete`アクションを実行する前に、対象の仮想マシンが**パワーオフ**されている必要があります。パワーオン状態の場合はエラー終了します。

## ロールの構造

このロールは、`vm_action`の値に応じて、`tasks`ディレクトリ内の対応するタスクファイルを動的に読み込みます。

- `tasks/main.yml`: `vm_action`の値を検証し、`create.yml`, `update.yml`, `delete.yml`のいずれかをインクルードするディスパッチャーです。
- `tasks/create.yml`: 仮想マシンの新規作成に関するタスクを定義します。
- `tasks/update.yml`: 既存の仮想マシンの変更に関するタスクを定義します。
- `tasks/delete.yml`: 仮想マシンの削除に関するタスクを定義します。
- `tasks/common.yml`: `update`と`delete`で共通して使用される、VMの存在確認と電源状態のチェックタスクを定義します。

## 要件

- `community.vmware`コレクションがインストールされていること (`ansible-galaxy collection install community.vmware`)。
- AnsibleコントローラーにPythonライブラリ`PyVmomi`がインストールされていること (`pip install PyVmomi`)。
- VMware vCenter Serverへのアクセスが可能であること。
- （作成時）Red HatおよびWindows用のVMテンプレートが事前に構成されていること。

## ロール変数

### アクション制御
- `vm_action`: (必須) 実行するアクション。`create`, `update`, `delete`のいずれかを指定。デフォルトは`create`。

### vCenter接続情報
- `vcenter_hostname`: (必須) vCenter Serverのホスト名またはIPアドレス。
- `vcenter_username`: (必須) vCenter認証用のユーザー名。
- `vcenter_password`: (必須) vCenter認証用のパスワード。
- `vcenter_validate_certs`: (任意) vCenterのSSL証明書を検証するかどうか。デフォルトは`false`。

### VM共通設定
- `vm_name`: (必須) 対象の仮想マシンの名前。
- `vm_datacenter`: (必須) VMが所属するデータセンターの名前。

### 作成時 (`create`) の設定
- `vm_os_family`: (必須) VMのOSファミリー。`RedHat`または`Windows`をサポート。デフォルトは`RedHat`。
- `vm_cluster`: (必須) VMを作成するクラスターの名前。
- `vm_folder`: (任意) VMを配置するフォルダのパス。デフォルトは`/vm`。
- `vm_template_redhat`: Red Hat系VMに使用するテンプレートの名前。
- `vm_template_windows`: Windows系VMに使用するテンプレートの名前。

### 変更時 (`update`) の設定
- `vm_cpu_cores`: 変更後のCPUコア数。
- `vm_memory_mb`: 変更後のメモリ量（MB）。
- `vm_disk_size_gb`: 変更後のプライマリディスクのサイズ（GB）。ディスクの縮小はできません。
- `vm_network_portgroup`: 変更後のポートグループ名。
- `vm_ip_address`: 変更後の静的IPアドレス。
- `vm_netmask`: 変更後のサブネットマスク。
- `vm_gateway`: 変更後のデフォルトゲートウェイ。

## 依存関係

なし

## Playbookの例

### VMの作成
```yaml
- hosts: localhost
  connection: local
  gather_facts: no
  vars:
    vm_action: "create"
    vm_name: "my-new-server"
    # ... その他の作成に必要な変数を指定 ...
  roles:
    - role: vsphere_management/vm_management
```

### VMの変更 (メモリを8GBに増設)
```yaml
# Note: updateアクションでは、指定した変数のみが変更されます。
- hosts: localhost
  connection: local
  gather_facts: no
  vars:
    vm_action: "update"
    vm_name: "my-new-server"
    vm_datacenter: "MyDatacenter"
    vm_memory_mb: 8192
  roles:
    - role: vsphere_management/vm_management
```

### VMの削除
```yaml
- hosts: localhost
  connection: local
  gather_facts: no
  vars:
    vm_action: "delete"
    vm_name: "my-new-server"
    vm_datacenter: "MyDatacenter"
  roles:
    - role: vsphere_management/vm_management
```

## セキュリティに関する注意事項

### Ansible Vaultの使用

このロールでは、機密情報（パスワード、認証情報など）をansible-vaultで暗号化することを強く推奨します。

#### テンプレート認証情報の暗号化

VMテンプレート用の認証情報は、`vars/vm-template-<template_name>-credentials.yml`ファイルに格納し、ansible-vaultで暗号化してください。

```bash
# 認証情報ファイルの暗号化
ansible-vault encrypt vars/vm-template-redhat-credentials.yml
ansible-vault encrypt vars/vm-template-windows_server-credentials.yml

# プレイブック実行時（vaultパスワードを対話的に入力）
ansible-playbook your-playbook.yml --ask-vault-pass

# プレイブック実行時（vaultパスワードファイルを使用）
ansible-playbook your-playbook.yml --vault-password-file /path/to/vault_password_file
```

#### 暗号化対象の変数

以下の変数は機密情報のため、ansible-vaultで暗号化することを推奨します：

- `vcenter_password`
- `vm_template_username` (テンプレート認証情報)
- `vm_template_password` (テンプレート認証情報)
- `vm_template_windows_admin_password` (Windows系テンプレート用の管理者パスワード)

## ライセンス

MIT