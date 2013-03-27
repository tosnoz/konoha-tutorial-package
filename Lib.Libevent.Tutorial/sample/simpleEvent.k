/*
 * Lib.Libevent signal handler
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

void main() {
	event_base evBase = new event_base();

	//signal event
	event sighup = new event(evBase, 1 /*HUP*/, signal_handler, evBase);
	sighup.event_add(NULL);
	event sigterm = new event(evBase, 15 /*TERM*/, signal_handler, evBase);
	sigterm.event_add(NULL);

	evBase.event_dispatch();
}

main();
