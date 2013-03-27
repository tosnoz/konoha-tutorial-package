/*
 * Lib.Libevent simple handler(timer, signal)
 */
import("JavaStyle.Object");
import("cstyle");
import("Lib.Libevent");

void signal_handler(int sig, int evflag, Object arg) {
	event_base evBase = arg as event_base;
	System.p("signal_handler() executed!!");
	System.p("evBase = " + evBase);
	System.p("signal = " + sig + ", evflag = " + evflag);

	if (sig == 15) {
		evBase.event_loopbreak();
	}
}

void timer_handler_once(int fd, int evflag, Object arg) {
	event tev = arg as event;
	System.p("timer_handler_once() executed!!");
	System.p("tev = " + tev);
	System.p("timer = " + fd + ", evflag = " + evflag);
	tev.event_del();
}

void timer_handler_freq(int fd, int evflag, Object arg) {
	event tev = arg as event;
	System.p("timer_handler_freq() executed!!");
	System.p("tev = " + tev);
	System.p("timer = " + fd + ", evflag = " + evflag);
	
	tev.timer_add(new timeval(10, 0));
}

void main() {
	event_base evBase = new event_base();

	//signal event
	event sighup = new event(evBase, 1 /*HUP*/, signal_handler, evBase);
	sighup.event_add(NULL);
	event sigterm = new event(evBase, 15 /*TERM*/, signal_handler, evBase);
	sigterm.event_add(NULL);

	//timer event
	event tm1 = new event(evBase, timer_handler_once, NULL);
	tm1.timer_assign(evBase, timer_handler_once, tm1);	//set cbArg
	tm1.timer_add(new timeval(2, 0));

	event tm2 = new event(evBase, timer_handler_freq, NULL);
	tm2.timer_assign(evBase, timer_handler_freq, tm2);	//set cbArg
	tm2.timer_add(new timeval(10, 0));

	evBase.event_dispatch();
}

main();
