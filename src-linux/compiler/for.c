/******************************************************************************
*
* Copyright (C) 2006, The Gentee Group. All rights reserved.
* This file is part of the Gentee open source project - http://www.gentee.com.
*
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT").
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS
* ACCEPTANCE OF THE AGREEMENT.
*
* ID: for 09.02.07 0.0.A.
*
* Author: Alexander Krivonogov ( algen )
*
* Summary: Конструкции for, fornum
*
******************************************************************************/

#include "func.h"
#include "bcodes.h"

/*-----------------------------------------------------------------------------
*
* ID: c_for 09.02.07 0.0.A.
*
* Summary: The for processing
*
-----------------------------------------------------------------------------*/
plexem STDCALL c_for( plexem curlex )
{
   uint       labbeg;          //Метка начало
   uint       labend;          //Метка конец
   uint       labcont;         //Метка на continue
   uint       fd_offlcbreak;   //Смещение в таблице меток
   uint       fd_offlccontinue;//Смещение в таблице меток
   plexem     incrlex;         //Лесема начала выражения инкремента

D( "For start\n" );
   fd.blcycle++;

   //Обработка выражения инициализации
   curlex = f_expr( curlex, EXPR_COMMA, 0, 0 );

   if ( curlex->type != LEXEM_OPER || curlex->oper.operid != OpComma )
      msg( MExpcomma | MSG_LEXERR, curlex );
   curlex = lexem_next( curlex, 0 );

   //Добавляем метку на начало
   labbeg = j_label( LABT_LABELVIRT, -1 );

   //Обработка логического выражения
   curlex = f_expr( curlex, EXPR_BOOL | EXPR_COMMA, 0, 0 );
   if ( curlex->type != LEXEM_OPER || curlex->oper.operid != OpComma )
      msg( MExpcomma | MSG_LEXERR, curlex );
   curlex = lexem_next( curlex, 0 );

   //Сохраняем последние метки цикла
   fd_offlcbreak = fd.offlcbreak;
   fd_offlccontinue = fd.offlccontinue;

   //Добавляем переход на конец
   fd.offlcbreak = j_jump( CIfze, LABT_GTVIRT, -1);
   fd.offlccontinue = -1;

   //Пропуск инкремента
   incrlex = curlex;
   do
   {
      curlex = lexem_next( curlex, 0 );
   }
   while ( curlex->type != LEXEM_OPER || curlex->oper.operid != OpLcrbrack );

   //Обработка тела
   curlex = f_body( curlex );

   //Метка на continue
   labcont = j_label( LABT_LABELVIRT, -1 );

   //Обработка инкремента
   incrlex = f_expr( incrlex, 0, 0, 0 );
   incrlex = lexem_next( incrlex, LEXNEXT_SKIPLINE );

   if ( incrlex->type != LEXEM_OPER || incrlex->oper.operid != OpLcrbrack )
      msg( MLcurly | MSG_LEXERR, incrlex );

   //Добавляем переход на начало
   j_jump( CGoto, LABT_GTVIRT, labbeg );

   //Добавляем метку на конец
   labend = j_label( LABT_LABELVIRT, -1 );

   //Цикл установки переходов на конец
   j_correct( fd.offlcbreak, labend );

   //Цикл установки переходов на начало
   j_correct( fd.offlccontinue, labcont );

   //Восстановление меток цикла
   fd.offlcbreak = fd_offlcbreak;
   fd.offlccontinue = fd_offlccontinue;
   fd.blcycle--;

D( "For stop\n" );
   return curlex;
}


/*-----------------------------------------------------------------------------
*
* ID: c_fornum 09.02.07 0.0.A.
*
* Summary: The fornum processing
*
-----------------------------------------------------------------------------*/
#define INDEX_LOCVAR 0x1  //Индекс-переменная локальная
#define INDEX_GLOBVAR 0x2 //Индекс-переменная глобальная
plexem STDCALL c_fornum( plexem curlex )
{
   plexem     indexlex;      //Лексема с переменной индекска
   uint       indexflg;      //Флаг переменной индекса локальная/глобальная переменная
   uint       indexnum;      //Номер/код переменной индекса
   uint       indextype;     //Тип индекса

   uint       labbeg;          //Метка начало
   uint       labend;          //Метка конец
   uint       labcont;         //Метка на continue

   uint       fd_offlcbreak;   //Смещение в таблице меток
   uint       fd_offlccontinue;//Смещение в таблице меток

   uint       casenum;  //Номер дополнительной переменной хранящей верхнее условие
   uint       globid;   //Идентификатор глобальной переменной
   pfvar      var;      //Указатель на структуру локальной переменной
   phashiuint phitem;   //Элемент хэштаблицы с локальной переменной
   uint       parsc[4]; //Параметры для получения кода операции

D( "Fornum start\n" );
   fd.blcycle++;
   indexlex = curlex;
   indexflg = 0;

   //Получение переменной индеска
   phitem = (phashiuint)hash_find( &fd.nvars, lexem_getname( curlex ) );
   if ( phitem )
   {  //Идентификатор есть в таблице локальных переменных
      var = ( pfvar )(fd.bvars.data + phitem->val);
      if ( !(var->flg ) )
      {  // Локальная переменная
         indexnum = var->num;
         indexflg = INDEX_LOCVAR;
         indextype = var->type;
      }
   }   
   if ( !indexflg  )
   {      
      globid = bc_getid( curlex );      
      if ( globid && (( pvmobj )PCMD( globid ))->type == OVM_GLOBAL )
      {  //Глобальная переменная    
         indexnum = globid;
         indexflg = INDEX_GLOBVAR;
         indextype = ((povmglobal)PCMD( globid ))->type->type;
      }
   }   
   if ( !indexflg )
      msg( MUnklex | MSG_LEXNAMEERR, curlex );//Неизвестный идентификатор
   if ( indextype <= TInt || indextype >= TUshort )
      msg( MVaruint | MSG_LEXERR, curlex );
   parsc[0] = indextype;

   //Обработка выражения инициализации
   curlex = lexem_next( curlex, 0 );
   if ( curlex->type == LEXEM_OPER && curlex->oper.operid == OpSet )
   {
      curlex = f_expr( indexlex, EXPR_COMMA, 0, 0 );
   }


   curlex = lexem_next( curlex, LEXNEXT_SKIPLINE );
   if ( curlex->type != LEXEM_OPER || curlex->oper.operid != OpComma )
      msg( MExpcomma | MSG_LEXERR, curlex );//Ошибка Должна быть запятая
   curlex = lexem_next( curlex, 0 );

   //Обработка выражения максимального значения
   //Получение максимального значения и запись в локальную переменную
   casenum = var_addtmp( indextype, 0 );
   out_add2uint( CVarptrload, casenum );
   curlex = f_expr( curlex, EXPR_NONULL, &parsc[2], &parsc[3] );

   parsc[1] = 0;   
   out_adduint( bc_funcname( curlex, "#=", 2, parsc )->vmo.id );

   //Добавляем метку на начало
   labbeg = j_label( LABT_LABELVIRT, -1 );

   out_debugtrace( curlex );
   //Операция сравнения <
   out_add2uint( indexflg & INDEX_LOCVAR ? CVarload : CPtrglobal,
               indexnum );
   if ( indexflg & INDEX_GLOBVAR )
   {
      out_adduint( CGetI );
   }
   out_adduints( 3, CVarload,
                  casenum,
                  bc_funcname( curlex, "#<", 2, parsc )->vmo.id );

   //Сохраняем последние метки цикла
   fd_offlcbreak = fd.offlcbreak;
   fd_offlccontinue = fd.offlccontinue;

   //Добавляем переход на конец
   fd.offlcbreak = j_jump( CIfze, LABT_GTVIRT, -1);
   fd.offlccontinue = -1;

   //Обработка тела
   curlex = f_body( curlex );

   //Метка на continue
   labcont = j_label( LABT_LABELVIRT, -1 );

   //Обработка инкремента ++
   out_adduints( 3, indexflg & INDEX_LOCVAR ? CVarptrload : CPtrglobal,
                  indexnum,
                  bc_funcname( curlex, "#++", 1, parsc )->vmo.id );

   //Добавляем переход на начало
   j_jump( CGoto, LABT_GTVIRT, labbeg );

   //Добавляем метку на конец
   labend = j_label( LABT_LABELVIRT, -1 );

   //Цикл установки переходов на конец
   j_correct( fd.offlcbreak, labend );

   //Цикл установки переходов на начало
   j_correct( fd.offlccontinue, labcont );

   //Восстановление меток цикла
   fd.offlcbreak = fd_offlcbreak;
   fd.offlccontinue = fd_offlccontinue;
   fd.blcycle--;

D( "Fornum stop\n" );
   return curlex;
}
