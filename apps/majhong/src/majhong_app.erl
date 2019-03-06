%%%-------------------------------------------------------------------
%% @doc majhong public API
%% @end
%%%-------------------------------------------------------------------

-module(majhong_app).

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
            {"/", majhong_ws_handler, []},

            %% for test
            {"/home", cowboy_static, {priv_file, majhong, "index.html"}},
            {"/static/[...]", cowboy_static, {priv_dir, majhong, "static"}}
        ]}
    ]),
    {ok, Port} = application:get_env(majhong, port),
    ?PRINT("cowboy listen ~p port", [Port]),
    {ok, _} = cowboy:start_clear(http, [{port, Port}], #{
        env => #{dispatch => Dispatch}
    }),
    majhong_sup:start_link().

%%--------------------------------------------------------------------
stop(_State) ->
    ok.

%%====================================================================
%% Internal functions
%%====================================================================
