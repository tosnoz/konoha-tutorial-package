# Lib.Libevent パッケージ サンプルスクリプト

ここでは、Lib.Libevent パッケージを使用した Konoha スクリプトのサンプルを実際に動作させてみます。

## サンプルスクリプト(simpleEvent.k)
     1	/*
     2	 * Lib.Libevent signal handler
     3	 */
     4	import("JavaStyle.Object");
     5	import("cstyle");
     6	import("Lib.Libevent");
     7	
     8	void signal_handler(int sig, int evflag, Object arg) {
     9		event_base evBase = arg as event_base;
    10		System.p("signal_handler() executed!!");
    11		System.p("evBase = " + evBase);
    12		System.p("signal = " + sig + ", evflag = " + evflag);
    13	
    14		if (sig == 15) {
    15			evBase.event_loopbreak();
    16		}
    17	}
    18	
    19	void main() {
    20		event_base evBase = new event_base();
    21	
    22		//signal event
    23		event sighup = new event(evBase, 1 /*HUP*/, signal_handler, evBase);
    24		sighup.event_add(NULL);
    25		event sigterm = new event(evBase, 15 /*TERM*/, signal_handler, evBase);
    26		sigterm.event_add(NULL);
    27	
    28		evBase.event_dispatch();
    29	}
    30	
    31	main();

## サンプルスクリプト概要
サンプルスクリプトの概要について説明します。

ここでは Konoha および libevent についての基本的な知識は持っているものとして説明していきます。
libevent 詳細については、[http://www.wangafu.net/~nickm/libevent-book/](http://www.wangafu.net/~nickm/libevent-book/) をご覧ください。

サンプルスクリプトは、次のメソッドで構成されています。

<table border=1 align=center class="inline">
	<tr align=center>
		<th> メソッド </th>
		<th> 概要 </th>
	</tr>
	<tr>
		<td> main() </td>
		<td> signal イベントハンドラ、timer イベントハンドラを登録し、libevent のイベントループに入ります。</td>
	</tr>
	<tr>
		<td> signal_handler() </td>
		<td> シグナルハンドリングメソッドです。登録したシグナルを受信すると Lib.Libevent パッケージから呼ばれるので、シグナル受信処理を記述します。</td>
	</tr>
</table>


## main() メソッド
main() メソッドでは、シグナルイベントおよびタイマーイベントの登録を行なっています。
その後、イベント待ち状態となり、イベント処理終了まで main()メソッドからは戻りません。

それではスクリプトを見ていきます。

20行で event_base evBase を作成します。
evBase は、28行で呼ばれている event_dispatch() メソッドが扱うイベントを保持しているいわゆる「イベントグループ」です。
evBase グループとして処理するべきイベントを登録していきます。

23行で、シグナル番号1(HUP)のイベントを生成しています。
evBase グループに(第一引数)、
* シグナルハンドラメソッドを signal_handler() (第二引数)
* ハンドラメソッドへ渡すユーザー指定の引数を evBase (第三引数)
として登録しています。

24行では、sighupのイベントを有効にしています。
引数には有効となるまでの遅延時間を timeval により指定しますが、ここでは NULL としているので即座に有効となります。

25,26行は、シグナル番号が15になる以外は、23,24行と同じです。
このサンプルではハンドラメソッドは同じものを使用していますが、別のハンドラメソッドを登録することも可能です。


28行の evBase.event_dispatch() で evBase に登録しているイベント待ちに入ります。
このメソッドは、evBase の待ちイベントが無くなるか、外部からevent_loopbreak() などを使用して待ち状態を解除するまではブロックされます。


## signal_handler() メソッド
signal_handler() メソッドは、その名の通りシグナル受信により呼び出される _ハンドラメソッド_ です。

9行は、ユーザーが任意に指定する arg を メソッド内でアクセスしやすいように event_base 型にキャストしています。
23,25行の "new event()" で指定したユーザー指定引数は event_base 型だったことに注意してください。

10-12行はこのハンドラの情報を標準出力に出力しています。
この情報表示により、スクリプトを実行してシグナル番号1(SIGHUP), 15(SIGTERM)を受信すると、次のような内容が標準出力に出力されます。

    - (simpleEvent.k:10) signal_handler() executed!!
    - (simpleEvent.k:11) evBase = &0x7fe9030f8b80
    - (simpleEvent.k:12) signal = 1, evflag = 8
	
    ※行頭の "- (simpleEvent.k:xx)" は Konoha が自動付与しているものです。

14-16行は シグナル番号15(SIGTERM) の場合の処理が記述されています。
SIGTERM の場合には15行の evBase.event_loopbreak() が実行されるため、main() メソッドの evBase.event_dispatch() から戻りそのまま main() メソッドは return するため、このスクリプトは終了します。
