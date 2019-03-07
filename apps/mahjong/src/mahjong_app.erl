%%%-------------------------------------------------------------------
%% @doc mahjong public API
%% @end
%%%-------------------------------------------------------------------

-module(mahjong_app).

-include("common.hrl").

-behaviour(application).

%% Application callbacks
-export([start/2, stop/1]).

%%====================================================================
%% API
%%====================================================================


start(_StartType, _StartArgs) ->
    Dispatch = cowboy_router:compile([
        {'_', [
            {"/", mahjong_ws_handler, []},

            %% for test
            {"/home", cowboy_static, {priv_file, mahjong, "index.html"}},
            {"/static/[...]", cowboy_static, {priv_dir, mahjong, "static"}}
        ]}
    ]),
    {ok, Port} = application:get_env(mahjong, port),
    ?PRINT("cowboy listen on [~p]", [Port]),
    {ok, _} = cowboy:start_clear(http, [{port, Port},
        {delay_send, true}, {nodelay, true}], #{
        env => #{dispatch => Dispatch}
    }),
    mahjong_sup:start_link().

%%--------------------------------------------------------------------
stop(_State) ->
    ok.

%%====================================================================
%% Internal functions
%%====================================================================
