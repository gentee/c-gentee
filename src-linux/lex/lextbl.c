/******************************************************************************
*
* Copyright (C) 2006, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* ID: lextbl 18.10.06 0.0.A.
*
* Author: Alexey Krivonogov ( gentee )
*
******************************************************************************/

#include "lex.h"
#include "lextbl.h"
//! temporary
#include "../os/user/defines.h"

//----------------------------------------------------------------------------

uint  STDCALL lex_tbl( plex pl, puint input )
{
   uint     count, states = *input++;
   uint     i, j, l, r, ch1, ch2, val;
   puint    start;
   pubyte   ptr;

   buf_clear( &pl->tbl );
   buf_reserve( &pl->tbl, states * 1024 );

   while ( states-- )
   {
      count = *input++;
      
      start = ( puint )( buf_ptr( &pl->tbl ) + buf_len( &pl->tbl ));
      // Записываем значения для 0 и по умолчанию
      for ( i = 0; i < 256; i++ )
         buf_appenduint( &pl->tbl, *input );
      if ( !( *input & LEXF_RET ))
         start[0] = LEX_STOP;
      for ( i = 0; i < count; i ++ )
      {
         val = *++input;
         l = HIBY( val );
         r = LOBY( val );
         ch1 = ( val >> 16 ) & 0xFF;
         ch2 = ( val >> 24 ) & 0xFF;
         val = *++input;
         if ( val & LEXF_MULTI )
         {
            uint curm, posm;
            plexmulti  pmulti;

            if ( start[r] & LEXF_MULTI )  // Уже добавлен один multi объект
            {
               curm = start[r] >> 24;
               posm = (( start[r] >> 16 ) & 0xff ) + 1;
            }
            else
            {
               // Надо запомнить команду в случае всех неудач и писать ее 
               // первой 
               curm = pl->imulti++;
               pmulti = arr_ptr( &pl->mitems, curm * 8 );
               pmulti->value = start[r];
               posm = 1;
               start[ r ] = ( curm << 24 ) | LEXF_MULTI;
            }
            start[ r ] &= 0xFF00FFFF;
            start[ r ] |= ( posm << 16 );
            pmulti = arr_ptr( &pl->mitems, curm * 8 + posm );
            pmulti->chars = *( input - 1 );
            if ( pmulti->chars >> 24 ) pmulti->len = 4;
            else
               if ( pmulti->chars >> 16 ) pmulti->len = 3;
               else
                  if ( pmulti->chars >> 8 ) pmulti->len = 2;
                  else pmulti->len = 1;
            pmulti->value = val & ~LEXF_MULTI;
//            printf("Posm 2 = %i start = %i %s\n", posm, (start[r] >> 16 ) & 0xFF,
//                      &(*( input - 1 )) );
            continue;
         }
         if ( l && !r)
         {
            switch ( l )
            {
               case 0x30:
                  for ( j = '0'; j <= '9'; j++ )
                     start[ j ] = val;
               case 0x41:
//                  printf("NumName\n");
                  start[ '_' ] = val;
                  for ( j = 'A'; j <= 'Z'; j++ )
                  {
                     start[ j ] = val;
                     start[ _lower[j] ] = val;
                  }
//                  for ( j = 'a'; j <= 'z'; j++ )
//                     start[ j ] = val;
                  for ( j = 0x80; j <= 0xff; j++ )
                     start[ j ] = val;
                  break;
               case 0x58:
                  for ( j = '0'; j <= '9'; j++ )
                     start[ j ] = val;
                  for ( j = 'A'; j <= 'F'; j++ )
                  {
                     start[ j ] = val;
                     start[ _lower[j] ] = val;
                  }
//                  for ( j = 'a'; j <= 'f'; j++ )
//                     start[ j ] = val;
                  break;
            }
         }
         else
            while ( l <= r )
               start[ l++ ] = val;
         if ( ch1 )
            start[ ch1 ] = val;
         if ( ch2 )
            start[ ch2 ] = val;
      }
      input++;
   }
   ptr = ( pubyte )input;
   if ( j = *ptr++ )
   {
      if ( *ptr++ & 0x0001 )
         pl->keywords.ignore = 1;
      for ( i = 0; i < j; i++ )
      {
         l = *( puint )ptr;
         ptr += sizeof( uint );
         while ( *ptr )
         {
            hash_setuint( &pl->keywords, ptr, l++ );
//            printf(">%s\n", ptr );
            ptr += mem_len( ptr ) + 1;
         }
         ptr++;
      }
   }
   return 1;
}

//----------------------------------------------------------------------------
