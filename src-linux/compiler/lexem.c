/******************************************************************************
*
* Copyright (C) 2006, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* ID: lexem 18.10.06 0.0.A.
*
* Author: Alexey Krivonogov ( gentee )
*
* Summary: Working with lexems
*
******************************************************************************/

#include "lexem.h"
#include "compile.h"
#include "../genteeapi/gentee.h"
#include "../lex/lex.h"
#include "../lex/lexgentee.h"
#include "operlist.h"
#include "ifdef.h"
#include "macro.h"
#include "../common/file.h"

uint _istext; // processing text function
uint _ishex;  // /h mode in binary
uint _bimode; // 1 2 4 or 8 in binary

/*-----------------------------------------------------------------------------
*
* ID: lexem_delete 30.10.06 0.0.A.
* 
* Summary: Delete the array of lexems.
*
-----------------------------------------------------------------------------*/

void  STDCALL  lexem_delete( parr lexems )
{
/*   plexem pil, end;

   pil = ( plexem )arr_ptr( lexems, 0 );
   end = ( plexem )arr_ptr( lexems, arr_count( lexems ));
   while ( pil < end )
   {
      if ( pil->type == LEXEM_STRING )
         str_delete( &pil->string );
      if ( pil->type == LEXEM_BINARY )
         buf_delete( &pil->binary );
      pil++;
   }*/
   arr_delete( lexems );
}

/*-----------------------------------------------------------------------------
*
* ID: lexem_isys 30.10.06 0.0.A.
* 
* Summary: If a lexem equals a character.
*
-----------------------------------------------------------------------------*/

uint  STDCALL lexem_isys( plexem plex, uint ch )
{
   return ( plex->type == LEXEM_OPER && plex->oper.name == ch );
}

/*-----------------------------------------------------------------------------
*
* ID: lexem_new 30.10.06 0.0.A.
* 
* Summary: Create a new lexem.
*
-----------------------------------------------------------------------------*/

plexem  STDCALL  lexem_new( parr lexems, uint pos, uint type, uint param )
{
   plexem     pl;

   pl = ( plexem )arr_append( lexems );
   pl->pos = pos;
   pl->type = ( ubyte )type;
   switch ( type )
   {
      case LEXEM_OPER:
         pl->oper.name = param;
         if ( param == ';' )
            pl->oper.operid = OpLine;
         else
            pl->oper.operid = hash_getuint( &_compile->opers, ( pubyte )&param );
         break;
      case LEXEM_NUMBER:
         num_getval( str_ptr( _compile->cur->src ) + pos, &pl->num );
         break;
      case LEXEM_STRING:
      case LEXEM_FILENAME:
         pl->strid = arr_count( &_compile->string ) - 1;
         break;
      case LEXEM_BINARY:
         pl->binid = arr_count( &_compile->binary ) - 1;
         break;
   }
   return pl;
}

/*-----------------------------------------------------------------------------
*
* ID: lexem_line 30.10.06 0.0.A.
* 
* Summary: Create a new line lexem.
*
-----------------------------------------------------------------------------*/

plexem  STDCALL  lexem_line( parr lexems, uint pos )
{
   return lexem_new( lexems, pos, LEXEM_OPER, ';' );
}

/*-----------------------------------------------------------------------------
*
* ID: lexem_name 30.10.06 0.0.A.
* 
* Summary: Create LEXEM_NAME lexem.
*
-----------------------------------------------------------------------------*/

plexem  STDCALL  lexem_nameptr( parr lexems, uint pos, uint value, pubyte name )
{
   phashitem  phi;
   plexem     pl;

   phi = hash_create( &_compile->names, name );
//   printf("%s = %i pos = %i len = %i\n", name, phi->id, pil->pos, pil->len );
   pl = ( plexem )arr_append( lexems );
   pl->pos = pos;
   if ( value )
   {
      pl->type = LEXEM_KEYWORD;
      pl->key = value;
   }
   else
   {
      pl->type = LEXEM_NAME;
      pl->nameid = phi->id;
   }
   return pl;
}

/*-----------------------------------------------------------------------------
*
* ID: lexem_name 30.10.06 0.0.A.
* 
* Summary: Create LEXEM_NAME lexem.
*
-----------------------------------------------------------------------------*/

plexem  STDCALL  lexem_name( parr lexems, plexitem pil )
{
   ubyte      name[256];
//   phashitem  phi;
//   plexem     pl;

   if ( pil->len > 255 )
      msg( MLongname | MSG_EXIT | MSG_POS, pil->pos );

   mem_copy( name, str_ptr( _compile->cur->src ) + pil->pos, pil->len );
   if ( name[ pil->len - 1 ] == '$' ) // Для макросов $name$
      pil->len--;
   name[ pil->len ] = 0;

   return lexem_nameptr( lexems, pil->pos, pil->value, name );
/*   phi = hash_create( &_compile->names, name );
//   printf("%s = %i pos = %i len = %i\n", name, phi->id, pil->pos, pil->len );
   pl = ( plexem )arr_append( lexems );
   pl->pos = pil->pos;
   if ( pil->value )
   {
      pl->type = LEXEM_KEYWORD;
      pl->key = pil->value;
   }
   else
   {
      pl->type = LEXEM_NAME;
      pl->nameid = phi->id;
   }
   return pl;*/
}

/*-----------------------------------------------------------------------------
*
* ID: lexem_str2macro 30.10.06 0.0.A.
* 
* Summary: Convert $name or $name$ in strings or binary to LEXEM_MACRO.
*
-----------------------------------------------------------------------------*/

void  STDCALL  lexem_str2macro( parr lexems, plexitem litem, plexitem pil, 
                                uint off )
{
   uint    len = 1;
   uint    j = off + len;
   pubyte  ptr = str_ptr( _compile->cur->src ) + pil->pos;

   while ( _name[ ptr[ j ]] )
      j++;
   if ( ptr[ j ] == '$' )
      j++;

   litem->type = G_MACRO;
   litem->pos = pil->pos + off;
   litem->len = j - off;
   litem->value = 0;

   lexem_name( lexems, litem )->type = LEXEM_MACRO;

   litem->pos = pil->pos + j;
   litem->len = pil->len - j;
}

/*-----------------------------------------------------------------------------
*
* ID: lexem_macrostr 30.10.06 0.0.A.
* 
* Summary: Create LEXEM_STRING lexem from MACROSTR.
*
-----------------------------------------------------------------------------*/

uint  STDCALL  lexem_macrostr( parr lexems, plexitem pil, uint shift, uint type )
{
   pstr      out;
   pubyte    ptr, cur;
   uint      i, end;
   plexem    pl;

   if ( !pil->len ) 
      return 1;
   out = str_init( ( pstr )arr_append( &_compile->string ));
   ptr = str_ptr( str_reserve( out, pil->len ));

   pl = lexem_new( lexems, pil->pos, type, 0 );
   end = pil->len - ( type == LEXEM_STRING ? 1 : 0 );
/*   pl = ( plexem )arr_append( lexems );
   pl->pos = pil->pos;
   pl->type = LEXEM_STRING;
   pl->strid = arr_count( &_compile->string ) - 1;*/

   cur = str_ptr( _compile->cur->src ) + pil->pos;
   for ( i = shift; i < end; i++ )
   {
      if ( type == LEXEM_STRING && cur[ i ] == '"' )
      {
         *ptr++ = '"';
         i++;
      }
      else
         if ( cur[ i ] == '$' )
         {
            if ( _name[ cur[ i + 1 ]] != 2 ) /* не имя */
            {
               *ptr++ = '$';
               if ( cur[ i + 1 ] == '$' )
                  i++;
            }
            else
            {
               lexitem  litem;

               *ptr = 0;
               str_setlen( out, ptr - str_ptr( out ));
               lexem_str2macro( lexems, &litem, pil, i );
               lexem_macrostr( lexems, &litem, 0, type );
               return 1;
            }
         }
         else
            *ptr++ = cur[i];
   }
//   if ( cur[i] != '"' )
//      msg( MUneofsb | MSG_LEXERR, pl );

   *ptr = 0;
   str_setlen( out, ptr - str_ptr( out ));
   return 1;
}

/*-----------------------------------------------------------------------------
*
* ID: lexem_oper 30.10.06 0.0.A.
* 
* Summary: Create LEXEM_OPER lexem.
*
-----------------------------------------------------------------------------*/

plexem  STDCALL  lexem_oper( parr lexems, uint pos, uint lexsys )
{
 /*  plexem     pl;

   pl = ( plexem )arr_append( lexems );
   pl->pos = pos;
   pl->type = LEXEM_OPER;
   pl->oper.name = lexsys;
   pl->oper.operid = hash_getuint( &_compile->opers, ( pubyte )&lexsys );;*/
   return lexem_new( lexems, pos, LEXEM_OPER, lexsys );
}

/*-----------------------------------------------------------------------------
*
* ID: lexem_string 30.10.06 0.0.A.
* 
* Summary: Create LEXEM_STRING lexem from MACROSTR.
*
-----------------------------------------------------------------------------*/

uint  STDCALL  lexem_endtext( parr lexems, uint pos )
{
   _istext = 0;
   lexem_oper( lexems, pos, '}' );
   return 1;
}

/*-----------------------------------------------------------------------------
*
* ID: lexem_emptystr 30.10.06 0.0.A.
* 
* Summary: Create empty LEXEM_STRING lexem.
*
-----------------------------------------------------------------------------*/

plexem  STDCALL  lexem_emptystr( parr lexems, uint pos )
{
   str_init( ( pstr )arr_append( &_compile->string ));
  
   return lexem_new( lexems, pos, LEXEM_STRING, 0 );
}

/*-----------------------------------------------------------------------------
*
* ID: lexem_string 30.10.06 0.0.A.
* 
* Summary: Create LEXEM_STRING lexem from MACROSTR.
*
-----------------------------------------------------------------------------*/

uint  STDCALL  lexem_string( parr lexems, plexitem pil, uint shift, uint text )
{
   pstr      out;
   pubyte    ptr, cur, start;
   ubyte     ch, prev;
   uint      i, k, len, pos;
   plexem    pl;
   lexitem   litem;

   if ( !pil->len ) 
      return 1;

   cur = str_ptr( _compile->cur->src ) + pil->pos;
   if ( shift && cur[ 0 ] == ')' )
   {
      lexem_oper( lexems, pil->pos, ')' );
      if ( !text )
         lexem_oper( lexems, pil->pos, LSYS_PLUSEQ )->oper.operid = OpStrappend;
   }
   if ( text )
   {
      lexem_line( lexems, pil->pos );
      lexem_oper( lexems, pil->pos, 0 )->oper.operid = OpStrtext;
   }

   out = str_init( ( pstr )arr_append( &_compile->string ));
   start = ptr = str_ptr( str_reserve( out, pil->len ));
   
/*   pl = ( plexem )arr_append( lexems );
   pl->pos = pil->pos;
   pl->type = LEXEM_STRING;
   pl->strid = arr_count( &_compile->string ) - 1;*/
   pl = lexem_new( lexems, pil->pos, LEXEM_STRING, 0 );
//   print("String pos=%i len = %i\n", pil->pos, pil->len );
   for ( i = shift; i < pil->len - 1; i++ )
   {
      if ( cur[i] == '\\' )
      {
         pos = pil->pos + i;
         i++;
//         print("String x=%i %c\n", i, cur[i] );
         switch ( cur[ i ] )
         {
            case '\\' :
            case '"' :
               *ptr++ = cur[ i ];
               break;
            case 'r' :
               *ptr++ = 0xd;
               break;
            case 'n' :
               *ptr++ = 0xa;
               break;
            case 't' :
               *ptr++ = 0x9;
               break;
            case 'l' :
               *ptr++ = 0xd;
               *ptr++ = 0xa;
               break;
            case 0xd :
            case 0xa :
               if ( cur[ i ] == 0xd && cur[ i + 1 ] == 0xa )
                  i++;
               break;
            case '#':
               if ( ptr > start )
                  ch = *--ptr;
               while ( ptr > start )
               {
                  prev = *( ptr - 1 );
                  if ( ch== prev || (( ch == 0xa || ch == 0xd ) && 
                      ( prev == 0xa || prev == 0xd )) ||
                      (( ch == ' ' || ch == 0x9 ) && 
                      ( prev == ' ' || prev == 0x9 )) )
                     ptr--;
                  else
                     break;
               }
               break;
            case '0':
               i++;
               *ptr++ = ( _hex[cur[ i ]] << 4 ) + _hex[ cur[ i + 1 ]];
               i++;
               break;
            case '*':  // Надо ли это?
               while ( ++i < pil->len - 1 )
               {
                  if ( cur[ i ] == '*' && cur[ i + 1 ] == '\\' )
                     break;
               }
               i++;
               break;
            case '$':
               *ptr = 0;
               str_setlen( out, ptr - str_ptr( out ));
               
               lexem_str2macro( lexems, &litem, pil, i );
               lexem_string( lexems, &litem, 0, text );
               return 1;
            case '[':
               k = i;
               len = 1;
               while ( ++k < pil->len - 1 && cur[ k ] != ']' )
               len = k - i + 1;
                  
               while ( ++k < pil->len - 1 )
               {
                  if ( cur[ k ] == '[' && !mem_cmp( cur + k, cur + i, len ))
                  {
                     k += len;
                     break;
                  }
                  *ptr++ = cur[k];
               }
               i = k;
               break;
            case '(':       
               if ( text )
               {
                  lexem_line( lexems, pos );
                  lexem_oper( lexems, pos, '@' );
                  lexem_emptystr( lexems, pos );
                  // Может быть новый alloc для элементов
                  // Надо присваивать заново !
                  out = ( pstr )arrdata_get( &_compile->string, 
                                 arr_count( &_compile->string ) - 2 );
 //                 lexem_oper( lexems, pos, 0 )->oper.operid = OpStrset;
//                  lexem_oper( lexems, pos, '(' );
               }
//               else
//               {
                  // +=
                  lexem_oper( lexems, pos, LSYS_PLUSEQ )->oper.operid = OpStrappend;
                  lexem_oper( lexems, pos, '(' );
//               }
               goto stop;
            default:
               if ( text )
               {
                  switch ( cur[ i ] )
                  {
                     case '!' :
                        lexem_endtext( lexems, pos );
                        goto stop;
                     case '{' :
                        lexem_line( lexems, pos );
                        goto stop;
                     case '@' :
                        lexem_line( lexems, pos );
                        lexem_oper( lexems, pos, '@' );
                        goto stop;
                  } 
               }
               msg( MUnksbcmd | MSG_EXIT | MSG_VALUE | MSG_POS, pos, 
                    cur[ i ] );
         }
//         i++;
         continue;
      }
      *ptr++ = cur[i];
   }
//   if ( cur[i] != '"' && cur[ i + 1 ] != '\\' )
//      msg( MUneofsb | MSG_LEXERR, pl );
//end:
//   if ( text )
//   {
//      if ( cur[ i + 1 ]!= '!' && cur[ i + 1 ] != '(' && cur[ i + 1 ] != '{')
//         *ptr++ = cur[ pil->len - 1 ];
//   }
//   else
      if ( cur[ pil->len - 1 ] != '"' )//&& cur[ pil->len - 1 ] != '(')
         *ptr++ = cur[ pil->len - 1 ];
stop:
   *ptr = 0;
   str_setlen( out, ptr - str_ptr( out ));
//   print( "Out=%s len=%i num=%i\n", str_ptr( out ), str_len( out ),
//          arr_count( &_compile->string ));
   return 1;
}

/*-----------------------------------------------------------------------------
*
* ID: lexem_binary 30.10.06 0.0.A.
* 
* Summary: Create LEXEM_BINARY lexem.
*
-----------------------------------------------------------------------------*/

uint  STDCALL  lexem_binary( parr lexems, plexitem pil, uint shift )
{
   pbuf      out;
   pubyte    cur;
   uint      i, k, pos;
   plexem    pl;
   lexitem   litem;
   number    num;

   if ( !pil->len ) 
      return 1;

   cur = str_ptr( _compile->cur->src ) + pil->pos;
   if ( shift && cur[ 0 ] == ')' )
   {
      lexem_oper( lexems, pil->pos, ')' );
      lexem_oper( lexems, pil->pos, LSYS_PLUSEQ )->oper.operid = OpStrappend;
   }

   out = buf_init( ( pstr )arr_append( &_compile->binary ));
   buf_reserve( out, pil->len );
   
   pl = lexem_new( lexems, pil->pos, LEXEM_BINARY, 0 );

   for ( i = shift; i < pil->len - 1; i++ )
   {
      if ( cur[i] <= ' ' || cur[i] == ',' || cur[i] == ';'  )
         continue;
      if ( cur[i] == '\\' )
      {
         pos = pil->pos + i;
         i++;
         switch ( cur[ i ] )
         {
            case '"':
               while ( ++i < pil->len - 1 )
               {
                  if ( cur[ i ] == '"' )
                     break;
                  buf_appendch( out, cur[i] );
               }
               break;
            case '*':
               while ( ++i < pil->len - 1 )
               {
                  if ( cur[ i ] == '*' && cur[ i + 1 ] == '\\' )
                     break;
               }
               i++;
               break;
            case '$':
               lexem_str2macro( lexems, &litem, pil, i );
               lexem_binary( lexems, &litem, 0 );
               // Может быть новый alloc для элементов
               // Надо присваивать заново !
               out = ( pbuf )arrdata_get( &_compile->binary, 
                              arr_count( &_compile->binary ) - 2 );
               return 1;
            case '(':       
                  // +=
               lexem_oper( lexems, pos, LSYS_PLUSEQ )->oper.operid = OpStrappend;
               lexem_oper( lexems, pos, '(' );
               return 1;
            case 'h':
            case 'i':
               _ishex = ( cur[ i ] == 'h' ? 1 : 0 );
               switch ( cur[ i + 1 ] ) {
                  case '2':
                  case '4':
                  case '8':
                     _bimode = cur[ ++i ] - '0';
                     break;
                  default:
                     _bimode = 1;
                     break;
               }
               break;
            default:
               msg( MUnksbcmd | MSG_EXIT | MSG_VALUE | MSG_POS, pos, 
                    cur[ i ] );
         }
         continue;
      }
      if ( _ishex )
         k = num_gethex( cur + i, &num, _bimode ) - cur;
      else
         k = num_getval( cur + i, &num ) - cur;
      if ( i == k )
         msg( MUnkbinch | MSG_EXIT | MSG_POS | MSG_VALUE, pil->pos + i, cur[i] );
      switch ( num.type )
      {
         case TFloat:
            buf_append( out, ( pubyte )&num.vfloat, sizeof( float ));
            break;
         case TLong:
         case TUlong:
         case TDouble:
            buf_append( out, ( pubyte )&num.vdouble, sizeof( double ));
            break;
         default:
//               printf("Append =%i i=%i k=%i\n", num.vint, i, k );
            buf_append( out, ( pubyte )&num.vint, _bimode );
      }
      i = k - 1;
//      *ptr++ = cur[i];
   }
//   if ( cur[ pil->len - 1 ] != '\'' )//&& cur[ pil->len - 1 ] != '(')
//         *ptr++ = cur[ pil->len - 1 ];
//stop:
//   *ptr = 0;
//   str_setlen( out, ptr - str_ptr( out ));

//   printf( str_ptr( out ));
   return 1;
}

/* -----------------------------------------------------------------------------
*
* ID: lexem_number 30.10.06 0.0.A.
* 
* Summary: Create LEXEM_NUMBER lexem.
*
----------------------------------------------------------------------------

uint  STDCALL  lexem_number( parr lexems, plexitem pil )
{
   plexem    pl;

   pl = ( plexem )arr_append( lexems );
   pl->pos = pil->pos;
   pl->type = LEXEM_NUMBER;
   num_getval( str_ptr( _compile->cur->src ) + pil->pos, &pl->num );
   return 1;
}
*/

/*-----------------------------------------------------------------------------
*
* ID: lexem_load 30.10.06 0.0.A.
* 
* Summary: The creating the array of lexems.
*
-----------------------------------------------------------------------------*/

uint  STDCALL  lexem_load( parr lexems, parr input )
{
   plexitem pil, end;
   uint     off = _compile->cur->off;
   pubyte   src = str_ptr( _compile->cur->src );
   uint     colon = 0;
   uint     lexsys, shift;
   plexem   plex;

   _istext = 0;
   arr_init( lexems, sizeof( lexem ));
   arr_step( lexems, 512 );
   arr_reserve( lexems, arr_count( input ) + 100 );

   if ( !arr_count( input ))
      return 1;
   pil = ( plexitem )arr_ptr( input, 0 );
   end = ( plexitem )arr_ptr( input, arr_count( input ));
   while ( pil < end )
   {
      pil->pos += off;
//      printf("Pos=%i len=%i type=%X %s\n", pil->pos, pil->len, pil->type,
//               src + pil->pos );
      switch ( pil->type )
      {
         case G_NAME:
            lexem_name( lexems, pil );
            break;
         case G_LINE:
            while ( colon )   // if ':' was
            {
               lexem_oper( lexems, pil->pos, '}' );
               colon--;
            }
            lexem_line( lexems, pil->pos );
            break;
         case G_OPERCHAR:
            switch ( src[ pil->pos ] )
            {
               case '(': 
                  (( plexem )arr_ptr( lexems, arr_count( lexems ) - 1 ))->flag |= LEXF_CALL;
                  break;
               case '[': 
                  (( plexem )arr_ptr( lexems, arr_count( lexems ) - 1 ))->flag |= LEXF_ARR;
                  break;
            }
            lexsys = 0;
            mem_copy( &lexsys, src + pil->pos, pil->len );
            lexem_oper( lexems, pil->pos, lexsys );
            break;
         case G_SYSCHAR:
            if ( src[ pil->pos ] == ';' )
               lexem_line( lexems, pil->pos );
            else
               if ( src[ pil->pos ] == ':' )
               {
                  lexem_oper( lexems, pil->pos, '{' );
                  colon++;
               }
            break;
         case G_NUMBER:
            lexem_new( lexems, pil->pos, LEXEM_NUMBER, 0 );
            break;
         case G_MACRO:
            lexem_name( lexems, pil )->type = LEXEM_MACRO;
            break;
         case G_MACROSTR:
            lexem_macrostr( lexems, pil, 2 /* $" */, LEXEM_STRING );
            break;
         case G_STRING:
            lexem_string( lexems, pil, ( src[ pil->pos ] == '"' ||
                          src[ pil->pos ] == ')' ) ? 1 : 0 /* " */, 0 );
            break;
         case G_TEXTSTR:
            if ( _istext ) 
               shift = 1;
            else
            {
               _istext = 1;
               shift = 0;
               lexem_oper( lexems, pil->pos, '{' );
//               lexem_nameptr( lexems, pil->pos, 0, "str" );
//               lexem_nameptr( lexems, pil->pos, 0, "text" );
//               lexem_line( lexems, pil->pos );
            }
            lexem_string( lexems, pil, shift, 1 );
            break;
         case G_BINARY:
            if ( src[ pil->pos + 2 ] == '\'')
            {
               plex = lexem_new( lexems, pil->pos, LEXEM_NUMBER, 0 );
               plex->num.type = TUint;
               plex->num.vint = src[ pil->pos + 1 ];
               break;
            }
            if ( src[ pil->pos ] == '\'' )
            {
               _ishex = 1;
               _bimode = 1;
            }
            lexem_binary( lexems, pil, ( src[ pil->pos ] == '\'' ||
                          src[ pil->pos ] == ')' ) ? 1 : 0 /* ' */ );
            break;
         case G_FILENAME:
            lexem_macrostr( lexems, pil, 1 /* \< */, LEXEM_FILENAME );
            break;
      }
//      printf("ID=%x pos=%i len=%i \n", pil->type, pil->pos, pil->len,
//             input + pil->pos );
      pil++;
   }
   pil--;
   while ( colon )   // if ':' was
   {
      lexem_oper( lexems, pil->pos, '}' );
      colon--;
   }
   if ( _istext )
      lexem_endtext( lexems, pil->pos );
   // Проверка на незаконченные строки и двоичные данные
   lexsys = 0;
   switch ( pil->type )
   {
      case G_MACROSTR:
      case G_STRING:
         lexsys = '"';
         break;
      case G_FILENAME:
         lexsys = '>';
         break;
      case G_BINARY:
         lexsys = '\'';
         break;
   }
   if ( lexsys &&  src[ pil->pos + pil->len - 1 ] != lexsys )
      msg( MUneofsb | MSG_LEXERR, arr_top( lexems ));
   return 1;
}

/*-----------------------------------------------------------------------------
*
* ID: lexem_getname 30.10.06 0.0.A.
* 
* Summary: Get a pointer to name identifier.
*
-----------------------------------------------------------------------------*/

pubyte  STDCALL  lexem_getname( plexem plex )
{
   return hash_name( &_compile->names, plex->nameid );
}

/*-----------------------------------------------------------------------------
*
* ID: lexem_get 30.10.06 0.0.A.
* 
* Summary: Get a pointer to string, binary.
*
-----------------------------------------------------------------------------*/

pstr  STDCALL  lexem_getstr( plexem plex )
{
   switch ( plex->type )
   {
      case  LEXEM_STRING:
      case  LEXEM_FILENAME:
        return arrdata_get( &_compile->string, plex->strid );
      case  LEXEM_BINARY:
      case  LEXEM_COLLECT:
        return arrdata_get( &_compile->binary, plex->binid );
   }
   return 0;
}

/*-----------------------------------------------------------------------------
*
* ID: lexem_file 01.12.06 0.0.A.
* 
* Summary: Get the filename.
*
-----------------------------------------------------------------------------*/

void lexem_file( plexem powner, plexem plex )
{
   uint first = powner == plex ? 1 : 0;
   pstr output = lexem_getstr( powner );
   pbuf data = &_compile->cur->lexems->data;

   if ( *str_index( output, str_len( output ) - 1 ) == '>' )
   {
      powner->type = LEXEM_STRING;
      return;
   }
   plex++;
   if ( ( pubyte )plex >= data->data + data->use )
      goto error;

   if ( plex->type == LEXEM_MACRO )
   {
      plex = macro_get( plex );
      if ( plex->type == LEXEM_STRING )
         plex->type = LEXEM_FILENAME;
      else
         msg( MUnsmoper | MSG_LEXNAMEERR, plex );
   }
   if ( plex->type == LEXEM_FILENAME )
   {
      str_add( lexem_getstr( powner ), lexem_getstr( plex ));
      plex->type = LEXEM_SKIP;
      lexem_file( powner, plex );
      return;
   }
error:
   msg( MUneofsb | MSG_LEXERR, powner );
}

/*-----------------------------------------------------------------------------
*
* ID: lexem_strbin 01.12.06 0.0.A.
* 
* Summary: Get the string or binary lexems.
*
-----------------------------------------------------------------------------*/

void lexem_strbin( plexem powner, plexem plex )
{
   uint first = powner == plex ? 1 : 0;
   pstr output;
   pbuf data = &_compile->cur->lexems->data;

   do 
   {
      plex++;
      if ( ( pubyte )plex >= data->data + data->use )
         return;
   }
   while ( plex->type == LEXEM_SKIP );

   if ( plex->type == LEXEM_MACRO )
      plex = macro_get( plex );
   if ( plex->type == LEXEM_FILENAME )
   {
      pstr sfile;

      lexem_file( plex, plex );
      sfile = str_trim( str_new( str_ptr( lexem_getstr( plex )) + 1 ), 
                                 '>', TRIM_RIGHT );
      file2buf( sfile, buf_init( ( pbuf )arr_append( &_compile->binary )), 
                plex->pos );
      plex->type = LEXEM_BINARY;
      plex->binid = arr_count( &_compile->binary ) - 1;
      str_destroy( sfile );
   }
   if ( plex->type == LEXEM_STRING || plex->type == LEXEM_BINARY )
   {
      if ( first )
      {
         if ( powner->type == LEXEM_STRING )   
         {
            output = str_init( ( pstr )arr_append( &_compile->string ));
            str_copy( output, lexem_getstr(  powner ));
            powner->strid = arr_count( &_compile->string ) - 1;
         }
         else
         {
            output = buf_init( ( pbuf )arr_append( &_compile->binary ));
            buf_set( output, lexem_getstr(  powner ));
            powner->binid = arr_count( &_compile->binary ) - 1;
         }
      }
      else
         output = lexem_getstr( powner );

      if ( powner->type == LEXEM_STRING )   
      {
         str_add( output, lexem_getstr( plex ));
         // Добавились довичные данные без нуля в конце
         if ( plex->type == LEXEM_BINARY && buf_index( output, 
                buf_len( output ) - 1 ))
            buf_appendch( output, 0 );
      }
      else
         buf_add( output, lexem_getstr( plex ));

      plex->type = LEXEM_SKIP;
      lexem_strbin( powner, plex );
//      printf("OK 1=%i-%i - %s - %s------\n", plex->type, powner->strid, 
//         str_ptr(lexem_getstr(  powner )), str_ptr( output  ));
   }
}

/*-----------------------------------------------------------------------------
*
* ID: lexem_get 30.10.06 0.0.A.
* 
* Summary: Get the next lexem. If plex == 0 returns the first lexem
*
-----------------------------------------------------------------------------*/

plexem  STDCALL  lexem_next( plexem plex, uint flag )
{
   pbuf data = &_compile->cur->lexems->data;

   if ( flag & LEXNEXT_LCURLY )
   {
/*      while ( ( plex->type == LEXEM_OPER && plex->oper.operid == OpLine ) ||
             plex->type == LEXEM_SKIP )
         plex++;*/
      if ( !lexem_isys( plex, LSYS_LCURLY ))
         msg( MLcurly | MSG_POS | MSG_EXIT, plex->pos );
   }
   if ( flag & LEXNEXT_SKIPLINE )
   {
      while ( ( plex->type == LEXEM_OPER && plex->oper.operid == OpLine ) ||
             plex->type == LEXEM_SKIP )
         plex++;
      return plex;
   }

   if ( !plex )
      plex = ( plexem )data->data;
   else
      plex++;

again:
   while ( 1 )
   {
      if ( ( pubyte )plex >= data->data + data->use )
      {    
         if ( flag & LEXNEXT_NULL )
            return 0;
         else
            msg( MUneof | MSG_POS | MSG_EXIT, str_len( _compile->cur->src ));
      }
      if ( flag & LEXNEXT_IGNLINE && plex->type == LEXEM_OPER && 
             plex->oper.operid == OpLine )
         goto next;
      if ( flag & LEXNEXT_IGNCOMMA && lexem_isys( plex, LSYS_COMMA ))
         goto next;
      if ( plex->type != LEXEM_SKIP )
         break;
next:
      plex++;
   }
   if ( !( flag & LEXNEXT_NOMACRO ))
   {
      if ( plex->type == LEXEM_MACRO || ( plex->type == LEXEM_NAME && 
          !( flag & LEXNEXT_NAMEDEF )) )
         plex = macro_get( plex );

      if ( plex->type == LEXEM_STRING || plex->type == LEXEM_BINARY )
      {
         lexem_strbin( plex, plex );
//      printf( "string= %i %s\n", plex->strid, str_ptr( lexem_getstr(  plex )));
      }
      if ( plex->type == LEXEM_KEYWORD && plex->key == KEY_IFDEF )
      {
         plex = ifdef( plex );
         goto again;
      }
   }
   if ( flag & LEXNEXT_NAME && plex->type != LEXEM_NAME )
      msg( MExpname | MSG_LEXERR, plex );
  
   return plex;
}

/*-----------------------------------------------------------------------------
*
* ID: lexem_copy 30.10.06 0.0.A.
* 
* Summary: Copy lexems
*
-----------------------------------------------------------------------------*/

plexem STDCALL lexem_copy( plexem dest, plexem src )
{
   uint pos = dest->pos;
   mem_copy( dest, src, sizeof( lexem ));
   dest->pos = pos;
   return dest;
}

//--------------------------------------------------------------------------
