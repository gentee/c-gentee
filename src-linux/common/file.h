/******************************************************************************
*
* Copyright (C) 2006, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* ID: file 18.10.06 0.0.A.
*
* Author: Alexey Krivonogov
*
* Summary: This file provides file system functions.
*
******************************************************************************/

#include "str.h"

pbuf  STDCALL file2buf( pstr name, pbuf ret, uint pos );
uint  STDCALL buf2file( pstr name, pbuf ret );
pstr  STDCALL gettempdir( pstr name );
pstr  STDCALL gettempfile( pstr name, pstr additional );
pstr  STDCALL getmodulename( pstr name );
pstr  STDCALL getmodulepath( pstr name, pstr additional );

//--------------------------------------------------------------------------
