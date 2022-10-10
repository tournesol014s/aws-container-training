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
      - sbcntr-AccessingCodeCommitPolicy
    - IAMロール
      - sbcntr-cloud9-role
- 書籍と異なる設定
  - ECS Cloudwatch Log Group名
    - /ecs/sbcntr-backend-def -> /ecs/sbcntr-backend
    - /ecs/sbcntr-frontend-def -> /ecs/sbcntr-frontend
  - FrontendもBackend同様、ECSサービスを構築
  - RDSパラメータグループはdefaultではなく、別途作成
  - RDS 削除保護を無効化
  - CodeCommit用のIAM policyを新規に作成

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

### Chapter6
- 書籍p.286-296の内容の構築
- FrontendもBackend同様、ECS Cluster/サービスを構築。

### Chapter7
- 書籍p.297-313の内容の構築
- RDSパラメータグループはdefaultではなく、別途作成。
- RDS削除保護を無効にする。
  - terraform destroyでfailしないようにするため。
- RDSパスワードは、random_passwordを利用して自動生成する。 

### Chapter8
- 書籍p.314-321の内容の構築

### Chapter9
- 書籍p.321-334の内容の構築
- backendアプリのデプロイメントはCodeDeployに委ねているため、terraformによる新しいタスク定義でのECSサービスのデプロイは行えない。そのためp.323-327の内容は手動で実行する必要がある。

### Chapter10
- 書籍p.337-368の内容の構築
- CodeCommitがECRへアクセスするためのIAM policyは、Cloud9用に作成したsbcntr-AccessingECRRepositoryPolicyとは別に新規作成。
- CodeCommitへpushされたことをトリガーに、CodePipelineを起動するためのEventBridgeは、手動で作成。（コンソールからPipeline作成時は自動生成される）

### Chapter11
- 書籍p.369-372の内容の構築

### Chapter12
- 書籍p.373-378の内容の構築

### Chapter13
- 書籍p.379-390の内容の構築

### Chapter14
- 書籍p.391-407の内容の構築
- backendアプリのデプロイメントはCodeDeployに委ねているため、Terraformによる新しいタスク定義でのECSサービスのデプロイは行えない。そのためp.404-405の内容は手動で実行する必要がある。

### Chapter15
- 書籍p.408-422の内容の構築
- アドバンストインスタンスティアの有効化はTerraformから行えないため、コンソールから実施する。
- BastionのLogDriver設定は明示的に行う。

### Chapter16
- 書籍p.423-432の内容の構築
- Terraform code追加・修正なし

### Capter17
- 作成したリソースの削除
- 基本的には、`terraform destroy`による削除。手動作成したCloud9関連のリソースは手動削除する。
  - 先にCloud9インスタンスを削除しないと、`terraform destroy`実行時にsubnet等の削除が行えない。
  - ECR,S3は中身が存在すると`terraform destroy`に失敗するので、事前にコンソールから手動削除する。
  - ECR,S3,CodeCommitの内容を残したい場合は、`state rm`によりTerraform管理対象外にしたうえで`terraform destroy`を行う。
