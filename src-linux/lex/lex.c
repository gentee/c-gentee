/******************************************************************************
*
* Copyright (C) 2006, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* ID: lex 18.10.06 0.0.A.
*
* Author: Alexey Krivonogov ( gentee )
*
******************************************************************************/

#include "lex.h"
#include "lextbl.h"
//! temporary
#include "../os/user/defines.h"

//----------------------------------------------------------------------------

uint  STDCALL gentee_lexptr( pubyte in, plex pl, parr output )
{
   plexitem pli, pn;
   plexexp  pexp = 0;
   uint     pos, i, posoff = 0;
//   pubyte   in = buf_ptr( input );               // Входящий буфер
   puint    pmain = ( puint )buf_ptr( &pl->tbl );
   puint    ptbl = pmain;   // текущая строка разбора
   uint     cur = 0;    // Номер текущего разбираемого символа
   
   uint     newstate, cmd, nameoff, len;
   uint     flag, val, keyword = 0, istext = 0;
   lextry   ltry;
   uint     sn_pos, sn_len = 0;
   uint     isnew = 0;
   uint     pair = 0;

   arr_clear( &pl->state );
   arr_clear( &pl->expr );
   arr_clear( &pl->litems );
   arr_clear( &pl->mitems );
   pl->imulti = 0;
//   arr_appendnum( &pl->state, 0 );
   do 
   {
      val = ptbl[ in[ cur ]];   // Получаем новое состояние
rettry:
//      printf("val=%x %c cur=%i li=%i\n", val, in[cur], cur, arr_count( &pl->litems ));
      if ( pexp && ptbl == pmain )
      {
         if ( in[cur] == pexp->left )
            pexp->count++;
         if ( in[cur] == pexp->right )
         {
            if ( pexp->count )
               pexp->count--;
            else
            {
               val = ( pexp->state + 1 ) << 16;
               val |= LEXF_ITSTATE | LEXF_POS;
               arr_pop( &pl->expr );
               pexp = ( plexexp )arr_top( &pl->expr );
            }
         }
      }
      flag = val & 0xFFFF;
      if ( isnew )
      {
         flag |= LEXF_ITSTATE | LEXF_POS;
//         isnew = 0;
      }
      if ( flag & LEXF_PAIR )
      {
         switch ( in[ cur ] )
         {
            case '[' :
               pair++;
               flag = 0;
               val = LEX_OK;
               break;
            case ']' :
               if ( pair )
               {
                  pair--;
                  val = LEX_OK;
                  flag = 0;
               }
               break;
         }
      }
      if ( flag & LEXF_MULTI )
      {
         uint  curm, count, k;
         plexmulti   pmulti;
         pubyte      pcmp;
         
         curm = val >> 24;
         count = (( val >> 16 ) & 0xff );
         for ( i = 1; i <= count; i++ )
         {
            pmulti = ( plexmulti )arr_ptr( &pl->mitems, curm * 8 + i );
            pcmp = ( pubyte )&pmulti->chars;
//            printf( "CMP XXX %s ==% s len = %i\n", 
//                       pcmp, in + cur, pmulti->len );
            for ( k = 1; k < pmulti->len; k++ )
            {
               if ( pcmp[k] != in[ cur + k ] )
                  break;
            }
            if ( k == pmulti->len )
            {
               val = pmulti->value;
               pos = cur;
               cur += pmulti->len - 1;
               if ( val & LEXF_POS ) 
                  posoff = pmulti->len - 1;
//               printf( "Multi XXX %i val=%x pos = %i len = %i\n", 
//                       cur, val, pos, pmulti->len );
               goto rettry;
            }
         }
         val = (( plexmulti )arr_ptr( &pl->mitems, curm * 8 ))->value;
//         printf("Ooops 1= %x\n", val );
         goto rettry;
      }
      newstate = ( val >> 16 ) & 0xFF;
      cmd = val & 0xFF000000;
      if ( flag & LEXF_TRY ) 
      {
         ltry.pos = cur;
//         ltry.state = ((( pubyte )ptbl - buf_ptr( &pl->tbl )) >> 10 ) + 1;
         ltry.ret = cmd >> 24;
      }
      if ( flag & LEXF_RET ) 
      {
//         printf("Ret=%i\n", cur );
         cur = ltry.pos;//arr_pop( &pl->itry );
         val = *( puint )( buf_ptr( &pl->tbl ) + (( ltry.ret - 1 ) << 10 ) + 
                           sizeof( uint ));
//         val &= ~LEXF_RET;
         goto rettry;
      }

      if ( flag & LEXF_POS ) 
      {
         pos = cur - posoff;
         posoff = 0;
      }
      if ( flag & LEXF_ITCMD || flag & LEXF_ITSTATE )
      {  
         if ( istext && in[cur] == 0xa )
         {
            newstate = 2;
            istext = 0;
         }
         if ( keyword ) // Надо проверить предыдущую лексему на keyword 
         {
            ubyte  curch = in[ pli->pos + pli->len ];

            keyword = 0;
            in[ pli->pos + pli->len ] = 0;
            pli->value = hash_getuint( &pl->keywords, in + pli->pos );
//            printf( ">%s< %i = %i\n", in + pli->pos, pli->len, pli->value );
            if ( pli->value == 255 && 
               *( puint )( in + pli->pos ) == 0x74786574 )// text for gentee
            {
               in[ pli->pos + pli->len ] = curch;
               cur = pli->pos + pli->len;
               istext = 1;
               continue;
            }
            else
               in[ pli->pos + pli->len ] = curch;
         }
         // Добавляем лексему
         pli = arr_append( output );
         pli->type = ( flag & LEXF_ITCMD ) ? cmd : ( val & 0xFF0000 );
         pli->pos = pos;
         if ( isnew )
         {
            pli->type =  (((( pubyte )ptbl - buf_ptr( &pl->tbl )) >> 10 ) + 1 ) << 16 ;
//            printf( "TYPE NEW = %i\n", pli->type );
            isnew = 0;
         }
         pli->value = 0;
         pli->len = cur - pos + 1;
         if ( flag & LEXF_STAY )
            pli->len--;
         if ( flag & LEXF_VALUE )
         {
            for ( i = 0; i < pli->len; i++ )
               pli->value |= in[ pos + i ] << ( i << 3 );
         }
         if ( flag & LEXF_KEYWORD )
            keyword = 1;
//         printf("LEX_ITEM %i %i state=%x val=%x\n", pli->pos, pli->len, pli->type, val & 0xFF0000 );
      }
      switch ( cmd )
      {
         case LEX_STRNAME:
            if ( sn_len )            
            {
               if ( mem_cmp( in + cur, in + sn_pos, sn_len ))
               {
                  cur++;
                  continue;
               }
               sn_len = 0;
            }
            else
            {
               sn_pos = cur;
               while ( in[ cur ] && in[cur] != ']' )
                  cur++;
               sn_len = cur - sn_pos + 1;
//               printf("STR_NAME %i %i\n", sn_pos, sn_len );
               cur--;
            }
            break;
         case LEX_EXPR:
            pexp = ( plexexp )arr_append( &pl->expr );
            pexp->left = in[cur];
            pexp->right = in[cur] != '{' ? ')' : '}';
            pexp->count = 0;
            pexp->state = (( pubyte )ptbl - buf_ptr( &pl->tbl )) >> 10;
         case LEX_OK: 
            pli->len = cur - pli->pos + 1;//++;
//            printf("LEX_OK %i %i cur = %i c=%c\n", pli->pos, pli->len, cur, in[ cur ] );
            break;
         case LEX_GTNAME:
            pn = ( plexitem )arr_ptr( output, arr_getlast( &pl->litems ));
            nameoff = pn->pos + 1;
            if ( in[ nameoff ] == '|' )
               nameoff++;
            if ( in[ nameoff ] == '*' )
               nameoff++;
            len = pn->len - ( nameoff - pn->pos );

            for ( i = 0; i < len; i++ )
            {
               if ( in[ cur + i ] != in[ nameoff + i ])
                  break;
            }
//            printf("OK %i %c == %c\n", i, in[ cur + i], in[ nameoff + i ]);

            if ( i == len && in[ cur + i ] == '>' )
            {
               cur += i;
               continue;
            }
            else
            {
//               cur++;
         //      val = //ptbl[ 1 ];   
               cur = ltry.pos;//arr_pop( &pl->itry );
               val = *( puint )( buf_ptr( &pl->tbl ) + (( ltry.ret - 1 ) << 10 ) + 
                           sizeof( uint ));
//               printf( "GTNAME=%i %x\n", cur, val );
               goto rettry;
            }
            break;
      }
      if ( flag & LEXF_PUSHLI )
      {
         arr_appendnum( &pl->litems, arr_count( output ) - 1 );
//         printf("PUSHLI now = %i\n", arr_count( &pl->litems ));
      }
      if ( flag & LEXF_PUSH )
      {
//            arr_appendnum( &pl->litems, arr_count( output ) - 1 );
         i = (( pubyte )ptbl - buf_ptr( &pl->tbl )) >> 10;
         arr_appendnum( &pl->state, i + 1 );
//         printf("PUSH newstate = %x now = %i first=%i\n", i + 1, 
//                arr_count( &pl->state ), *( puint )arr_ptr( &pl->state, 0 ));
//            if ( flag & LEXF_NAME )
//               arr_appendnum( &pl->litems, arr_count( output ) - 1 );
      }
      if ( flag & LEXF_POPLI )
      {
         arr_pop( &pl->litems );
//         printf("POPLI now = %i\n", arr_count( &pl->litems ));
      }
      if ( flag & LEXF_POP )// && !newstate )
      {
         uint l = arr_pop( &pl->state );
         if ( !newstate )
            newstate = l;
         if ( flag & LEXF_NEW )
         {
            isnew = 1;
//            printf("NEW\n");
//         printf("POP newstate = %x remain = %i first=%i\n", newstate, 
//               arr_count( &pl->state ), *( puint )arr_ptr( &pl->state, 0 ));
         }
//         printf("POP newstate = %x remain = %i first=%i\n", newstate, 
//               arr_count( &pl->state ), *( puint )arr_ptr( &pl->state, 0 ));
      }
      if ( newstate )
         ptbl = ( puint )( buf_ptr( &pl->tbl ) + (( newstate - 1 ) << 10 ));
      if ( !( flag & LEXF_STAY ))
         cur++;

   } while ( cmd != LEX_STOP );

   return 1;
}

//----------------------------------------------------------------------------

uint  STDCALL gentee_lex( pbuf input, plex pl, parr output )
{
   return gentee_lexptr( buf_ptr( input ), pl, output );
}

//----------------------------------------------------------------------------

plex  STDCALL lex_init( plex pl, puint ptbl )
{
   if ( !pl )
   {
      pl = ( plex )mem_alloc( sizeof( lex ));
      pl->alloced = 1;
   }
   else 
      pl->alloced = 0;

   buf_init( &pl->tbl );
   arr_init( &pl->state, sizeof( uint ));
   arr_init( &pl->litems, sizeof( uint ));
   arr_init( &pl->mitems, sizeof( lexmulti ));
   arr_appenditems( &pl->mitems, 64 * 8 );
   pl->imulti = 0;
   hash_init( &pl->keywords, sizeof( uint ));
   arr_init( &pl->expr, sizeof( lexexp ));

   if ( ptbl )
      lex_tbl( pl, ptbl );
   return pl;
}

//----------------------------------------------------------------------------
 
void  STDCALL lex_delete( plex pl )
{
   buf_delete( &pl->tbl );
   arr_delete( &pl->state );
   arr_delete( &pl->litems );
   arr_delete( &pl->mitems );
   arr_delete( &pl->expr );
   hash_delete( &pl->keywords );
   if ( pl->alloced )
      mem_free( pl );
}
