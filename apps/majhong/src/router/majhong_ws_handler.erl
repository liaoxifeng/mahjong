%%%-------------------------------------------------------------------
%%% @author feng.liao
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 26. 二月 2019 下午5:18
%%%-------------------------------------------------------------------

-module(majhong_ws_handler).

-include("common.hrl").

-author("feng.liao").

-export([init/2]).
-export([websocket_init/1]).
-export([websocket_handle/2]).
-export([websocket_info/2]).

init(Req, _Opts) ->
    ?PRINT("connet success"),
    State = #{},
    {cowboy_websocket, Req, State}.

websocket_init(State) ->
    {ok, State}.

websocket_handle({text, Msg}, State) ->
    {reply, {text, << "That's what she said! ", Msg/binary >>}, State};

websocket_handle({binary, Msg}, State) ->
    {MsgPkg, _} = pt:decode_msg(Msg),
    ?PRINT("server received: ~p", [element(1, MsgPkg)]),
    MsgBin = client_hdl:do(MsgPkg),
    {reply, {binary, MsgBin}, State};

websocket_handle(_Data, State) ->
    {ok, State}.

websocket_info({timeout, _Ref, Msg}, State) ->
    erlang:start_timer(1000, self(), <<"How' you doin'?">>),
    {reply, {text, Msg}, State};

websocket_info({binary, Msg}, State) ->
    {MsgBin, _} = pt:decode_msg(Msg),
    {reply, {binary, MsgBin}, State};

websocket_info(_Info, State) ->
    {ok, State}.
