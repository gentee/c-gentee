/******************************************************************************
*
* Copyright (C) 2006, The Gentee Group. All rights reserved.
* This file is part of the Gentee open source project - http://www.gentee.com.
*
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT").
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS
* ACCEPTANCE OF THE AGREEMENT.
*
* ID: while 09.02.07 0.0.A.
*
* Author: Alexander Krivonogov ( algen )
*
* Summary: The while and do-while statements
*
******************************************************************************/

#include "func.h"

/*-----------------------------------------------------------------------------
*
* ID: c_while 09.02.07 0.0.A.
*
* Summary: The while processing
*
-----------------------------------------------------------------------------*/
plexem STDCALL c_while( plexem curlex )
{
   uint       labbeg;          //Метка начало
   uint       labend;          //Метка конец
   uint       offlcbreak;    //Смещение в таблице меток
   uint       offlccontinue; //Смещение в таблице меток

   fd.blcycle++;
D( "While start\n" );
   //Добавляем метку на начало
   labbeg = j_label( LABT_LABELVIRT, -1 );

   //Обработка логического выражения
   curlex = f_expr( curlex, EXPR_BOOL, 0, 0 );

   //Сохраняем последние метки цикла
   offlcbreak = fd.offlcbreak;
   offlccontinue = fd.offlccontinue;

   //Добавляем переход на конец
   fd.offlcbreak = j_jump( CIfze, LABT_GTVIRT, -1);
   fd.offlccontinue = -1;

   //Обработка тела
   curlex = f_body( curlex );

   //Добавляем переход на начало
   j_jump( CGoto, LABT_GTVIRT, labbeg );

   //Добавляем метку на конец
   labend = j_label( LABT_LABELVIRT, -1 );

   //Цикл установки переходов на конец
   j_correct( fd.offlcbreak, labend );

   //Цикл установки переходов на начало
   j_correct( fd.offlccontinue, labbeg );

   //Восстановление меток цикла
   fd.offlcbreak = offlcbreak;
   fd.offlccontinue = offlccontinue;
   fd.blcycle--;
D( "While stop\n" );
   return curlex;
}

/*-----------------------------------------------------------------------------
*
* ID: c_dowhile 09.02.07 0.0.A.
*
* Summary: <do_while> processing
*
-----------------------------------------------------------------------------*/
plexem STDCALL c_dowhile( plexem curlex )
{
   uint       labbeg;          //Метка начало
   uint       labend;          //Метка конец
   uint       labcont;         //Метка продолжить
   uint       fd_offlcbreak;    //Смещение в таблице меток
   uint       fd_offlccontinue; //Смещение в таблице меток

D( "DoWhile start\n" );
   fd.blcycle++;
   //Добавляем метку на начало
   labbeg = j_label( LABT_LABELVIRT, -1 );

   //Сохраняем последние метки цикла
   fd_offlcbreak = fd.offlcbreak;
   fd_offlccontinue = fd.offlccontinue;

   //Добавляем переход на конец
   fd.offlcbreak = -1;
   fd.offlccontinue = -1;

   //Обработка тела
   curlex = f_body( curlex );

   //Проверка ключевого слова while
   curlex = lexem_next( curlex, LEXNEXT_IGNLINE );
   if ( curlex->type != LEXEM_KEYWORD || curlex->key != KEY_WHILE )
      msg( MExpwhile | MSG_LEXERR, curlex );
   curlex = lexem_next( curlex, 0 );
   //Добавляем метку на продолжить
   labcont = j_label( LABT_LABELVIRT, -1 );

   //Обработка логического выражения
   curlex = f_expr( curlex, EXPR_BOOL, 0, 0);
   //Добавляем переход на начало
   j_jump( CIfnze, LABT_GTVIRT, labbeg );

   //Добавляем метку на конец
   labend = j_label( LABT_LABELVIRT, -1 );

   //Цикл установки переходов на конец
   j_correct( fd.offlcbreak, labend );

   //Цикл установки переходов на продолжить
   j_correct( fd.offlccontinue, labcont );

   //Восстановление меток цикла
   fd.offlcbreak = fd_offlcbreak;
   fd.offlccontinue = fd_offlccontinue;
   fd.blcycle--;
D( "DoWhile stop\n" );
   return curlex;
}