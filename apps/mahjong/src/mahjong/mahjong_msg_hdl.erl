%%%-------------------------------------------------------------------
%%% @author feng.liao
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 16. 八月 2018 15:46
%%%-------------------------------------------------------------------
-module(mahjong_msg_hdl).

-author("feng.liao").

-include("pt_mahjong.hrl").
-include("mahjong.hrl").
-include("room.hrl").

-export([
    init_on_create_room/0,
    do_cast/2,
    do_info/2
]).


%% mahjong_state初始化
init_on_create_room() ->
    #{
        ?map_name => ?mahjong_state,
        mahjong_seats => #mahjong_seats{
            seat1 = #{},
            seat2 = #{},
            seat3 = #{},
            seat4 = #{}
        },
        remain_cards                => [],                %%牌堆
        ready_seats                 => [],                %%已准备的座位列表
        all_round                   => 0,                 %%游戏总局数
        current_round              => 0,                 %%当前游戏局数
        zhuangjia                   => <<>>,              %%玩家id
        zhuangjia_copy              => 0,                 %%庄家副本
        no_change_three_seats      => [1, 2, 3, 4],      %%未确定换三张的座位列表
        no_next_round_seats        => [1, 2, 3, 4],
        change_three_type          => 0,                 %%换三张的方式
        no_dingque_seats           => [1, 2, 3, 4],      %%未定缺的座位列表
        current_state              => [],
        timer_ref                   => ?undefined,        %%定时器引用
        paiju_detail                => [],
        current_win_msg            => [],
        first_turn                  => {0, true},
        no_hupai_seats              => [1, 2, 3, 4],
        deal_conflicts              => [],
        gang_no_hu_state            => 0
    }.

%% 准备游戏
do_cast(
        {#'C2S_MahjongPrepare'{} = _Msg, SeatId},
        #{?map_name := ?room_state, mahjongState := MahjongState, seat2player_id := Seat2PlayerId} = State) ->
    ReadySeats = maps:get(ready_seats, MahjongState),
    PlayerId   = maps:get(SeatId, Seat2PlayerId),
    case lists:member(SeatId, ReadySeats) of
        false ->
            Msg           = #'S2C_MahjongPrepare'{playerId = PlayerId},
            ReplyBin      = pt:encode_msg(pt_mahjong, Msg),
            MahjongState1 = MahjongState#{ready_seats := [SeatId | ReadySeats]},
            State1        = State#{mahjongState := MahjongState1},
            room_lib:broadcast(ReplyBin, State1),
            {ok, State1};
        true ->
            ?PRINT("~p已准备~n", [SeatId]),
            Msg = #'S2C_MahjongHadPrepare'{},
            ReplyBin = pt:encode_msg(pt_mahjong, Msg),
            room_lib:send_player(ReplyBin, PlayerId, State),
            {ok, State}
    end;

%% 取消准备
do_cast(
        {#'C2S_MahjongCancelPrepare'{} = _Msg, SeatId},
        #{?map_name := ?room_state, mahjongState := MahjongState, seat2player_id := Seat2PlayerId} = State) ->

    ReadySeats = maps:get(ready_seats, MahjongState),
    PlayerId   = maps:get(SeatId, Seat2PlayerId),
    case lists:member(SeatId, ReadySeats) of
        true ->
            Msg           = #'S2C_MahjongCancelPrepare'{playerId = PlayerId},
            ReplyBin      = pt:encode_msg(pt_mahjong, Msg),
            MahjongState1 = MahjongState#{ready_seats := lists:delete(SeatId, ReadySeats)},
            State1        = State#{mahjongState := MahjongState1},
            room_lib:broadcast(ReplyBin, State1),
            {ok, State1};
        false ->
            ?PRINT("~p未准备~n", [SeatId]),
            Msg = #'S2C_MahjongNoPrepare'{},
            ReplyBin = pt:encode_msg(pt_mahjong, Msg),
            room_lib:send_player(ReplyBin, PlayerId, State),
            {ok, State}
    end;

%% 游戏开始
do_cast(
        {#'C2S_MahjongStart'{} = _Msg, SeatId},
        #{?map_name := ?room_state, mahjongState := MahjongState, player_id2seat := PlayerId2Seat, seat2player_id := Seat2PlayerId, play_type := PlayType} = State) ->

    #{
        zhuangjia      := ZhuangJia,
        mahjong_seats := MahjongSeats
    } = MahjongState,
    ZhuangJiaSeatId = maps:get(ZhuangJia, PlayerId2Seat),
    PlayerId        = maps:get(SeatId, Seat2PlayerId),

    if
        SeatId =/= ZhuangJiaSeatId ->
            ?PRINT("~p你不是房主~n", [SeatId]),
            Msg      = #'S2C_MahjongNoOwner'{},
            ReplyBin = pt:encode_msg(pt_mahjong, Msg),
            room_lib:send_player(ReplyBin, PlayerId, State),
            {ok, State};

        true ->
            case length(maps:get(ready_seats, MahjongState)) of
                4 ->
                    MahjongState1  =
                        mahjong_lib:send_cards2player(ZhuangJiaSeatId, PlayType, MahjongSeats, MahjongState),
                    Temp           = [1, 2, 3, 4],
                    Msg            = #'S2C_MahjongStart'{
                        players    = [
                            #'Struct_MahjongPlayerBrief'{
                            id     = (maps:get(X, Seat2PlayerId)),
                            seatId = X
                        } || X <- Temp]
                    },
                    ReplyBin = pt:encode_msg(pt_mahjong, Msg),
                    State1 = State#{mahjongState := MahjongState1},
                    room_lib:broadcast(ReplyBin, State1),
                    {ok, State1};
                _ ->
                    ?PRINT("有玩家未准备~n"),
                    Msg      = #'S2C_MahjongHaveNoPrepare'{},
                    ReplyBin = pt:encode_msg(pt_mahjong, Msg),
                    room_lib:send_player(ReplyBin, PlayerId, State),
                    {ok, State}
            end
    end;

%% 换三张
do_cast(
        {#'C2S_MahjongChangeThree'{threeCards = ThreeCards} = _Msg, SeatId},
        #{?map_name := ?room_state, mahjongState := MahjongState, seat2player_id := Seat2PlayerId} = State) ->

    #{
        mahjong_seats          := MahjongSeats,
        no_change_three_seats := NoChangeThreeSeats,
        timer_ref              := Ref} = MahjongState,
    Seat      = element(SeatId + 1, MahjongSeats),
    HandCards = maps:get(hand_cards, Seat),
    PlayerId  = maps:get(SeatId, Seat2PlayerId),
    case length(NoChangeThreeSeats) of
        1 ->
            case mahjong_lib:can_change_three(SeatId, ThreeCards, HandCards, State) of
                {error, State1} ->
                    Msg = #'S2C_MahjongChangeThreeError'{},
                    ReplyBin = pt:encode_msg(pt_mahjong, Msg),
                    room_lib:send_player(ReplyBin, PlayerId, State1),
                    {ok, State1};

                {ok, State1} ->
                    util:cancel_timer(Ref),
                    {ok, ChangeType, State2} =
                        mahjong_lib:change_three_hdl(State1),
                    Msg = #'S2C_MahjongChangeThree'{changeType = ChangeType},
                    ReplyBin = pt:encode_msg(pt_mahjong, Msg),
                    room_lib:broadcast(ReplyBin, State2),
                    {ok, State2}
            end;
        _ ->
            case mahjong_lib:can_change_three(SeatId, ThreeCards, HandCards, State) of
                {ok, State1} ->
                    Msg = #'S2C_MahjongFinishChangeThree'{id = PlayerId},
                    ReplyBin = pt:encode_msg(pt_mahjong, Msg),
                    room_lib:broadcast(ReplyBin, State1),
                    {ok, State1};
                {error, State1} ->
                    Msg = #'S2C_MahjongChangeThreeError'{},
                    ReplyBin = pt:encode_msg(pt_mahjong, Msg),
                    room_lib:send_player(ReplyBin, PlayerId, State1),
                    {ok, State1}
            end
    end;

%% 定缺
do_cast(
        {#'C2S_MahjongDingQue'{color = Color } = _Msg, SeatId},
        #{?map_name := ?room_state, mahjongState := MahjongState, seat2player_id := Seat2PlayerId} = State) ->

    NoDingqueSeats = maps:get(no_dingque_seats, MahjongState),
    Ref            = maps:get(timer_ref, MahjongState),
    PlayerId       = maps:get(SeatId, Seat2PlayerId),
    case length(NoDingqueSeats) of
        1 ->
            case mahjong_lib:can_dingque(SeatId, Color, State) of
                {error, State1} ->
                    {ok, State1};

                {ok, State1} ->
                    util:cancel_timer(Ref),
                    {ok, Mahjong_seats, State2} = mahjong_lib:dingque_hdl(State1),
                    Msg = #'S2C_MahjongDingQue'{
                        players = [
                            #'Struct_MahjongDingQueBrief'{
                                id    = maps:get(X, Seat2PlayerId),
                                color = maps:get(dingque_color, element(X + 1, Mahjong_seats))
                            } || X <- [1, 2, 3, 4]]},
                    ReplyBin = pt:encode_msg(pt_mahjong, Msg),
                    room_lib:broadcast(ReplyBin, State2),
                    {ok, State2}
            end;
        _ ->
            case mahjong_lib:can_dingque(SeatId, Color, State) of
                {ok, State1} ->
                    Msg = #'S2C_MahjongFinishDingQue'{id = PlayerId},
                    ReplyBin = pt:encode_msg(pt_mahjong, Msg),
                    room_lib:broadcast(ReplyBin, State1),
                    {ok, State1};
                {error, State1} ->
                    {ok, State1}
            end
    end;

%% 打牌
do_cast(
        {#'C2S_MahjongDiscard'{cardId = CardId} = _Msg, SeatId},
        #{?map_name := ?room_state, mahjongState := MahjongState, seat2player_id := Seat2PlayerId} = State) ->

    #{
        mahjong_seats := MahjongSeats,
        timer_ref     := Ref
    } =MahjongState,
    Seat      = element(SeatId + 1, MahjongSeats),
    HandCards = maps:get(hand_cards, Seat),
    PlayerId  = maps:get(SeatId, Seat2PlayerId),

    case mahjong_tool:discard(HandCards, CardId) of
        {ok, HandCards1} ->
            util:cancel_timer(Ref),
            {ok, State1} = mahjong_lib:discard_hdl(SeatId, HandCards1, CardId, State),
            Msg          = #'S2C_MahjongDiscard'{cardId = CardId, seatId = SeatId},
            ReplyBin     = pt:encode_msg(pt_mahjong, Msg),
            room_lib:broadcast(ReplyBin, State1),
            {ok, State1};
        false ->
            Msg = #'S2C_MahjongNoCardId'{seatId = SeatId, cardId = CardId},
            ReplyBin = pt:encode_msg(pt_mahjong, Msg),
            room_lib:send_player(ReplyBin, PlayerId, State),
            {ok, State}
    end;


%% 碰
do_cast(
        {#'C2S_MahjongPongs'{cardId = CardId} = _Msg, SeatId},
        #{?map_name := ?room_state, mahjongState := MahjongState, seat2player_id := Seat2PlayerId} = State) ->
    #{
        mahjong_seats   := MahjongSeats,
        current_state  := CurrentState} = MahjongState,
    Seat      = element(SeatId + 1, MahjongSeats),
    HandCards = maps:get(hand_cards, Seat),
    PlayerId  = maps:get(SeatId, Seat2PlayerId),

    case mahjong_tool:can_pong(CardId, CurrentState, HandCards) of
        false ->
            Msg = #'S2C_MahjongNoPongs'{seatId = SeatId, cardId = CardId},
            ReplyBin = pt:encode_msg(pt_mahjong, Msg),
            room_lib:send_player(ReplyBin, PlayerId, State),
            {ok, State};
        true ->
           mahjong_lib:conflicts_hdl(pong, SeatId, CardId, State)
    end;

%%
%% 杠
do_cast(
        {#'C2S_MahjongKong'{cardId = CardId} = _Msg, SeatId},
        #{?map_name := ?room_state, mahjongState := MahjongState} = State) ->
    #{
        mahjong_seats  := MahjongSeats,
        current_state  := CurrentState
    } = MahjongState,
    Seat = element(SeatId + 1, MahjongSeats),
    #{
        hand_cards             := HandCards,
        not_in_hand_cards     := NotInHandCards,
        dingque_color         := _DingqueColor,
        record_counts         := _RecordCounts,
        current_seat_records := _CurrentSeatRecords
        } = Seat,
    Flag = mahjong_tool:can_kong(CurrentState, CardId, NotInHandCards, HandCards),
    case Flag of
        ?MAHJONG_ZHAGANG ->
            ?PRINT("玩家炸杠~n"),
            Msg = #'S2C_MahjongNoKong'{seatId = SeatId, cardId = CardId},
            ReplyBin = pt:encode_msg(pt_mahjong, Msg),
            room_lib:broadcast(ReplyBin, State),
            {ok, State};
        _ ->
            mahjong_lib:conflicts_hdl(kong, {SeatId, Flag}, CardId, State)
    end;

%% 自摸
do_cast(
        {#'C2S_MahjongZimo'{} = _Msg, SeatId},
        #{?map_name := ?room_state, mahjongState := MahjongState, play_type := PlayType, player_id2seat := PlayerId2Seat} = State) ->
    #{
        mahjong_seats     := MahjongSeats,
        timer_ref         := Ref,
        zhuangjia         := ZhuangJia,
        first_turn        := {_FirstTurn1, FirstTurn2}
        } = MahjongState,
    Seat = element(SeatId + 1, MahjongSeats),
    #{
        hand_cards             := HandCards,
        not_in_hand_cards     := NotInHandCards
    } = Seat,
    ZhuangJiaSeatId = maps:get(ZhuangJia, PlayerId2Seat),
    IsZhuangJia     = ZhuangJiaSeatId =:= SeatId,
    WinType = mahjong_tool:get_win_type(NotInHandCards, HandCards, PlayType, FirstTurn2, IsZhuangJia),

    case WinType of
        false ->
            ?PRINT("玩家炸自摸~n"),
            Msg = #'S2C_MahjongNoZimo'{seatId = SeatId},
            ReplyBin = pt:encode_msg(pt_mahjong, Msg),
            room_lib:broadcast(ReplyBin, State),
            {ok, State};
        _ ->
            util:cancel_timer(Ref),
            {ok, Faan1, State1} = mahjong_lib:zimo_hdl(SeatId, WinType, State),
            Msg = #'S2C_MahjongZimo'{winnerSeatId = SeatId, faan = Faan1},
            ReplyBin = pt:encode_msg(pt_mahjong, Msg),
            room_lib:broadcast(ReplyBin, State),
            {ok, State1}
    end;

%% 胡牌
do_cast(
        {#'C2S_MahjongHu'{} = _Msg, SeatId},
        #{?map_name := ?room_state, mahjongState := MahjongState} = State) ->
    #{
        mahjong_seats  := MahjongSeats,
        current_state  := CurrentState
    } = MahjongState,
    Seat = element(SeatId + 1, MahjongSeats),
    #{hand_cards := HandCards} = Seat,
    [_, _, CardId] = CurrentState,

    case mahjong_tool:can_win([CardId | HandCards]) of
        -1 ->
            ?PRINT("玩家炸胡~n"),
            Msg = #'S2C_MahjongNoHu'{seatId = SeatId},
            ReplyBin = pt:encode_msg(pt_mahjong, Msg),
            room_lib:broadcast(ReplyBin, State),
            {ok, State};
        _ ->
            mahjong_lib:conflicts_hdl(hu, SeatId, CardId, State)
    end;

%% 下一局
do_cast(
        {#'C2S_MahjongNextGame'{} = _Msg, SeatId},
        #{?map_name := ?room_state, mahjongState := MahjongState, seat2player_id := Seat2PlayerId} = State) ->

    NoNextRoundSeats = maps:get(no_next_round_seats, MahjongState),
    PlayerId         = maps:get(SeatId, Seat2PlayerId),
    case length(maps:get(no_next_round_seats, MahjongState)) of
        1 ->
            {MahjongState1, CurrentRound} = mahjong_lib:next_round_hdl(MahjongState),
            Msg = #'S2C_MahjongNextGame'{currentround = CurrentRound},
            ReplyBin = pt:encode_msg(pt_mahjong, Msg),
            State1 = State#{mahjongState := MahjongState1},
            room_lib:broadcast(ReplyBin, State1),
            {ok, State1};

        _ ->
            ?PRINT("等待其他玩家选择下一局准备~n"),
            State1 = State#{
                mahjongState := MahjongState#{
                    no_next_round_seats := lists:delete(SeatId, NoNextRoundSeats)}
            },
            Msg = #'S2C_MahjongHaveNoNextGame'{},
            ReplyBin = pt:encode_msg(pt_mahjong, Msg),
            room_lib:send_player(ReplyBin, PlayerId, State),
            {ok, State1}
    end.

%% 换三张超时
do_info(change_three,
        #{?map_name := ?room_state, mahjongState := MahjongState} = State) ->
    NoChangeThreeSeats = maps:get(no_change_three_seats, MahjongState),
    MahjongSeats       = maps:get(mahjong_seats, MahjongState),
    ?PRINT("没换三张的座位列表： ~p", [NoChangeThreeSeats]),
    MahjongSeats1      = mahjong_lib:auto_change_three(NoChangeThreeSeats, MahjongSeats),
    State1 = State#{
        mahjongState := MahjongState#{
            mahjong_seats := MahjongSeats1
        }},
    {ok, ChangeType, State2} = mahjong_lib:change_three_hdl(State1),

    Msg = #'S2C_MahjongChangeThree'{changeType = ChangeType},
    ReplyBin = pt:encode_msg(pt_mahjong, Msg),
    room_lib:broadcast(ReplyBin, State2),
    {ok, State2};

%% 定缺
do_info(dingque,
        #{?map_name := ?room_state, mahjongState := MahjongState, seat2player_id := Seat2PlayerId} = State) ->
    NoDingqueSeats = maps:get(no_dingque_seats, MahjongState),
    MahjongSeats   = maps:get(mahjong_seats, MahjongState),
    MahjongSeats1  = mahjong_lib:auto_dingque(NoDingqueSeats, MahjongSeats),
    State1 = State#{
        mahjongState := MahjongState#{
            mahjong_seats := MahjongSeats1
        }},
    {ok, MahjongSeats2, State2} = mahjong_lib:dingque_hdl(State1),

    Msg = #'S2C_MahjongDingQue'{
        players = [
            #'Struct_MahjongDingQueBrief'{
                id = maps:get(X, Seat2PlayerId),
                color = maps:get(dingque_color, element(X + 1, MahjongSeats2))
            } || X <- [1, 2, 3, 4]]},

    ReplyBin = pt:encode_msg(pt_mahjong, Msg),
    room_lib:broadcast(ReplyBin, State2),
    {ok, State2};

%% 摸牌
do_info({draw, SeatId},
        #{?map_name := ?room_state, mahjongState := MahjongState} = State) ->
    RemainCards = maps:get(remain_cards, MahjongState),
    case length(RemainCards) of
        0 ->   %% 一局麻将结束
            {ok, State1} = mahjong_lib:one_round_end_hdl(State),
            Msg = #'S2C_MahjongFinish'{},
            ReplyBin = pt:encode_msg(pt_mahjong, Msg),
            room_lib:broadcast(ReplyBin, State1),
            {ok, State1};
        _ ->
            {ok, CardId, State1} = mahjong_lib:draw_hdl(SeatId, State),
            Msg = #'S2C_MahjongDraw'{cardId = CardId, seatId = SeatId},
            ReplyBin = pt:encode_msg(pt_mahjong, Msg),
            room_lib:broadcast(ReplyBin, State1),
            {ok, State1}
    end;

%% 出牌
do_info({discard, SeatId},
        #{?map_name := ?room_state, mahjongState := MahjongState} = State) ->
    MahjongSeats = maps:get(mahjong_seats, MahjongState),
    Seat         = element(SeatId + 1, MahjongSeats),
    HandCards    = maps:get(hand_cards, Seat),
    do_cast({#'C2S_MahjongDiscard'{cardId = hd(HandCards)}, SeatId}, State);

%% 下一局
do_info(next_game,
        #{?map_name := ?room_state} = State) ->
    {State1, CurrentRound} = mahjong_lib:next_round_hdl(State),
    Msg = #'S2C_MahjongNextGame'{currentround = CurrentRound},
    ReplyBin = pt:encode_msg(pt_mahjong, Msg),
    room_lib:broadcast(ReplyBin, State1),
    {ok, State1};

%% 处理优先级pong，kong, hu
%%
do_info({kong, SeatId, CardId, Flag},
        #{?map_name := ?room_state} = State) ->
    {ok, State1} = mahjong_lib:kong_hdl(SeatId, CardId, Flag, State),
    Msg = #'S2C_MahjongKong'{seatId = SeatId, cardId = CardId},
    ReplyBin = pt:encode_msg(pt_mahjong, Msg),
    room_lib:broadcast(ReplyBin, State1),
    {ok, State1};

%% pong 超时处理
do_info({pong, SeatId, CardId},
        #{?map_name := ?room_state} = State) ->
    {ok, State1} = mahjong_lib:pong_hdl(SeatId, CardId, State),
    Msg = #'S2C_MahjongPongs'{seatId = SeatId, cardId = CardId},
    ReplyBin = pt:encode_msg(pt_mahjong, Msg),
    room_lib:broadcast(ReplyBin, State1),
    {ok, State1};

%% hu 超时处理
%% PlayType: 1:门清中将 2:幺九将对 3:天地胡
do_info({conflicts_hdl, hu, SeatId},
        #{?map_name := ?room_state, mahjongState := MahjongState, player_id2seat := PlayerId2Seat} = State) ->
    #{
        zhuangjia       := ZhuangJia,
        deal_conflicts := DealConflicts,
        zhuangjia_copy := ZhuangJiaCopy,
        current_state  := [_, Id, CardId]
    } = MahjongState,
    ZhuangJiaSeatId = maps:get(ZhuangJia, PlayerId2Seat),
    IsZhuangJia     = ZhuangJiaSeatId =:= SeatId,

    %% 将DealConflicts排序 -> DealConflicts2
    DealConflicts1  = maps:from_list(DealConflicts),
    DealConflicts2  = maps:to_list(DealConflicts1),

    KongSeatList    = [element(1, X) || X <- DealConflicts2, is_integer(element(2, X))],
    HuSeatList      = [element(1, X) || X <- DealConflicts2, element(2, X) =:= hu],

    %% 下局庄家的判断
    MahjongState1 =
        mahjong_judge:zhuangjia([HuSeatList, Id], ZhuangJiaCopy, MahjongState),

    %% 一炮多响，结算后摸牌者 Id2
    Id1 = mahjong_tool:get_up_seatid(Id),
    Id2 =
        case lists:member(Id1, HuSeatList) of
            true ->
                Id;
            false ->
                mahjong_tool:get_next_seatid(lists:last(HuSeatList))
        end,

    {List1, State1} =
        case KongSeatList of
            [] ->
                erlang:send_after(1000, self(), {mahjong, timeout, {draw, Id2}}),
                hupai_hdl(HuSeatList, 0, DealConflicts1, IsZhuangJia, State);
            [KongId] ->
                case maps:get(KongId, DealConflicts1) of
                    2 ->
                        erlang:send_after(1000, self(), {mahjong, timeout, {kong, KongId, CardId, 2}});
                    _ ->
                        erlang:send_after(1000, self(), {mahjong, timeout, {draw, Id2}})
                end,
                hupai_hdl(HuSeatList, KongId, DealConflicts1, IsZhuangJia, State)
        end,
    State2 = State1#{mahjongState := MahjongState1#{
        gang_no_hu_state := 0
    }},

    [room_lib:broadcast(X, State2) || X <- List1],
    {ok, State2}.



hupai_hdl(HuSeatList, KongId, DealConflicts, IsZhuangJia, State) ->
    hupai_hdl(HuSeatList, KongId, DealConflicts, IsZhuangJia, State, []).

hupai_hdl([], _KongId, _DealConflicts, _IsZhuangJia, State, List) ->
    {List, State};
hupai_hdl([H | HuSeatList], KongId, DealConflicts, IsZhuangJia, State, List) ->
    {ReplyBin, State1} =
        hupai(H, KongId, DealConflicts, IsZhuangJia, State),
    hupai_hdl(HuSeatList, KongId, DealConflicts, IsZhuangJia, State1, [ReplyBin | List]).

hupai(HuId, KongId, DealConflicts, IsZhuangJia,
        #{?map_name := ?room_state, mahjongState := MahjongState, play_type := PlayType} = State) ->

    #{
        mahjong_seats    := MahjongSeats,
        current_state    := CurrentState,
        first_turn       := {_FirstTurn1, FirstTurn2},
        no_hupai_seats   := NoHupaiSeats,
        gang_no_hu_state := GangNoHuState,
        remain_cards     := RemainCards
    } = MahjongState,
    Seat = element(HuId + 1, MahjongSeats),
    #{
        hand_cards            := HandCards,
        not_in_hand_cards    := NotInHandCards,
        current_seat_records := CurrentSeatRecords
    } = Seat,
    [_, Id, CardId] = CurrentState,

    WinType = mahjong_tool:get_win_type(NotInHandCards, [CardId | HandCards], PlayType, FirstTurn2, IsZhuangJia),
    Faan    = mahjong_tool:cacul_faan(WinType),

    %% 抢杠胡
    {WinType1, Faan1, MahjongSeats1} =
        mahjong_judge:qiangganghu(KongId, WinType, Faan, DealConflicts, MahjongSeats),

    %% 杠上炮
    {WinType2, Faan2} =
        mahjong_judge:gangshangpao(GangNoHuState, WinType1, Faan1),

    %% 海底炮
    {WinType3, Faan3} =
        mahjong_judge:haidipao(RemainCards, WinType2, Faan2),

    CurrentSeatRecords1 = {[{jiepao, [HuId, Id, CardId] ++ [WinType3]} | CurrentSeatRecords]},
    Seat1               = Seat#{current_seat_records := CurrentSeatRecords1},
    MahjongSeats2       = setelement(HuId + 1, MahjongSeats1, Seat1),
    NoHupaiSeats1       = lists:delete(HuId, NoHupaiSeats),
    State1              = State#{
        mahjongState := MahjongState#{
            mahjong_seats  := MahjongSeats2,
            hupai_count    := NoHupaiSeats1,
            deal_conflicts := []
        }},
    Msg = #'S2C_MahjongHu'{winnerSeatId = HuId, loserSeatId = Id, faan = Faan3},
    ReplyBin = pt:encode_msg(pt_mahjong, Msg),
    {ReplyBin, State1}.



