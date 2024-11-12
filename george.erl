-module(george).
-export([start/3, stop/0]).

start(Lock, Sleep, Work) ->
    register(l3, spawn(Lock, init,[3, [{l1,'Ringo@127.0.0.1'},{l2,'John@127.0.0.1'},{l4,'Paul@127.0.0.1'}]])),
    register(george, spawn(worker, init, ["George",l3,12,Sleep,Work])),
    ok.

stop() ->
    george ! stop,
    l3 ! stop.
