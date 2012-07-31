/******************************************************************************
*
* Copyright (C) 2006, The Gentee Group. All rights reserved.
* This file is part of the Gentee open source project - http://www.gentee.com.
*
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT").
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS
* ACCEPTANCE OF THE AGREEMENT.
*
* ID: foreach 09.02.07 0.0.A.
*
* Author: Alexander Krivonogov ( algen )
*
* Summary: The foreach statement
*
******************************************************************************/

#include "func.h"
#include "bcodes.h"

/*-----------------------------------------------------------------------------
*
* ID: c_foreach 08.02.07 0.0.A.
*
* Summary: The foreach processing
*
-----------------------------------------------------------------------------*/
plexem STDCALL c_foreach( plexem curlex )
{
   uint       labbeg;           //Метка начало
   uint       labend;           //Метка конец
   uint       labcont;          //Метка на continue
   uint       fd_offlcbreak;    //Смещение в таблице меток
   uint       fd_offlccontinue; //Смещение в таблице меток
   uint       indexnum;         //Номер/код переменной индекса
   uint       objnum;           //Номер дополнительной переменной хранящей объект
   uint       fordata;          //Номер переменной со структурой fordata

   plexem     indexlex;      //Лексема с описанной переменной

   uint       objtype;       //Тип объекта   
   uint       itemtype;      //Тип элемента
   uint       deftype;       //Описанный тип элемента
   uint       vartype;

   uint       bcfirst;       //Байт-код метода First
   uint       bceof;         //Байт-код метода Eof
   uint       bcnext;        //Байт-код метода Next
   //uint       bcset;         //Байт-код присваивания значения
   uint       bcadvget;      //Байт-код для дополнительного кода присваивания
   uint       bcadvset;      //Байт-код для дополнительного кода присваивания

   pfvar      var;          //Указатель на структуру локальной переменной
   pfvaras    varas;        //Указатель на структуру as
   phashiuint phitem;       //Элемент хэштаблицы с локальной переменной
   pubyte     varname;      //Имя локальной переменной
   uint       flgnewvar;    //Флаг добавлять новую локальную переменную с индекском
   s_descid   descvar;      //Структура для описания локальной переменной
   uint       offvar;       //Смещение структуры локальной переменной

   //pvmfunc    pfunc;    //Указатель на структуру операции
   //uint       parsc[4]; //Параметры для получения кода операции

D( "Foreach start\n" );
   fd.blcycle++;

   //Обработка индекса цикла
   
   if ( curlex->type != LEXEM_NAME )
      msg( MExpname | MSG_LEXERR, curlex );
   vartype = bc_type( curlex );   
   if ( vartype )
   {
      curlex = lexem_next( curlex, LEXNEXT_IGNLINE );
   }
   if ( curlex->type != LEXEM_NAME )
      msg( MExpname | MSG_LEXERR, curlex );
   
   indexlex = curlex;

   //Существует ли локальная переменная
   phitem = (phashiuint)hash_find( &fd.nvars, lexem_getname( curlex ) );
   //flgnewvar = 1;
   if ( phitem && phitem->val &&
        !(( var = (pfvar)( fd.bvars.data + ( offvar = phitem->val )))->flg & FVAR_SUBFUNC))
   {  //Идентификатор есть в таблице локальных переменных
      flgnewvar = 0;
      indexnum = var->num;        
   }
   else
   {
      flgnewvar = 1;      
      varname = lexem_getname( curlex );
   }
   curlex = lexem_next( curlex, LEXNEXT_IGNLINE );
   if ( curlex->type != LEXEM_OPER || curlex->oper.operid != OpComma )
      msg( MExpcomma | MSG_LEXERR, curlex );
   curlex = lexem_next( curlex, LEXNEXT_IGNLINE );

   //Обработка выражения-объекта
   objnum = var_addtmp( TUint, 0 ); //Создание переменной для хранения адреса объекта
   out_add2uint( CVarptrload, objnum );//Байт код для сохранения результата выражения
   curlex = f_expr( curlex, EXPR_NONULL, &objtype, &itemtype );
   if ( !itemtype )
   {
      /*if ( ! (itemtype = (( povmtype)PCMD( objtype ))->index.type ))
         itemtype = TUint;*/
      itemtype = (( povmtype)PCMD( objtype ))->index.type;
      
   }   
   out_adduint( CSetI );//Байт код загрузки значения
   //Получаем байт-коды методов
   bcfirst = bc_find( indexlex, "@first", 2, objtype, TAny );
   bceof   = bc_find( indexlex, "@eof", 2, objtype, TAny );
   bcnext  = bc_find( indexlex, "@next", 2, objtype, TAny );


   if ( (( pvmfunc)PCMD( bcfirst ))->ret->type != TUint )
   {
      itemtype = (( pvmfunc)PCMD( bcfirst ))->ret->type;
      deftype = TUint;
      /*if ( !(itemtype = (( pvmfunc)PCMD( bcfirst ))->ret->type ))
      {
         itemtype = TUint;
      }*/
   }
   fordata = var_addtmp((( pvmfunc)PCMD( bcfirst ))->params[1].type , 0 );   

   //Уточнение типов
   if ( (( pvmobj )PCMD( itemtype ))->flag & GHTY_STACK )
   {//Базовый тип элемента, приводим указатель к значению
    //Предполагается что first/next могут возвращать только указатели
      //Заполнение полей фиктивной лексемы
      /*parsc[0] = itemtype;
      parsc[1] = 0;
      parsc[2] = itemtype;
      parsc[3] = 0;
      pfunc = bc_funcname( curlex, "#=", 2, parsc );*/
      //bcset = CSetI;            
      bcadvget = artypes[ itemtype ];
      bcadvset = (( povmtype )PCMD( itemtype ))->stsize == 1 ? CSetI : CSetL;
      deftype = itemtype;
   }
   else
   {  //Тип элемента структура      
      //bcset = CSetI;
      bcadvget = 0;
      deftype = TUint;
   }   
   if ( flgnewvar )
   {  //Создание новой локальной переменной-индекса
      mem_zero( &descvar, sizeof( descvar ));
      descvar.idtype = deftype;
      descvar.name = varname;
      descvar.lex = curlex;
      descvar.flgdesc = DESCID_VAR;
      offvar = fd.bvars.use;
      indexnum = var_checkadd( &descvar );   
   }
   var = (( pfvar )( fd.bvars.data + offvar ));
   if ( deftype != ( var->flg & FVAR_UINTAS ? TUint : var->type ) ||
        ( vartype && vartype != itemtype ) )
      msg( MDiftypes | MSG_LEXERR, indexlex );
   if ( !((( pvmobj )PCMD( itemtype ))->flag & GHTY_STACK) ||
        var->flg & FVAR_UINTAS )
   {
      varas = ( pfvaras )buf_appendtype( &fd.bvarsas, sizeof( fvaras ) );

      varas->offbvar = offvar;
      varas->type = var->type;
      varas->oftype = var->oftype; 
      varas->flg = var->flg; 
      
      var->type = itemtype;
      var->oftype = 0;
      var->flg |= FVAR_UINTAS;      
   }

   //Добавляем вызов first
   out_adduints( 8, CVarptrload,
                  indexnum,
                  CVarload,
                  objnum,
                  CVarload,
                  fordata,
                  bcfirst,
                  /*bcset*/CSetI );

   //Добавляем метку на начало
   labbeg = j_label( LABT_LABELVIRT, -1 );

   out_debugtrace( curlex );

   //Вызов метода Eof
   //Обработка логического выражения
   out_adduints( 5, CVarload,
                  objnum,
                  CVarload,
                  fordata,
                  bceof );

   //Сохраняем последние метки цикла
   fd_offlcbreak = fd.offlcbreak;
   fd_offlccontinue = fd.offlccontinue;

   //Добавляем переход на конец
   fd.offlcbreak = j_jump( CIfnze, LABT_GTVIRT, -1);
   fd.offlccontinue = -1;

   if ( bcadvget )
   {
      //Коррекция для базовых типов
      out_adduints( 7, CVarptrload,
                     indexnum,
                     CVarptrload,
                     indexnum,
                     CGetI,
                     bcadvget,
                     bcadvset );
      /*out_adduints( 6, CVarptrload,
                     indexnum,
                     CVarload,
                     indexnum,
                     bcadvget,
                     bcset );*/
   }

   //Обработка тела
   curlex = f_body( curlex );

   //Метка на continue
   labcont = j_label( LABT_LABELVIRT, -1 );

   //Вызов метода Next
   out_adduints( 8, CVarptrload,
                  indexnum,
                  CVarload,
                  objnum,
                  CVarload,
                  fordata,
                  bcnext,                  
                  /*bcset*/CSetI );

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

D( "Foreach stop\n" );
   return curlex;
}