%% -*- coding: utf-8 -*-
%% Automatically generated, do not edit
%% Generated by gpb_compile version 4.4.0

-ifndef(pt_mahjong).
-define(pt_mahjong, true).

-define(pt_mahjong_gpb_version, "4.4.0").

-ifndef('C2S_MAHJONGPREPARE_PB_H').
-define('C2S_MAHJONGPREPARE_PB_H', true).
-record('C2S_MahjongPrepare',
        {
        }).
-endif.

-ifndef('S2C_MAHJONGPREPARE_PB_H').
-define('S2C_MAHJONGPREPARE_PB_H', true).
-record('S2C_MahjongPrepare',
        {playerId               :: iolist()         % = 2
        }).
-endif.

-ifndef('C2S_MAHJONGCANCELPREPARE_PB_H').
-define('C2S_MAHJONGCANCELPREPARE_PB_H', true).
-record('C2S_MahjongCancelPrepare',
        {
        }).
-endif.

-ifndef('S2C_MAHJONGCANCELPREPARE_PB_H').
-define('S2C_MAHJONGCANCELPREPARE_PB_H', true).
-record('S2C_MahjongCancelPrepare',
        {playerId               :: iolist()         % = 2
        }).
-endif.

-ifndef('STRUCT_MAHJONGPLAYERBRIEF_PB_H').
-define('STRUCT_MAHJONGPLAYERBRIEF_PB_H', true).
-record('Struct_MahjongPlayerBrief',
        {id                     :: iolist(),        % = 1
         seatId                 :: non_neg_integer() % = 2, 32 bits
        }).
-endif.

-ifndef('C2S_MAHJONGSTART_PB_H').
-define('C2S_MAHJONGSTART_PB_H', true).
-record('C2S_MahjongStart',
        {
        }).
-endif.

-ifndef('S2C_MAHJONGSTART_PB_H').
-define('S2C_MAHJONGSTART_PB_H', true).
-record('S2C_MahjongStart',
        {players = []           :: [pt_mahjong:'Struct_MahjongPlayerBrief'()] | undefined % = 2
        }).
-endif.

-ifndef('S2C_MAHJONGDRAW_PB_H').
-define('S2C_MAHJONGDRAW_PB_H', true).
-record('S2C_MahjongDraw',
        {cardId                 :: non_neg_integer(), % = 1, 32 bits
         seatId                 :: non_neg_integer() % = 2, 32 bits
        }).
-endif.

-ifndef('C2S_MAHJONGDISCARD_PB_H').
-define('C2S_MAHJONGDISCARD_PB_H', true).
-record('C2S_MahjongDiscard',
        {cardId                 :: non_neg_integer() % = 1, 32 bits
        }).
-endif.

-ifndef('S2C_MAHJONGDISCARD_PB_H').
-define('S2C_MAHJONGDISCARD_PB_H', true).
-record('S2C_MahjongDiscard',
        {cardId                 :: non_neg_integer(), % = 1, 32 bits
         seatId                 :: non_neg_integer() % = 2, 32 bits
        }).
-endif.

-ifndef('C2S_MAHJONGPONGS_PB_H').
-define('C2S_MAHJONGPONGS_PB_H', true).
-record('C2S_MahjongPongs',
        {cardId                 :: non_neg_integer() % = 1, 32 bits
        }).
-endif.

-ifndef('S2C_MAHJONGPONGS_PB_H').
-define('S2C_MAHJONGPONGS_PB_H', true).
-record('S2C_MahjongPongs',
        {seatId                 :: non_neg_integer(), % = 1, 32 bits
         cardId                 :: non_neg_integer() % = 2, 32 bits
        }).
-endif.

-ifndef('C2S_MAHJONGKONG_PB_H').
-define('C2S_MAHJONGKONG_PB_H', true).
-record('C2S_MahjongKong',
        {cardId                 :: non_neg_integer() % = 1, 32 bits
        }).
-endif.

-ifndef('S2C_MAHJONGKONG_PB_H').
-define('S2C_MAHJONGKONG_PB_H', true).
-record('S2C_MahjongKong',
        {seatId                 :: non_neg_integer(), % = 1, 32 bits
         cardId                 :: non_neg_integer() % = 2, 32 bits
        }).
-endif.

-ifndef('C2S_MAHJONGCHOW_PB_H').
-define('C2S_MAHJONGCHOW_PB_H', true).
-record('C2S_MahjongChow',
        {cardId                 :: non_neg_integer() % = 1, 32 bits
        }).
-endif.

-ifndef('S2C_MAHJONGCHOW_PB_H').
-define('S2C_MAHJONGCHOW_PB_H', true).
-record('S2C_MahjongChow',
        {seatId                 :: non_neg_integer(), % = 1, 32 bits
         cardId                 :: non_neg_integer(), % = 2, 32 bits
         meld = []              :: [non_neg_integer()] | undefined % = 3, 32 bits
        }).
-endif.

-ifndef('C2S_MAHJONGHU_PB_H').
-define('C2S_MAHJONGHU_PB_H', true).
-record('C2S_MahjongHu',
        {
        }).
-endif.

-ifndef('S2C_MAHJONGHU_PB_H').
-define('S2C_MAHJONGHU_PB_H', true).
-record('S2C_MahjongHu',
        {winnerSeatId           :: non_neg_integer(), % = 1, 32 bits
         loserSeatId            :: non_neg_integer(), % = 2, 32 bits
         faan                   :: non_neg_integer() % = 4, 32 bits
        }).
-endif.

-ifndef('C2S_MAHJONGZIMO_PB_H').
-define('C2S_MAHJONGZIMO_PB_H', true).
-record('C2S_MahjongZimo',
        {
        }).
-endif.

-ifndef('S2C_MAHJONGZIMO_PB_H').
-define('S2C_MAHJONGZIMO_PB_H', true).
-record('S2C_MahjongZimo',
        {winnerSeatId           :: non_neg_integer(), % = 1, 32 bits
         faan                   :: non_neg_integer() % = 2, 32 bits
        }).
-endif.

-ifndef('C2S_MAHJONGCHANGETHREE_PB_H').
-define('C2S_MAHJONGCHANGETHREE_PB_H', true).
-record('C2S_MahjongChangeThree',
        {seatId                 :: non_neg_integer(), % = 1, 32 bits
         threeCards = []        :: [non_neg_integer()] | undefined % = 2, 32 bits
        }).
-endif.

-ifndef('S2C_MAHJONGCHANGETHREE_PB_H').
-define('S2C_MAHJONGCHANGETHREE_PB_H', true).
-record('S2C_MahjongChangeThree',
        {changeType             :: non_neg_integer() % = 1, 32 bits
        }).
-endif.

-ifndef('C2S_MAHJONGDINGQUE_PB_H').
-define('C2S_MAHJONGDINGQUE_PB_H', true).
-record('C2S_MahjongDingQue',
        {seatId                 :: non_neg_integer(), % = 1, 32 bits
         color                  :: non_neg_integer() % = 2, 32 bits
        }).
-endif.

-ifndef('STRUCT_MAHJONGDINGQUEBRIEF_PB_H').
-define('STRUCT_MAHJONGDINGQUEBRIEF_PB_H', true).
-record('Struct_MahjongDingQueBrief',
        {id                     :: iolist(),        % = 1
         color                  :: non_neg_integer() % = 2, 32 bits
        }).
-endif.

-ifndef('S2C_MAHJONGDINGQUE_PB_H').
-define('S2C_MAHJONGDINGQUE_PB_H', true).
-record('S2C_MahjongDingQue',
        {players = []           :: [pt_mahjong:'Struct_MahjongDingQueBrief'()] | undefined % = 2
        }).
-endif.

-ifndef('C2S_MAHJONGNEXTGAME_PB_H').
-define('C2S_MAHJONGNEXTGAME_PB_H', true).
-record('C2S_MahjongNextGame',
        {
        }).
-endif.

-ifndef('S2C_MAHJONGNEXTGAME_PB_H').
-define('S2C_MAHJONGNEXTGAME_PB_H', true).
-record('S2C_MahjongNextGame',
        {currentround           :: non_neg_integer() % = 1, 32 bits
        }).
-endif.

-ifndef('S2C_MAHJONGNOPREPARE_PB_H').
-define('S2C_MAHJONGNOPREPARE_PB_H', true).
-record('S2C_MahjongNoPrepare',
        {
        }).
-endif.

-ifndef('S2C_MAHJONGNOOWNER_PB_H').
-define('S2C_MAHJONGNOOWNER_PB_H', true).
-record('S2C_MahjongNoOwner',
        {
        }).
-endif.

-ifndef('S2C_MAHJONGHAVENOPREPARE_PB_H').
-define('S2C_MAHJONGHAVENOPREPARE_PB_H', true).
-record('S2C_MahjongHaveNoPrepare',
        {
        }).
-endif.

-ifndef('S2C_MAHJONGFINISHCHANGETHREE_PB_H').
-define('S2C_MAHJONGFINISHCHANGETHREE_PB_H', true).
-record('S2C_MahjongFinishChangeThree',
        {id                     :: iolist()         % = 1
        }).
-endif.

-ifndef('S2C_MAHJONGFINISHDINGQUE_PB_H').
-define('S2C_MAHJONGFINISHDINGQUE_PB_H', true).
-record('S2C_MahjongFinishDingQue',
        {id                     :: iolist()         % = 1
        }).
-endif.

-ifndef('S2C_MAHJONGNOPONGS_PB_H').
-define('S2C_MAHJONGNOPONGS_PB_H', true).
-record('S2C_MahjongNoPongs',
        {seatId                 :: non_neg_integer(), % = 1, 32 bits
         cardId                 :: non_neg_integer() % = 2, 32 bits
        }).
-endif.

-ifndef('S2C_MAHJONGNOKONG_PB_H').
-define('S2C_MAHJONGNOKONG_PB_H', true).
-record('S2C_MahjongNoKong',
        {seatId                 :: non_neg_integer(), % = 1, 32 bits
         cardId                 :: non_neg_integer() % = 2, 32 bits
        }).
-endif.

-ifndef('S2C_MAHJONGNOZIMO_PB_H').
-define('S2C_MAHJONGNOZIMO_PB_H', true).
-record('S2C_MahjongNoZimo',
        {seatId                 :: non_neg_integer() % = 1, 32 bits
        }).
-endif.

-ifndef('S2C_MAHJONGNOHU_PB_H').
-define('S2C_MAHJONGNOHU_PB_H', true).
-record('S2C_MahjongNoHu',
        {seatId                 :: non_neg_integer() % = 1, 32 bits
        }).
-endif.

-ifndef('S2C_MAHJONGHAVENONEXTGAME_PB_H').
-define('S2C_MAHJONGHAVENONEXTGAME_PB_H', true).
-record('S2C_MahjongHaveNoNextGame',
        {
        }).
-endif.

-ifndef('S2C_MAHJONGFINISH_PB_H').
-define('S2C_MAHJONGFINISH_PB_H', true).
-record('S2C_MahjongFinish',
        {
        }).
-endif.

-ifndef('C2S_MAHJONGHISTORY_PB_H').
-define('C2S_MAHJONGHISTORY_PB_H', true).
-record('C2S_MahjongHistory',
        {gameType               :: non_neg_integer(), % = 1, 32 bits
         startTime              :: non_neg_integer(), % = 2, 32 bits
         endTime                :: non_neg_integer(), % = 3, 32 bits
         page                   :: non_neg_integer(), % = 4, 32 bits
         pageSize               :: non_neg_integer() % = 5, 32 bits
        }).
-endif.

-ifndef('STRUCT_MAHJONGHISTORY_PB_H').
-define('STRUCT_MAHJONGHISTORY_PB_H', true).
-record('Struct_MahjongHistory',
        {gameType               :: non_neg_integer(), % = 1, 32 bits
         time                   :: non_neg_integer(), % = 2, 32 bits
         cost                   :: non_neg_integer(), % = 3, 32 bits
         reward                 :: non_neg_integer(), % = 4, 32 bits
         start = []             :: [non_neg_integer()] | undefined, % = 6, 32 bits
         'end'                  :: non_neg_integer(), % = 7, 32 bits
         moneyBase              :: non_neg_integer(), % = 12, 32 bits
         moneyMulti             :: non_neg_integer() % = 13, 32 bits
        }).
-endif.

-ifndef('S2C_MAHJONGHISTORY_PB_H').
-define('S2C_MAHJONGHISTORY_PB_H', true).
-record('S2C_MahjongHistory',
        {data = []              :: [pt_mahjong:'Struct_MahjongHistory'()] | undefined % = 1
        }).
-endif.

-ifndef('STRUCT_DEVICEINFO_PB_H').
-define('STRUCT_DEVICEINFO_PB_H', true).
-record('Struct_DeviceInfo',
        {os                     :: iolist(),        % = 1
         deviceType             :: iolist(),        % = 2
         resolution             :: iolist(),        % = 3
         network                :: iolist()         % = 4
        }).
-endif.

-ifndef('S2C_PLAYERINFO1_PB_H').
-define('S2C_PLAYERINFO1_PB_H', true).
-record('S2C_PlayerInfo1',
        {moneyLeft              :: non_neg_integer() % = 2, 32 bits
        }).
-endif.

-ifndef('STRUCT_ROOMBRIEF_PB_H').
-define('STRUCT_ROOMBRIEF_PB_H', true).
-record('Struct_RoomBrief',
        {roomId                 :: non_neg_integer(), % = 1, 32 bits
         gameId                 :: non_neg_integer(), % = 2, 32 bits
         playerCount            :: non_neg_integer(), % = 3, 32 bits
         isLocked               :: boolean() | 0 | 1, % = 4
         ownerId                :: iolist()         % = 5
        }).
-endif.

-ifndef('STRUCT_ROOMPLAYERBRIEF_PB_H').
-define('STRUCT_ROOMPLAYERBRIEF_PB_H', true).
-record('Struct_RoomPlayerBrief',
        {id                     :: iolist(),        % = 1
         nickname               :: iolist(),        % = 3
         avatar                 :: iolist()         % = 4
        }).
-endif.

-ifndef('C2S_LOGIN_PB_H').
-define('C2S_LOGIN_PB_H', true).
-record('C2S_Login',
        {token                  :: iolist(),        % = 2
         version                :: non_neg_integer(), % = 3, 32 bits
         device                 :: pt_mahjong:'Struct_DeviceInfo'() % = 4
        }).
-endif.

-ifndef('S2C_LOGIN_PB_H').
-define('S2C_LOGIN_PB_H', true).
-record('S2C_Login',
        {id                     :: iolist(),        % = 1
         nickname               :: iolist(),        % = 3
         money                  :: non_neg_integer(), % = 4, 32 bits
         rooms = []             :: [pt_mahjong:'Struct_RoomBrief'()] | undefined, % = 10
         notFinishedRoom        :: pt_mahjong:'Struct_RoomBrief'() | undefined % = 11
        }).
-endif.

-ifndef('S2C_ERR_PB_H').
-define('S2C_ERR_PB_H', true).
-record('S2C_Err',
        {code                   :: 'E_S2CErrCode_Succ' | 'E_S2CErrCode_Sys' | 'E_S2CErrCode_Busy' | 'E_S2CErrCode_OpToFrequency' | 'E_S2CErrCode_ReLogin' | 'E_S2CErrCode_NotLogin' | 'E_S2CErrCode_LoginCheckTimeout' | 'E_S2CErrCode_LoginCheckNotThrough' | 'E_S2CErrCode_ErrArgs' | 'E_S2CErrCode_ProtoErr' | 'E_S2CErrCode_LoginTokenInvalid' | 'E_S2CErrCode_BeKicked' | 'E_S2CErrCode_NotEnoughMoney' | integer(), % = 1, enum EnumS2CErrCode
         type                   :: 'E_S2CTipsShowType_PopUp' | 'E_S2CTipsShowType_Marquee' | integer(), % = 2, enum EnumS2CTipsShowType
         msg                    :: iolist()         % = 3
        }).
-endif.

-ifndef('C2S_HEARTBEAT_PB_H').
-define('C2S_HEARTBEAT_PB_H', true).
-record('C2S_Heartbeat',
        {
        }).
-endif.

-ifndef('S2C_HEARTBEAT_PB_H').
-define('S2C_HEARTBEAT_PB_H', true).
-record('S2C_Heartbeat',
        {
        }).
-endif.

-ifndef('C2S_GM_PB_H').
-define('C2S_GM_PB_H', true).
-record('C2S_Gm',
        {cmd                    :: iolist(),        % = 1
         seqId                  :: integer(),       % = 2, 32 bits
         arg1                   :: iolist() | undefined, % = 11
         arg2                   :: iolist() | undefined, % = 12
         arg3                   :: iolist() | undefined, % = 13
         arg4                   :: iolist() | undefined, % = 14
         arg5                   :: iolist() | undefined, % = 15
         arg6                   :: iolist() | undefined, % = 16
         arg7                   :: iolist() | undefined, % = 17
         arg8                   :: iolist() | undefined, % = 18
         arg9                   :: iolist() | undefined % = 19
        }).
-endif.

-ifndef('S2C_GM_PB_H').
-define('S2C_GM_PB_H', true).
-record('S2C_Gm',
        {seqId                  :: integer(),       % = 2, 32 bits
         code                   :: integer()        % = 3, 32 bits
        }).
-endif.

-endif.