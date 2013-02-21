Tutorial2 メソッドを定義する

TODO 「バインド関数」→「グルー関数」
先頭で用語の説明

Tutorial2ではパッケージ内でC/C++で記述されたメソッドを定義する方法について述べます。

Tutorial2ではコールバック関数を対象としていません。複雑なケースはLib.Tutorial5を参照してください。

目次
1. Konoha言語の型, C言語の型
2. バインド関数の作成
3. Konoha言語への登録

1. Konoha言語の型, C言語の型
C/C++言語でKonoha言語のメソッドを記述する場合、最も気を付けなければならない点はKonoha言語とC言語の間でデータ表現の違いです。
まずはじめにKonoha言語とC言語でのデータ表現の違いについて説明します。
Konoha言語ではプログラム記述にはboolean型、int型, String型, Array型などが利用できます。また、Type.Floatパッケージを利用することでfloat型の利用も可能となっています。

TODO
Konohaのデータ型とスタックからのアクセス方法
K_FRAME_MEMBER	- defined in "include/konoha3/konoha.h"

KReturnマクロ - defined in "include/konoha3/konoha.h"
KReturn(o):	オブジェクト
KReturnUnboxValue(d):	 基本型
KReturnVoid():	なし
KReturnWith(VAL, CLEANUP) - JavaScript.Array/Array_glue.c, JavaScript.Regexp/Regexp_glue.c で使用されている
KReturnFloatValue(c):	float型(TODO check 受け取る側は Type.Float パッケージが必要？)

2. バインド関数の作成
実行中のKonohaはバインド関数を呼び出し、バインド関数からC/C++ライブラリ関数を呼び出すという流れになります。
これがバインド関数の実装の手順です。
 1. Konoha スタックからの引数の取得
 2. C/C++ 外部ライブラリ関数を呼び出し
 3. 返り値をKonoha言語のデータ型からC言語の型へ変換する。

それではC言語で定義された関数に含まれるhello_world関数をSystemクラスのhello_worldメソッドにバインドする例を示します。

今回の例で利用するhello_world関数は"Hello world"とn回出力する関数で、以下のインタフェースを持ちます。
 int hello_world(int n);

 この関数を呼び出すためのバインド関数は以下のようになります。

/*
1 KMETHOD System_hello_world(KonohaContext *kctx, KonohaStack *sfp)
2 {
3     int n = sfp[1].intValue;
4     int ret = hello_world(n);
5     KReturnUnboxValue(ret);
6 }
*/


 まず１行目では。System_hello_world関数を開始しています。
この関数がC/C++ライブラリ関数hello_worldを呼び出すためのバインド関数です。
 後に説明しますが、バインド関数はすべてこの関数と同じインタフェース(引数にKonohaContext*型, KonohaStack*型、返り値がKMETHODの関数型)を持っています。
 ２、３行目ではKonoha VMから受け取った引数(Konoha言語のint型)をC言語のint型に変換して、ローカル変数nに保持します。 ４行目では、そのローカル変数を引数として、hello_world関数を呼び出します。返り値は、ローカル変数retに保存されます。 ５行目では、ローカル変数retをKonoha言語のint型に変換して、VMに返しています。

TODO sfp[1].asBytes の説明
System.read(fd, buf, size);
sfp[0]: this
sfp[1]: int f = sfp[1].intValue;
sfp[2]: kBytes *buf = sfp[2].asBytes;
sfp[3]: int s = sfp[3].intValue;

TODO 返り値説明追加、メンバ変数とのデータのやりとり


3. Konoha言語への登録
先ほど示したSystem_hello_world関数はC言語の世界で定義された関数です。
Konohaで利用できるようにするためにはKonoha側に、バインド関数で利用する引数、返り値の情報を通知する必要があります。
バインド関数のKonohaへの登録はpackupNameSpace関数にて行われます。

1 static kbool_t Tutorial2_PackupNameSpace(KonohaContext *kctx, kNameSpace *ns, int option, KTraceInfo *trace)
2 {
3 	KDEFINE_METHOD MethodData[] = {
4 		_Public|_Im, _F(System_hello_world), KType_int, KType_System, KMethodName_("hello_world"), 1, KType_int, KFieldName_("n"),
4 		DEND,
5 	};
6 	KLIB kNameSpace_LoadMethodData(kctx, ns, MethodData, trace);
7 	return true;
8 }

3行目から5行目までがこのパッケージで定義されるメソッドのリストを示しています。
今回の例では以下のKonohaメソッドを1つ定義しています。
@Public @Immutable int System.hello_world(int n);

Konohaメソッドを登録するデータ構造MethodDataは以下のフォーマットとなっています。
アノテーション , バインド関数のアドレス , 返り値の型 , Thisの型 , メソッド名 , 引数の数, 第1引数の型, 第1引数の型, 第2引数の型, 第2引数の型...

最後にkNameSpace_LoadMethodData()によりメソッドの定義リストをNameSpaceに登録することでメソッドの呼び出しが可能となります。

>>> import("Lib.Tutorial2")
>>> System.hello_world(3)
    hello world!
    hello world!
    hello world!
    (int) 3


_Public, _Imはメソッドに付与されたアノテーションを意味します。
メソッドには必ず0個以上のアノテーションを付与します。今回の場合、@Public @Immutableのアノテーションを付与しています。
メソッドに付与可能なアノテーションは以下のとおりです。
_Public   ... @Public
_Final    ... @Final
_Const    ... @Const
_Static   ... @Static
_Im       ... @Immutable
_Coercion ... @Coercion
_Hidden   ... @Hidden
_Virtual  ... @Virtual
_Ignored  ... @IgnoredOverride

FIXME 各アノテーションの説明

    _Im：thisが変化しない
    _Const：引数が同じ場合，同じ物を返す
    _Coercion：引数が自動的にキャストされる
    _Public：クラス外部からのアクセスを許可する
    _Static：インスタンス化せずにメソッドを呼び出すことを許可する
    _Private：クラス外部からのアクセスを禁止する

