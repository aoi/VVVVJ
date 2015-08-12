VVVVJ
====

vvvvによるVJのためのパッチ。
16種類の映像の切り替えが可能。  
キーボード操作の他にMIDI、OSCでの操作が可能。  
(OSCはTouchOSCをiPadでする場合に可能。)  
オーディオ入力の簡易的なFFT解析を行うサブパッチも組み込み済み。

使い方
----
 1. VVVVJ.v4pを実行する。
 1. バンクに映像をセットする。
  1. 動画ファイルまたは画像ファイルの場合はBankのFilenameを左クリックしてファイルを選択する。
  1. 任意のパッチからのレンダリング結果をセットしたい場合はテクスチャとして出力し、BankのTexture Inにセットする。
 1. キーボード操作の場合
  1. Preferenceノードを開き、Input ModeをKeyboardにセットする。
  1. PreferenceノードのEnabled Keyboard Inputをtrueにする。
  1. 操作方法
     * Q、W、E、R、T、Y、U、I: 左側の映像を選択する。
     * A、S、D、F、G、H、J、K: 右側の映像を選択する。
     * Z、X、C、V、B、N: 右側/左側映像を切り替える際のエフェクトを選択する。
     * Space: 右側の映像を出力する。
     * Shift+Space: 左側の映像を出力する。
 1. OSC操作の場合
  1. <a href="http://hexler.net/software/touchosc">TouchOSC</a>をiPadにインストールする。
  1. Preferenceノードを開き、Input ModeをOSCにセットする。
  1. OSCInputノードの各ピンを適宜セットする。
  1. TouchOSCにはリポジトリにあるVVVVJ.touchoscというレイアウトファイルをインストールする。
     1. (TODO: VVVVJ.touchoscの説明)
  1. OSCの場合は動画のPlay(再生/停止)、DoSeek(最初から再生)、Loop(繰り返しON/OFF)を制御できる。

主要ノード
----

### Bank
映像を設定するノード。
動画ファイル、画像ファイル、パッチからのテクスチャ入力に対応。

 * FileName: 動画ファイル、または画像ファイルの名前を設定する。未指定の場合はInspektorから空にすること。拡張子によって動画ファイルか画像ファイルか判断される。
  * 動画ファイル: .wmv、.avi
  * 画像ファイル: .jpg、.jpeg、.bmp、.dds、.hdr、.png、.tif、.tga
 * Texture In: 任意のパッチからのテクスチャを入力する。
 * Create Thumbnail: レンダリング中画像のサムネイルを作成する。

**FileNameかTexture Inのいずれか1つだけを設定しないとエラーとなりNILが出力される。**

### Preference
操作モードやMIDIについての設定。
MIDI操作の場合、チャンネルとノートの値をバンクやエフェクトに割り当てる。同チャンネルのノート番号は重複してはならない。

 * Enabled Keyboard Input: Input ModeがKeyboardの場合にはtrueにセットする。開発中などはfalseにセットしておけば意図しない映像の切り替えなどが起こらない。

### Debug
パフォーマンスやログ出力など開発時に参考になるノードが集まっている。

フレームワーク
----
### Bankに任意のパッチを設定する
Template (Bank)というノードが用意されている。  
これはBankを内包し、Bank InputからのEnabledの値を取得したり、サムネイルを生成するなどの機能を持っている。  
Template (Bank)はテンプレートなので、呼び出して別名で保存して使う。  
その後、任意のパッチ(以下パッチAと呼ぶ)をTemplate (Bank)の中に配置する。  
パフォーマンスを気にする場合はEnabledの値を配置したパッチAのEvaluateに接続する。  
VVVVJパッチで任意のBank IDの出力をTemplate (Bank)のBank ID入力に繋げる。  
Template (Bank)の出力をバンクスペース右下にあるノードに繋げる。

### OSCを使用する
値はR (Value)で受け取る。  
(TODO: 詳細)

### MIDIを使用する
値はR (Value)で受け取る。  
(TODO: 詳細)

### オーディオ入力を使用する
VVVVJではオーディオ入力をFFTノードで解析した結果をS (Value)で出力している。  
任意のパッチでFFTノードを使用したい場合はパッチごとにその都度FFTノードを配置するよりは、  
R (Value)で値を受け取る方が望ましい。  
以下の名前でR (Value)ノードにてFFTの結果を受け取ることが出来る。  

使用するにはAudioInputのEnabledをtrueにする。  
AudioInputノードに繋がっているGainノードでゲインを調節できる。
