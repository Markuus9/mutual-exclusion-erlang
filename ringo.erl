-module(ringo).
-export([start/3, stop/0]).

start(Lock, Sleep, Work) ->
    register(l1, spawn(Lock, init,[1, [{l2,'John@127.0.0.1'},{l3,'George@127.0.0.1'},{l4,'Paul@127.0.0.1'}]])),
    register(ringo, spawn(worker, init, ["Ringo", l1,10,Sleep,Work])),
    ok.

stop() ->
    ringo ! stop,
    l1 ! stop.
