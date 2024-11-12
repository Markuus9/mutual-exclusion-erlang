-module(paul).
-export([start/3, stop/0]).

start(Lock, Sleep, Work) ->
    register(l4, spawn(Lock, init,[4, [{l1,'Ringo@127.0.0.1'},{l2,'John@127.0.0.1'},{l3,'George@127.0.0.1'}]])),
    register(paul, spawn(worker, init, ["Paul", l4,13,Sleep,Work])),
    ok.

stop() ->
    paul ! stop,
    l4 ! stop.
