/******************************************************************************
*
* Copyright (C) 2006, The Gentee Group. All rights reserved.
* This file is part of the Gentee open source project - http://www.gentee.com.
*
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT").
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS
* ACCEPTANCE OF THE AGREEMENT.
*
* ID: body 22.01.07 0.0.A.
*
* Author: Alexander Krivonogov ( algen )
*
* Summary: Block of function processing
*
******************************************************************************/


#include "func.h"
#include "ifdef.h"
#include "../vm/vmtype.h"

/*-----------------------------------------------------------------------------
*
* ID: f_body 22.01.07 0.0.A.
*
* Summary: Block of function processing
*
-----------------------------------------------------------------------------*/
plexem STDCALL f_body( plexem curlex )
{
   plexem    nextlex;     //Лексема следующая после ключевого слова
   plexem    prevlex;

   uint      oldbvaruse;   //Пред. размер буфера для локальных переменных
   uint      oldbblinituse;//Пред. размер стэка ининициализации буферов
   uint      oldboutuse;   //Пред. размер байткода для вставки инициализации буферов
   uint      oldblabelsuse;//Пред. размер таблицы меток
   uint      oldbvarsasuse;//Перд. размер таблицы переменных As
   uint      lastcurcount; //Пред. значение fd.lastcurcount
   uint      oldvarcount;  //Пред. количество переменных

   pflabel   curlabel;   // Текущий элемент в таблице меток

   pfvar     pvar;       //Указатель на структуру переменной
   pfvaras   pvaras;     //Указатель на структуру as переменной
   uint      numins;     //На сколько сдвигать байткод при вставке команд иниц. блоков
   uint      rettype;    //Тип значения return
   uint      retoftype;  //Тип элеменента значения return
   uint      off;        //Временная переменная для смещений

D( "Body start\n" );

//Инициализация и сохранение данных по верхнему блоку
   oldbblinituse = fd.bblinit.use;
   oldboutuse     = fd.bout->use;
   oldbvarsasuse  = fd.bvarsas.use;
   if ( fd.curcount )
   {
      lastcurcount = fd.lastcurcount;
      fd.lastcurcount = fd.curcount;
   }
   else
   {
      lastcurcount = -1;
   }
   oldvarcount = fd.varcount;
   fd.curcount = 0;
   fd.bllevel++;
   oldbvaruse = fd.oldoffbvar;
   fd.oldoffbvar = fd.bvars.use;
   oldblabelsuse = fd.blabels.use;

   //Открывающая фигурная скобка
   curlex = lexem_next( curlex, LEXNEXT_SKIPLINE );
   curlex = lexem_next( curlex, LEXNEXT_IGNLINE | LEXNEXT_LCURLY );

   //Главный цикл чтения лексем
   while ( 1 )
   {      
      if ( curlex->type == LEXEM_KEYWORD )
      {
         nextlex = lexem_next( curlex, 0 );
         switch ( curlex->key )
         {
            case KEY_SUBFUNC:
               curlex = f_subfunc( nextlex );
               goto next;
            case KEY_IF:
               curlex = c_if( nextlex );
               continue;
            case KEY_WHILE:
               curlex = c_while( nextlex );
               goto next;
            case KEY_BREAK:
               out_debugtrace( curlex );
               curlex = nextlex;
               if ( fd.blcycle )
                  fd.offlcbreak = j_jump( CGoto, LABT_GTVIRT, fd.offlcbreak );
               else
                  msg( MLoopcmd | MSG_LEXERR, curlex );
               break;
            case KEY_CONTINUE:
               out_debugtrace( curlex );
               curlex = nextlex;
               if ( fd.blcycle )
                  fd.offlccontinue = j_jump( CGoto, LABT_GTVIRT, fd.offlccontinue );
               else
                  msg( MLoopcmd | MSG_LEXERR, curlex );
               break;
            case KEY_FOR:
               curlex = c_for( nextlex );
               goto next;
            case KEY_FORNUM:
               curlex = c_fornum( nextlex );
               goto next;
            case KEY_FOREACH:
               curlex = c_foreach( nextlex );
               goto next;
            case KEY_DO:
               curlex = c_dowhile( nextlex );
               goto next;
            case KEY_LABEL:
               curlex = c_label( nextlex );
               continue;
            case KEY_GOTO:
               curlex = c_goto( nextlex );
               break;
            case KEY_RETURN:
               prevlex = curlex;
               curlex = f_expr( nextlex, 0, &rettype, &retoftype );                              
               if (  !type_compat( rettype, fd.functype, 0 ) ||
                     ( fd.funcoftype && !type_compat( retoftype, fd.funcoftype, 1 )) )
                  /*type_compfull( rettype ) !=
                    type_compfull( fd.functype ) ||
                    type_compfull( retoftype ) !=
                    type_compfull( fd.funcoftype )*/
                  msg( MRettype | MSG_LEXERR, curlex );

               if ( !rettype )
                  out_debugtrace( prevlex );

               if ( fd.bout == &fd.bsubout )
                  out_adduint( CSubreturn );
               else
               {
                  if ( fd.flgfunc & GHBC_RESULT )
                  {
                     out_add2uint( CVarload, fd.idresult );
                  }
                  out_adduint( CReturn );
               }
               j_label( LABT_RETURN, -1 );
               continue;

            case KEY_SWITCH:
               curlex = c_switch( nextlex );
               goto next;

            case KEY_WITH:
               curlex = c_with( nextlex );
               goto next;

            default:
               curlex = f_expr( curlex, 0, 0, 0 );//Обработка выражения
               continue;
         }
         if ( curlex->type == LEXEM_OPER && !(curlex->oper.operid == OpLine ||
               curlex->oper.operid == OpRcrbrack) )
            msg( MExpline | MSG_LEXERR, curlex );
         continue;
      }
      else
      {
         if ( curlex->type == LEXEM_OPER )
         {
            if ( curlex->oper.operid == OpRcrbrack )//}
            {
               break;//Выйти из тела
            }
            if ( curlex->oper.operid == OpLcrbrack )//{
            {
               curlex = f_body( curlex );//Ещё одно тело
               goto next;
            }
            else if ( curlex->oper.operid == OpLine )
               goto next;
         }
         else
         if ( curlex->type == LEXEM_NAME )
         {  //Возможно определение локальных переменных
            curlex = var_def( curlex, DESCID_VAR );
         }
         curlex = f_expr( curlex, 0, 0, 0 );//Обработка выражения
         continue;
      }
next:
      curlex = lexem_next( curlex, LEXNEXT_IGNLINE );
   }

   //Восстановление типов as
   off = (uint)fd.bvarsas.data + oldbvarsasuse;   
   for ( pvaras = ((pfvaras)(fd.bvarsas.data + fd.bvarsas.use)) - 1;
         (uint)pvaras >= off;
         pvaras-- )
   {            
      pvar = ( pfvar )(fd.bvars.data + pvaras->offbvar);
      pvar->type = pvaras->type;      
      pvar->oftype = pvaras->oftype;
      pvar->flg = pvaras->flg;
   }
   fd.bvarsas.use = oldbvarsasuse;

   //Очистка локальных переменных
   off = (uint)fd.bvars.data + fd.oldoffbvar;
   for ( (uint)pvar = (uint)fd.bvars.data + fd.bvars.use - sizeof( fvar );
         (uint)pvar >= off; pvar-- )
   {
      if ( pvar->hidn )
      {
         pvar->hidn->val = pvar->oldoffbvar;
      }
   }
   //Удаляем лишние локальные переменные
   fd.bvars.use = fd.oldoffbvar;
   fd.oldoffbvar = oldbvaruse;
   //Установка количества локальных переменных для последнего блока
   if ( fd.curcount )
   {
      buf_appenduint( &fd.bhead, fd.curcount );
   }
   if ( oldvarcount != fd.varcount )
   {
      fd.curcount = 0;
      fd.lastcurcount = 0;
   }
   else
   {
      if ( lastcurcount != -1 )
      {
         fd.curcount = fd.lastcurcount;
         fd.lastcurcount = lastcurcount;
      }
   }

   //Вставка команд инициализации блоков
   numins = fd.bblinit.use - oldbblinituse;
   if ( numins )
   {
      buf_insert( fd.bout, oldboutuse, fd.bblinit.data + oldbblinituse, numins );
      fd.bblinit.use = oldbblinituse;
   }

//Корректировка меток
   curlabel = ( pflabel )( fd.blabels.data + oldblabelsuse );
   oldblabelsuse = ( uint )( fd.blabels.data + fd.blabels.use );
   while( ( uint )curlabel < oldblabelsuse )
   {      
      curlabel->offbout += numins;
      
      if ( !( curlabel->type & LABT_VIRT ) )
      {
         if ( curlabel->type & LABT_LABEL )
         {            
            curlabel->type = LABT_LABELUNDEF;
         }
         else
         if ( ( curlabel->type & LABT_GTUNDEF ) == LABT_GTUNDEF )
         {  //Определение неопределенных меток
            off = curlabel->hitem->val;
            if ( off != -1 )
            {
               if ( (( pflabel )(fd.blabels.data + off ))->type & LABT_LABEL )
               {
                  curlabel->type = LABT_GTDEF;
                  curlabel->link = off;
               }
               else
                  msg( MUnklabel | MSG_LEXNAMEERR, curlabel->lex );
            }
         }
      }
      curlabel++;
   }
   fd.bllevel--;

D( "Body stop\n" );
   return curlex;
}