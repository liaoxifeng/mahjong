%% =========================
%% @doc 全局的定义
%% =========================
-ifndef(__COMMON_HRL__).
-define(__COMMON_HRL__, true).

-include("log.hrl").
-define(undefined, undefined).
-define(map_name, map_name).


%% 订单号
-record(mn_id, {
    key,
    value
}).

%% 玩家信息
-record(mn_player, {
    id,
    svn = 1,
    info = #{}
}).

-endif.