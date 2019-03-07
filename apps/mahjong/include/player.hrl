%%%-------------------------------------------------------------------
%%% @author feng.liao
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 06. 三月 2019 下午3:52
%%%-------------------------------------------------------------------
-ifndef(__PLAYER_HRL__).
-define(__PLAYER_HRL__, true).

-include("common.hrl").

-author("feng.liao").

%% 玩家web socket 状态
-define(player_ws_state, player_state).
-type player_ws_state() :: #{
    ?map_name  => ?player_ws_state,
    id         => binary(),             %% 玩家id
    username   => binary(),             %% 昵称
    player_pid => pid()                 %% 进程pid

    }.


%% 玩家的游戏状态
-define(player_game, player_game).
-type player_game() :: #{
    ?map_name => ?player_game,
    sub_type => integer(),              %% 游戏类型子id
    bo_game_id => integer(),            %% 后台游戏id
    cfg_mod => atom(),                  %% 配置是哪个module
    extra_game => #{},                  %% 额外免费游戏
    last_op_ts_ms => integer()          %% 最后一次操作时间戳，单位ms
    }.

%% 玩家状态
-define(player_state, player_state).
-type player_state() :: #{
    ?map_name => ?player_state,
    id => binary(),                     %% 玩家id
    web_socket_pid => atom() | pid(),   %% websocket pid
    %%    agent_id => integer(),              %% 代理id
    username => binary(),               %% 昵称
    money => integer(),                 %% 余额
    room_id => integer(),               %% 当前房间id
    room_pid => pid() | undefined,      %% 当前房间pid
    game_id => integer(),               %% 当前游戏id
    bo_game_id => integer(),            %% 当前游戏后台id
    other => map()
    }.

-export_type([player_ws_state/0, player_game/0, player_state/0]).

-endif.
