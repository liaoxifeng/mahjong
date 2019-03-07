%%%-------------------------------------------------------------------
%%% @author feng.liao
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%     unit testing
%%% @end
%%% Created : 13. 八月 2018 13:59
%%%-------------------------------------------------------------------

-module(unit_test).

-ifdef(TEST).

-author("feng.liao").

-include("common.hrl").
-include("mahjong.hrl").
-include("room.hrl").
-include("pt_mahjong.hrl").
-include_lib("eunit/include/eunit.hrl").

%%length_test() -> ?assert(1 =:= 2).
%%length1_test() -> 1 =:= 2.
%%length2_test() -> 1 = 2.
%%length3_test() -> 1 = 1.
%%length4_test() -> false.
%%length5_test() -> ?assert(1 = 1).
%%length6_test() -> ?assert(1 = 2).
%%
%%
%%
%%
%%start_room_test() ->
%%    {ok, RoomPid} = room_srv:start_link([{1, 2, "123", 1, 1, true,"1"}]),

















%% kong测试
%% [discard, DiscardId, CardId],
%% [draw, DrawId, CardId]
kong_test() ->
    L  = [1,1,1,1,2,2,2,3,3,3,4,4,4],
    L1 = [5,1,1,1,1,2,2,2,3,3,3,4,4,4],       %% 摸 5
    L2 = [1,1,1,1,2,2,2,3,3,3,4,4,4,4],       %% 摸 1
    L3 = [1,1,1,1,3,3,3,4,4,4,4],             %% 摸 2
    ?MAHJONG_MINGGANG = mahjong_tool:can_kong([discard, 4, 3], 3, [], L),
    ?MAHJONG_ZHAGANG  = mahjong_tool:can_kong([discard, 4, 3], 4, [], L),
    ?MAHJONG_ZHAGANG  = mahjong_tool:can_kong([discard, 4, 5], 5, [], L),
    ?MAHJONG_ZHAGANG  = mahjong_tool:can_kong([discard, 4, 5], 1, [], L),
    ?MAHJONG_ZHAGANG  = mahjong_tool:can_kong([discard, 4, 5], 2, [], L),
    ?MAHJONG_ANGANG   = mahjong_tool:can_kong([draw, 4, 5], 1, [], L1),
    ?MAHJONG_ANGANG   = mahjong_tool:can_kong([draw, 4, 1], 1, [], L2),
    ?MAHJONG_ZHAGANG  = mahjong_tool:can_kong([draw, 4, 5], 2, [], L1),
    ?MAHJONG_ANGANG   = mahjong_tool:can_kong([draw, 4, 1], 4, [], L2),
    ?MAHJONG_BUGANG   = mahjong_tool:can_kong([draw, 4, 2], 2, [[2,0,3]], L3),
    ?MAHJONG_ANGANG   = mahjong_tool:can_kong([draw, 4, 2], 1, [[2,0,3]], L3),
    ?MAHJONG_ZHAGANG  = mahjong_tool:can_kong([draw, 4, 2], 3, [[2,0,3]], L3).

%% pong测试
pong_test() ->
    L = [1,1,1,2,2,2,3,3,3,4,4,4,5],
    L1 = [1,1,1,2,2,2,3,3,3,4,4,4,5,5],
    false = mahjong_tool:can_pong(1, [discard, 4, 11], L),
    false = mahjong_tool:can_pong(11,[discard, 4, 11], L),
    false = mahjong_tool:can_pong(11,[discard, 4, 1], L),
    false = mahjong_tool:can_pong(2, [discard, 4, 1], L),
    true  = mahjong_tool:can_pong(1, [discard, 4, 1], L),
    false = mahjong_tool:can_pong(1, [draw, 4, 1], L1),
    false = mahjong_tool:can_pong(11,[draw, 4, 1], L1),
    false = mahjong_tool:can_pong(2, [draw, 4, 1], L1).

%% 出牌测试
discard_test() ->
    L = [1,1,1,1,2,2,2,2,3,3,3,3,4,4],
    false = mahjong_tool:discard(L, 11),
    {ok, [1,1,1,1,2,2,2,2,3,3,3,4,4]} = mahjong_tool:discard(L, 3).

%% 自动选择定缺花色测试
auto_dingque_test() ->
    L1  = [1,2,3,11,11,11,12,15,21,21,21,22,24],
    L2  = [11,11,11,12,15,16,17,18,21,21,21,22,24],
    L3  = [1,2,3,5,11,12,14,15,21,22,23,24,25],
    _L4 = [1,3,4,5,11,13,14,15,21,22,23,24,25],
    _L5 = [1,1,1,1,2,2,2,2,3,3,3,3,4],
    ?MAHJONG_CARD_TYPE_CHARACTER = mahjong_tool:auto_dingque_hdl(L1),                           %% 选择牌少的花色
    ?MAHJONG_CARD_TYPE_CHARACTER = mahjong_tool:auto_dingque_hdl(L2),                           %% 选择没有的花色
    ?MAHJONG_CARD_TYPE_DOT       = mahjong_tool:auto_dingque_hdl(L3).                           %% 牌少的且数量相等，选散牌多的
%%    ?MAHJONG_CARD_TYPE_CHARACTER = mahjong_tool:auto_dingque_hdl(L4),                           %% 散牌一样多，二选一
%%    ?MAHJONG_CARD_TYPE_BAMBOO    = mahjong_tool:auto_dingque_hdl(L5).                           %% 没有的花色有两种，二选一

%% 自动换三张测试
auto_change_three_test() ->
    L1  = [1,2,3,11,11,11,12,15,21,21,21,22,24,25],
    L2  = [1,3,4,6,11,13,14,15,21,22,23,24,25,27],
    L4  = [1,2,11,11,11,11,21,22,23,24,26,26,26,29],
    L3  = [1,2,11,11,11,11,12,12,23,24,26,26,26,29],
    _L5 = [1,3,4,5,11,13,14,15,21,22,23,24,25,27],
    [[1,2,3],[11,11,11,12,15,21,21,21,22,24,25]]   = mahjong_tool:auto_change_three_hdl(L1),    %% 选择长度最少的且大于3的
    [[1,3,4],[6,11,13,14,15,21,22,23,24,25,27]]    = mahjong_tool:auto_change_three_hdl(L2),    %% 长度相等选散牌多的
    [[11,11,11],[1,2,11,21,22,23,24,26,26,26,29]]  = mahjong_tool:auto_change_three_hdl(L4),    %% 选长度大于3的，不足3的不选
    [[23,24,29],[1,2,11,11,11,11,12,12,26,26,26]]  = mahjong_tool:auto_change_three_hdl(L3).    %% 长度相等选散牌多的
%%    [[1,3,4],[5,11,13,14,15,21,22,23,24,25,27]]    = mahjong_tool:auto_change_three_hdl(L5).    %% 长度相等，散牌相等，随机选
%%  [[11,13,14],[1,3,4,5,15,21,22,23,24,25,27]]

%% 牌型测试
paixing_test() ->
    zhahu(),
    paixing0(),
    paixing1(),
    paixing2(),
    paixing3(),
    paixing3_5(),
    paixing4(),
    paixing4_5(),
    paixing5(),
    paixing6(),
    paixing7(),
    paixing6_7(),
    paixing8(),
    paixing9(),
    paixing10(),
    paixing11(),
    paixing12(),
    paixing12(),
    paixing13().


zhahu() ->
    L = [2,3,4,1],
    ?PRINT("zhahu~n"),
    false =
        mahjong_tool:get_win_type([], L, [], false, false).

paixing0() ->
    L = [1,2,3,14,15,16,7,8,9,1,1,1,2,2],
    [{<<"平胡"/utf8>>, 0}] = mahjong_tool:get_win_type([], L, [], false, false).

paixing1() ->
    L = [15,15],
    [{<<"十八罗汉"/utf8>>, 7}] =
        mahjong_tool:get_win_type([[1, 0, 4], [11, 1, 4], [19, 1, 4], [21, 2, 4]], L, [], false, false).

paixing2() ->
    L = [1,1,1,14,14,14,7,7,7,21,21,21,2,2],
    [{<<"对对胡"/utf8>>, 1}] =
        mahjong_tool:get_win_type([], L, [], false, false).

paixing3() ->
    L = [1,1,2,2,3,3,4,4,5,5,6,6,17,17],
    [{<<"七对"/utf8>>, 2}] =
        mahjong_tool:get_win_type([], L, [], false, false).

paixing3_5() ->
    L = [1,1,2,2,3,3,4,4,5,5,6,6,7,7],
    [{<<"七对"/utf8>>, 2}, {<<"清一色"/utf8>>, 2}] =
        mahjong_tool:get_win_type([], L, [], false, false).

paixing4() ->
    L = [1,1,1,1,3,3,4,4,5,5,6,6,17,17],
    [{<<"龙七对"/utf8>>, 3}] =
        mahjong_tool:get_win_type([], L, [], false, false).

paixing4_5() ->
    L = [1,1,1,1,3,3,4,4,5,5,6,6,7,7],
    [{<<"龙七对"/utf8>>, 3}, {<<"清一色"/utf8>>, 2}] =
        mahjong_tool:get_win_type([], L, [], false, false).

paixing5() ->
    L = [1,2,3,4,5,6,7,8,9,1,1,1,2,2],
    [{<<"清一色"/utf8>>, 2}] =
        mahjong_tool:get_win_type([], L, [], false, false).

paixing6() ->
    L = [1,2,3,14,15,16,7,8,9,1,1,1,2,2],
    [{<<"门清"/utf8>>, 1}] =
        mahjong_tool:get_win_type([], L, [1], false, false).

paixing7() ->
    L = [4,2,3,14,15,16,7,7,7,2,2],
    [{<<"中将"/utf8>>, 1}] =
        mahjong_tool:get_win_type([[18, 1, 3]], L, [1], false, false).

paixing6_7() ->
    L = [4,2,3,14,15,16,7,7,7,18,18,18,2,2],
    [{<<"门清"/utf8>>, 1}, {<<"中将"/utf8>>, 1}] =
        mahjong_tool:get_win_type([], L, [1], false, false).

paixing8() ->
    L = [1,2,3,11,11,11,17,18,19,7,8,9,29,29],
    [{<<"全幺九"/utf8>>, 3}] =
        mahjong_tool:get_win_type([], L, [2], false, false).

paixing9() ->
    L = [2,2,2,5,5,5,8,8,8,15,15,15,18,18],
    [{<<"将对"/utf8>>, 3}] =
        mahjong_tool:get_win_type([], L, [2], false, false).

paixing10() ->
    L = [2,2,2,2,5,5,8,8,12,12,15,15,18,18],
    [{<<"将七对"/utf8>>, 4}] =
        mahjong_tool:get_win_type([], L, [2], false, false).

paixing11() ->
    L = [4,2,3,14,15,16,7,7,7,2,2],
    [{<<"天胡"/utf8>>, 3}] =
        mahjong_tool:get_win_type([[18, 1, 3]], L, [3], true, true).

paixing12() ->
    L = [4,2,3,14,15,16,7,7,7,2,2],
    [{<<"地胡"/utf8>>, 2}] =
        mahjong_tool:get_win_type([[18, 1, 3]], L, [3], true, false).

paixing13() ->
    L = [2,2],
    [{<<"金钩胡"/utf8>>, 1}] =
        mahjong_tool:get_win_type([[18, 1, 3], [2, 0, 5], [14, 1, 5], [7, 0, 3]], L, [3], fasle, fasle).
-endif.