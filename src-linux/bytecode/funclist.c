/******************************************************************************
*
* Copyright (C) 2006, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project <http://www.gentee.com>. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* funclist_c 16.06.2008 0.0.A.
*
* Author: Generated with 'funclist' program
*
* Summary: This file contains the embedded functions.
*
******************************************************************************/


#include <math.h>
#include "../genteeapi/gentee.h"
#include "funclist.h"
#include "bytecode.h"
#include "cmdlist.h"
#include "../common/crc.h"
#include "../common/mix.h"
#include "../common/arr.h"
#include "../common/collection.h"
#include "../vm/vmtype.h"
#include "../vm/vmres.h"
#include "../algorithm/qsort.h"
#include "../algorithm/search.h"

#ifdef RUNTIME
extern uint  STDCALL gentee_lex( pbuf input, plex pl, parr output );
extern plex  STDCALL lex_init( plex pl, puint ptbl );
extern void  STDCALL lex_delete( plex pl );
//uint  STDCALL gentee_lex( pbuf input, plex pl, parr output ){ return 0; }
//plex  STDCALL lex_init( plex pl, puint ptbl ){ return NULL; }
//void  STDCALL lex_delete( plex pl ){}
//uint  STDCALL gentee_compile( pcompileinfo compinit ){ return 0; }
#endif

#if defined (__WATCOMC__) || defined (__GNUC__)
   #define  ATOI64 atoll
   #define PUTENV putenv
#else
   #define  ATOI64 _atoi64
   #define PUTENV  _putenv
#endif

const ubyte embfuncs[] = {
'g', 'e', 't', 'i', 'd', 0, 0x83, TUint, TStr, TUint, TCollection, 
't', 'y', 'p', 'e', '_', 'h', 'a', 's', 'i', 'n', 'i', 't', 0, 0x81, TUint, TUint, 
't', 'y', 'p', 'e', '_', 'h', 'a', 's', 'd', 'e', 'l', 'e', 't', 'e', 0, 0x81, TUint, TUint, 
't', 'y', 'p', 'e', '_', 'i', 's', 'i', 'n', 'h', 'e', 'r', 'i', 't', 0, 0x82, TUint, TUint, TUint, 
't', 'y', 'p', 'e', '_', 'i', 'n', 'i', 't', 0, 0x82, TUint, TUint, TUint, 
't', 'y', 'p', 'e', '_', 'd', 'e', 'l', 'e', 't', 'e', 0, 0x2, TUint, TUint, 
's', 'i', 'z', 'e', 'o', 'f', 0, 0x81, TUint, TUint, 
'n', 'e', 'w', 0, 0x82, TUint, TUint, TUint, 
'd', 'e', 's', 't', 'r', 'o', 'y', 0, 0x1, TUint, 
'l', 'e', 'x', '_', 'i', 'n', 'i', 't', 0, 0x82, TUint, TUint, TUint, 
'l', 'e', 'x', '_', 'd', 'e', 'l', 'e', 't', 'e', 0, 0x1, TUint, 
'g', 'e', 'n', 't', 'e', 'e', '_', 'l', 'e', 'x', 0, 0x83, TUint, TUint, TUint, TUint, 
'g', 'e', 'n', 't', 'e', 'e', '_', 'c', 'o', 'm', 'p', 'i', 'l', 'e', 0, 0x81, TUint, TUint, 
'g', 'e', 'n', 't', 'e', 'e', '_', 's', 'e', 't', 0, 0x82, TUint, TUint, TUint, 
'm', 'a', 'l', 'l', 'o', 'c', 0, 0x81, TUint, TUint, 
'm', 'c', 'o', 'p', 'y', 0, 0x83, TUint, TUint, TUint, TUint, 
'm', 'c', 'm', 'p', 0, 0x83, TInt, TUint, TUint, TUint, 
'm', 'f', 'r', 'e', 'e', 0, 0x1, TUint, 
'm', 'm', 'o', 'v', 'e', 0, 0x83, TUint, TUint, TUint, TUint, 
'm', 'z', 'e', 'r', 'o', 0, 0x82, TUint, TUint, TUint, 
'm', 'l', 'e', 'n', 0, 0x81, TUint, TUint, 
'm', 'l', 'e', 'n', 's', 'h', 0, 0x81, TUint, TUint, 
'g', 'e', 't', 'c', 'h', 0, 0x80, TUint, 
's', 'c', 'a', 'n', 0, 0x82, TUint, TUint, TUint, 
'r', 'e', 's', '_', 'g', 'e', 't', 's', 't', 'r', 0, 0x81, TStr, TUint, 
'c', 'r', 'c', 0, 0x83, TUint, TUint, TUint, TUint, 
's', 't', 'r', 'c', 'm', 'p', 0, 0x82, TInt, TUint, TUint, 
's', 't', 'r', 'c', 'm', 'p', 'i', 'g', 'n', 0, 0x82, TInt, TUint, TUint, 
's', 't', 'r', 'c', 'm', 'p', 'l', 'e', 'n', 0, 0x83, TInt, TUint, TUint, TUint, 
's', 't', 'r', 'c', 'm', 'p', 'i', 'g', 'n', 'l', 'e', 'n', 0, 0x83, TInt, TUint, TUint, TUint, 
'u', 's', 't', 'r', 'c', 'm', 'p', 'l', 'e', 'n', 0, 0x83, TInt, TUint, TUint, TUint, 
'u', 's', 't', 'r', 'c', 'm', 'p', 'i', 'g', 'n', 'l', 'e', 'n', 0, 0x83, TInt, TUint, TUint, TUint, 
'g', 'e', 'n', 't', 'e', 'e', '_', 'p', 't', 'r', 0, 0x81, TUint, TUint, 
'a', 'r', 'g', 'c', 0, 0x80, TUint, 
'a', 'r', 'g', 'v', 0, 0x82, TStr, TStr, TUint, 
'c', 'a', 'l', 'l', 'a', 'd', 'd', 'r', 0, 0x80, TUint, 
'q', 's', '_', 'i', 'n', 'i', 't', 0, 0x4, TUint, TUint, TUint, TUint, 
'q', 's', '_', 's', 'e', 'a', 'r', 'c', 'h', 0, 0x83, TUint, TUint, TUint, TUint, 
'f', 'a', 's', 't', 's', 'o', 'r', 't', 0, 0x4, TUint, TUint, TUint, TUint, 
's', 'o', 'r', 't', 0, 0x4, TUint, TUint, TUint, TUint, 
'g', 'e', 't', 't', 'e', 'm', 'p', 0, 0x80, TStr, 
'@', 'a', 'p', 'p', 'e', 'n', 'd', 0, 0x83, TBuf, TBuf, TUint, TUint, 
'@', 'i', 'n', 'i', 't', 0, 0x81, TBuf, TBuf, 
'@', 'd', 'e', 'l', 0, 0x83, TBuf, TBuf, TUint, TUint, 
'@', 'd', 'e', 'l', 'e', 't', 'e', 0, 0x1, TBuf, 
'@', 'c', 'l', 'e', 'a', 'r', 0, 0x81, TBuf, TBuf, 
'@', 'c', 'o', 'p', 'y', 0, 0x83, TBuf, TBuf, TUint, TUint, 
'@', 'i', 'n', 's', 'e', 'r', 't', 0, 0x84, TBuf, TBuf, TUint, TUint, TUint, 
'@', 'f', 'r', 'e', 'e', 0, 0x81, TBuf, TBuf, 
'@', 'p', 't', 'r', 0, 0x81, TUint, TBuf, 
'@', 'l', 'o', 'a', 'd', 0, 0x83, TBuf, TBuf, TUint, TUint, 
'@', 'a', 'r', 'r', 'a', 'y', 0, 0x82, TBuf, TBuf, TUint, 
'@', 'i', 'n', 'd', 'e', 'x', 0, 0x82, TUint, TBuf, TUint, 
'@', 'r', 'e', 's', 'e', 'r', 'v', 'e', 0, 0x82, TBuf, TBuf, TUint, 
'@', 'e', 'x', 'p', 'a', 'n', 'd', 0, 0x82, TBuf, TBuf, TUint, 
'#', '*', 0, 0x81, TUint, TBuf, 
'#', '=', 0, 0x82, TBuf, TBuf, TBuf, 
'#', '+', '=', 0, 0x82, TBuf, TBuf, TBuf, 
'#', '+', '=', 0, 0x82, TBuf, TBuf, TUbyte, 
'#', '+', '=', 0, 0x82, TBuf, TBuf, TUshort, 
'#', '+', '=', 0, 0x82, TBuf, TBuf, TUint, 
'#', '+', '=', 0, 0x82, TBuf, TBuf, TUlong, 
'#', '=', '=', 0, 0x82, TUint, TBuf, TBuf, 
'@', 'f', 'i', 'n', 'd', 'c', 'h', 0, 0x83, TUint, TBuf, TUint, TUint, 
'@', 'f', 'i', 'n', 'd', 's', 'h', 0, 0x83, TUint, TBuf, TUint, TUint, 
'@', 'i', 'n', 'i', 't', 0, 0x81, TStr, TStr, 
'@', 'l', 'o', 'a', 'd', 0, 0x83, TStr, TStr, TUint, TUint, 
'@', 'c', 'o', 'p', 'y', 0, 0x82, TStr, TStr, TUint, 
'@', 'f', 'i', 'n', 'd', 'c', 'h', 0, 0x84, TUint, TStr, TUint, TUint, TUint, 
'@', 'f', 'i', 'n', 'd', 'c', 'h', 0, 0x82, TUint, TStr, TUint, 
'@', 'f', 'w', 'i', 'l', 'd', 'c', 'a', 'r', 'd', 0, 0x82, TUint, TStr, TStr, 
'@', 'p', 'r', 'i', 'n', 't', 0, 0x1, TStr, 
'p', 'r', 'i', 'n', 't', 0, 0x1, TStr, 
'@', 's', 'e', 't', 'l', 'e', 'n', 0, 0x82, TStr, TStr, TUint, 
'@', 's', 'u', 'b', 's', 't', 'r', 0, 0x84, TStr, TStr, TStr, TUint, TUint, 
'#', '=', 0, 0x82, TStr, TStr, TStr, 
'#', '+', '=', 0, 0x82, TStr, TStr, TStr, 
'#', '+', '=', 0, 0x82, TStr, TStr, TUint, 
'#', '*', 0, 0x81, TUint, TStr, 
'@', 'o', 'u', 't', '4', 0, 0x83, TStr, TStr, TStr, TUint, 
'@', 'o', 'u', 't', '8', 0, 0x83, TStr, TStr, TStr, TUlong, 
'@', 'i', 'n', 'd', 'e', 'x', 0, 0x82, TUint, TReserved, TUint, 
'@', 'i', 'n', 'i', 't', 0, 0x81, TArr, TArr, 
'@', 'd', 'e', 'l', 'e', 't', 'e', 0, 0x1, TArr, 
'@', 'o', 'f', 't', 'y', 'p', 'e', 0, 0x2, TArr, TUint, 
'@', 'a', 'r', 'r', 'a', 'y', 0, 0x2, TArr, TUint, 
'@', 'a', 'r', 'r', 'a', 'y', 0, 0x3, TArr, TUint, TUint, 
'@', 'a', 'r', 'r', 'a', 'y', 0, 0x4, TArr, TUint, TUint, TUint, 
'@', 'i', 'n', 'd', 'e', 'x', 0, 0x82, TUint, TArr, TUint, 
'@', 'i', 'n', 'd', 'e', 'x', 0, 0x83, TUint, TArr, TUint, TUint, 
'@', 'i', 'n', 'd', 'e', 'x', 0, 0x84, TUint, TArr, TUint, TUint, TUint, 
'#', '*', 0, 0x81, TUint, TArr, 
'@', 'e', 'x', 'p', 'a', 'n', 'd', 0, 0x82, TUint, TArr, TUint, 
'@', 'i', 'n', 's', 'e', 'r', 't', 0, 0x83, TUint, TArr, TUint, TUint, 
'@', 'd', 'e', 'l', 0, 0x83, TArr, TArr, TUint, TUint, 
'@', 'i', 'n', 'd', 'e', 'x', 0, 0x82, TUint, TCollection, TUint, 
'@', 'p', 't', 'r', 0, 0x82, TUint, TCollection, TUint, 
'@', 'g', 'e', 't', 't', 'y', 'p', 'e', 0, 0x82, TUint, TCollection, TUint, 
'#', '*', 0, 0x81, TUint, TCollection, 
'@', 'p', 'r', 'i', 'n', 't', 'f', 0, 0x83, TStr, TStr, TStr, TCollection, 
's', 'i', 'n', 0, 0x81, TDouble, TDouble, 
'c', 'o', 's', 0, 0x81, TDouble, TDouble, 
't', 'a', 'n', 0, 0x81, TDouble, TDouble, 
'a', 's', 'i', 'n', 0, 0x81, TDouble, TDouble, 
'a', 'c', 'o', 's', 0, 0x81, TDouble, TDouble, 
'a', 't', 'a', 'n', 0, 0x81, TDouble, TDouble, 
'e', 'x', 'p', 0, 0x81, TDouble, TDouble, 
'l', 'n', 0, 0x81, TDouble, TDouble, 
'l', 'o', 'g', 0, 0x81, TDouble, TDouble, 
'p', 'o', 'w', 0, 0x82, TDouble, TDouble, TDouble, 
's', 'q', 'r', 't', 0, 0x81, TDouble, TDouble, 
'a', 'b', 's', 0, 0x81, TUint, TInt, 
'f', 'a', 'b', 's', 0, 0x81, TDouble, TDouble, 
'm', 'o', 'd', 'f', 0, 0x82, TDouble, TDouble, TUint, 
'c', 'e', 'i', 'l', 0, 0x81, TDouble, TDouble, 
'f', 'l', 'o', 'o', 'r', 0, 0x81, TDouble, TDouble, 
's', 't', 'r', 't', 'o', 'l', 0, 0x83, TInt, TUint, TUint, TUint, 
's', 't', 'r', 't', 'o', 'u', 'l', 0, 0x83, TUint, TUint, TUint, TUint, 
'a', 't', 'o', 'f', 0, 0x81, TDouble, TUint, 
'a', 't', 'o', 'i', '6', '4', 0, 0x81, TLong, TUint, 
'_', 'g', 'e', 't', 'e', 'n', 'v', 0, 0x81, TUint, TUint, 
'_', 's', 'e', 't', 'e', 'n', 'v', 0, 0x81, TInt, TUint, 
};

const pvoid embfuncaddr[] = {
vm_getid, type_hasinit, type_hasdelete, type_isinherit, type_init, 
type_delete, type_sizeof, type_new, type_destroy, lex_init, lex_delete, 
gentee_lex, gentee_compile, gentee_set, mem_alloc, mem_copy, mem_cmp, 
mem_free, mem_move, mem_zero, mem_len, mem_lensh, os_getchar, os_scan, 
vmres_getstr, crc, os_strcmp, os_strcmpign, os_strcmplen, os_strcmpignlen, 
os_ustrcmplen, os_ustrcmpignlen, gentee_ptr, argc, argv, vm_calladdr, 
qs_init, qs_search, fastsort, sort, os_gettemp, buf_append, buf_init, 
buf_del, buf_delete, buf_clear, buf_copy, buf_insert, buf_free, buf_ptr, 
buf_copy, buf_array, buf_index, buf_reserve, buf_expand, buf_len, 
buf_set, buf_add, buf_appendch, buf_appendushort, buf_appenduint, 
buf_appendulong, buf_isequal, buf_find, buf_findsh, str_init, str_copylen, 
str_copyzero, str_find, str_findch, str_fwildcard, str_output, str_output, 
str_setlen, str_substr, str_copy, str_add, str_appenduint, str_len, 
str_out4, str_out8, mem_index, garr_init, garr_delete, garr_oftype, 
garr_array, garr_array2, garr_array3, garr_index, garr_index2, garr_index3, 
garr_count, garr_expand, garr_insert, garr_del, collect_index, collect_index, 
collect_gettype, collect_count, str_sprintf, sin, cos, tan, asin, 
acos, atan, exp, log, log10, pow, sqrt, labs, fabs, modf, ceil, floor, 
strtol, strtoul, atof, ATOI64, getenv, PUTENV,
};
