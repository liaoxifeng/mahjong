%% -*- coding: utf-8 -*-
%% Automatically generated, do not edit
%% Generated by gpb_compile version 4.4.0

-ifndef(pt_common).
-define(pt_common, true).

-define(pt_common_gpb_version, "4.4.0").

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
         device                 :: pt_common:'Struct_DeviceInfo'() % = 4
        }).
-endif.

-ifndef('S2C_LOGIN_PB_H').
-define('S2C_LOGIN_PB_H', true).
-record('S2C_Login',
        {id                     :: iolist(),        % = 1
         nickname               :: iolist(),        % = 3
         money                  :: non_neg_integer(), % = 4, 32 bits
         rooms = []             :: [pt_common:'Struct_RoomBrief'()] | undefined, % = 10
         notFinishedRoom        :: pt_common:'Struct_RoomBrief'() | undefined % = 11
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
