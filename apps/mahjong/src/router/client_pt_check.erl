%%%-------------------------------------------------------------------
%%% @author feng.liao
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 06. 三月 2019 下午8:03
%%%-------------------------------------------------------------------

-module(client_pt_check).

-include("common.hrl").
-include("pt_common.hrl").

-author("feng.liao").

%% API
-export([before_dispatch/2]).

%% 分发前检查。包括可在此阶段检查的参数，和其他

-spec before_dispatch(
        ProtoMsg :: tuple(),
        State :: map()) ->
    true | error | {error, Code :: atom()}.

%% 处理登录
before_dispatch(#'C2S_Login'{}, State) ->
    case maps:find(player_pid, State) of
        {ok, PlayerPid} when is_pid(PlayerPid) ->
            %% 已登录
            error;
        error ->
            true
    end;

%% 没有写规则的自动通过
before_dispatch(_Msg, _State) ->
    true.

