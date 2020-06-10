# dev-base

## これは何か？

dockerを基盤にして開発するための雛形です。
このリポジトリをcloneした後は、プロジェクトに合わせて適宜編集してから使う想定です。

AWSなど外部サービスの認証情報を環境変数として渡す場合はEnviflesディレクトリ以下の.envに書いて渡す方針。

**目次**
  - [よく使う？Docker関連のコマンド](#%e3%82%88%e3%81%8f%e4%bd%bf%e3%81%86docker%e9%96%a2%e9%80%a3%e3%81%ae%e3%82%b3%e3%83%9e%e3%83%b3%e3%83%89)
      - [起動 & 終了](#%e8%b5%b7%e5%8b%95--%e7%b5%82%e4%ba%86)
      - [コンテナ起動してる？](#%e3%82%b3%e3%83%b3%e3%83%86%e3%83%8a%e8%b5%b7%e5%8b%95%e3%81%97%e3%81%a6%e3%82%8b)
      - [起動中のコンテナに入る（とりあえずbash）](#%e8%b5%b7%e5%8b%95%e4%b8%ad%e3%81%ae%e3%82%b3%e3%83%b3%e3%83%86%e3%83%8a%e3%81%ab%e5%85%a5%e3%82%8b%e3%81%a8%e3%82%8a%e3%81%82%e3%81%88%e3%81%9abash)
      - [起動してないコンテナでコマンド実行する（初期セットアップとか）](#%e8%b5%b7%e5%8b%95%e3%81%97%e3%81%a6%e3%81%aa%e3%81%84%e3%82%b3%e3%83%b3%e3%83%86%e3%83%8a%e3%81%a7%e3%82%b3%e3%83%9e%e3%83%b3%e3%83%89%e5%ae%9f%e8%a1%8c%e3%81%99%e3%82%8b%e5%88%9d%e6%9c%9f%e3%82%bb%e3%83%83%e3%83%88%e3%82%a2%e3%83%83%e3%83%97%e3%81%a8%e3%81%8b)
      - [一括削除](#%e4%b8%80%e6%8b%ac%e5%89%8a%e9%99%a4)
  - [rubyコンテナ for Rails](#ruby%e3%82%b3%e3%83%b3%e3%83%86%e3%83%8a-for-rails)
      - [初めの rails new まで](#%e5%88%9d%e3%82%81%e3%81%ae-rails-new-%e3%81%be%e3%81%a7)
      - [overmind使う時](#overmind%e4%bd%bf%e3%81%86%e6%99%82)
  - [nodeコンテナ for Amplify](#node%e3%82%b3%e3%83%b3%e3%83%86%e3%83%8a-for-amplify)
  - [nodeコンテナ for React](#node%e3%82%b3%e3%83%b3%e3%83%86%e3%83%8a-for-react)
      - [create-react-app を TypeScript で](#create-react-app-%e3%82%92-typescript-%e3%81%a7)
  - [nodeコンテナ for Gatsby](#node%e3%82%b3%e3%83%b3%e3%83%86%e3%83%8a-for-gatsby)
      - [gatsby new まで](#gatsby-new-%e3%81%be%e3%81%a7)
  - [slsコンテナ](#sls%e3%82%b3%e3%83%b3%e3%83%86%e3%83%8a)
  - [samコンテナ](#sam%e3%82%b3%e3%83%b3%e3%83%86%e3%83%8a)


## よく使う？Docker関連のコマンド

#### 起動 & 終了

```
docker-compose up -d --build
docker-compose down
```

#### コンテナ起動してる？

```
docker-compose ps
```

#### 起動中のコンテナに入る（とりあえずbash）

```
docker-compose exec コンテナ名 bash
```

#### 起動してないコンテナでコマンド実行する（初期セットアップとか）

```
docker-compose run コンテナ名 コマンド
docker-compose run コンテナ名 bash -c "コマンド"
```

#### 一括削除

`-a` オプションをつけるととにかく全部消せる
```
docker system prune      # 未使用まとめて（ネットワーク、コンテナ、イメージ）
docker container prune   # 未使用コンテナ
docker image prune       # 未使用イメージ（中間イメージ、壊れたやつとか）
docker volume prune      # 未使用ボリューム
```



## rubyコンテナ for Rails

* 初期イメージの中身はDockerfiles/ruby.Dockerfileを参照。
* Procfileを作ればovermindでも起動できるようにしてある。
* `bundle exec` のエイリアス代替スクリプトは好みで。手抜きしすぎ？

#### 初めの rails new まで

* サーバ起動するときはhost, portに気をつけましょう

```
docker-compose run ruby bundle init
  => Gemfileが作成されるのでrailsのコメントアウトを外す

docker-compose run ruby bundle install --path vendor/bundle
  => railsインストール

docker-compose run ruby bundle exec rails new . --force --skip-bundle
  => Railsアプリケーション作成, オプションは任意（データベースなど）
  => Gemfileを適宜編集する

docker-compose run ruby bin/setup
  => アプリ用 gemインストール

docker-compose run ruby bundle exec rake db:create db:create
  => DBセットアップ
```

#### overmind使う時

https://github.com/DarthSim/overmind

* docker-compose.ymlのcommandで起動してるやつをpryで止めたい時とか
* sidekiqとかも一緒に起動したい時とか
* いろいろめんどくさい時とか

Procfileを作る
```
rails: bundle exec rails s -b 0.0.0.0 -p 3000
```

docker-compose.ymlのcommandを追加して `up` したら `rails s` するようにする
```
version: '3.7'
services:
  ruby:
    ~ 略 ~
    command: bash -c 'rm -f tmp/pids/* && rm -f .overmind.sock && overmind s -D'
    ~ 略 ~
```

別ターミナルから（もしくはバックグラウンドに回して）
```
docker-compose exec ruby overmind c rails
  => overmindでrailsにコネクト
  => [ctrl]+[c]とかしちゃうとrails落とすことになるので気をつける
  => 抜ける時は[ctrl]+[b] -> [d]
```


## nodeコンテナ for Amplify

* amplify-cliはグローバルに置いてます。
* team-provider-info.json は .gitignore 済み

  https://aws-amplify.github.io/docs/cli/multienv

```
docker-compose run node amplify init
```



## nodeコンテナ for React

* `npx` 使えるならそっちで。
* サーバ起動するときはhost, portに気をつけましょう

#### create-react-app を TypeScript で

```
docker-compose run node npx create-react-app . --typescript
  => でけた
```



## nodeコンテナ for Gatsby

* gatsby-cliはグローバルに置いてます。
* サーバ起動するときはhost, portに気をつけましょう

#### gatsby new まで

TypeScript のミニマムなスターターが欲しい・・

```
docker-compose run node gatsby new .
  => でけた
```



## slsコンテナ

* serverlessはグローバルに置いてます。
* まぁ、sam-cliと迷うよね

  https://serverless.com

```
docker-compose run sls serverless --template aws-ruby
```

## samコンテナ

* aws sam-cliはホストのdockerを使うようにしてます。
* まぁ、serverlessと迷うよね

  https://github.com/awslabs/aws-sam-cli

samアプリはsamディレクトリ直下に置いてください・・

```
docker-compose run sam sam init --runtime ruby2.7
cp -fr sam/sam-app/* sam/
rm -fr sam/sam-app
```
* bundle installを忘れないように・・・(https://github.com/awslabs/aws-sam-cli/issues/865)

localstackと同時に使う時は、ネットワークの指定に注意

```
docker-compose exec sam bash
sam local start-api --host 0.0.0.0 --docker-network docker-lan
```
