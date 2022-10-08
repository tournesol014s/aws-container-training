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
- 書籍と異なる設定

## Training Menu
### Chapter0
- [.terraform-version](./.terraform-version)を作成し、バージョンを指定
- [main.tf](./main.tf)を作成し、AWS provider等の設定を行う。
  - 本コンテンツで作成したリソースを簡単に区別できるよう、default tagの設定を実施。
  - AWSアカウントIDの参照のため、aws_caller_identityをdata参照。
  - デフォルトリージョンを変数で設定。

