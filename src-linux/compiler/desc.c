/******************************************************************************
*
* Copyright (C) 2006, The Gentee Group. All rights reserved.
* This file is part of the Gentee open source project - http://www.gentee.com.
*
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT").
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS
* ACCEPTANCE OF THE AGREEMENT.
*
* ID: desc 03.11.06 0.0.A.
*
* Author: Alexander Krivonogov ( algen )
*
* Summary: Обработка описаний переменных, параметров, приведений типов
*
******************************************************************************/


#include "func.h"
#include "macroexp.h"

/*-----------------------------------------------------------------------------
*
* ID: desc_nextidvar 03.11.06 0.0.A.
*
* Summary: Обработка следующей переменной, параметра, поля структуры
*
-----------------------------------------------------------------------------*/
plexem STDCALL desc_nextidvar( plexem curlex, ps_descid descid )
{
   //uint flgnextlex;//Игнорировать переносы
   uint type;      //Тип текущей переменной
   pmacrores mr;   //Результат обработки макровыражения
   uint msrtype;   //Тип текущей размерности
   uint stkparsc[ MAX_MSR * 2 ];//Стэк для заполнения размерностей TReserved
   puint parsc;    //Текущий указатель в стэке размерностей
   plexem beglex;  //Лексема с именем идентификатора
   plexem skiplex; //Текущая лексема для пропуска

   D( "Nextidvar start\n" );
   //flgnextlex = 0;
   //if ( descid->flgdesc & DESCID_PAR )
   //   flgnextlex = LEXNEXT_IGNLINE;
   if ( curlex->type == LEXEM_OPER &&
        curlex->oper.operid == OpComma )     
   {
      if ( descid->idtype )
      {
         curlex = lexem_next( curlex, LEXNEXT_IGNLINE );   
         if (descid->flgdesc & DESCID_PARFUNC)
         {
            descid->idtype = 0;     
         }
      }      
   }

   if ( !( descid->flgdesc & DESCID_VAR ) && 
        curlex->type == LEXEM_OPER && curlex->oper.operid == OpLine )
   {      
      descid->idtype = 0;
      curlex = lexem_next( curlex, LEXNEXT_SKIPLINE );
   }
   //Определяем тип идентификатора
   if ( curlex->type != LEXEM_NAME )
   {  //Идентификаторов больше нет
      descid->idtype = 0;
      return curlex;
   }
   type = bc_type( curlex );
   if ( descid->idtype && type )
   {   //Указан новый тип
      descid->idtype = 0;
   }
   
   if ( !descid->idtype )
   {   //Получаем новый тип
      if ( !type || curlex->flag & LEXF_CALL )
      {         
         if ( descid->flgdesc & DESCID_PARFUNC &&
             curlex->type == LEXEM_NAME )
            msg( MExptype | MSG_LEXERR, curlex );//Ожидается имя типа         
         return curlex;
      }
      descid->idtype = type;
      curlex = lexem_next( curlex, 0/*flgnextlex*/ );
   }
   //Получаем идентификатор
   
   if ( curlex->type != LEXEM_NAME )
      msg( MExpname | MSG_LEXERR, curlex );//Ожидается идентификатор   

   beglex = curlex;
   descid->name = lexem_getname( curlex );
   descid->lex = curlex;
   descid->msr = 0;
   descid->oftype = 0;
   descid->lexres = 0;

   //Обработка размерностей
   if ( curlex->flag & LEXF_ARR )
   {
      if ( descid->flgdesc == DESCID_VAR && descid->idtype != TReserved )
      {  // Если не тип Reserved то начальная загрузка
         parsc = stkparsc;
         out_add2uint( CVarload, fd.varcount );
         *(parsc++) = type;
         *(parsc++) = 0;
      }
      curlex = lexem_next( curlex, 0/*flgnextlex*/ );

      while ( 1 ) //цикл по размерностям
      {
         curlex = lexem_next( curlex, LEXNEXT_IGNLINE );
         if ( !( descid->flgdesc & DESCID_PAR ))
         {   //может быть число, выражение
            if ( descid->flgdesc == DESCID_VAR && descid->idtype != TReserved )
            {
               //Обработка выражения
               curlex = f_expr( curlex, EXPR_ARR | EXPR_COMMA, &msrtype, 0 );
               *(parsc++) = msrtype;
               *(parsc++) = 0;
            }
            else
            {
               //Обработка макровыражения/числа
               curlex = macroexpr( curlex, &mr );
               if ( mr->vallexem.type = LEXEM_NUMBER &&
                     mr->vallexem.num.type == TUint )
               {
                  descid->msrs[descid->msr] = mr->vallexem.num.vint;
               }
               else
                  msg( MExpuint | MSG_LEXERR, curlex );
            }
         }
         descid->msr++;
         if ( curlex->type == LEXEM_OPER )
         {
            if ( curlex->oper.operid == OpComma )
            {                  
               continue;
            }
            if ( curlex->oper.operid == OpRsqbrack )
            {
               break;
            }
         }
         msg( MExpcomma | MSG_LEXERR, curlex );
      }
   }

   curlex = lexem_next( curlex, 0/*flgnextlex*/ );

   //Обработка of
   if ( curlex->type == LEXEM_KEYWORD &&
        curlex->key == KEY_OF )
   {      
      if ( (( povmtype)PCMD( type ))->index.type )
         msg( 0 | MSG_LEXERR, curlex );
      curlex = lexem_next( curlex, LEXNEXT_IGNLINE );
      descid->oftype = bc_type( curlex );
      if ( !descid->oftype )
         msg( MExptype | MSG_LEXERR, curlex );//Должен быть указан тип после of
      curlex = lexem_next( curlex, 0 );
   }

   //Конечная обработка
   switch ( descid->flgdesc )
   {
      case DESCID_GLOBAL:
      case DESCID_TYPE:
         if ( curlex->type == LEXEM_OPER &&
               curlex->oper.operid == OpSet )
         {
            curlex = lexem_next( curlex, LEXNEXT_IGNLINE );
            curlex = macroexpr( curlex, &mr );
            descid->lexres = &mr->vallexem;
         }
         //curlex = lexem_next( curlex, LEXNEXT_SKIPLINE );
         break;
      case DESCID_VAR:
         if ( descid->idtype != TReserved )
         {
            if ( descid->oftype )
            {
               out_adduints( 5, CVarload, fd.varcount, CCmdload, descid->oftype,
               bc_find( curlex, "@oftype", 2, descid->idtype, TUint ) );
            }
            if ( descid->msr )
               out_adduint(
                     bc_funcname( curlex, "@array", descid->msr+1, stkparsc )->vmo.id );

         }
         var_checkadd( descid );
         if ( ( curlex->type == LEXEM_OPER &&
              curlex->oper.operid == OpSet ) ||
              ( curlex->type == LEXEM_KEYWORD &&
              curlex->key == KEY_AS ))
         {
            //Удаление из обработки описания массива
            for( skiplex = curlex + 1; skiplex < curlex; skiplex++ )
               skiplex->type = LEXEM_SKIP;
            curlex = f_expr( beglex, EXPR_COMMA, 0, 0 );
         }
         //Обработка выражения
         break;
      case DESCID_PARFUNC:
      case DESCID_PARSUBFUNC:
         var_checkadd( descid );
         break;
   }

   /*if ( curlex->type == LEXEM_OPER &&
        curlex->oper.operid == OpComma )     
      curlex = lexem_next( curlex, LEXNEXT_IGNLINE );   */
   D( "Nextidvar stop\n" );
   return curlex;
}


/*-----------------------------------------------------------------------------
*
* ID: desc_idtype 03.11.06 0.0.A.
*
* Summary: Обработка описания типа
*
-----------------------------------------------------------------------------*/
plexem STDCALL desc_idtype( plexem curlex, ps_desctype desctype)
{
   D( "type start\n" );
   desctype->idtype = bc_type( curlex );
   desctype->msr = 0;
   desctype->oftype = 0;

   if ( desctype->idtype )
   {
      curlex = lexem_next( curlex, 0 );

      if ( curlex->type == LEXEM_OPER &&
           curlex->oper.operid == OpLsqbrack ) //Обработка размерностей []
      {   //Данный код нужен для совместимости со старой версией
         while ( 1 ) //цикл по размерностям
         {
            curlex = lexem_next( curlex, LEXNEXT_IGNLINE );
            desctype->msr++;
            if ( curlex->type == LEXEM_OPER )
            {
               if ( curlex->oper.operid == OpComma )
               {
                  continue;
               }
               if ( curlex->oper.operid == OpRsqbrack )
               {
                  curlex = lexem_next( curlex, 0 );
                  break;
               }
            }
            if ( desctype->msr > 2 )
               msg( MExpcomma | MSG_LEXERR, curlex );
            else
            {
               return curlex - 1;
            }
         }
      }

      if ( curlex->type == LEXEM_KEYWORD &&
           curlex->key == KEY_OF )//Обработка типа элемента of
      {
         curlex = lexem_next( curlex, LEXNEXT_IGNLINE );
         desctype->oftype = bc_type( curlex );
         if ( !desctype->oftype )
            msg( MExptype | MSG_LEXERR, curlex );
         curlex = lexem_next( curlex, 0 );
      }
   }
   D( "type stop\n" );
   return curlex;
}
