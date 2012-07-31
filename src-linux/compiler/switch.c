/******************************************************************************
*
* Copyright (C) 2006, The Gentee Group. All rights reserved.
* This file is part of the Gentee open source project - http://www.gentee.com.
*
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT").
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS
* ACCEPTANCE OF THE AGREEMENT.
*
* ID: switch 08.02.07 0.0.A.
*
* Author: Alexander Krivonogov ( algen )
*
* Summary: The switch statement
*
******************************************************************************/

#include "func.h"
#include "bcodes.h"

/*-----------------------------------------------------------------------------
*
* ID: c_if 08.02.07 0.0.A.
*
* Summary: The switch processing
*
-----------------------------------------------------------------------------*/
//Состояния для обработки switch
#define SWITCH_STFIRST    0x01 //Начальное состояние
#define SWITCH_STCASE     0x02 //Обработано условие очередного case
#define SWITCH_STBODY     0x04 //Обработано тело case
#define SWITCH_STDEFAULT  0x08 //Обработан default
plexem STDCALL c_switch( plexem curlex )
{
   uint      state;    //Текущее состояние функции SWITCH_*

   uint      jmpnext;// Ссылка переход на следующий case
   uint      jmpbody;// Cсылка переход на начало блока
   uint      jmpend; // Ссылка переход на конец

   pvmfunc   pfunc;    //Указатель на структуру операции ==
   uint      parsc[4]; //Параметры для получения кода операции ==
   uint      ltype;    //Тип левой части выражения
   uint      dwsize;   //Размер типа левой части выражения

   //Инициализация
   state = SWITCH_STFIRST;
   jmpnext = -1;
   jmpbody = -1;
   jmpend = -1;
D( "Switch start\n" );

   //Значение выражения
   curlex = f_expr( curlex, EXPR_NONULL, &ltype, &parsc[1] );
   parsc[0] = ltype;   
   dwsize = (( povmtype )PCMD( ltype ))->stsize; //Получаем размер типа левой части выражения

   //Главный блок switch
   curlex = lexem_next( curlex, LEXNEXT_SKIPLINE );
   if ( curlex->type != LEXEM_OPER ||
        curlex->oper.operid != OpLcrbrack )//Открывающая фигурная скобка
      msg( MLcurly | MSG_LEXERR, curlex );// Ошибка Ожадается открывающая фигурная скобка
   //Главный цикл
   while ( 1 )
   {
      if ( jmpnext != -1 )
      {
         //Корректировка последнего перехода
         j_correct( jmpnext, j_label( LABT_LABELVIRT, -1) );
         jmpnext = -1;
      }
      curlex = lexem_next( curlex, LEXNEXT_IGNLINE  );
      if ( !(state & SWITCH_STDEFAULT ) && curlex->type == LEXEM_KEYWORD )
      {
         switch ( curlex->key )
         {
            case KEY_CASE:
               D( "Case\n" );
               curlex = lexem_next( curlex, 0 );
               //Цикл проверок условий для текущего Case
               while ( 1 )
               {  //Удаление из стэка результата сравнения
                  if ( !( state & SWITCH_STFIRST ) &&
                        !( state & SWITCH_STCASE ))
                     out_adduint( CPop );

                  state = SWITCH_STCASE;
                  // Добавляем в стэк команду дублирования последнего значения
                  out_adduint( dwsize == 1 ? CDup : CDuplong );

                  //Обрабатываем условие
                  curlex = f_expr( curlex, EXPR_COMMA | EXPR_NONULL, &parsc[2], &parsc[3]);

                  //Получаем операцию равенства
                  pfunc = bc_funcname( curlex, "#==", 2, parsc );
                  out_adduint( pfunc->vmo.id );
                  if ( (( povmtype )PCMD( pfunc->ret->type ))->stsize == 2 )
                     out_adduint( CLoglongtrue );
                  
                  if ( curlex->type == LEXEM_OPER && curlex->oper.operid == OpComma )
                  {
                     D( "Comma\n" );
                     curlex = lexem_next( curlex, LEXNEXT_IGNLINE );                     
                  }
                  else
                  {
                     //Устанавливаем переход на следующий Case
                     jmpnext = j_jump( CIfznocls, LABT_GTVIRT, -1 );
                     break;
                  }
                  //Устанавливаем переход на тело текущего Case
                  jmpbody = j_jump( CIfnznocls, LABT_GTVIRT, jmpbody );
               }
               state = SWITCH_STBODY;
               //Корректировка меток на текущее тело
               j_correct( jmpbody, j_label( LABT_LABELVIRT, -1) );
               jmpbody = -1;
               
               //Цикл обработки дополнительных меток
               curlex = lexem_next( curlex, LEXNEXT_SKIPLINE );
               while ( curlex->type == LEXEM_KEYWORD && curlex->key == KEY_LABEL )
               {
                  curlex = lexem_next( curlex, 0 );
                  curlex = c_label( curlex );
                  curlex = lexem_next( curlex, LEXNEXT_SKIPLINE );
               }               
               //Обработка тела
               curlex = f_body( curlex );
               //Перход на конец
               jmpend = j_jump( CGoto, LABT_GTVIRT, jmpend );
               break;

            case KEY_DEFAULT:
               //Корректировка последнего перехода
               state = SWITCH_STDEFAULT;
               //Цикл обработки дополнительных меток
               while ( 1 )
               {
                  curlex = lexem_next( curlex, LEXNEXT_IGNLINE  );
                  if ( curlex->type == LEXEM_KEYWORD && curlex->key == KEY_LABEL )
                     curlex = c_label( curlex );
                  else
                     break;
               }               
               curlex = f_body( curlex );
               break;
            default:
               msg( MNokeyword | MSG_LEXERR, curlex );// Ошибка Неправильное использование ключевого слова
         }
         continue;
      }
      else
      {
         if ( curlex->type == LEXEM_OPER && curlex->oper.operid == OpRcrbrack )
         {
            //Корректировка переходов на конец
            j_correct( jmpend, j_label( LABT_LABELVIRT, -1) );
            break;//Выйти из тела switch
         }
         msg( MRcurly | MSG_LEXERR, curlex );// Ошибка Ожадается закрывающая фигурная скобка
      }
   }

D( "Switch stop\n" );
   return curlex;
}