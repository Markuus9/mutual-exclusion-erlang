-module(muty).
-export([start/3, stop/0]).

start(Lock, Sleep, Work) ->
    register(l1, spawn(Lock, init,[1, [l2,l3,l4]])),
    register(l2, spawn(Lock, init,[2, [l1,l3,l4]])),
    register(l3, spawn(Lock, init,[3, [l1,l2,l4]])),
    register(l4, spawn(Lock, init,[4, [l1,l2,l3]])),
    register(ringo, spawn(worker, init, ["Ringo", l1,10,Sleep,Work])),
    register(john, spawn(worker, init, ["John", l2,11,Sleep,Work])),
    register(george, spawn(worker, init, ["George", l3,12,Sleep,Work])),
    register(paul, spawn(worker, init, ["Paul",l4,13,Sleep,Work])),
    ok.

stop() ->
    ringo ! stop,
    john ! stop,
    george ! stop,
    paul ! stop,
    l1 ! stop,
    l2 ! stop,
    l3 ! stop,
    l4 ! stop.
