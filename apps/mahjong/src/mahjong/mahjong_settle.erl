%%%-------------------------------------------------------------------
%%% @author feng.liao
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 28. 八月 2018 19:18
%%%-------------------------------------------------------------------
-module(mahjong_settle).

-author("feng.liao").

-include("mahjong.hrl").

-export([
    get_handcards_situation/2,
    check_hand_cards/5,
    get_current_score/2,
    update_all_score/2

]).


%% 获取玩家胡牌，听牌，不听牌，剩3种花色的列表
-spec get_handcards_situation(list(), any()) -> list().
get_handcards_situation(NoHupaiSeats, MahjongSeats) ->
    Temp = [1, 2, 3, 4],
    HupaiSeats      = [X || X <- Temp, not lists:member(X, NoHupaiSeats)],
    ColorPigSeats   = is_color_pig(NoHupaiSeats, MahjongSeats),
    NoColorPigSeats = [X || X <- NoHupaiSeats, not lists:member(X, ColorPigSeats)],
    TingPaiList     = is_ting_pai(NoColorPigSeats, MahjongSeats),
    NoTingPaiSeats  = [X || X <- NoColorPigSeats, not lists:member(X, TingPaiList)],
    [HupaiSeats, TingPaiList, NoTingPaiSeats, ColorPigSeats].

%%听牌
-spec is_ting_pai(list(), any()) -> any().
is_ting_pai(SeatIds, MahjongSeats) ->
    is_ting_pai(SeatIds, MahjongSeats, []).

is_ting_pai([], _MahjongSeats, TingPaiList) ->
    TingPaiList;
is_ting_pai([H | Remain], MahjongSeats, TingPaiList) ->
    Seat = element(H + 1, MahjongSeats),
    #{hand_cards := HandCards, dingque := Color} = Seat,
    L1 = lists:seq(1, 29),
    L2 = [X || X <- L1, X div 10 =/= Color, X =/= 20],
    Temp = tingpai_judge(L2, HandCards),
    case Temp of
        [] ->
            is_ting_pai(Remain, MahjongSeats, TingPaiList);
        _ ->
            is_ting_pai(Remain, MahjongSeats, [{H, Temp} | TingPaiList])
    end.

%%听牌的判断
tingpai_judge(List, HandCards) ->
    tingpai_judge(List, HandCards, []).

tingpai_judge([], _HandCards, TingCardIds) ->
    TingCardIds;
tingpai_judge([H | List], HandCards, TingCardIds) ->
    HandCards1 = lists:sort([H | HandCards]),
    case mahjong_tool:can_win(HandCards1) of
        -1 ->
            tingpai_judge(List, HandCards, TingCardIds);
        _ ->
            tingpai_judge(List, HandCards, [H | TingCardIds])
    end.

%%是花猪
-spec is_color_pig(list(), any()) -> any().
is_color_pig(List, MahjongSeats) ->
    is_color_pig(List, MahjongSeats, []).

is_color_pig([], _MahjongSeats, ColorPigSeats) ->
    ColorPigSeats;
is_color_pig([H | NoHupaiSeats], MahjongSeats, ColorPigSeats) ->
    Seat = element(H + 1, MahjongSeats),
    #{hand_cards := HandCards, dingque := Color} = Seat,
    case length([X || X <- HandCards, X div 10 =:= Color]) of
        0 ->
            is_color_pig(NoHupaiSeats, MahjongSeats, ColorPigSeats);
        _ ->
            is_color_pig(NoHupaiSeats, MahjongSeats, [H | ColorPigSeats])
    end.

%%计算查花猪， 查大叫赔的番与分数
check_hand_cards(Flag, CheckedList, TingPaiList, PlayType, MahjongSeats) ->
    check_hand_cards(Flag, CheckedList, TingPaiList, PlayType, MahjongSeats, []).

check_hand_cards(_Flag, [], _TingPaiList, _PlayType, MahjongSeats, List) ->
    {MahjongSeats, List};
check_hand_cards(Flag, [Head | CheckedList], TingPaiList, PlayType, MahjongSeats, List) ->
    {MahjongSeats1, List1} =
        checked_pay(Flag, Head, TingPaiList, PlayType, MahjongSeats),
    SeatChecked  = element(Head + 1, MahjongSeats1),
    RecordCounts = maps:get(record_counts, SeatChecked),
    SeatChecked1 =
        case Flag of
            chahuazhu ->
                SeatChecked#{
                    record_counts := RecordCounts#{
                        chahuazhu := maps:get(chahuazhu, RecordCounts) + 1}};
            chadajiao ->
                SeatChecked#{
                    record_counts := RecordCounts#{
                        chadajiao := maps:get(chadajiao, RecordCounts) + 1}}
        end,
    MahjongSeats2 = setelement(Head + 1, MahjongSeats1, SeatChecked1),
    check_hand_cards(Flag, CheckedList, TingPaiList, PlayType, MahjongSeats2, List ++ List1).

%% 被查着要赔的番数和分数计算
checked_pay(Flag, CheckedSeatId, TingPaiList, _PlayType, MahjongSeats) ->
    checked_pay(Flag, CheckedSeatId, TingPaiList, _PlayType, MahjongSeats, []).

checked_pay(_Flag, _CheckedSeatId, [], _PlayType, MahjongSeats, List) ->
    {MahjongSeats, List};
checked_pay(Flag, CheckedSeatId, [{SeatId, TingCardIds} | TingPaiList], PlayType, MahjongSeats, List) ->
    Seat = element(SeatId + 1, MahjongSeats),
    #{
        hand_cards         := HandCards,
        not_in_hand_cards := NotInHandCards
    } = Seat,
    %% 可能胡牌的番数列表
    FaanList = lists:map(fun(X) ->
        WinType =
            mahjong_tool:get_win_type(NotInHandCards, [X | HandCards], PlayType, fasle, false),
        mahjong_tool:cacul_faan(WinType)
                         end, TingCardIds),

    Faan = lists:max(FaanList),
    MahjongSeats1 =
        win_one_people(SeatId, CheckedSeatId, MahjongSeats, Faan, 1),
    List1 =
        case Flag of
            chahuazhu ->
                [{chahuazhu, CheckedSeatId, SeatId, Faan} | List];
            chadajiao ->
                [{chadajiao, CheckedSeatId, SeatId, Faan} | List]
        end,
    checked_pay(Flag, CheckedSeatId, TingPaiList, PlayType, MahjongSeats1, List1).

%%计算分数
get_current_score(List, MahjongSeats) ->
    get_current_score(List, MahjongSeats, []).

get_current_score([], MahjongSeats, List) ->
    {MahjongSeats, List};
get_current_score([H | SeatIds], MahjongSeats, List) ->
    Seat = element(H + 1, MahjongSeats),
    CurrentSeatRecords = maps:get(current_seat_records, Seat),
    Count = length([X || X <- CurrentSeatRecords, element(1, X) =:= zimo orelse element(1, X) =:= jiepao]),
    {MahjongSeats2, List2} =
        if
            Count =/= 0 ->
                {MahjongSeats1, List1} = cacul_score(CurrentSeatRecords, MahjongSeats),
                {MahjongSeats1, List ++ List1};
            true ->
                {MahjongSeats, List}
        end,
    get_current_score(SeatIds, MahjongSeats2, List2).



cacul_score(List, MahjongSeats) ->
    cacul_score(List, MahjongSeats, []).

cacul_score([], MahjongSeats, List) ->
    {MahjongSeats, List};
cacul_score([H | Record], MahjongSeats, List) ->
    case H of
        {angang, Id} ->
            MahjongSeats1 = win_three_people(Id, MahjongSeats, 2, fasle),
            cacul_score(Record, MahjongSeats1, List);

        {minggang, [WinId, FailId]} ->
            MahjongSeats1 = win_one_people(WinId, FailId, MahjongSeats, 1, 1),
            cacul_score(Record, MahjongSeats1, List);

        {bugang, Id} ->
            MahjongSeats1 = win_three_people(Id, MahjongSeats, 1, false),
            cacul_score(Record, MahjongSeats1, List);

        {zimo, [Id, Elem, Temp]} ->
            Faan = mahjong_tool:cacul_faan(Temp),
            MahjongSeats1 = win_three_people(Id, MahjongSeats, Faan, true),
            List1 = [{zimo, Id, Elem, [element(1,X) || X <- Temp], 3 * jiecheng(2, Faan)} | List],
            cacul_score(Record, MahjongSeats1, List1);

        {jiepao, [JieId, DianId, Elem, Temp]} ->
            Faan = mahjong_tool:cacul_faan(Temp),
            MahjongSeats1 = win_one_people(JieId, DianId, MahjongSeats, Faan, 2),
            PaixingList   = [element(1, X) || X <- Temp],
            Mark          = jiecheng(2, Faan),
            Jiepao        = {jiepao, JieId, Elem, PaixingList, Mark},
            Dianpao       = {dianpao, DianId, Elem, PaixingList, - Mark},
            List1         = [Jiepao, Dianpao | List],
            cacul_score(Record, MahjongSeats1, List1)
    end.

%%更新全局分数
-spec update_all_score(list(), any())-> any().
update_all_score([], MahjongSeats) ->
    MahjongSeats;
update_all_score([H | SeatId], MahjongSeats) ->
    Seat = element(H + 1, MahjongSeats),
    #{
        all_score      := AllScore,
        current_score := CurrentScore} = Seat,
    Seat1 = Seat#{all_score := AllScore + CurrentScore},
    MahjongSeats1 = setelement(H + 1, MahjongSeats, Seat1),
    update_all_score(SeatId, MahjongSeats1).

%%赢3个人
win_three_people(SeatId, MahjongSeats, Faan, Bool) ->
    #mahjong_seats{seat1 = Seat1, seat2 = Seat2, seat3 = Seat3, seat4 = Seat4} = MahjongSeats,
    Temp = [1, 2, 3, 4],
    [CurrentScore1, CurrentScore2, CurrentScore3, CurrentScore4] =
        [if
             X =:= SeatId ->
                 maps:get(current_score, element(X + 1, MahjongSeats)) + 3 * jiecheng(2, Faan);
             true ->
                 maps:get(current_score, element(X + 1, MahjongSeats)) - jiecheng(2, Faan)
         end || X <- Temp],
    MahjongSeats1 = MahjongSeats#mahjong_seats{
        seat1     = Seat1#{current_score := CurrentScore1},
        seat2     = Seat2#{current_score := CurrentScore2},
        seat3     = Seat3#{current_score := CurrentScore3},
        seat4     = Seat4#{current_score := CurrentScore4}
    },
    case Bool of
        false ->
            MahjongSeats1;
        true ->
            Seat          =  element(SeatId + 1, MahjongSeats1),
            RecordCounts  = maps:get(record_counts, Seat),
            RecordCounts1 = RecordCounts#{zimo := maps:get(zimo, RecordCounts) + 1},
            Seat1 = Seat#{
                record_counts := RecordCounts1},
            setelement(SeatId + 1, MahjongSeats1, Seat1)
    end.

%%赢一个人
win_one_people(WinSeatId, FailSeatId, MahjongSeats, Faan, Num) ->
    Seat1 = element(WinSeatId + 1, MahjongSeats),
    Seat2 = element(FailSeatId + 1, MahjongSeats),
    CurrentScore1 = maps:get(current_score, Seat1),
    CurrentScore2 = maps:get(current_score, Seat2),
    RecordCount1  = maps:get(record_counts, Seat1),
    RecordCount2  = maps:get(record_counts, Seat2),
    case Num of
        1 ->
            Seat3 = Seat1#{
                current_score := CurrentScore1 + jiecheng(2, Faan)},
            Seat4 = Seat2#{
                current_score := CurrentScore2 - jiecheng(2, Faan)};
        2 ->
            Seat3 = Seat1#{
                current_score := CurrentScore1 + jiecheng(2, Faan),
                record_counts := RecordCount1#{jiepao := maps:get(jiepao, RecordCount1) + 1}},
            Seat4 = Seat2#{
                current_score := CurrentScore2 - jiecheng(2, Faan),
                record_counts := RecordCount2#{dianpao := maps:get(dianpao, RecordCount2) + 1}}
    end,
    MahjongSeats1 = setelement(WinSeatId + 1, MahjongSeats, Seat3),
    setelement(FailSeatId + 1, MahjongSeats1, Seat4).

%%阶乘
jiecheng(_, 0) ->
    1;
jiecheng(Num, N) ->
    Num * jiecheng(Num, N - 1).
