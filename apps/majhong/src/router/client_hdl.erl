%%%-------------------------------------------------------------------
%%% @author feng.liao
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 06. 三月 2019 上午10:10
%%%-------------------------------------------------------------------

-module(client_hdl).

-include("common.hrl").
-include("pt_common.hrl").

-author("feng.liao").

%% API
-export([do/1]).

do(MsgPkg) ->
    case MsgPkg of
        #'C2S_Heartbeat'{} ->
            pt:encode_msg(pt_common, #'S2C_Heartbeat'{});
        _ ->
            pt:encode_msg(pt_common, MsgPkg)
    end.