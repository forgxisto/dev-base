# dev-base

## これは何か？

dockerを基盤にして開発するための雛形です。
このリポジトリをcloneした後は、プロジェクトに合わせて適宜編集してから使う想定です。

# よく使う？Docker関連のコマンド

### 起動 & 終了

```
docker-compose up -d --build
docker-compose down
```

### 一括削除

`-a` オプションをつけるととにかく全部消せる

```
docker system prune      # 未使用まとめて（ネットワーク、コンテナ、イメージ）
docker container prune   # 未使用コンテナ
docker image prune       # 未使用イメージ（中間イメージ、壊れたやつとか）
```

# for Rails

* 初期イメージの中身はDockerfiles/ruby.Dockerfileを参照。
* Procfileを作ればovermindでも起動できるようにしてある。
* `bundle exec` のエイリアス代替スクリプトは好みで。手抜きしすぎ？

### 初めの rails new まで

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

### 普段の開発中に使うやーつ

とりあえずそのまま起動（docker-compose.ymlでcommandを指定してない時は `-d` つけておく）
```
docker-compose up -d --build
```

rubyコンテナに入る
```
docker-compose exec ruby bash
```

コマンドでrails起動する
```
docker-compose exec ruby bundle exec rails s -b 0.0.0.0
```


### overmind使う時

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
