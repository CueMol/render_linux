# render_linux
LinuxやmacOSを使って、コマンドラインからシーンファイル(qsc)をレンダリングするためのコードです。

## 環境構築
libcuemol2をビルドするための環境を構築します。
[Dockerfile](Dockerfile)を使う、あるいは、[Dockerfile](Dockerfile)に記述されているものと同じライブラリをlinuxにインストールする。
Dockerfile内では、/optに依存ライブラリがインストールされる。（以下では、/optにインストールされているものとして記述）

## libcuemol2のビルド
- cuemol2のリポジトリをcloneしてくる。
- (build_scripts/build_libcuemol2_posix/run.sh)[https://github.com/CueMol/cuemol2/blob/develop/build_scripts/build_libcuemol2_posix/run.sh]を実行する。
```bash
bash build_scripts/build_libcuemol2_posix/run.sh /opt Release
```
- 依存ライブラリのインストール先が違う場合は`/opt`の部分を変える。
-デバッグ版をビルドする場合は、Debugにする。
- `/opt`以下は書ける必要がある。 (/opt/libcuemol2_build以下にbuild treeが作られるため)

## python moduleのビルド
