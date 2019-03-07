%%%-------------------------------------------------------------------
%%% @author feng.liao
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%% ws_hdl
%%% @end
%%% Created : 06. 三月 2019 上午10:10
%%%-------------------------------------------------------------------

-module(client_hdl).

-include("common.hrl").
-include("pt_common.hrl").

-author("feng.liao").

%% API
-export([dispatch/2]).

%% 心跳
dispatch(#'C2S_Heartbeat'{}, State) ->
    ReplyBin = pt:encode_msg(pt_common, #'S2C_Heartbeat'{}),
    {reply, {binary, ReplyBin}, State};

%% 登录
dispatch(#'C2S_Login'{token = _Token}, State) ->
    LoginPkg = #'S2C_Login'{id = <<"1">>,
        nickname = <<"helloworld">>,
        money = 1000000},
    ReplyBin = pt:encode_msg(pt_common, LoginPkg),
    {reply, {binary, ReplyBin}, State};

dispatch(_Msg, State) ->

    {reply, error, State}.