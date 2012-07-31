/******************************************************************************
*
* Copyright (C) 2006, The Gentee Group. All rights reserved.
* This file is part of the Gentee open source project - http://www.gentee.com.
*
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT").
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS
* ACCEPTANCE OF THE AGREEMENT.
*
* ID: subfunc 02.02.06 0.0.A.
*
* Author: Alexander Krivonogov ( algen )
*
* Summary: Обработка подфункции
*
******************************************************************************/

#include "func.h"

/*-----------------------------------------------------------------------------
*
* ID: f_subfunc 02.02.06 0.0.A.
*
* Summary: The subfunc processing
*
-----------------------------------------------------------------------------*/
plexem STDCALL f_subfunc( plexem curlex )
{
   uint       fd_lastcurcount;//Предыдущее значение кол. переменных в верхнем блоке
   uint       fd_functype;  //Текущий тип функции
   uint       fd_funcoftype;  //Текущий подтип функции
   uint       fd_oldoffbvar;//Текущее смещение в стэке локальных переменных
   uint       offbvars;     //Смещение в стэке локальных переменных для подфункции

   pflabel    curlabel;     //Текущий элемент в таблице меток
   pflabel    endlabel;     //Конец таблицы меток
   uint       offblabels;   //Начало подфункции в стэке меток

   uint       addr;         //Адрес подфункции в байткоде
   uint       pars;         //Количество параметров у подфункции
   uint       offbvardef;   //Смещение в буфере описание переменных

   s_desctype desctype;     //Структура для получения типа подфункции
   s_descid   descvar;      //Структура для описания подфункции как локальной переменной
   pfvar      var;          //Указатель на локальную переменную-подфункцию

   uint       isreturn;     //Флаг выхода из функции
   plexem     lexname;      //Лексема с именем функции
   uint       off;          //Временная переменная для смещений

   if ( fd.bllevel > 1 )
      msg( MSublevel | MSG_LEXERR, curlex );

//Инициализация
   desctype.idtype = 0;
   descvar.idtype = 0;
   _compile->pout = fd.bout = &fd.bsubout;

   offblabels  = fd.blabels.use;
   fd_functype = fd.functype;
   fd_funcoftype = fd.funcoftype;

   //if ( !fd.bsubout.use )
   if ( !fd.offsubgoto )
   {
      out_add2uint( CGoto, 0 );
      fd.offsubgoto = fd.bsubout.use - 4;
   }
   addr = fd.bsubout.use/sizeof( uint );

//Тип возвращаемого значения если указан   
   if ( curlex->type == LEXEM_NAME )
      curlex = desc_idtype( curlex, &desctype );
   if ( desctype.idtype )
   {
      fd.functype = desctype.idtype;
      fd.funcoftype = desctype.oftype;
      //Инициализация возврата
      out_add2uint( CSubret, (( povmtype)PCMD( fd.functype ))->stsize );
   }
   else
   {
      fd.functype = 0;
      fd.funcoftype = 0;
   }
//Имя функции
   curlex = lexem_next( curlex, LEXNEXT_SKIPLINE );
   if ( curlex->type != LEXEM_NAME )
      msg( MExpname | MSG_LEXERR, curlex );//Ошибка Должен быть идентификатор
   lexname = curlex;
   offbvars = fd.bvars.use;
   descvar.idtype = fd.functype;
   descvar.oftype = fd.funcoftype;
   descvar.name = lexem_getname( lexname );
   descvar.lex = lexname;
   descvar.flgdesc = DESCID_SUBFUNC;
   var_checkadd( &descvar );

//Список параметров
   curlex = lexem_next( curlex, LEXNEXT_IGNLINE );
   fd_oldoffbvar = fd.oldoffbvar;
   fd.oldoffbvar = fd.bvars.use;
   pars = 0;
   if ( curlex->type == LEXEM_OPER &&
        curlex->oper.operid == OpLbrack )//Открывающая скобка
   {
      curlex = lexem_next( curlex, LEXNEXT_IGNLINE );

      fd_lastcurcount = fd.lastcurcount;
      fd.lastcurcount = fd.curcount;
      fd.curcount = 0;
      offbvardef = fd.bvardef.use;

      curlex = var_def( curlex, DESCID_PARSUBFUNC );

      pars = fd.curcount;
      if ( fd.curcount )
      {
         out_add2uint( CSubpar, fd.blcount - 1 );//Загрузка параметров
         buf_appenduint( &fd.bhead, fd.curcount );
         fd.curcount = 0;
      }
      else
      {
         fd.curcount = fd.lastcurcount;
         fd.lastcurcount = fd_lastcurcount;
      }

      if ( curlex->type != LEXEM_OPER ||
           curlex->oper.operid != OpRbrack )//Закрывающая скобка
         msg( MExpclosebr | MSG_LEXERR, curlex );// Ошибка Ожадается закрывающая скобка
      curlex = lexem_next( curlex, LEXNEXT_IGNLINE );
   }

//Запись подфункции как локальной переменной
   var = (pfvar)( fd.bvars.data + offbvars );
   var->flg  = FVAR_SUBFUNC;
   var->addr = addr;
   var->pars = pars;
   var->offbvardef = offbvardef;

//Обработка тела функции
   curlex = f_body( curlex );

//Очистка параметров из стэка локальных переменных
   off = (uint)fd.bvars.data + fd.oldoffbvar;
   for ( (uint)var = (uint)fd.bvars.data + fd.bvars.use - sizeof( fvar );
         (uint)var >= off; var-- )
   {
      if ( var->hidn )
         var->hidn->val = var->oldoffbvar;
   }
   fd.bvars.use = fd.oldoffbvar;
   fd.oldoffbvar = fd_oldoffbvar;

//Установка переходов, корректировка меток
   isreturn = 0;
   curlabel = ( pflabel )( fd.blabels.data + offblabels );
   endlabel = ( pflabel )( fd.blabels.data + fd.blabels.use );
   while( curlabel < endlabel )
   {
      if ( curlabel->type & LABT_GT )
      {
         if ( ( curlabel->type & LABT_GTUNDEF ) == LABT_GTUNDEF )
            msg( MUnklabel | MSG_LEXNAMEERR, curlabel->lex );

         *( puint )(fd.bsubout.data + curlabel->offbout ) =
               ((( pflabel )(fd.blabels.data + curlabel->link ))->offbout)/sizeof(uint);
         if ( !isreturn )
         {
            //Помечаем метку как отработавшую (на неё был переход)
            (( pflabel )(fd.blabels.data + curlabel->link ))->type |= LABT_LABELWORK;
         }
      }
      else
      if ( curlabel->type & LABT_RETURN )
         isreturn = 1;//Устанавливаем флаг
      else
      if ( curlabel->type & LABT_LABELWORK )
         isreturn = 0;//Если была отработавшая метка, то сбрасываем флаг
      curlabel++;
   }
   fd.blabels.use = offblabels;

//Проверка выходов из функции
   if ( fd.functype )
   {
      if ( !isreturn )
         msg( MMustret | MSG_LEXNAMEERR, lexname );
   }
   else
      if ( !isreturn )
         out_adduint( CSubreturn );
//Восстановление данных
   _compile->pout = fd.bout = &fd.bfuncout;
   fd.functype = fd_functype;
   fd.funcoftype = fd_funcoftype;

   return curlex;
}