%%%-------------------------------------------------------------------
%%% @author feng.liao
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 15. 八月 2018 10:12
%%%-------------------------------------------------------------------
-module(mahjong_lib).

-author("feng.liao").

-include("mahjong.hrl").
-include("room.hrl").

-export([

    send_cards2player/4,
    can_change_three/4,
    change_three_hdl/1,
    auto_change_three/2,
    can_dingque/3,
    dingque_hdl/1,
    auto_dingque/2,
    discard_hdl/4,
    draw_hdl/2,
    conflicts_hdl/4,
    pong_hdl/3,
    kong_hdl/4,
    zimo_hdl/3,
    one_round_end_hdl/1,
    next_round_hdl/1

]).

%% 将牌分配给玩家（座位）
-spec send_cards2player(integer(), list(), any(), mahjong_state()) -> mahjong_state().
send_cards2player(ZhuangjiaSeatId, PlayType, MahjongSeats, #{?map_name := ?mahjong_state} = MahjongState) ->
    [List1, List2, List3, List4, [H | List5]] = mahjong_tool:shuffle_and_send(1, 4),
    Temp = [{1, List1}, {2, List2}, {3, List3}, {4, List4}],
    Temp1 = maps:from_list(Temp),                                                                %% list -> map
    Temp2 = Temp1#{                                                                              %% 庄家添一张牌
        ZhuangjiaSeatId := ([H | maps:get(ZhuangjiaSeatId, Temp1)])},                            %%
    Temp3 = maps:to_list(Temp2),                                                                 %% map -> list

    Mahjong_seats1 = init_cards(Temp3, MahjongSeats),
    Ref = mahjong_judge:change_three(PlayType),
    MahjongState#{
        remain_cards   := List5,
        ready_seats    := [],
        current_round  := 1,
        mahjong_seats  := Mahjong_seats1,
        timer_ref       := Ref,
        current_state   := [draw, ZhuangjiaSeatId, H]
    }.

%% initialize cards
init_cards([], MahjongSeats) ->
    MahjongSeats;
init_cards([{Num, List} | RemainList], MahjongSeats) ->
    Seat =
        #{
            hand_cards             => List,
            not_in_hand_cards     => [],
            dingque_color          => -1,
            current_seat_records  => [],
            current_score          => 0,
            all_score              => 0,
            record_counts => #{
                zimo        => 0,
                jiepao      => 0,
                dianpao     => 0,
                angang      => 0,
                minggang    => 0,
                chadajiao   => 0,
                chahuazhu   => 0
            }
        },
    MahjongSeats1 = setelement(Num + 1, MahjongSeats, Seat),
    init_cards(RemainList, MahjongSeats1).

%% 判断换三张的操作是否正确
-spec can_change_three(integer(), list(), list(), room_state()) -> {ok, room_state()} | {error, room_state()}.
can_change_three(
        SeatId,
        ThreeCards,
        HandCards,
        #{?map_name := ?room_state, mahjongState := MahjongState} = State) ->

    [CardId1, CardId2, CardId3] = ThreeCards,
    NewHandCards       = mahjong_tool:change_three_card(HandCards, CardId1, CardId2, CardId3),
    MahjongSeats       = maps:get(mahjong_seats, MahjongState),
    NoChangeThreeSeats = maps:get(no_change_three_seats, MahjongState),
    Seat = element(SeatId + 1, MahjongSeats),

    case NewHandCards of
        false ->
            ?PRINT("请选择3张相同的花色~n"),
            {error, State};
        _ ->
            Seat1 = Seat#{
                hand_cards := NewHandCards},
            MahjongSeats1 = setelement(SeatId + 1, MahjongSeats, Seat1),
            State1 = State#{
                mahjongState := MahjongState#{
                    mahjong_seats          := MahjongSeats1,
                    no_change_three_seats := lists:delete(SeatId, NoChangeThreeSeats)}},
            {ok, State1}
    end.

%% 换三张处理
-spec change_three_hdl(room_state()) -> tuple().
change_three_hdl(#{?map_name := ?room_state, mahjongState := MahjongState} = State) ->
    MahjongSeats = maps:get(mahjong_seats, MahjongState),
    #mahjong_seats{seat1 = Seat1, seat2 = Seat2, seat3 = Seat3, seat4 = Seat4} = MahjongSeats,
    HandCards1 = maps:get(hand_cards, Seat1),
    HandCards2 = maps:get(hand_cards, Seat2),
    HandCards3 = maps:get(hand_cards, Seat3),
    HandCards4 = maps:get(hand_cards, Seat4),
    [List1, List2, List3, List4, ChangeType] = mahjong_tool:after_change(HandCards1, HandCards2, HandCards3, HandCards4),
    MahjongSeats1 = MahjongSeats#mahjong_seats{
        seat1 = Seat1#{hand_cards := List1},
        seat2 = Seat2#{hand_cards := List2},
        seat3 = Seat3#{hand_cards := List3},
        seat4 = Seat4#{hand_cards := List4}
    },
    Ref = erlang:send_after(?TIME, self(), {mahjong, timeout, dingque}),
    State1 = State#{
        mahjongState := MahjongState#{
            mahjong_seats := MahjongSeats1,
            no_change_three_seats := [1, 2, 3, 4],
            change_three_type := ChangeType,
            timer_ref := Ref}},
    {ok, ChangeType, State1}.

%% 自动换三张
-spec auto_change_three(list(), any()) -> any().
auto_change_three([], MahjongSeats) ->
    MahjongSeats;
auto_change_three([H | List], MahjongSeats) ->
    Seat = element(H + 1, MahjongSeats),
    HandCards = maps:get(hand_cards, Seat),
    ?PRINT("座位：~p 其手牌为： ~p~n", [H, HandCards]),
    NewHandCards = mahjong_tool:auto_change_three_hdl(HandCards),
    Seat1 = Seat#{hand_cards := NewHandCards},
    MahjongSeats1 = setelement(H + 1, MahjongSeats, Seat1),
    auto_change_three(List, MahjongSeats1).

%% 定缺处理
-spec can_dingque(integer(), integer(), room_state()) -> tuple().
can_dingque(
        SeatId,
        Color,
        #{?map_name := ?room_state, mahjongState := MahjongState} = State) ->
    MahjongSeats   = maps:get(mahjong_seats, MahjongState),
    NoDingqueSeats = maps:get(no_dingque_seats, MahjongState),
    Seat           = element(SeatId + 1, MahjongSeats),
    case maps:get(dingque_color, Seat) of
        -1 ->
            Seat1 = Seat#{dingque_color := Color},
            MahjongSeats1 = setelement(SeatId + 1, MahjongSeats, Seat1),
            State1 = State#{
                mahjongState := MahjongState#{
                    mahjong_seats     := MahjongSeats1,
                    no_dingque_seats := lists:delete(SeatId, NoDingqueSeats)}},
            {ok, State1};
        _ ->
            ?PRINT("你已定缺~n"),
            {error, State}
    end.

%% 定缺处理
-spec dingque_hdl(room_state()) -> tuple().
dingque_hdl(#{?map_name := ?room_state, mahjongState := MahjongState, player_id2seat := PlayerId2Seat} = State) ->
    MahjongSeats = maps:get(mahjong_seats, MahjongState),
    ZhuangJia    = maps:get(zhuangjia, MahjongState),
    ZhuangJia1   = maps:get(ZhuangJia, PlayerId2Seat),
    Ref          = erlang:send_after(?TIME, self(), {mahjong, timeout, {discard, ZhuangJia1}}),
    State1 = State#{
        mahjongState := MahjongState#{
            no_dingque_seats := [1 ,2, 3, 4],
            timer_ref         := Ref}},
    {ok, MahjongSeats, State1}.

%% 自动定缺
-spec auto_dingque(list(), any()) -> any().
auto_dingque([], MahjongSeats) ->
    MahjongSeats;
auto_dingque([H | List], MahjongSeats) ->
    Seat          = element(H + 1, MahjongSeats),
    HandCards     = maps:get(hand_cards, Seat),
    Color         = mahjong_tool:auto_dingque_hdl(HandCards),
    Seat1         = Seat#{dingque_color := Color},
    MahjongSeats1 = setelement(H + 1, MahjongSeats, Seat1),
    auto_dingque(List, MahjongSeats1).

%% 出牌处理
-spec discard_hdl(integer(), list(), integer(), room_state()) -> tuple().
discard_hdl(SeatId, HandCards, CardId,
        #{?map_name := ?room_state, mahjongState := MahjongState} = State) ->

    #{
        mahjong_seats    := MahjongSeats,
        gang_no_hu_state := GangNoHuState
    } =MahjongState,

    GangNoHuState1 =                        %% 用于判断点杠花
        if
            SeatId =:= GangNoHuState ->
                GangNoHuState;
            true ->
                0
        end,

    SeatId1       = mahjong_tool:get_next_seatid(SeatId),
    Ref           = erlang:send_after(?TIME, self(), {mahjong, timeout, {draw, SeatId1}}),
    Seat          = element(SeatId + 1, MahjongSeats),
    Seat1         = Seat#{hand_cards := HandCards},
    MahjongSeats1 = setelement(SeatId + 1, MahjongSeats, Seat1),
    ?PRINT("seat~p,出牌,~p~n", [SeatId, CardId]),
    State1 = State#{
        mahjongState := MahjongState#{
            current_state    := [discard, SeatId, CardId],
            mahjong_seats    := MahjongSeats1,
            timer_ref        := Ref,
            deal_conflicts   := [],
            gang_no_hu_state := GangNoHuState1
        }},
    {ok, State1}.

%% 摸牌处理
draw_hdl(SeatId,
        #{?map_name := ?room_state, mahjongState := MahjongState} = State) ->
    {FirstTrun1, FirstTrun2}   = maps:get(first_turn, MahjongState),
    MahjongSeats               = maps:get(mahjong_seats, MahjongState),
    Seat                       = element(SeatId + 1, MahjongSeats),
    HandCards                  = maps:get(hand_cards, Seat),
    RemainCards                = maps:get(remain_cards, MahjongState),
    {FirstTurn3, FirstTurn4}   = mahjong_judge:first_turn(FirstTrun1, FirstTrun2),
    [HandCards1, RemainCards1] = mahjong_tool:draw(HandCards, RemainCards),

    ?PRINT("seat~p,摸牌,~p~n", [SeatId, hd(HandCards1)]),

    Seat1 = Seat#{
        hand_cards := HandCards1},
    MahjongSeats1 = setelement(SeatId + 1, MahjongSeats, Seat1),
    Ref = erlang:send_after(?TIME_WAIT_OP, self(), {mahjong, timeout, {discard, SeatId}}),
    State1 = State#{
        mahjongState := MahjongState#{
            current_state := [draw, SeatId, hd(HandCards1)],
            mahjong_seats := MahjongSeats1,
            remain_cards  := RemainCards1,
            timer_ref     := Ref,
            first_turn    := {FirstTurn3, FirstTurn4}
        }},
    {ok, hd(HandCards1), State1}.

%% 处理 pong
pong_hdl(SeatId, CardId,
        #{?map_name := ?room_state, mahjongState := MahjongState} = State) ->
    #{
        mahjong_seats := MahjongSeats,
        first_turn    := {FirstTurn1, _FirstTurn2}
    } = MahjongState,
    Seat = element(SeatId + 1, MahjongSeats),
    #{
        hand_cards         := HandCards,
        dingque_color      := _DingqueColor,
        not_in_hand_cards := NotInHandCards
    } = Seat,

    [NotInHandCards1, HandCards1] = mahjong_tool:handle_pong(CardId, HandCards),
    Seat1 = Seat#{
        hand_cards := HandCards1,
        not_in_hand_cards := [NotInHandCards1 | NotInHandCards]},
    MahjongSeats1 = setelement(SeatId + 1, MahjongSeats, Seat1),
    Ref = erlang:send_after(?TIME_WAIT_OP, self(), {mahjong, timeout, {discard, SeatId}}),
    State1 = State#{
        mahjongState := MahjongState#{
            mahjong_seats := MahjongSeats1,
            timer_ref := Ref,
            first_turn :=  {FirstTurn1, false},
            deal_conflicts := []}
    },
    {ok, State1}.

%% 处理 kong
kong_hdl(SeatId, CardId, Flag,
        #{?map_name := ?room_state, mahjongState := MahjongState} = State) ->
    #{
        mahjong_seats := MahjongSeats,
        first_turn := {FirstTurn1, _FirstTurn2},
        current_state := CurrentState
    } = MahjongState,
    Seat = element(SeatId + 1, MahjongSeats),
    #{
        hand_cards          := HandCards,
        dingque_color       := _DingqueColor,
        not_in_hand_cards   := NotInHandCards
    } = Seat,
    [NotInHandCards1, HandCards1] = mahjong_tool:handle_kong(Flag, CardId, NotInHandCards, HandCards),
    Seat1 = get_kong_type(Flag, SeatId, CurrentState, MahjongSeats),
    Seat2 = Seat1#{
        hand_cards := HandCards1,
        not_in_hand_cards := NotInHandCards1},
    Mahjong_seats1 = setelement(SeatId + 1, MahjongSeats, Seat2),
    Ref =
        erlang:send_after(1000, self(), {timeout, {mahjong, draw, SeatId}}),
    State1 = State#{
        mahjongState := MahjongState#{
            mahjong_seats     := Mahjong_seats1,
            first_turn        := {FirstTurn1, false},
            timer_ref         := Ref,
            deal_conflicts   := [],
            gang_no_hu_state := SeatId
        }
    },
    {ok, State1}.

%% 处理自摸
zimo_hdl(SeatId, WinType,
        #{?map_name := ?room_state, mahjongState := MahjongState} = State) ->

    #{
        mahjong_seats     := MahjongSeats,
        zhuangjia_copy   := ZhuangJiaCopy,
        no_hupai_seats   := NoHupaiSeats,
        gang_no_hu_state := GangNoHuState
    } = MahjongState,
    Seat = element(SeatId + 1, MahjongSeats),
    #{
        hand_cards             := HandCards,
        current_seat_records  := CurrentSeatRecords
    } = Seat,

    Ref    = erlang:send_after(1000, self(), {mahjong, timeout, {draw, mahjong_tool:get_next_seatid(SeatId)}}),
    Faan   = mahjong_tool:cacul_faan(WinType),
    NoHupaiSeats1 =
        case lists:member(SeatId, NoHupaiSeats) of
            true ->
                lists:delete(SeatId, NoHupaiSeats);
            fasle ->
                NoHupaiSeats
        end,

    %% 下局庄家的判断
    MahjongState1 = mahjong_judge:zhuangjia(SeatId, ZhuangJiaCopy, MahjongState),
    %% 杠上花的判断
    {WinType1, Faan1} = mahjong_judge:gangshanghua(SeatId, GangNoHuState, WinType, Faan),

    CardId = hd(HandCards),
    CurrentSeatRecords1 = {[{zimo, [SeatId, CardId] ++ [WinType1]} | CurrentSeatRecords]},
    Seat1 = Seat#{
        seat_records := CurrentSeatRecords1,
        hand_cards   := lists:delete(CardId, HandCards)},
    MahjongSeats1      = setelement(SeatId + 1, MahjongSeats, Seat1),
    State1 = State#{
        mahjongState := MahjongState1#{
            mahjong_seats     := MahjongSeats1,
            timer_ref         := Ref,
            no_hupai_seats   := NoHupaiSeats1,
            gang_no_hu_state := 0
        }},
    {ok, Faan1, State1}.

%% 处理conflicts
-spec conflicts_hdl(atom(), any(), integer(), room_state()) -> tuple().
conflicts_hdl(pong, SeatId, CardId,
        #{?map_name := ?room_state, mahjongState := MahjongState} = State) ->

    #{
        timer_ref       := Ref,
        deal_conflicts := DealConflicts} = MahjongState,
    DealConflicts1        = maps:from_list(DealConflicts),
    DealConflicts1Values  = maps:values(DealConflicts1),
    case lists:member(hu, DealConflicts1Values) of
        true ->
            {ok, State};
        false ->
            util:cancel_timer(Ref),
            Ref1 = erlang:send_after(?TIME, self(), {mahjong, timeout, {pong, SeatId, CardId}}),
            State1 = State#{
                mahjongState := MahjongState#{
                    deal_conflicts := [{SeatId, pong} | DealConflicts],
                    timer_ref       := Ref1
                }},
            {ok, State1}
    end;

conflicts_hdl(kong, {SeatId, Flag}, CardId,
        #{?map_name := ?room_state, mahjongState := MahjongState} = State) ->

    #{
        timer_ref       := Ref,
        deal_conflicts := DealConflicts} = MahjongState,
    DealConflicts1        = maps:from_list(DealConflicts),
    DealConflicts1Values  = maps:values(DealConflicts1),

    case lists:member(hu, DealConflicts1Values) of
        true ->
            State1 = State#{
                mahjongState := MahjongState#{
                    deal_conflicts := [{SeatId, Flag} | DealConflicts]
                }},
            {ok, State1};
        false ->
            util:cancel_timer(Ref),
            Ref1 = erlang:send_after(?TIME, self(), {mahjong, timeout, {kong, SeatId, CardId, Flag}}),
            State1 = State#{
                mahjongState := MahjongState#{
                    deal_conflicts := [{SeatId, Flag} | DealConflicts],
                    timer_ref       := Ref1
                }},
            {ok, State1}
    end;

conflicts_hdl(hu, SeatId, _CardId,
        #{?map_name := ?room_state, mahjongState := MahjongState} = State) ->

    #{
        timer_ref       := Ref,
        deal_conflicts := DealConflicts} = MahjongState,
    DealConflicts1        = maps:from_list(DealConflicts),
    DealConflicts1Values  = maps:values(DealConflicts1),
    case lists:member(hu, DealConflicts1Values) of
        true ->
            State1 = State#{
                mahjongState := MahjongState#{
                    deal_conflicts := [{SeatId, hu} | DealConflicts]
                }},
            {ok, State1};
        false ->
            util:cancel_timer(Ref),
            Ref1 =
                erlang:send_after(?TIME_WAIT_OP, self(), {mahjong, timeout, {conflicts_hdl, hu, SeatId}}),
            State1 = State#{
                mahjongState := MahjongState#{
                    timer_ref := Ref1,
                    deal_conflicts := [{SeatId, hu} | DealConflicts]
                }},
            {ok, State1}
    end.

%% 游戏结束(一局游戏结束）
-spec one_round_end_hdl(room_state()) -> tuple().
one_round_end_hdl(
        #{?map_name := ?room_state, mahjongState := MahjongState, play_type := PlayType, seat2player_id := Seat2PlayerId} = State) ->
    #{
        mahjong_seats  := MahjongSeats,
        zhuangjia_copy := ZhuangJiaCopy,
        no_hupai_seats := NoHupaiSeats
    } = MahjongState,
    SeatIds = [1, 2, 3, 4],
    [HupaiSeats, TingPaiList, NoTingPaiSeats, ColorPigSeats] =
        mahjong_settle:get_handcards_situation(NoHupaiSeats, MahjongSeats),

    %% 查花猪
    {MahjongSeats1, List} =
        mahjong_judge:check_color_pig(ColorPigSeats, TingPaiList, HupaiSeats, PlayType, MahjongSeats),

    %% 流局查大叫
    {MahjongSeats2, List1} =
        mahjong_judge:check_dajiao(HupaiSeats, NoTingPaiSeats, TingPaiList, PlayType, MahjongSeats1),

    %% 更新当局玩家的分数
    {MahjongSeats3, List2} =
        mahjong_settle:get_current_score(SeatIds, MahjongSeats2),

    %% 更新玩家全局分数
    MahjongSeats4 =
        mahjong_settle:update_all_score(SeatIds, MahjongSeats3),

    MahjongState1 = MahjongState#{
        zhuangjia      := maps:get(ZhuangJiaCopy, Seat2PlayerId),
        mahjong_seats := MahjongSeats4,
        paiju_detail  := List ++ List1 ++ List2,
        first_round   := {0, true}
    },
    Ref = erlang:send_after(15000, self(), {mahjong, timeout, next_game}),
    State1 = State #{
        mahjongState := MahjongState1,
        ref := Ref
    },
    {ok, State1}.

%% 下一局游戏处理
-spec next_round_hdl(room_state()) -> tuple().
next_round_hdl(#{?map_name := ?room_state, mahjongState := MahjongState, play_type := PlayType} = State) ->
    #{
        mahjong_seats := MahjongSeats,
        zhuangjia_copy := ZhuangJiaCopy,
        %% game_all_num := Game_all_num,
        current_round := CurrentRound} = MahjongState,
    [List1, List2, List3, List4, [H | List5]] = mahjong_tool:shuffle_and_send(1, 4),
    Temp = [{1, List1}, {2, List2}, {3, List3}, {4, List4}],
    Temp1 = maps:from_list(Temp),
    Temp2 = Temp1#{
        ZhuangJiaCopy := ([H | maps:get(ZhuangJiaCopy, Temp1)])},
    Temp3 = maps:to_list(Temp2),
    %% 下局游戏初始化
    MahjongSeats1 = init_next_round_cards(Temp3, MahjongSeats),

    Ref = mahjong_judge:change_three(PlayType),
    MahjongState1 = MahjongState#{
        remain_cards         := List5,
        no_next_round_seats := [1,2,3,4],
        current_round        := CurrentRound + 1,
        zhuangjia_copy       := 0,
        mahjong_seats        := MahjongSeats1,
        paiju_detail         := [],
        current_state        := [],
        timer_ref             := Ref
    },
    State1 = State#{mahjongState := MahjongState1},
    {ok, CurrentRound + 1, State1}.

%% initialize next round cards
init_next_round_cards([], MahjongSeats) ->
    MahjongSeats;
init_next_round_cards([{Num, List} | RemainList], MahjongSeats) ->
    Seat  = element(Num + 1, MahjongSeats),
    Seat1 = Seat#{
        hand_cards            := List,
        not_in_hand_cards    := [],
        dingque_color         := -1,
        current_seat_records := [],
        current_score         := 0
    },
    MahjongSeats1 = setelement(Num + 1, MahjongSeats, Seat1),
    init_next_round_cards(RemainList, MahjongSeats1).

%% 获取杠的类型
-spec get_kong_type(integer(), integer(), list(), any()) -> seat_state().
get_kong_type(Flag, SeatId, CurrentState, MahjongSeats) ->
    Seat = element(SeatId + 1, MahjongSeats),
    #{
        record_counts         := RecordCounts,
        current_seat_records := CurrentSeatRecords
    } = Seat,
    case Flag of
        1 ->
            RecordCounts1 = RecordCounts#{angang := maps:get(angang, RecordCounts) + 1},
            Seat#{
                record_counts         := RecordCounts1,
                current_seat_records := [{angang, SeatId} | CurrentSeatRecords]
            };
        2 ->
            [discard, Id, _] = CurrentState,
            RecordCounts1     = RecordCounts#{minggang := maps:get(minggang, RecordCounts) + 1},
            Seat#{
                record_counts         := RecordCounts1,
                current_seat_records := [{minggang, [SeatId, Id]} | CurrentSeatRecords]};
        3 ->
            Seat#{
                current_seat_records := [{bugang, SeatId} | CurrentSeatRecords]}
    end.
