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

-define(DBG(Fmt), lager:debug([], Fmt, [])).
-define(DBG(Fmt, Args), lager:debug([], Fmt, Args)).

-define(INF(Fmt), lager:info([], Fmt, [])).
-define(INF(Fmt, Args), lager:info([], Fmt, Args)).

-define(NTC(Fmt), lager:notice([], Fmt, [])).
-define(NTC(Fmt, Args), lager:notice([], Fmt, Args)).

-define(WRN(Fmt), lager:warning([], Fmt, [])).
-define(WRN(Fmt, Args), lager:warning([], Fmt, Args)).

-define(ERR(Fmt), lager:error([], Fmt, [])).
-define(ERR(Fmt, Args), lager:error([], Fmt, Args)).

-define(CRT(Fmt), lager:critical([], Fmt, [])).
-define(CRT(Fmt, Args), lager:critical([], Fmt, Args)).

-define(ALT(Fmt), lager:alert([], Fmt, [])).
-define(ALT(Fmt, Args), lager:alert([], Fmt, Args)).

-define(EMG(Fmt), lager:emergency([], Fmt, [])).
-define(EMG(Fmt, Args), lager:emergency([], Fmt, Args)).

%% ClassReason :: {atom(), term()}
-define(ERR_ST(Fmt, Args, ClassReason),
    lager:error(
        [],
        Fmt ++ "~nStacktrace:~s",
        Args ++ [lager:pr_stacktrace(erlang:get_stacktrace(), ClassReason)])).

-define(PRINT(Fmt), io:format("~w:~w| " ++ Fmt ++ "~n", [?MODULE, ?LINE])).
-define(PRINT(Fmt, Args), io:format("~w:~w| " ++ Fmt ++ "~n", [?MODULE, ?LINE|Args])).


-endif.
