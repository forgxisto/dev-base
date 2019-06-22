# dev-base

## これは何か？

dockerを基盤にして開発するための雛形です。
このリポジトリをcloneした後は、プロジェクトに合わせて適宜編集してから使う想定です。

**目次**
  - [よく使う？Docker関連のコマンド](#%E3%82%88%E3%81%8F%E4%BD%BF%E3%81%86Docker%E9%96%A2%E9%80%A3%E3%81%AE%E3%82%B3%E3%83%9E%E3%83%B3%E3%83%89)
      - [起動 & 終了](#%E8%B5%B7%E5%8B%95--%E7%B5%82%E4%BA%86)
      - [コンテナ起動してる？](#%E3%82%B3%E3%83%B3%E3%83%86%E3%83%8A%E8%B5%B7%E5%8B%95%E3%81%97%E3%81%A6%E3%82%8B)
      - [起動中のコンテナに入る（とりあえずbash）](#%E8%B5%B7%E5%8B%95%E4%B8%AD%E3%81%AE%E3%82%B3%E3%83%B3%E3%83%86%E3%83%8A%E3%81%AB%E5%85%A5%E3%82%8B%E3%81%A8%E3%82%8A%E3%81%82%E3%81%88%E3%81%9Abash)
      - [起動してないコンテナでコマンド実行する（初期セットアップとか）](#%E8%B5%B7%E5%8B%95%E3%81%97%E3%81%A6%E3%81%AA%E3%81%84%E3%82%B3%E3%83%B3%E3%83%86%E3%83%8A%E3%81%A7%E3%82%B3%E3%83%9E%E3%83%B3%E3%83%89%E5%AE%9F%E8%A1%8C%E3%81%99%E3%82%8B%E5%88%9D%E6%9C%9F%E3%82%BB%E3%83%83%E3%83%88%E3%82%A2%E3%83%83%E3%83%97%E3%81%A8%E3%81%8B)
      - [一括削除](#%E4%B8%80%E6%8B%AC%E5%89%8A%E9%99%A4)
  - [for Rails](#for-Rails)
      - [初めの rails new まで](#%E5%88%9D%E3%82%81%E3%81%AE-rails-new-%E3%81%BE%E3%81%A7)
      - [overmind使う時](#overmind%E4%BD%BF%E3%81%86%E6%99%82)
  - [for React](#for-React)
      - [create-react-app を TypeScript で](#create-react-app-%E3%82%92-TypeScript-%E3%81%A7)
  - [for Gatsby](#for-Gatsby)
      - [gatsby new まで](#gatsby-new-%E3%81%BE%E3%81%A7)
  - [for Serverless](#for-Serverless)

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
    command: bash -c 'rm -f tmp/pids/* && rm -f .overmind.sock && overmind start'
    ~ 略 ~
```

別ターミナルから（閉じるしかなくなるので）
```
docker-compose exec ruby overmind c rails
  => overmindでrailsにコネクト
  => [ctrl]+[c]とかしちゃうとrails落とすことになるので気をつける
```
## nodeコンテナ for Amplify

* amplify-cliはグローバルに置いてます。
* team-provider-info.json は .gitignore 済み

  https://aws-amplify.github.io/docs/cli/multienv

* docker-compose.yml の環境変数で credential, config を渡す方針で。

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

## nodeコンテナ for Serverless

* serverlessはグローバルに置いてます。
* まぁ、sam-cliと迷うよね

  https://serverless.com

```
docker-compose run node serverless --template aws-ruby
```
