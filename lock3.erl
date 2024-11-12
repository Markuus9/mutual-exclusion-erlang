-module(lock3).
-export([init/2]).

init(_, Nodes) ->
    open(Nodes, 0).
    
open(Nodes, Time) ->
    receive
        {take, Master} ->
            Refs = requests(Nodes, Time),
            wait(Nodes, Master, Refs, [], Time, Time);
        {request, From, Ref, SenderTime} ->
            ActualTime = getTime(Time, SenderTime),
            From ! {ok, Ref, ActualTime},
            open(Nodes, ActualTime);
        stop ->
            ok
    end.

requests(Nodes, Time) ->
    lists:map(
        fun(P) ->
            R = make_ref(),
            P ! {request, self(), R, Time},
            R
        end,
        Nodes).

wait(Nodes, Master, [], Waiting, Time, _) ->
    Master ! taken,
    held(Nodes, Waiting, Time);

wait(Nodes, Master, Refs, Waiting, Time, RequestSentTime) ->
    receive
        {request, From, Ref, SenderTime} ->
            ActualTime = getTime(Time, SenderTime),
            if
                SenderTime < RequestSentTime ->
                    From ! {ok, Ref, ActualTime},
                    NewRef = requests([From], ActualTime),
                    wait(Nodes, Master, lists:merge(Refs, NewRef), Waiting, ActualTime, RequestSentTime);
                true ->
                    wait(Nodes, Master, Refs, [{From, Ref}|Waiting], ActualTime, RequestSentTime)
            end;
        {ok, Ref, SenderTime} ->
            ActualTime = getTime(Time, SenderTime),
            NewRef = lists:delete(Ref, Refs),
            wait(Nodes, Master, NewRef, Waiting, ActualTime, RequestSentTime);
        release ->
            ok(Waiting, Time),
            open(Nodes, Time)
    end.

ok(Waiting, Time) ->
    lists:map(
        fun({F,R}) ->
            F ! {ok, R, Time}
        end,
        Waiting).

held(Nodes, Waiting, Time) ->
    receive
        {request, From, Ref, SenderTime} ->
            ActualTime = getTime(Time, SenderTime),
            held(Nodes, [{From, Ref}|Waiting], ActualTime);
        release ->
            ok(Waiting, Time),
            open(Nodes, Time)
    end.

getTime(Time, SenderTime) -> lists:max([Time, SenderTime]) + 1.
