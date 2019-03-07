%%%-------------------------------------------------------------------
%%% @author feng.liao
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 27. 八月 2018 20:31
%%%-------------------------------------------------------------------
-module(mahjong_judge).

-author("feng.liao").

-include("mahjong.hrl").
-include("room.hrl").

-export([
    change_three/1,
    first_turn/2,
    zhuangjia/3,
    gangshanghua/4,
    check_color_pig/5,
    check_dajiao/5,
    qiangganghu/5,
    gangshangpao/3,
    haidipao/3,
    pure_hand/2,
    jingouhu/2,
    basic_hu/3,
    is_menqing_zhongjiang/4,
    is_tiandihu/4,
    is_yaojiu_jiangdui/4
]).

%% 换三张
-spec change_three(list()) -> any().
change_three(PlayType) ->
    Bool = lists:member(4, PlayType),
    if
        Bool ->
            erlang:send_after(?TIME, self(), {mahjong, timeout, change_three});
        true ->
            erlang:send_after(?TIME, self(), {mahjong, timeout, dingque})
    end.

%% 第一轮
-spec first_turn(integer(), boolean()) -> any().
first_turn(FirstTrun1, FirstTrun2) ->
    if
        FirstTrun1 < 3 ->
            {FirstTrun1 + 1, FirstTrun2};
        true ->
            {FirstTrun1, false}
    end.

%% 下一局的庄家
-spec zhuangjia(any(), integer(), mahjong_state()) -> mahjong_state().
zhuangjia(SeatId, ZhuangJiaCopy, MahjongState) when is_integer(SeatId) ->
    if
        ZhuangJiaCopy =:= 0 ->
            MahjongState#{zhuangjia_copy := SeatId};
        true ->
            MahjongState
    end;

zhuangjia([HuSeatList, Id] = List, ZhuangJiaCopy, MahjongState) when is_list(List) ->
    if
        length(HuSeatList) =:= 1 ->
            if
                ZhuangJiaCopy =:= 0 ->
                    MahjongState#{zhuangjia_copy := hd(HuSeatList)};
                true ->
                    MahjongState
            end;
        true ->
            MahjongState#{zhuangjia_copy := Id}
    end.

%% 杠上花
-spec gangshanghua(integer(), integer(), list(), integer()) -> any().
gangshanghua(SeatId, GangNoHuState, WinType, Faan) ->
    if
        GangNoHuState =:= SeatId ->
            {[{gangshangkaihua, 1} | WinType], Faan + 1};
        true ->
            {WinType, Faan}
    end.

%% 抢杠胡
-spec qiangganghu(integer(), list(), integer(), list(), any()) -> tuple().
qiangganghu(KongId, WinType, Faan, DealConflicts, MahjongSeats) ->
    if
        KongId =:= 0 ->
            {WinType, Faan, MahjongSeats} ;
        true ->
            case maps:get(KongId, DealConflicts) of
                %% 抢明杠，杠继续结算
                2 ->
                    {[{qiangganghu, 1} | WinType], Faan + 1, MahjongSeats};
                %% 抢补杠，杠失效
                3 ->
                    %% 将补杠者摸的牌去掉_H
                    KongSeat             = element(KongId + 1, MahjongSeats),
                    [_H | KongHandCards] = maps:get(hand_cards, KongSeat),
                    KongSeat1            = KongSeat#{hand_cards := KongHandCards},
                    MahjongSeats1        = setelement(KongId + 1, MahjongSeats, KongSeat1),
                    {[{qiangganghu, 1} | WinType], Faan + 1, MahjongSeats1}
            end
    end.

%% 杠上炮
-spec gangshangpao(integer(), list(), integer()) -> tuple().
gangshangpao(GangNoHuState, WinType, Faan) ->
    if
        GangNoHuState =/= 0 ->
            {[{gangshangpao, 1} | WinType], Faan + 1};
        true ->
            {WinType, Faan}
    end.

%% 海底炮
-spec haidipao(list(), list(), integer()) -> tuple().
haidipao(RemainCards, WinType, Faan) ->
    if
        length(RemainCards) =:= 0 ->
            {[{haidipao, 1} | WinType], Faan + 1};
        true ->
            {WinType, Faan}
    end.

%% 查花猪
-spec check_color_pig(list(), list(), list(), list(), list()) -> tuple().
check_color_pig(ColorPigSeats, TingPaiList, HupaiSeats, PlayType, MahjongSeats) ->
    HupaiLists   = mahjong_settle:is_ting_pai(HupaiSeats, MahjongSeats),
    TingPaiList1 = HupaiLists ++ TingPaiList,
    case {length(ColorPigSeats), length(TingPaiList), length(HupaiSeats)} of
        {0, _, _} ->
            {MahjongSeats, []};
        {_, 0, 0} ->
            {MahjongSeats, []};
        _ ->
            mahjong_settle:check_hand_cards(chahuazhu, ColorPigSeats, TingPaiList1, PlayType, MahjongSeats)
    end.

%% 查大叫
check_dajiao(HupaiSeats, NoTingPaiSeats, TingPaiList, PlayType, MahjongSeats) ->
    if
        length(HupaiSeats) =/= 0 ->
            {MahjongSeats, []};
        true ->
            mahjong_settle:check_hand_cards(chadajiao, NoTingPaiSeats, TingPaiList, PlayType, MahjongSeats)
    end.

%% 顺子，碰，杠次数的判断
-spec basic_hu(integer(), list(), list()) -> list().
basic_hu(Num, NotInHandCards, HandCards) ->
    case Num of
        0 ->
            AllCards = mahjong_tool:get_conf_seven_pairs_card(HandCards),
            [PairCount, FourCount] = mahjong_tool:get_pair_four_count(AllCards),
            if
                PairCount =:= 7, FourCount =:= 0 ->
                    [AllCards, [3]] ;
                true ->
                    [AllCards, [4]]
            end;
        _ ->
            HandCards1 = mahjong_tool:list_remove_two(Num, Num, HandCards),
            HandCards2 = NotInHandCards ++ mahjong_tool:get_conf_card(HandCards1),
            AllCards   = HandCards2 ++ [[Num, Num div 10, 2]],
            [ChowCount, PongCount, KongCount] =
                mahjong_tool:get_chow_pong_kong_count(HandCards2),
            if
                ChowCount =:= 0, PongCount =:= 0, KongCount =:= 4 ->
                    [AllCards, [1]];
                ChowCount =:= 0, PongCount =:= 4, KongCount =:= 0 ->
                    [AllCards, [2]];
                true ->
                    [AllCards, []]
            end
    end.

%% 清一色
-spec pure_hand(list(), list()) -> list().
pure_hand(AllCards, HuTypeIds) ->
    case mahjong_tool:is_pure_hand(AllCards) of
        true ->
            [5 | HuTypeIds];
        _ ->
            HuTypeIds
    end.

%% 金钩胡
-spec jingouhu(list(), list()) -> list().
jingouhu(HandCards, HuTypeIds) ->
    case length(HandCards) of
        2 ->
            [13 | HuTypeIds];
        _ ->
            HuTypeIds
    end.

%% 幺九将对
-spec is_yaojiu_jiangdui(list(), list(), list(), list()) -> list().
is_yaojiu_jiangdui(NotInHandCards, AllCards, HuTypeIds, PlayType) ->
    case lists:member(2, PlayType) of
        false ->
            HuTypeIds;
        true ->
            Bool1 = mahjong_tool:is_all_one_nine(AllCards) =:= 1,
            Bool2 =
                case length(NotInHandCards) of
                    0 ->
                        mahjong_tool:is_258_cards(AllCards);
                    _ ->
                        false
                end,
            Bool3 = lists:member(2, HuTypeIds) andalso Bool2,
            Bool4 = lists:member(4, HuTypeIds) andalso Bool2,
            if
                Bool1, Bool3 ->
                    [8, 9 | lists:delete(2, HuTypeIds)];
                not Bool1, Bool3 ->
                    [9 | lists:delete(2, HuTypeIds)];
                Bool1, Bool4 ->
                    [8, 10 | lists:delete(4, HuTypeIds)];
                not Bool1, Bool4 ->
                    [10 | lists:delete(4, HuTypeIds)];
                Bool1, not Bool3, not Bool4 ->
                    [8 | HuTypeIds];
                true ->
                    HuTypeIds
            end
    end.

%%门清中将
-spec is_menqing_zhongjiang(list(), list(), list(), list()) -> list().
is_menqing_zhongjiang(NotInHandCards, AllCards, HuTypeIds, PlayType) ->
    case lists:member(1, PlayType) of
        false ->
            HuTypeIds;
        true ->
            Bool = mahjong_tool:is_all_one_nine(AllCards) =:= 2,
            if
                length(NotInHandCards) =:= 0 , Bool ->
                    [6, 7 | HuTypeIds];
                length(NotInHandCards) =:= 0 , not Bool ->
                    [6 | HuTypeIds];
                not (length(NotInHandCards) =:= 0) , Bool ->
                    [7 | HuTypeIds];
                true ->
                    HuTypeIds
            end
    end.

%%天地胡
-spec is_tiandihu(boolean(), boolean(), list(), list()) -> list().
is_tiandihu(IsFirstTurn, IsZhuangJia, HuTypeIds, PlayType) ->
    case lists:member(3, PlayType) of
        false ->
            HuTypeIds;
        true ->
            if
                IsFirstTurn, IsZhuangJia ->
                    [11 | HuTypeIds];
                IsFirstTurn, not IsZhuangJia ->
                    [12 | HuTypeIds];
                true ->
                    HuTypeIds
            end
    end.

















