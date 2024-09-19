# render_linux
LinuxやmacOSを使って、コマンドラインからシーンファイル(qsc)をレンダリングするためのコードです。

## 環境構築
libcuemol2をビルドするための環境を構築します。
[Dockerfile](Dockerfile)を使う、あるいは、[Dockerfile](Dockerfile)に記述されているものと同じライブラリをlinuxにインストールする。
Dockerfile内では、/optに依存ライブラリがインストールされる。（以下では、/optにインストールされているものとして記述）

## libcuemol2のビルド
- cuemol2のリポジトリをcloneしてくる。
- [build_scripts/build_libcuemol2_posix/run.sh](https://github.com/CueMol/cuemol2/blob/develop/build_scripts/build_libcuemol2_posix/run.sh)を実行する。
```bash
bash build_scripts/build_libcuemol2_posix/run.sh /opt Release
```
- 依存ライブラリのインストール先が違う場合は`/opt`の部分を変える。
-デバッグ版をビルドする場合は、Debugにする。
- `/opt`以下は書ける必要がある。 (/opt/libcuemol2_build以下にbuild treeが作られるため)

## python moduleのビルド
- インストール先のpython環境を整える。(以下のスクリプトではpython3.12が使われる)
- [build_scripts/build_pymod_posix/run.sh](https://github.com/CueMol/cuemol2/blob/develop/build_scripts/build_pymod_posix/run.sh)を実行する。
```bash
bash build_scripts/build_pymod_posix/run.sh /opt
```
- 依存ライブラリのインストール先が違う場合は`/opt`の部分を変える。
- python3.12以外（例えばpythonやpython3とか）が適切な場合は、↑run.shの`PYTHON=`の部分を書き換える。
- pytestが走るが、`libcuemol2.so`に`LD_LIBRARY_PATH`が通っていないと落ちるので、その際は気にしない。

## povrayを入れる
上記のDockerfileではpovrayを入れていないので、入れる。
- buildしたものが、[CueMol/povray_build](https://github.com/CueMol/povray_build/releases/download/v0.0.5/)にあるので、これを使うのが手っ取り早い
- 以下では、/opt/povrayに展開
- （ともかくもインストールできればこれ以外の方法でもよい）

# 実行方法
[render.py](render.py)を適切な引数を与えて実行すると、画像が生成されるはず。
```bash
env LD_LIBRARY_PATH=/opt/cuemol2/lib/ python3.12 render.py \
    --infile test1.qsc \
    --pov=/opt/povray/bin/povray \
    --povinc /opt/povray/include \
    --blendpng /opt/cuemol2/bin/blendpng \
    --nthreads 16 \
    --radiosity_mode=7
```
