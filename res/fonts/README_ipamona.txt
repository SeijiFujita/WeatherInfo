
IPAモナーフォント
                             Jun Kobayashi <kobayashi@junkobayashi.jp>

概要
----
アスキーアートがなるべくズレないように、IPAフォントの字幅に変更を加えたも
のです。東雲フォントをもとに作られたモナーフォントと同じ発想で作成しました。

このフォントは、Windowsで作成された各種文書を他のOSで表示する際に便利に使う
ことができます。フォントの幅と高さをWindowsで標準添付されている日本語フォン
トに合わせてあるので、レイアウトの崩れを最小限に抑えることができます。

ご意見やバグ報告は、小林　準(kobayashi@junkobayashi.jp)までお願いします。

http://www.geocities.jp/ipa_mona/

ライセンス及び再配布条件
-----------------------
IPAモナーフォントは、下記のフォントを組み合わせて作成したものです。
利用許諾条件や再配布条件は、下記のフォントに準じます。

 * IPAフォント
  Copyright (C) 2003 Information-technology Promotion Agency, Japan.
  ライセンス・再配布条件は、COPYING.font.ja を参照してください。
　※IPAフォントのバージョン1を使用しています。バージョン2とはライセンスが
    異なります。

 * さざなみフォント
  Copyright (c) 1990-2003
   Wada Laboratory, the University of Tokyo. All rights reserved.
  Copyright (c) 2003-2004
   Electronic Font Open Laboratory (/efont/). All rights reserved.
  ライセンス・再配布条件は、doc/sazanami/README を参照してください。

 * モナーフォント
  ライセンス・再配布条件は、doc/mona/README-ttf.txt を参照してください。

 * M+フォント
  Copyright (C) 2003-2006 M+ FONTS PROJECT
  ライセンス・再配布条件は、doc/mplus/ 以下のファイルを参照してください。

IPAモナーフォントは、IPAフォントのライセンス条項に従い、HP Vector Driver 
に同梱して配布しています。

IPAモナーフォントは一切の保証なしに提供されます。


IPAモナーフォント変更点
----------------------
 * IPA モナー P ゴシック
   - フォント幅をMS P ゴシックの幅に近くなるよう調整
   - 幅を変更したアウトラインフォントの微調整
   - 12pixelのビットマップフォントを13pixelとしてコピー
   - 14pixelのビットマップフォントを15pixelとしてコピー
   - ビットマップフォント12〜16pixelの英数字と記号(x0021〜0x007e)を
     モナーフォントからコピー
   - ビットマップフォント12〜16pixelのひらがなとカタカナ(0x3041〜0x30f6)
     をモナーフォントからコピー
   - ビットマップフォント10〜11pixelに10pixelのM+ Fontを埋め込み
   - 未定義だった0x301cに0xff5e(〜:波線)のデータをコピー
   - 0x00a1-0x00ff間で未定義の文字をさざなみゴシックからコピーして微調整
   - 0x2661(白抜きハート)と0x2665(塗りつぶしハート)をさざなみフォントから
     コピーして調整
   - 高さと深さをMS P ゴシックに近くなるよう調整
   - "',:;~の字形をAAに適したものに調整
   - ○付き文字を追加(Mitsuya Shibataさんの提供)
 * IPA モナー P 明朝
   - フォント幅をMS P 明朝の幅に近くなるよう調整
   - 幅を変更したアウトラインフォントの微調整
   - ビットマップフォント12〜16pixelをさざなみフォントに含まれるフォントに
     変更
   - ビットマップフォント10〜11pixelに10pixelのM+ Fontを埋め込み
   - 未定義だった0x301cに0xff5e(〜:波線)のデータをコピー
   - 0x00a1-0x00ff間で未定義の文字をさざなみ明朝からコピーして微調整
   - 0x2661(白抜きハート)と0x2665(塗りつぶしハート)をさざなみフォントから
     コピーして調整
   - 高さと深さをMS P 明朝に近くなるよう調整
   - ○付き文字を追加(Mitsuya Shibataさんの提供)
 * IPA モナー ゴシック
   - 12pixelのビットマップフォントを13pixelとしてコピー
   - 14pixelのビットマップフォントを15pixelとしてコピー
   - ビットマップフォント10〜11pixelに10pixelのM+ Fontを埋め込み
   - 未定義だった0x301cに0xff5e(〜:波線)のデータをコピー
   - 0x00a1-0x00ff間で未定義の文字をさざなみゴシックからコピーして微調整
   - 0x2661(白抜きハート)と0x2665(塗りつぶしハート)をさざなみフォントから
     コピーして調整
   - 高さと深さをMS ゴシックに近くなるよう調整
   - ○付き文字を追加(Mitsuya Shibataさんの提供)
 * IPA モナー 明朝
   - ビットマップフォント12〜16pixelをさざなみフォントに含まれるフォントに
     変更
   - ビットマップフォント10〜11pixel10pixelのM+ Fontを埋め込み
   - 未定義だった0x301cに0xff5e(〜:波線)のデータをコピー
   - 0x00a1-0x00ff間で未定義の文字をさざなみ明朝からコピーして微調整
   - 0x2661(白抜きハート)と0x2665(塗りつぶしハート)をさざなみフォントから
     コピーして調整
   - 高さと深さをMS 明朝に近くなるよう調整
   - ○付き文字を追加(Mitsuya Shibataさんの提供)
 * IPA モナー UI ゴシック
   - 12pixelのビットマップフォントを13pixelとしてコピー
   - 14pixelのビットマップフォントを15pixelとしてコピー
   - 未定義だった0x301cに0xff5e(〜:波線)のデータをコピー
   - 0x00a1-0x00ff間で未定義の文字をさざなみゴシックからコピーして微調整
   - 0x2661(白抜きハート)と0x2665(塗りつぶしハート)をさざなみフォントから
     コピーして調整
   - 高さと深さをMS UI ゴシックに近くなるよう調整
   - ○付き文字を追加(Mitsuya Shibataさんの提供)
