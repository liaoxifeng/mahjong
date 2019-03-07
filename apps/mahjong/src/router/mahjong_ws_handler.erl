%%%-------------------------------------------------------------------
%%% @author feng.liao
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 26. 二月 2019 下午5:18
%%%-------------------------------------------------------------------

-module(mahjong_ws_handler).

-include("common.hrl").
-include("player.hrl").

-author("feng.liao").

-export([init/2]).
-export([websocket_init/1]).
-export([websocket_handle/2]).
-export([websocket_info/2]).

init(Req, Opts) ->
    ?INF("connet success"),
    {cowboy_websocket, Req, Opts}.

websocket_init(_State) ->
    State = #{?map_name => ?player_ws_state},
    ?INF("erlang:list_to_pid(\"~p\") ", [self()]),
    rand:seed(exs1024),
    {ok, State}.

websocket_handle({text, Msg}, State) ->
    ReplyBin = web_test:dispatch(Msg),
    {reply, {text, << ReplyBin/binary >>},State};

websocket_handle({binary, MsgBin}, State) ->
    {Msg, _} = pt:decode_msg(MsgBin),
    ?INF("server received: ~p", [Msg]),
    case client_pt_check:before_dispatch(Msg, State) of
        true ->
            client_hdl:dispatch(Msg, State);
        _ ->
            ReplyBin = <<"已登录">>,
            {reply, {binary, ReplyBin}, State}
    end;

websocket_handle(_Data, State) ->
    {ok, State}.

websocket_info(_Info, State) ->
    {ok, State}.
