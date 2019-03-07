%%%-------------------------------------------------------------------
%%% @author feng.liao
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 06. 三月 2019 下午8:03
%%%-------------------------------------------------------------------

-module(web_test).

-include("common.hrl").

-author("feng.liao").

%% API
-compile([export_all, nowarn_export_all]).

%% 分发help
dispatch(<<"help">>) ->
    <<
        "Command\t<br>"
        "<br>------- Help ------<br>"
        "help<br>"
        "&nbsp;&nbsp;Return help infomation<br>"
    >>;
dispatch(<<"ping">>) ->
    <<
        "ping"/utf8
    >>;
dispatch(_) ->
    <<"unkonwn cmd"/utf8>>.

%% 获取参数
get_args(ArgsBin) ->
    Tokens = string:tokens(binary_to_list(ArgsBin), [$ , $\t]),
    Tokens.

get_opts([ArgNameStr, ArgStr| Tokens], Res) ->
    ArgName = list_to_atom(ArgNameStr),
    get_opts(Tokens, Res#{ArgName => ArgStr});
get_opts([], Res) ->
    Res.

%% 取机器cpu核数
get_cpu_core_count() ->
    try erlang:system_info(logical_processors)
    catch _:_ -> 1
    end.

