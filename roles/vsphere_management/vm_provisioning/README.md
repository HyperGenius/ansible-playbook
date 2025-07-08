# Ansible Role: vSphere VM プロビジョニング

このロールは、VMware vSphere上で新しい仮想マシンをプロビジョニング（初回作成）します。

## 概要

このロールは、`vm_management`ロールから初回作成（provisioning）のタスクだけを抜き出して作成されました。テンプレートから新しい仮想マシンをクローンし、カスタマイズしてプロビジョニングします。

### 前提条件
- VMware vCenter Serverへのアクセスが可能であること
- Red HatおよびWindows用のVMテンプレートが事前に構成されていること
- プロビジョニングするVMの名前が既存のVMと重複しないこと

## 要件

- `community.vmware`コレクションがインストールされていること (`ansible-galaxy collection install community.vmware`)
- AnsibleコントローラーにPythonライブラリ`PyVmomi`がインストールされていること (`pip install PyVmomi`)

## ロール変数

### vCenter接続情報
- `vcenter_number`: vCenterサーバーの号機番号（最小値: 1, 最大値: 99）。デフォルトは`1`
- 認証情報は`vars/vcenter-XX-credentials.yml`ファイルから読み込まれます

### VM基本設定
- `vm_name`: (必須) 作成する仮想マシンの名前
- `vm_os_family`: VMのOSファミリー。`RedHat`または`Windows`。デフォルトは`RedHat`
- `vm_datacenter`: (必須) VMが所属するデータセンターの名前
- `vm_cluster`: (必須) VMを作成するクラスターの名前
- `vm_folder`: (必須) VMを配置するフォルダのパス
- `vm_template_name`: (必須) 使用するVMテンプレートの名前
- `vm_notes`: VM説明。デフォルトは`"Provisioned by Ansible"`

### VMリソース設定
- `vm_cpu_cores`: (必須) CPUコア数
- `vm_memory_mb`: (必須) メモリ量（MB）
- `vm_os_disk_size_gb`: (必須) OSディスクのサイズ（GB）
- `vm_os_disk_type`: ディスクのタイプ。デフォルトは`thin`
- `vm_os_disk_datastore`: ディスクのデータストア名。デフォルトは`null`（クラスタのデフォルトデータストアを使用）

### ネットワーク設定
- `vm_os_setting_network_portgroup`: 初回OS設定用管理ネットワークポートグループ名。デフォルトは`"VM Network"`
- `vm_domain`: (必須) ドメイン名
- `vm_dns_servers`: (必須) DNSサーバーのリスト（customization用）

**注意**: このロールではDHCPによるIP取得を前提としており、静的IPの設定は行いません。静的IP設定が必要な場合は、VM作成後に別途ネットワーク設定を行ってください。

### 電源設定
- `vm_power_state`: VM作成後の電源状態。デフォルトは`poweredon`

### 詳細設定（オプション）
- `vm_cpu_reservation`: CPU予約（MHz）。デフォルトは`null`
- `vm_memory_reservation`: メモリ予約（MB）。デフォルトは`null`
- `vm_memory_limit`: メモリ制限（MB）。デフォルトは`null`
- `vm_template_windows_admin_password`: Windows管理者パスワード（Windows VMの場合）
- `vm_template_sudo_password`: Red Hat系VMのsudoパスワード（Red Hat系VMの場合）

### 追加ディスク設定
- `vm_additional_disks`: 追加ディスクの設定リスト（省略可）

## 認証情報ファイル

以下のファイルに認証情報を設定し、ansible-vaultで暗号化してください：

### vCenter認証情報
- `vars/vcenter-XX-credentials.yml`: vCenter認証情報
  - `vcenter_hostname`: vCenterサーバーのホスト名またはIPアドレス
  - `vcenter_username`: vCenter認証用のユーザー名
  - `vcenter_password`: vCenter認証用のパスワード
  - `vcenter_validate_certs`: SSL証明書の検証フラグ

### VMテンプレート認証情報
- `vars/vm-template-<テンプレート名>-credentials.yml`: VMテンプレート認証情報

#### Red Hat系テンプレート
```yaml
vm_template_username: "your_vm_username"
vm_template_password: "your_vm_password"
vm_template_sudo_password: "your_vm_sudo_password"  # sudo用パスワード
```

#### Windows系テンプレート
```yaml
vm_template_username: "your_vm_username"
vm_template_password: "your_vm_password"
vm_template_windows_admin_password: "your_windows_admin_password"  # 管理者パスワード
```

## Playbookの例

### 基本的なVM作成（Red Hat系）
```yaml
- hosts: localhost
  connection: local
  gather_facts: no
  vars:
    vcenter_number: 1
    vm_name: "web-server-01"
    vm_os_family: "RedHat"
    vm_datacenter: "MyDatacenter"
    vm_cluster: "MyCluster"
    vm_folder: "/vm/production"
    vm_template_name: "redhat"
    vm_cpu_cores: 4
    vm_memory_mb: 8192
    vm_os_disk_size_gb: 50
    vm_os_setting_network_portgroup: "VM Network"
    vm_dns_servers:
      - "8.8.8.8"
      - "8.8.4.4"
    vm_domain: "example.com"
  roles:
    - role: vsphere_management/vm_provisioning
```

### Windows VMの作成
```yaml
- hosts: localhost
  connection: local
  gather_facts: no
  vars:
    vcenter_number: 1
    vm_name: "win-server-01"
    vm_os_family: "Windows"
    vm_datacenter: "MyDatacenter"
    vm_cluster: "MyCluster"
    vm_folder: "/vm/production"
    vm_template_name: "windows_server"
    vm_cpu_cores: 2
    vm_memory_mb: 4096
    vm_os_disk_size_gb: 100
    vm_os_setting_network_portgroup: "VM Network"
    vm_dns_servers:
      - "192.168.1.10"
      - "192.168.1.11"
    vm_domain: "example.local"
    vm_template_windows_admin_password: "{{ vault_windows_admin_password }}"
  roles:
    - role: vsphere_management/vm_provisioning
```

## 依存関係

なし

## 制限事項

- このロールはVMの初回作成のみをサポートします
- 既存VMの変更や削除は`vm_management`ロールを使用してください
- すべてのタスクは`localhost`で実行されます（vSphere API呼び出しのため）
- ネットワーク設定はDHCPによるIP取得を前提としており、静的IP設定は行いません
- 作成されるVMには管理用ネットワーク（`vm_os_setting_network_portgroup`）のみが接続されます

## ライセンス

MIT

## 作成者情報

このロールは`vm_management`ロールから抽出されました。
