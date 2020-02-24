# ベースイメージ名:タグ名
FROM continuumio/anaconda3:2019.03

# sudoを使えるようにする
RUN apt-get update && \
    apt-get install -y sudo

# cmakeコマンドを使用可能にする
RUN sudo apt-get install build-essential cmake && \
    sudo apt-get install libgtk-3-dev && \
    sudo apt-get install libboost-all-dev

# dlib環境の作成(buildする前に、ホスト側でgitとの鍵関係の環境を整える)
RUN git clone https://github.com/davisking/dlib.git && \
    cd dlib && \
    mkdir build && \
    cd build && \
    cmake .. && \
    cmake --build . && \
    cd .. && \
    python3 setup.py install

# pipをアップグレードし必要なパッケージをインストール
RUN pip install --upgrade pip && \
    pip install autopep8 && \
    pip install Keras && \
    pip install tensorflow && \
    pip install opencv-python && \
    pip install face_recognition

# コンテナ側にホスト側からマウントする用のフォルダを作成
RUN mkdir /mount 

# コンテナ側のルート直下にworkdir/（任意）という名前の作業ディレクトリを作り移動する
WORKDIR /workdir

# コンテナ側のリッスンポート番号
EXPOSE 8888

# ENTRYPOINT命令はコンテナ起動時に実行するコマンドを指定（基本docker runの時に上書きしないもの）
# "jupyter-lab" => jupyter-lab立ち上げコマンド
# "--ip=0.0.0.0" => ip制限なし
# "--port=8888" => EXPOSE命令で書いたポート番号と合わせる
# ”--no-browser” => ブラウザを立ち上げない。コンテナ側にはブラウザがないので 。
# "--allow-root" => rootユーザーの許可。セキュリティ的には良くないので、自分で使うときだけ。
# "--NotebookApp.token=''" => トークンなしで起動許可。これもセキュリティ的には良くない。
ENTRYPOINT ["jupyter-lab", "--ip=0.0.0.0", "--port=8888", "--no-browser", "--allow-root", "--NotebookApp.token=''"]

# CMD命令はコンテナ起動時に実行するコマンドを指定（docker runの時に上書きする可能性のあるもの）
# "--notebook-dir=/workdir" => Jupyter Labのルートとなるディレクトリを指定
CMD ["--notebook-dir=/workdir"]