# Lib.Libevent パッケージ サンプルスクリプト

ここでは、Lib.Libevent パッケージを使用した Konoha スクリプトのサンプルを実際に動作させてみます。

## サンプルスクリプト(simpleEvent.k)
     1  /*
     2   * Lib.Libevent simple handler(timer, signal)
     3   */
     4  import("JavaStyle.Object");
     5  import("cstyle");
     6  import("Lib.Libevent");
     7
     8  void signal_handler(int sig, int evflag, Object arg) {
     9          event_base evBase = arg as event_base;
    10          System.p("signal_handler() executed!!");
    11          System.p("evBase = " + evBase);
    12          System.p("signal = " + sig + ", evflag = " + evflag);
    13
    14          if (sig == 15) {
    15                  evBase.event_loopbreak();
    16          }
    17  }
    18
    19  void timer_handler_once(int fd, int evflag, Object arg) {
    20          event tev = arg as event;
    21          System.p("timer_handler_once() executed!!");
    22          System.p("tev = " + tev);
    23          System.p("timer = " + fd + ", evflag = " + evflag);
    24          tev.event_del();
    25  }
    26
    27  void timer_handler_freq(int fd, int evflag, Object arg) {
    28          event tev = arg as event;
    29          System.p("timer_handler_freq() executed!!");
    30          System.p("tev = " + tev);
    31          System.p("timer = " + fd + ", evflag = " + evflag);
    32
    33          tev.timer_add(new timeval(10, 0));
    34  }
    35
    36  void main() {
    37          event_base evBase = new event_base();
    38
    39          //signal event
    40          event sighup = new event(evBase, 1 /*HUP*/, signal_handler, evBase);
    41          sighup.event_add(NULL);
    42          event sigterm = new event(evBase, 15 /*TERM*/, signal_handler, evBase);
    43          sigterm.event_add(NULL);
    44
    45          //timer event
    46          event tm1 = new event(evBase, timer_handler_once, NULL);
    47          tm1.timer_assign(evBase, timer_handler_once, tm1);      //set cbArg
    48          tm1.timer_add(new timeval(2, 0));
    49
    50          event tm2 = new event(evBase, timer_handler_freq, NULL);
    51          tm2.timer_assign(evBase, timer_handler_freq, tm2);      //set cbArg
    52          tm2.timer_add(new timeval(10, 0));
    53
    54          evBase.event_dispatch();
    55  }
    56
    57  main();

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
	<tr>
		<td> timer_handler_once() <br>
			 timer_handler_freq() </td>
		<td rawspam="2"> タイマーハンドリングメソッドです。登録した時間を経過すると Lib.Libevent パッケージから呼ばれるので、タイマー処理を記述します。</td>
	</tr>
</table>


## main() メソッド
main() メソッドでは、シグナルイベントおよびタイマーイベントの登録を行なっています。
その後、イベント待ち状態となり、イベント処理終了まで main()メソッドからは戻りません。

それではスクリプトを見ていきます。

37行で event_base evBase を作成します。
evBase は、54行で呼ばれている event_dispatch() メソッドが扱うイベントを保持しているいわゆる「イベントグループ」です。
evBase グループとして処理するべきイベントを登録していきます。

40行で、シグナル番号1のイベントを生成しています。
evBase グループに(第一引数)、
* シグナルハンドラメソッドを signal_handler() (第二引数)
* ハンドラメソッドへ渡すユーザー指定の引数を evBase (第三引数)
として登録しています。

41行では、sighupのイベントを有効にしています。
引数には有効となるまでの遅延時間を timeval により指定しますが、ここでは NULL としているので即座に有効となります。

42,43行は、シグナル番号が15になる以外は、40,41行と同じです。
このサンプルではハンドラメソッドは同じものを使用していますが、別のハンドラメソッドを登録することも可能です。

以上で、シグナルイベントの登録は完了し、次はタイマーイベントの登録になります。

46 - 48行のタイマーイベントハンドラ登録では、ハンドラメソッドの引数として自分自身のイベント情報を渡すために、シグナルハンドラ登録に比べて1手順を追加しています。

46行の new event() で event tm1 を生成します。
signal イベントとの違いは
* タイマーハンドラメソッドとして timer_handler_once() メソッドを指定している
* ユーザー指定の引数として NULL を指定している(signal ハンドラ登録ではここでは evBase を指定)
となります。

47行の timer_assign() メソッドを使用して、ハンドラメソッドの引数を再設定しています。
第一、第二引数は "new event(...)" と同じですが、第三引数に "tm1" を指定していることに注意してください。

48行の timer_add() メソッドで、タイマー値を指定しています。
ここでは2秒を指定しています。

50-52行は、同じくタイマーハンドラ登録を行っていますが、ハンドラメソッドとタイマー値が異なります。

54行の evBase.event_dispatch() で evBase に登録しているイベント待ちに入ります。
このメソッドは、evBase の待ちイベントが無くなるか、外部からevent_loopbreak() などを使用して待ち状態を解除するまではブロックされます。


## signal_handler() メソッド
signal_handler() メソッドは、その名の通りシグナル受信により呼び出される _ハンドラメソッド_ です。

main() メソッドの 40, 42 行で次のように設定されています。

    40          event sighup = new event(evBase, 1 /*HUP*/, signal_handler, evBase);
    42          event sigterm = new event(evBase, 15 /*TERM*/, signal_handler, evBase);

9行は、ユーザーが任意に指定する arg を メソッド内でアクセスしやすいように event_base 型にキャストしています。
40,42行の "new event()" で指定したユーザー指定引数は event_base 型だったことに注意してください。

10-12行はこのハンドラの情報を標準出力に出力しています。
この情報表示により、スクリプトを実行して SIGHUP を受信すると、次のような内容が標準出力に出力されます。

    - (simpleEvent.k:14) signal_handler() executed!!
    - (simpleEvent.k:15) evBase = &0x7fb93c9fd180
    - (simpleEvent.k:16) signal = 1, evflag = 8
※行頭の "- (simpleEvent.k:xx)" は Konoha が自動付与しているものです。


14-16行は SIGTERM の場合の処理が記述されています。
SIGTERM の場合には15行の evBase.event_loopbreak() が実行されるため、main() メソッドの evBase.event_dispatch() から戻りそのまま main() メソッドは return するため、このスクリプトは終了します。

## timer_handler_once() メソッド
timer_handler_once() メソッドは、設定後、一度だけ起動するタイマーイベントハンドラのサンプルです。

main() メソッド 46-47行で次のように指定されています。

    46          event tm1 = new event(evBase, timer_handler_once, NULL);
    47          tm1.timer_assign(evBase, timer_handler_once, tm1);      //set cbArg

20行は signal_handler() と同様に arg をメソッド内で使いやすいようにキャストしています。

21-23行は、このハンドラの情報を標準出力に出力しています。
起動して2秒後にこのハンドラが呼ばれて、次のように出力されます。

    - (simpleEvent.k:25) timer_handler_once() executed!!
    - (simpleEvent.k:26) tev = &0x7fb93c9fd240
    - (simpleEvent.k:27) timer = -1, evflag = 1

24行で、このイベントは不要となるので、 event_del() によりイベントを削除しています。


## timer_handler_freq() メソッド
timer_handler_freq() メソッドは、設定後、一定周期で起動するタイマーイベントハンドラのサンプルです。

main() メソッド 50-51行で次のように指定されています。

    50          event tm2 = new event(evBase, timer_handler_freq, NULL);
    51          tm2.timer_assign(evBase, timer_handler_freq, tm2);      //set cbArg

timer_handler_once() メソッドとほとんど同じですが、timer_handler_freq() では最後が event_del() ではなく timer_add() となっています。
これにより、指定時間後に再度呼ばれることとなります。

このスクリプトを起動すると以下の出力が10秒周期で繰り返されます。

    - (simpleEvent.k:33) timer_handler_freq() executed!!
    - (simpleEvent.k:34) tev = &0x7fb93c9fd2c0
    - (simpleEvent.k:35) timer = -1, evflag = 1

