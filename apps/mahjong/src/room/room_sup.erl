%%%-------------------------------------------------------------------
%%% @author feng.liao
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 07. 三月 2019 上午9:59
%%%-------------------------------------------------------------------
-module(room_sup).
-author("feng.liao").

-behaviour(supervisor).

%% API
-export([start_link/0]).

%% Supervisor callbacks
-export([init/1,
    get_count/0]).

-define(SERVER, ?MODULE).

%%%===================================================================
%%% API functions
%%%===================================================================

start_link() ->
    supervisor:start_link({local, ?SERVER}, ?MODULE, []).

%%%===================================================================
%%% Supervisor callbacks
%%%===================================================================

init([]) ->

    SupFlags = {simple_one_for_one, 1000, 3600},
    AChild = {undefined, {room_srv, start_link, []},
        temporary, brutal_kill, worker, [room_srv]},

    {ok, {SupFlags, [AChild]}}.

%% 返回房间进程数
get_count() ->
    L = supervisor:count_children(?MODULE),
    {workers, Count} = lists:keyfind(workers, 1, L),
    Count.
