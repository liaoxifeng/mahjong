%%%-------------------------------------------------------------------
%%% @author feng.liao
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%% 玩家进程处理逻辑
%%% @end
%%% Created : 06. 三月 2019 下午3:46
%%%-------------------------------------------------------------------

-module(player_hdl).

-author("feng.liao").

%% API
-export([on_terminate/2,
    on_ws_terminate/2]).


on_terminate(Reason, State) ->
    ok.

on_ws_terminate(State, Pid) ->
    ok.