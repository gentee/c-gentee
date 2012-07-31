/******************************************************************************
*
* Copyright (C) 2006, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project <http://www.gentee.com>. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* lexgt2 03.11.2006
*
* Author: Generated with 'lextbl' program 
*
* Description: This file contains a lexical table for the lexical analizer.
*
******************************************************************************/


define
{
   // States
gt2_DATA = 0x110000 //  Value of the gt2 object 
gt2_COMMENT = 0x40000 //  Comments 
gt2_STRATTR = 0xB0000 //  Value of the attribute 
gt2_STRDQ = 0xC0000 //  Value of the attribute in the double quotes 
gt2_BEGIN = 0x70000 //  Begin of the gt2 object 
gt2_STRQ = 0xD0000 //  Value of the attribute in the apostrophes 
gt2_EQUAL = 0xA0000 //  Equal sign 
gt2_NAME = 0x90000 //  Identifier name 
gt2_END = 0x1000000 //  End of the gt2 object 

   // Keywords

}

global
{ 
   buf lexgt2 = '\h4  14 1 FD000000 3C3C 3020094 4 20 2D2D
 40001 2A2A 60000 7C7C 50000 3000 70201 0
 FD000100 1 FE000000 3E2D FE000900 2 20 2A2A
 60000 3000 70201 2 20 7C7C 50000 3000
 70201 1 80008 3000 FE000000 4 FD000000 4100
 90005 2F2F F0E0014 3D3D A0005 3E3E 100000 1
 80008 3000 FE000000 4 B0005 120 FD000000 3E2F2F
 80008 2222 C0005 2727 D0005 1 FE000000 2F3E0120
 80008 1 FE000000 2222 FE080000 1 FE000000 2727
 FE080000 2 20 3E3E 1000502 3000 FC000000 0
 FD080000 3 110005 120 FD000000 3C3C 14020094 2F3C
 130E0810 1 FE000000 2F3C 120E0810 0 FE110000 0
 110001 0 110101 0'
}
