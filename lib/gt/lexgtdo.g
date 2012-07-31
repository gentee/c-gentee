/******************************************************************************
*
* Copyright (C) 2006, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project <http://www.gentee.com>. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* lexgtdo 24.11.2006
*
* Author: Generated with 'lextbl' program 
*
* Description: This file contains a lexical table for the lexical analizer.
*
******************************************************************************/


define
{
   // States
GTDO_Q = 0x110000 //  Text with '' inside () 
GTDO_PARCALL = 0x2000000 //   
GTDO_RP = 0x6000000 //  The right parenthesis 
GTDO_RSP = 0x7000000 //  The right parenthesis 
GTDO_SIGN = 0x30000 //  # character 
GTDO_PARSTEXT = 0xE0000 //  Simple text inside [] 
GTDO_TEXT = 0x20000 //  Simple text 
GTDO_DOT = 0x1000000 //  Dot in the name of the macro 
GTDO_DQ = 0x100000 //  Text with double-quotes inside () 
GTDO_PAR = 0x4000000 //  Number of the parameter &#1; 
GTDO_HEX = 0x3000000 //  Hexadecimal value of the character &xff; 
GTDO_PARTEXT = 0xD0000 //  Simple text inside () 
GTDO_COLON = 0xC0000 //  Text until new string 
GTDO_NAME = 0x40000 //  Macro name after # 
GTDO_SPACE = 0xF0000 //  Characters less or equal space inside () 
GTDO_COMMA = 0x5000000 //  The comma between parameters 
GTDO_LP = 0xA0000 //  Left parenthesis after macroname 
GTDO_LSP = 0xB0000 //  Left parenthesis after macroname 

   // Keywords

}

global
{ 
   buf lexgtdo = '\h4  12 2 20005 2626 12050014 2323 30005 1
 FE000000 262323 10008 2 10008 2F3000 40005 2E2E
 1000006 6 10008 3D3D 2010002 2F3000 FE000000 2828
 A0005 5B5B B0005 3A3A C0005 2E2E 30008 4
 20 785858 60000 2323 80000 A0D5C FD010800 A5C
 FD010800 1 20 5800 70000 2 20 3B3B
 3010002 5800 FD000000 1 20 3039 90000 2
 20 3B3B 4010002 3039 FD000000 5 D0005 120
 F0005 2C2C 5000006 2929 6010006 2222 100005 2727
 110005 2 E0005 5D5D 7010006 5B5D 50B0806 1
 FE000000 A0D 10808 1 FE000000 2C290120 A0008 1
 FE000000 5D5B5B B4008 1 A0008 120 FE000000 1
 FE000000 2222 FE0A0000 1 FE000000 2727 FE0A0000 0
 20001 0'
}
