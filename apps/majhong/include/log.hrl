%%%-------------------------------------------------------------------
%%% @author feng.liao
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%% 打印
%%% @end
%%% Created : 02. 三月 2019 下午2:12
%%%-------------------------------------------------------------------
-ifndef(__log_hrl__).
-define(__log_hrl__, true).

-define(PRINT(Fmt), io:format("~w:~w| " ++ Fmt ++ "~n", [?MODULE, ?LINE])).
-define(PRINT(Fmt, Args), io:format("~w:~w| " ++ Fmt ++ "~n", [?MODULE, ?LINE|Args])).

-endif.