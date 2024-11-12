-module(john).
-export([start/3, stop/0]).

start(Lock, Sleep, Work) ->
    register(l2, spawn(Lock, init,[2, [{l1,'Ringo@127.0.0.1'},{l3,'George@127.0.0.1'},{l4,'Paul@127.0.0.1'}]])),
    register(john, spawn(worker, init, ["John", l2,11,Sleep,Work])),
    ok.

stop() ->
    john ! stop,
    l2 ! stop.
