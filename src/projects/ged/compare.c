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

#include "ged.h"

int   cmpubyte( pubyte left, pubyte right, uint len )
{
   if ( *left < *right ) return -1;
   if ( *left > *right ) return 1;
   return 0;
}

int   cmpushort( pushort left, pushort right, uint len )
{
   if ( *left < *right ) return -1;
   if ( *left > *right ) return 1;
   return 0;
}

int   cmpuint( puint left, puint right, uint len )
{
   if ( *left < *right ) return -1;
   if ( *left > *right ) return 1;
   return 0;
}

int   cmpbyte( char* left, char* right, uint len )
{
   if ( *left < *right ) return -1;
   if ( *left > *right ) return 1;
   return 0;
}

int   cmpshort( pshort left, pshort right, uint len )
{
   if ( *left < *right ) return -1;
   if ( *left > *right ) return 1;
   return 0;
}

int   cmpint( pint left, pint right, uint len )
{
   if ( *left < *right ) return -1;
   if ( *left > *right ) return 1;
   return 0;
}

int   cmpstr( pubyte left, pubyte right, uint len )
{
   int ret;

   ret = CompareString( LOCALE_USER_DEFAULT, NORM_IGNORECASE,
                left, len, right, len );
   if ( ret == CSTR_LESS_THAN )
      return -1;
   if ( ret == CSTR_GREATER_THAN )
      return 1;
   return 0;
}

int   cmpustr( pushort left, pushort right, uint len )
{
   int ret;

   ret = CompareStringW( LOCALE_USER_DEFAULT, NORM_IGNORECASE,
                left, len, right, len );
   if ( ret == CSTR_LESS_THAN )
      return -1;
   if ( ret == CSTR_GREATER_THAN )
      return 1;
   return 0;
}