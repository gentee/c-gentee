/******************************************************************************
*
* Copyright (C) 2009, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* Author: Alexey Krivonogov ( gentee )
*
******************************************************************************/

#include "windows.h"
#include "..\..\common\types.h"
#include <stdio.h>
#include <fcntl.h>
#include <io.h>

typedef uint  ( __cdecl *gentee_call )( uint, puint, ... );

#define FLN_ERROR     1
#define FLN_FILEBEGIN 2
#define FLN_FILEEND   3
#define FLN_ERROPEN   4
#define FLN_PROGRESS  5
#define FLN_NOTVALID  6  // Not CAB file
#define FLN_NEXTVOLUME 7






