-ifndef(mahjong_hrl).
-define(mahjong_hrl, true).

-include("common.hrl").

%% 图案类型
-define(PATTERN_TYPE_NORMAL, 1).   %% 普通图案
-define(PATTERN_TYPE_WILD, 2).     %% 百变图案
-define(TIME, 8000).              %%打麻将等待时间
-define(TIME_WAIT_OP, 3000).

-define(MAHJONG_XUELIUCHENGHE, 1).              %% 麻将血流成河
-define(MAHJONG_CARD_TYPE_CHARACTER, 0).        %% 万
-define(MAHJONG_CARD_TYPE_DOT, 1).              %% 筒
-define(MAHJONG_CARD_TYPE_BAMBOO, 2).           %% 索

-define(MAHJONG_CHANGE_TYPE_NEXT, 1).           %% 1: 下家  逆时针换
-define(MAHJONG_CHANGE_TYPE_UP, 2).             %% 2：上家  顺时针换
-define(MAHJONG_CHANGE_TYPE_OPP, 3).            %% 3：对家 换

%% 返回值 0:炸杠 1: 暗杠 2: 明杠 3: 补杠
-define(MAHJONG_ANGANG, 1).
-define(MAHJONG_MINGGANG, 2).
-define(MAHJONG_BUGANG, 3).
-define(MAHJONG_ZHAGANG, 0).

%%麻将座位
-record(mahjong_seats, {
    seat1 :: seat_state(),
    seat2 :: seat_state(),
    seat3 :: seat_state(),
    seat4 :: seat_state()
}).

-define(record_count, record_count).
-type record_counts() :: #{
    ?map_name => ?record_count,
    zimo           => integer(),   %% 自摸次数
    jiepao         => integer(),
    dianpao        => integer(),
    angang         => integer(),
    minggang       => integer(),
    chadajiao      => integer(),
    chahuazhu      => integer()
}.


-define(seat_state, seat_state).
-type seat_state() :: #{
    ?map_name => ?seat_state,
    hand_cards               => list(),         %% 手牌
    not_in_hand_cards       => list(),          %% 非手牌，pong，kong,chow
    dingque_color           => integer(),       %% 定缺花色 0：万 ， 1：筒， 2;条 ， -1：默认值
    current_seat_records   => list(),           %% 个人当前pong，kong, hu的情况
    record_counts           => record_counts(),  %% 个人各种次数统计
    current_score           => integer(),       %% 当局个人分数
    all_score                => integer()       %% 全局分数

    }.


-define(mahjong_state, mahjong_state).
-type mahjong_state() :: #{
    ?map_name => ?mahjong_state,
    mahjong_seats            => any(),
    remain_cards             => list(),         %%牌堆
    ready_seats              => list(),         %%已准备的座位列表
    all_round                 => integer(),      %%游戏总局数
    current_round            => integer(),      %%当前游戏局数
    zhuangjia                 => binary(),       %%玩家id
    zhuangjia_copy           => integer(),      %%座位id
    no_change_three_seats   => list(),        %%未确定换三张的座位列表
    no_next_round_seats      => list(),        %%未选择下一局的座位列表
    change_three_type        => integer(),     %%换三张的方式
    no_dingque_seats         => list(),         %%未定缺的座位列表
    current_state            => list(),         %%摸牌：[draw, Seat_id, Elem],  打牌：[discard, Seat_id, Elem]
    timer_ref                 => ?undefined,     %%定时器的引用
    paiju_detail             => list(),          %%牌局详情
    first_turn               => any(),           %%判断是否是第一轮的状态
    no_hupai_seats           => list(),          %%未胡牌的座位
    deal_conflicts           => list(),          %%pong, kong与胡牌的冲突处理
    gang_no_hu_state         => integer()          %%杠上花，杠上炮的判断

}.

-export_type([
    record_counts/0,
    seat_state/0,
    mahjong_state/0]).

-endif.
