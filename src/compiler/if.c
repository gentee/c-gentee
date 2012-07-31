/******************************************************************************
*
* Copyright (C) 2006, The Gentee Group. All rights reserved.
* This file is part of the Gentee open source project - http://www.gentee.com.
*
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT").
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS
* ACCEPTANCE OF THE AGREEMENT.
*
* ID: if 08.02.07 0.0.A.
*
* Author: Alexander Krivonogov ( algen )
*
* Summary: Конструкция if-elif-else
*
******************************************************************************/

#include "func.h"

/*-----------------------------------------------------------------------------
*
* ID: c_if 08.02.07 0.0.A.
*
* Summary: The if-elif-else processing
*
-----------------------------------------------------------------------------*/
plexem STDCALL c_if( plexem curlex )
{
   uint       jmpnext;     //Смещение в стэке меток - переход к следующему elif, else
   uint       jmpend;      //Смещение в стэке меток - переход к концу
   uint       labend;      //Смещение в стэке меток - метка конца

   D( "If start" );
   jmpend = -1;

   while ( 1 )
   {
      //Обработка логического выражения
      curlex = f_expr( curlex, EXPR_BOOL, 0, 0 );
      //Добавляем переход на следующий
      jmpnext = j_jump( CIfze, LABT_GTVIRT, -1 );
      //Обработка тела
      curlex = f_body( curlex );

      curlex = lexem_next( curlex, LEXNEXT_IGNLINE );
      if ( curlex->type == LEXEM_KEYWORD &&
            ( curlex->key == KEY_ELIF ||
              curlex->key == KEY_ELSE ))
      {
         //Добавляем переход на конец
         jmpend = j_jump( CGoto, LABT_GTVIRT, jmpend );

         //Добавляем метку на следующий, устанавливаем связь с последним переходом
         ((pflabel)( fd.blabels.data + jmpnext ))->link = j_label( LABT_LABELVIRT, -1);
         jmpnext = -1;
         if ( curlex->key == KEY_ELIF )
         {
D( "Elif start\n" );
            curlex = lexem_next( curlex, 0 );
            continue;
         }
D( "Else start\n" );
         curlex = f_body( lexem_next( curlex, LEXNEXT_IGNLINE ) );
         curlex = lexem_next( curlex, LEXNEXT_IGNLINE );
         break;
      }
      break;
   }
   //Добавляем метку на последний
   labend = j_label( LABT_LABELVIRT, -1 );

   //Корректируем все переходы на конец
   j_correct( jmpend, labend );

   //Корректировка, если нет else
   if ( jmpnext != -1 )
      ((pflabel)( fd.blabels.data + jmpnext ))->link = labend;

D( "If stop\n" );
   return curlex;
}

