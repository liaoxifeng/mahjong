%%%-------------------------------------------------------------------
%% @doc mahjong top level supervisor.
%% @end
%%%-------------------------------------------------------------------

-module(mahjong_sup).

-include("common.hrl").

-behaviour(supervisor).

%% API
-export([start_link/0, start_child/1]).

%% Supervisor callbacks
-export([init/1]).

-define(SERVER, ?MODULE).

%% Helper macro for declaring children of supervisor
-define(CHILD(I, Type), {I, {I, start_link, []}, permanent, 5000, Type, [I]}).

%%====================================================================
%% API functions
%%====================================================================

start_link() ->
    case supervisor:start_link({local, ?SERVER}, ?MODULE, []) of
        {ok, _} = Ret ->
            %% init something
            do_start(),
            Ret;

        OtherRet ->
            OtherRet
    end.

%%====================================================================
%% Supervisor callbacks
%%====================================================================

%% Child :: #{id => Id, start => {M, F, A}}
%% Optional keys are restart, shutdown, type, modules.
%% Before OTP 18 tuples must be used to specify a child. e.g.
%% Child :: {Id,StartFunc,Restart,Shutdown,Type,Modules}
init([]) ->
    {ok, { {one_for_all, 5, 10},
        [
            ?CHILD(mahjong_init, worker),
            ?CHILD(room_mgr_srv, worker)
        ]} }.

%%====================================================================
%% Internal functions
%%====================================================================

%% 启动 app 各模块
do_start() ->
    ok = start_player_sup(),
    ok.

%% 开启用户进程监控树
start_player_sup() ->
    {ok,_} = supervisor:start_child(?MODULE,
        {player_sup,
            {player_sup, start_link,[]},
            transient, infinity, supervisor, [player_sup]}),
    ok.

start_child(Spec) ->
    supervisor:start_child(?MODULE, Spec).