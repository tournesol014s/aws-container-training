# aws-container-training

## Overview
- 「AWSコンテナ設計・構築[本格]入門」のCahpter04/05のハンズオンの内容をTerraformで構築した場合のサンプルコードです。
- トレーニング用コンテンツとしての利用を想定し、段階的に構築を進められるようChapterを設定しています。

## 注意事項・前提事項
- オフィシャルなコンテンツではなく、著者や出版社とは何ら関係はありません。問い合わせ等行わないようお願いいたします。
- Terraformやtfenvのインストール、TerraformでAWSを操作するためのIAMアカウントの作成やクレデンシャルの設定は済んでいるものとします。
- 2022/10時点で以下のバージョンで検証していますが、仕様変更やバージョンアップにより構築に失敗する可能性があります。
  - Terraform : 1.3.2
  - AWS Provider : 4.34.0
  - tfenv : 2.2.3
- トレーニング用のため、tfstateファイルはローカルで管理する想定です。必要に応じてS3での管理を検討して下さい。
- 手動作成したリソース
  - Cloud9関連
    - Cloud9インスタンス/EBS
      - sbcntr-dev
    - インスタンス作成時に自動生成されるSG
      - aws-cloud9-sbcntr-dev-xxxxx-InstanceSecurityGroup-xxxxx
    - IAMポリシー
      - sbcntr-AccessingECRRepositoryPolicy
    - IAMロール
      - sbcntr-cloud9-role
- 書籍と異なる設定
  - ECS Cloudwatch Log Group名
    - /ecs/sbcntr-backend-def -> /ecs/sbcntr-backend

## Training Menu
### Chapter0
- [.terraform-version](./.terraform-version)を作成し、バージョンを指定
- [main.tf](./main.tf)を作成し、AWS provider等の設定を行う。
  - 本コンテンツで作成したリソースを簡単に区別できるよう、default tagの設定を実施。
  - AWSアカウントIDの参照のため、aws_caller_identityをdata参照。
  - デフォルトリージョンを変数で設定。

### Chapter1
- 書籍p.195-202の内容の構築
- PublicSubnetのIngressは、書籍やコード上は0.0.0.0/0としていますが、セキュリティの観点からアクセス元のIPアドレスに絞ることを推奨。
  - 変数名 : [clientIpAddress](./main.tf#L26-L27)

### Chapter2
- 書籍p.203-215の内容の構築
- Terraform code追加なし
  - Cloud9はSecurityGroupを作成時に指定ができず、自動で作成されるため、Cloud9関連のリソースはterraform管理対象外とし、手動構築とする。

### Chapter3
- 書籍p.216-245の内容の構築
- Cloud9関連の設定変更は手動で実施する。

### Chapter4
- 書籍p.246-265の内容の構築

### Chapter5
- 書籍p.265-285の内容の構築
- LogDriver出力先のCloudWatch Logsは、明示的に作成を行う。
- FargateのexecutionRoleは明示的に作成を行う。
- CodeDeployの設定作成を明示的に行う。
