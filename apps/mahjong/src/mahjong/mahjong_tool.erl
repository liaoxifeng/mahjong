%%%-------------------------------------------------------------------
%%% @author feng.liao
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 27. 八月 2018 10:52
%%%-------------------------------------------------------------------
-module(mahjong_tool).
-author("feng.liao").

-include("mahjong.hrl").
-export([
    shuffle_and_send/2,
    auto_change_three_hdl/1,
    after_change/4,
    change_three_card/4,
    auto_dingque_hdl/1,
    draw/2,
    discard/2,
    can_pong/3,
    handle_pong/2,
    can_kong/4,
    handle_kong/4,
    get_win_type/5,
    cacul_faan/1,
    get_next_seatid/1,
    get_up_seatid/1,
    is_pure_hand/1,
    is_258_cards/1,
    is_all_one_nine/1,
    get_conf_card/1,
    get_chow_pong_kong_count/1,
    get_pair_four_count/1,
    get_conf_seven_pairs_card/1,
    list_remove/2,
    list_remove_three/4,
    list_remove_two/3





]).



%% 麻将初始化
-spec mahjong_init(integer()) -> list() | error.
mahjong_init(GameId) ->
    case GameId of
        ?MAHJONG_XUELIUCHENGHE ->
            List1 = lists:seq(1, 29),
            List2 = lists:filter(fun(X) -> X =/= 10 andalso X =/= 20 end, List1),
            List3 = List2 ++ List2 ++ List2 ++ List2,
            {ok, List3};
        _ ->
            error
    end.

%% 洗牌算法
shuffle(List) -> shuffle(List, [], length(List)).

shuffle([], Acc, _) -> {ok, Acc};
shuffle(List, Acc, Len) ->
    {Temp, [H | T]} = lists:split(rand:uniform(Len) - 1, List),
    shuffle(Temp ++ T, [H | Acc], Len - 1).

%% 洗牌发牌
-spec shuffle_and_send(integer(), integer()) -> list().
shuffle_and_send(GameId, PlayerCount) ->
    {ok, List} = mahjong_init(GameId),
    {ok, List1} = shuffle(List),
    send_card(List1, PlayerCount).

send_card(List, PlayerCount) ->
    send_card(List, PlayerCount, []).
send_card(List, 0, Return) ->
    List1 = lists:sort(List),
    Return ++ [List1];
send_card(List, PlayerCount, Return) ->
    {Player, List1} = lists:split(13, List),
    Player1 = lists:sort(Player),
    send_card(List1, PlayerCount - 1, Return ++ [Player1] ).


%% 换三张（可选玩法）
-spec change_three_card(list(), integer(), integer(), integer()) -> boolean() | list().
change_three_card(HandCards, CardId1, CardId2, CardId3) ->
    Bool1 = CardId1 div 10 =:= CardId2 div 10,
    Bool2 = CardId1 div 10 =:= CardId3 div 10,
    if
        Bool1, Bool2 ->
            HandCards1 = mahjong_tool:list_remove_three(CardId1, CardId2, CardId3, HandCards),
            [[CardId1, CardId2, CardId3], HandCards1];
        true -> false
    end.

%% 交换牌
-spec after_change(list(), list(), list(), list()) -> list().
after_change([H1|List1], [H2|List2], [H3|List3], [H4|List4]) ->
    case rand:uniform(3) of
        ?MAHJONG_CHANGE_TYPE_NEXT ->
            [lists:sort(lists:flatten([H4|List1])), lists:sort(lists:flatten([H1|List2])),
                lists:sort(lists:flatten([H2|List3])), lists:sort(lists:flatten([H3|List4])), ?MAHJONG_CHANGE_TYPE_NEXT];
        ?MAHJONG_CHANGE_TYPE_UP ->
            [lists:sort(lists:flatten([H2|List1])), lists:sort(lists:flatten([H3|List2])),
                lists:sort(lists:flatten([H4|List3])), lists:sort(lists:flatten([H1|List4])), ?MAHJONG_CHANGE_TYPE_UP];
        ?MAHJONG_CHANGE_TYPE_OPP ->
            [lists:sort(lists:flatten([H3|List1])), lists:sort(lists:flatten([H4|List2])),
                lists:sort(lists:flatten([H1|List3])), lists:sort(lists:flatten([H2|List4])), ?MAHJONG_CHANGE_TYPE_OPP]
    end.

%% 自动换三张
-spec auto_change_three_hdl(list()) -> list().
auto_change_three_hdl(HandCards) ->
    Characters = [X || X <- HandCards, X < 10],
    Dots       = [X || X <- HandCards, X > 10, X < 20],
    Bamboos    = [X || X <- HandCards, X > 20, X < 30],
    List       = get_type(Characters, Dots, Bamboos),                                %%数目最少且散牌最多的花色的列表
    SanList    = [X || X <- List, is_san_card(X, List)],                             %%其中散牌的列表
    NoSanList  = [X || X <- List, not lists:member(X, SanList)],                     %%其中不是散牌的列表
    ThreeCards = get_three_card(SanList, NoSanList),
    [CardId1, CardId2, CardId3] = ThreeCards,
    RemainHandCards             = list_remove_three(CardId1, CardId2, CardId3, HandCards),
    [ThreeCards, RemainHandCards].


%% 智能取出三张散牌，不够三张散牌，由小到大补充
-spec get_three_card(list(), list()) -> list().
get_three_card(SanList, [H | NoSanList]) ->
    if
        length(SanList) < 3 ->
            get_three_card([H | SanList], NoSanList);
        true ->
            [CardId1, CardId2, CardId3 | _] = SanList,
            lists:sort([CardId1, CardId2, CardId3])
    end;

get_three_card(SanList, []) ->
    [CardId1, CardId2, CardId3 | _] = SanList,
    lists:sort([CardId1, CardId2, CardId3]).

%% 换三张 花色选择
-spec get_type(list(), list(), list()) -> list().
get_type(Characters, Dots, Bamboos) ->
    Count1 = length(Characters),
    Count2 = length(Dots),
    Count3 = length(Bamboos),
    if
        Count1 >= 3, Count2 >= 3, Count3 >= 3 ->
            select_three(Characters, Dots, Bamboos);
        Count1 >= 3, Count2 >= 3, Count3 <  3 ->
            select_two(Characters, Dots);
        Count1 >= 3, Count2 <  3, Count3 >= 3 ->
            select_two(Characters, Bamboos);
        Count1 >= 3, Count2 <  3, Count3 <  3 ->
            Characters;
        Count1 <  3, Count2 >  3, Count3 >  3 ->
            select_two(Dots, Bamboos);
        Count1 <  3, Count2 >  3, Count3 <  3 ->
            Dots;
        Count1 <  3, Count2 <  3, Count3 >  3 ->
            Bamboos;
        true ->
            ignore
    end.

%% 在两种长度大于3 的花色中选一种花色
select_two(List1, List2) ->
    Count1 = length(List1),
    Count2 = length(List2),
    if
        Count1 > Count2 ->
            List2;
        Count1 < Count2 ->
            List1;
        true ->
            case select_same_two(List1, List2) of
                1 -> List1;
                2 -> List2
            end
    end.

%% 在三种长度大于3 的花色中选一种花色
select_three(List1, List2, List3) ->
    Count1 = length(List1),
    Count2 = length(List2),
    Count3 = length(List3),
    if
        Count1 > Count2 ->
            if
                Count2 > Count3 ->
                    List3;
                Count2 < Count3 ->
                    List2;
                true ->
                    case select_same_two(List2, List3) of
                        1 -> List2;
                        2 -> List3
                    end
            end;
        Count1 < Count2 ->
            if
                Count1 > Count3 ->
                    List3;
                Count1 < Count3 ->
                    List1;
                true ->
                    case select_same_two(List1, List3) of
                        1 ->
                            List1;
                        2 ->
                            List3
                    end
            end;
        true ->
            if
                Count1 > Count3 ->
                    List3;
                Count1 < Count3 ->
                    case select_same_two(List1, List2) of
                        1 ->
                            List1;
                        2 ->
                            List2
                    end;
                true ->
                    ignore
            end
    end.


%%在两种长度相等的花色中选择散牌更多的花色
select_same_two(List1, List2) ->
    if
        length(List1) =:= 0 ->
            rand:uniform(2);
        true ->
            Count1 = length([X || X <- List1, is_san_card(X, List1)]),
            Count2 = length([X || X <- List2, is_san_card(X, List2)]),
            if
                Count1 < Count2 ->
                    2;
                Count1 > Count2 ->
                    1;
                true ->
                    rand:uniform(2)
            end
    end.

%%判断 CardId 在List 是不是散牌
is_san_card(CardId, List) ->
    Num = get_same_num(CardId, List),
    Bool0 = lists:member(CardId - 2, List),
    Bool1 = lists:member(CardId - 1, List),
    Bool2 = lists:member(CardId + 1, List),
    Bool3 = lists:member(CardId + 2, List),
    if
        Num >= 2 ; Bool1 , Bool2 ; Bool0 , Bool1 ; Bool2 , Bool3 ->
            false;
        true ->
            true
    end.

%%自动选择定缺花色
-spec auto_dingque_hdl(list()) -> integer().
auto_dingque_hdl(HandCards) ->
    Characters = [X || X <- HandCards, X < 10],
    Dots       = [X || X <- HandCards, X > 10, X < 20],
    Bamboos    = [X || X <- HandCards, X > 20, X < 30],
    Count1 = length(Characters),
    Count2 = length(Dots),
    Count3 = length(Bamboos),
    if
        Count1 > Count2 ->
            if
                Count2 > Count3 ->
                    ?MAHJONG_CARD_TYPE_BAMBOO;
                Count2 < Count3 ->
                    ?MAHJONG_CARD_TYPE_DOT;
                true ->
                    case select_same_two(Bamboos, Dots) of
                        1 ->
                            ?MAHJONG_CARD_TYPE_BAMBOO;
                        2 ->
                            ?MAHJONG_CARD_TYPE_DOT
                    end
            end;
        Count1 < Count2 ->
            if
                Count1 > Count3 ->
                    ?MAHJONG_CARD_TYPE_BAMBOO;
                Count1 < Count3 ->
                    ?MAHJONG_CARD_TYPE_CHARACTER;
                true ->
                    case select_same_two(Characters, Bamboos) of
                        1 ->
                            ?MAHJONG_CARD_TYPE_CHARACTER;
                        2 ->
                            ?MAHJONG_CARD_TYPE_BAMBOO
                    end
            end;
        true ->
            if
                Count1 > Count3 ->
                    ?MAHJONG_CARD_TYPE_BAMBOO;
                Count1 < Count3 ->
                    case select_same_two(Characters, Dots) of
                        1 ->
                            ?MAHJONG_CARD_TYPE_CHARACTER;
                        2 ->
                            ?MAHJONG_CARD_TYPE_DOT
                    end;
                true ->
                    ignore
            end
    end.

%%摸牌
-spec draw(list(), list()) -> list().
draw(PlayerCards, [H | RemainCards]) ->
    [[H | PlayerCards], RemainCards].

%% 出牌
%% 打出一张牌,返回排序后的列表
-spec discard(list(), integer()) -> {ok, list()} | false.
discard(PlayerCards, CardId) ->
    case lists:member(CardId, PlayerCards) of
        true ->
            PlayerCards1 = lists:delete(CardId, PlayerCards),
            {ok, lists:sort(PlayerCards1)};
        false ->
            false
    end.

%% 碰
-spec can_pong(integer(), list(), list()) -> boolean().
can_pong(CardId, CurrentState, HandCards) ->
    case CurrentState of
        [draw, _, _] ->
            false;
        [discard, _Id, Elem] ->
            Count = get_same_num(Elem, HandCards),
            if
                Count >= 2, CardId =:= Elem ->
                    true;
                true ->
                    false
            end
    end.

%% 处理pong
-spec handle_pong(integer(), list()) -> list().
handle_pong(CardId, HandCards) ->
    [[CardId, CardId div 10, 3], list_remove_two(CardId, CardId, HandCards)].


%% 返回值 0:不杠 1: 暗杠 2: 明杠 3: 补杠
-spec can_kong(list(), integer(), list(), list()) -> integer().
can_kong(CurrentState, CardId, NotInHandCards, HandCards) ->
    case CurrentState of
        [draw, _, _] ->
            Bool = length([X || X <- NotInHandCards, hd(X) =:= CardId, lists:nth(3, X) =:= 3]) =:= 1,
            case get_same_num(CardId, HandCards) of
                4 ->
                ?MAHJONG_ANGANG;
                _ ->
                    if
                        Bool ->
                            ?MAHJONG_BUGANG;
                        true ->
                            ?MAHJONG_ZHAGANG
                    end
            end;
        [discard, _Id, Elem]  ->
            Num = get_same_num(Elem, HandCards),
            if
                Elem =:= CardId, Num =:= 3 ->
                    ?MAHJONG_MINGGANG;
                true ->
                    ?MAHJONG_ZHAGANG
            end
    end.

-spec handle_kong(integer(), integer(), list(), list()) -> list().
handle_kong(Flag, CardId, NotInHandCards, HandCards) ->
    case Flag of
        3 ->
            NotInHandCards1 = [X || X <- NotInHandCards, not (hd(X) =:= CardId)],
            [[[CardId, CardId div 10, 4]] ++ NotInHandCards1, lists:delete(CardId, HandCards)];
        _ ->
            [[[CardId, CardId div 10, 4]] ++ NotInHandCards, list_remove(CardId, HandCards)]
    end.

%% 吃   _,_,X    _,X,_    X,_,_
%%can_chow(Elem, Hand_cards) ->
%%  Bool1 = lists:member(Elem - 2, Hand_cards),lists:member(Elem - 1, Hand_cards),
%%  Bool2 = lists:member(Elem - 1, Hand_cards),lists:member(Elem + 1, Hand_cards),
%%  Bool3 = lists:member(Elem + 1, Hand_cards),lists:member(Elem + 2, Hand_cards),
%%  if
%%    Bool1;Bool2;Bool3 -> true;
%%    true -> false
%%  end.
%%
%%deal_chow(Elem, Hand_cards, Num1, Num2) ->
%%  Elem1 = Elem + 1,
%%  Elem2 = Elem + 2,
%%  Elem_1 = Elem - 1,
%%  Elem_2 = Elem - 2,
%%  case [Num1, Num2] of
%%    [Elem1 , Elem2] -> [[Elem, Elem div 10, 5] , list_remove_two(Num1, Num2, Hand_cards)];
%%    [Elem_1 , Elem_2] -> [[Elem_2, Elem_2 div 10, 5] , list_remove_two(Num1, Num2, Hand_cards)];
%%    [Elem1 , Elem_1] -> [[Elem_1, Elem_1 div 10, 5] , list_remove_two(Num1, Num2, Hand_cards)];
%%    _ -> false
%%  end.
%%


%%判断胡牌
%%  返回值 0： 七对胡牌  -1：炸胡  其他的整数（牌的id): 3*n + 2 胡牌   ----- 胡牌的眼
-spec can_win(list()) -> integer().
can_win(HandCards_) ->
    HandCards = lists:sort(HandCards_),
    Bool      = win_seven_pair(HandCards),
    if
        Bool ->
            0;
        true ->
            Eye = win_three_two(HandCards),
            if
                Eye =:= false ->
                    -1;
                true ->
                    Eye
            end
    end.

%%胡牌
%%3*n +2
win_three_two(HandCards) ->
    Temp1 = lists:usort( [X || X <- HandCards, filter(X, HandCards)]),
    Temp2 = [X || X <- Temp1, is_win_three_two(list_remove_two(X, X, HandCards))],
    if
        length(Temp2) =/= 0 ->
            lists:last(Temp2);
        true ->
            false
    end.

is_win_three_two([]) ->
    true;
is_win_three_two(HandCards) ->
    [CardId1, CardId2, CardId3 | HandCards1] = HandCards,
    if
        CardId1 =:= CardId2, CardId1 =:= CardId3 ->
            is_win_three_two(HandCards1);
        true ->
            Bool1 = lists:member(CardId1 + 1, HandCards),
            Bool2 = lists:member(CardId1 + 2, HandCards),
            if
                Bool1 , Bool2 ->
                    is_win_three_two(list_remove_three(CardId1, CardId1 + 1, CardId1 + 2, HandCards));
                true ->
                    false
            end
    end.

%% 七对胡牌
win_seven_pair(HardCards) ->
    if
        length(HardCards) =/= 14 ->
            false;
        true ->
            is_seven_pair(HardCards)
    end.

is_seven_pair([]) ->
    true;
is_seven_pair([CardId1, CardId2 | RemainList]) ->
    if
        CardId1 =:= CardId2 ->
            is_seven_pair(RemainList);
        true ->
            false
    end.

%%   参数：
%%   List:pong, kong的列表    Is_first_round : 是否第一轮  Is_banker ：是否是庄主  Play_type: 1:门清中将 2:幺九将对 3:天地胡
%%   Hand_cards： 手牌
-spec get_win_type(list(), list(), integer(), boolean(), boolean()) -> list() | fasle.
get_win_type(NotInHandCards, HandCards_, PlayType, IsFirstTurn, IsZhuangJia) ->
    HandCards = lists:sort(HandCards_),
    Num = can_win(HandCards),
    HuTypeIds6 =
        if
            Num =:= -1 ->
                -1;
            true ->
                %% 顺子，碰，杠次数的判断
                [AllCards, HuTypeIds] =
                    mahjong_judge:basic_hu(Num, NotInHandCards, HandCards),

                %% 清一色的判断
                HuTypeIds1 =
                    mahjong_judge:pure_hand(AllCards, HuTypeIds),

                %% 金钩胡的判断
                HuTypeIds2 =
                    mahjong_judge:jingouhu(HandCards, HuTypeIds1),

                %%门清中将的判断
                HuTypeIds3 =
                    mahjong_judge:is_menqing_zhongjiang(NotInHandCards, AllCards, HuTypeIds2, PlayType),

                %%天地胡的判断
                HuTypeIds4 =
                    mahjong_judge:is_tiandihu(IsFirstTurn, IsZhuangJia, HuTypeIds3, PlayType),

                %% 幺九将对的判断
                _HuTypeIds5 =
                    mahjong_judge:is_yaojiu_jiangdui(NotInHandCards, AllCards, HuTypeIds4, PlayType)
        end,
    case HuTypeIds6 of
        -1 ->
            false;
        [] ->
            [{<<"平胡"/utf8>>, 0}];
        _ ->
            List = lists:sort(HuTypeIds6),
            List1 =
                if
                    hd(List) =:= 1 ->
                        lists:delete(13, List);
                    true ->
                        List
                end,
            [cfg_mahjong_hutype_faan:get_hutype_faan(X) || X <- List1]
    end.

cacul_faan(List) ->
    Sum_list = [element(2, X) || X <- List],
    lists:sum(Sum_list).

%%判断X 在List中是否存在一对
filter(X, List) ->
    Num = get_same_num(X, List),
    if
        Num >= 2 ->
            true;
        true ->
            false
    end.

%% 获取列表中与Elem相等的元素的个数
get_same_num(Elem, List) ->
    Temp = [X || X <- List, X =:= Elem],
    length(Temp).
%%
%%个位是 2 5 8 的牌（将对，将七对）(伪将)
%% 参数Cards_list: 配置化后的所有牌
-spec is_258_cards(list()) -> boolean().
is_258_cards(CardList) ->
    Temp = [2, 5, 8],
    Temp1 = [lists:member(hd(X) rem 10, Temp) || X <- CardList],
    Bool  = lists:member(false, Temp1),
    if
        Bool->
            false;
        true ->
            true
    end.

%% 1:全幺九
%% 2:中将
-spec is_all_one_nine(list()) -> integer().
is_all_one_nine(CardsList) ->
    Temp      = [1, 9],
    Temp1     = [2, 3, 4],
    Temp2     = [lists:member(hd(X) rem 10, Temp) || X <- CardsList, lists:member(lists:nth(3, X), Temp1)],
    Temp3     = [having_one_nine(hd(X)) || X <- CardsList, lists:nth(3, X) =:= 5],
    Temp4     = Temp2 ++ Temp3,
    BoolFalse = lists:member(false, Temp4),
    BoolTrue  = lists:member(true, Temp4),
    if
        %%全幺九
        not BoolFalse ->
            1;
        %%中将（断幺九）
        not BoolTrue ->
            2;
        true ->
            0
    end.

having_one_nine(Elem) ->
    Temp  = [Elem rem 10, (Elem + 1) rem 10, (Elem + 2) rem 10],
    Bool1 = lists:member(1, Temp),
    Bool2 = lists:member(9, Temp),
    if
        Bool1 ; Bool2 ->
            true;
        true ->
            false
    end.

%% Pure hand (清一色)
-spec is_pure_hand(list()) -> boolean().
is_pure_hand(CardsList) ->
    CardId = lists:nth(2, hd(CardsList)),
    Temp   = [lists:nth(2, X) =:= CardId || X <- CardsList],
    Bool   = lists:member(false, Temp),
    if
        Bool->
            false;
        true ->
            true
    end.


%% 手牌(除了眼)配置化
%% 3*n
-spec get_conf_card(list())-> list() |false.
get_conf_card(CardsList) ->
    get_conf_card(CardsList, []).

get_conf_card([], Temp) ->
    Temp;
get_conf_card(CardsList, Temp)->
    [CardId1, CardId2, CardId3 | List] = CardsList,
    if
        CardId1 =:= CardId2, CardId1 =:= CardId3 ->
            get_conf_card(List, [[CardId1, CardId1 div 10, 3] | Temp]);
        true ->
            Bool1 = lists:member(CardId1 + 1, CardsList),
            Bool2 = lists:member(CardId1 + 2, CardsList),
            if
                Bool1 , Bool2 ->
                    CardsList1 = list_remove_three(CardId1, CardId1 + 1, CardId1 +2, CardsList),
                    get_conf_card(CardsList1, [[CardId1, CardId1 div 10, 5] | Temp]);
                true ->
                    false
            end
    end.

-spec get_chow_pong_kong_count(list())-> list().
get_chow_pong_kong_count(CardList) ->
    ChowCount = length([X || X <- CardList, lists:nth(3, X) =:= 5]),
    PongCount = length([X || X <- CardList, lists:nth(3, X) =:= 3]),
    KongCount = length([X || X <- CardList, lists:nth(3, X) =:= 4]),
    [ChowCount, PongCount, KongCount].

%%2*n
%% 14 张手牌
-spec get_conf_seven_pairs_card(list())-> list().
get_conf_seven_pairs_card(CardsList) ->
    get_conf_seven_pairs_card(lists:sort(CardsList), []).

get_conf_seven_pairs_card([], Temp) ->
    Temp;
get_conf_seven_pairs_card(CardsList, Temp) ->
    if
        length(CardsList) > 4 ->
            [CardId1, _, CardId2, _ | List] = CardsList,
            if
                CardId1 =:= CardId2 ->
                    get_conf_seven_pairs_card(List, [[CardId1, CardId1 div 10, 4] | Temp]);
                true ->
                    get_conf_seven_pairs_card(List, [[CardId1, CardId1 div 10, 2], [CardId2, CardId2 div 10, 2] | Temp])
            end;
        true ->
            [CardId1, CardId2 | List] = CardsList,
            if
                CardId1 =:= CardId2 ->
                    get_conf_seven_pairs_card(List, [[CardId1, CardId1 div 10, 2] | Temp]);
                true ->
                    false
            end
    end.

-spec get_pair_four_count(list()) -> list().
get_pair_four_count(CardList) ->
    PairCount = length([X || X <- CardList, lists:nth(3, X) =:= 2]),
    FourCount = length([X || X <- CardList, lists:nth(3, X) =:= 4]),
    [PairCount, FourCount].

%%删除列表中的元素
list_remove(X, [H | L]) ->
    list_remove(X, [H | L], []).

list_remove(_, [], List) ->
    lists:reverse(List);
list_remove(X, [H | L], List) ->
    if
        X =:= H ->
            list_remove(X, L, List);
        true ->
            list_remove(X, L, [H | List])
    end.

list_remove_three(X, Y, Z, List) ->
    lists:delete(Z, lists:delete(Y, lists:delete(X, List))).

list_remove_two(X, Y, List) ->
    lists:delete(Y, lists:delete(X, List)).

%%-spec pong_kong_premise(integer(), integer()) -> boolean().
%%pong_kong_premise(Elem, Dingque_num) ->
%%    case Elem div 10 of
%%        Dingque_num ->
%%            true;
%%        _ ->
%%            false
%%    end.
%%
%%-spec hupai_premise(list(), integer()) -> boolean().
%%
%%hupai_premise(Hand_cards, Dingque_num) ->
%%    case length([X || X <- Hand_cards, X div 10 =:= Dingque_num]) of
%%        0 ->
%%            true;
%%        _ ->
%%            false
%%    end.

get_next_seatid(SeatId) ->
    if
        SeatId =:= 4 ->
            1;
        true ->
            SeatId + 1
    end.

get_up_seatid(SeatId) ->
    if
        SeatId =:= 1 ->
            4;
        true ->
            SeatId - 1
    end.

%%t_test() ->
%%    ?assert(length([1,2,3]) =:= 2).