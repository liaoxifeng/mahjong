%%%-------------------------------------------------------------------
%%% @author feng.liao
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 14. 十二月 2018 上午10:47
%%%-------------------------------------------------------------------

-module(pt).

-include("common.hrl").

-author("feng.liao").

%% API
-export([encode_msg/2, encode_msg/3, decode_msg/1]).

%% 打包协议
encode_msg(PtMod, Msg) -> encode_msg(PtMod, Msg, []).

encode_msg(PtMod, Msg, Opts) ->
    Body = PtMod:encode_msg(Msg, Opts),
    BodyLen = byte_size(Body),
    Name = iolist_to_binary([atom_to_list(PtMod), ".", atom_to_list(element(1, Msg)), "\0"]),
    NameLen = byte_size(Name),
    Len = 4 + 1 + NameLen + BodyLen,
    <<Len:32/little, NameLen:8, Name/binary, Body/binary>>.

%% 解包协议
decode_msg(<<Len:32/little, NameLen:8, NameBin:NameLen/binary, LeftBin/binary>>) ->
    BodyLen = Len - 4 - 1 - NameLen,
    <<Body:BodyLen/binary, OtherBin/binary>> = LeftBin,
    {PtModStr, [_|MsgNameStr0]} = lists:splitwith(fun(I) -> I =/= $. end, binary_to_list(NameBin)),
    MsgNameStr = lists:delete($\0, MsgNameStr0),
    PtMod = list_to_atom(PtModStr),
    MsgName = list_to_atom(MsgNameStr),
    {PtMod:decode_msg(Body, MsgName), OtherBin}.