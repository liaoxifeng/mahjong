-ifndef(__room_hrl__).
-define(__room_hrl__, true).

-include("common.hrl").
-include("mahjong.hrl").
-include("pt_room.hrl").

-define(room_state, room_state).
-type room_state() :: #{
    ?map_name => ?room_state,
    id  => integer(),            %% 房间id
    roomname => binary(),        %% 昵称
    room_pid => pid(),            %% 进程pid

    islock  => boolean(),        %%是否上锁
    owner   => binary(),         %%拥有者
    secret  => binary(),         %%密码
    moneybase   => non_neg_integer(), %%注基数
    moneymulti =>  non_neg_integer(), %%倍数

    %%game_type => game_type(),           %% 房间游戏类型
    game_id => integer(),               %% 房间游戏id

    web_socket_pid => atom() | pid(),   %% websocket pid
    playercount => integer(),    %%玩家人数
    playerlist => [], %玩家列表

    play_type => [], %玩法
    mahjong_state => mahjong_state(),
    room_state => false            %false:游戏没开始  true：游戏中
}.

-define(room_mgr_state, room_mgr_state).
-type room_mgr_state() :: #{
    ?map_name => ?room_mgr_state
}.

-export_type([room_state/0, room_mgr_state/0]).

-endif.








