/******************************************************************************
*
* Copyright (C) 2006, The Gentee Group. All rights reserved.
* This file is part of the Gentee open source project - http://www.gentee.com.
*
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT").
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS
* ACCEPTANCE OF THE AGREEMENT.
*
* ID: vars 07.11.06 0.0.A.
*
* Author: Alexander Krivonogov ( algen )
*
* Summary: Функции для работы с локальными переменными
*
******************************************************************************/

#include "func.h"
#include "bcodes.h"

/*-----------------------------------------------------------------------------
*
* ID: create_varmode 07.11.06 0.0.A.
*
* Summary: Добавление описания переменной, параметра в байткод функции
*
-----------------------------------------------------------------------------*/
STDCALL create_varmode( pbuf out, ps_desctype desctype, ps_descid descid )
{
   byte flags = 0; //Значение для поля flags
   uint off_flags; //Смещение поля с flags
   uint i;

   off_flags = out->use + sizeof( uint );
   if ( desctype )
   {
      buf_appenduint( out, desctype->idtype );
      buf_appendch( out, 0 );
      if ( desctype->oftype )
      {
         buf_appenduint( out, desctype->oftype );
         flags |= VAR_OFTYPE;
      }
   }
   else
   {
      buf_appenduint( out, descid->idtype );
      buf_appendch( out, 0 );
      if ( descid->flgdesc & DESCID_PAR )
         flags |= VAR_PARAM;
      if ( descid->flgdesc & DESCID_PAR || descid->idtype == TReserved )
      {
         if ( descid->oftype )
         {
            buf_appenduint( out, descid->oftype );
            flags |= VAR_OFTYPE;
         }
         if ( descid->msr )
         {
            buf_appendch( out, (byte)(descid->msr) );
            flags |= VAR_DIM;
            for ( i = 0; i < descid->msr; i++ )
            {
               buf_appenduint( out, descid->msrs[i] );
            }
         }
      }
      if ( _compile->flag & CMPL_DEBUG && descid->name )
      {           
         flags |= VAR_NAME;  
         buf_append( out, descid->name , mem_len( descid->name  ) + 1 );                                      
      }
   }
   *(byte *)( out->data + off_flags ) = flags;
}


/*-----------------------------------------------------------------------------
*
* ID: var_add 07.11.06 0.0.A.
*
* Summary: Добавление локальной переменной в таблицу
*
-----------------------------------------------------------------------------*/
uint STDCALL var_add( phashiuint hidn, ps_descid descvar )
{
   pfvar cvar;

   buf_expand( &fd.bvars, sizeof( fvar ));
   cvar = (pfvar)(fd.bvars.data + fd.bvars.use);
   fd.bvars.use += sizeof( fvar );

   cvar->hidn = hidn;
   cvar->type = descvar->idtype;
   cvar->oftype = descvar->oftype;
   cvar->msr = descvar->msr;
   cvar->num = fd.varcount;
   cvar->flg = 0;
   cvar->oldoffbvar = 0;

   if ( ( descvar->flgdesc & DESCID_VAR || ( descvar->flgdesc == DESCID_PARSUBFUNC )) &&
         !fd.curcount )
   {  //Формируем загрузку нового блока
      if ( descvar->flgdesc == DESCID_VAR )
      {
         buf_appenduint( &fd.bblinit, CVarsInit );
         buf_appenduint( &fd.bblinit, fd.blcount );
      }
      fd.blcount++;
      if ( fd.lastcurcount )
      {  //Закрытие блока данных
         buf_appenduint( &fd.bhead, fd.lastcurcount );
         fd.lastcurcount = 0;
      }
   }

   if ( descvar->flgdesc != DESCID_SUBFUNC )
   {
   //Добавляем в заголовок функции
      create_varmode( descvar->flgdesc == DESCID_PARFUNC  ? &fd.bhead : &fd.bvardef, 0, descvar );
      fd.curcount++;
      return fd.varcount++;
   }
   return 0;
}

/*-----------------------------------------------------------------------------
*
* ID: var_addtmp 07.11.06 0.0.A.
*
* Summary: Добавить локальную переменную не имеющую имени
*
-----------------------------------------------------------------------------*/
uint STDCALL var_addtmp( uint type, uint oftype )
{
   s_descid descvar;
   descvar.oftype = oftype;
   descvar.idtype = type;
   descvar.flgdesc = DESCID_VAR;
   descvar.name = 0;
   return var_add( 0, &descvar );
}

/*-----------------------------------------------------------------------------
*
* ID: var_checkadd 07.11.06 0.0.A.
*
* Summary: Проверка локальной переменной на наличие и добавление в таблицу
*
-----------------------------------------------------------------------------*/
uint STDCALL var_checkadd( ps_descid descvar )
{
   uint    oldoffbvar; // Предыдущее смещение локальной переменной
   uint    offbvar;  // Смещение локальной переменной в таблице
   uint    num;     // Номер локальной переменной
   pfvar   var;    // Указатель на структуру локальной переменной
   phashiuint phitem;//Элемент хэштаблицы с локальной переменной
   //Поиск в таблице имён если нет добавляем
   phitem = (phashiuint)hash_create( &fd.nvars, descvar->name);

   //Получение номера переменной если есть
   oldoffbvar = phitem->val;

   //Если переменная есть и она в текущем блоке, то ошибка
   if ( oldoffbvar && oldoffbvar >= fd.oldoffbvar )
      msg( MDblname | MSG_LEXNAMEERR, descvar->lex );//Ошибка Идентификатор с таким именем уже есть

   //Запись в таблицу смещения новой переменной
   phitem->val = offbvar = fd.bvars.use;

   //Вызов функции добавления
   num = var_add( phitem, descvar );

   //Запись дополнительной информации
   var = ( pfvar )( fd.bvars.data + offbvar );
   if ( oldoffbvar )
   {
      var->oldoffbvar = oldoffbvar;
   }
   return num;
}

/*-----------------------------------------------------------------------------
*
* ID: var_def 07.11.06 0.0.A.
*
* Summary: Обработка описаний локальных переменных, параметров функции
*
-----------------------------------------------------------------------------*/
plexem STDCALL var_def( plexem curlex, uint flgdesc )
{
   s_descid   descvar;

   descvar.flgdesc = flgdesc;
   descvar.idtype = 0;
   while ( 1 )
   {
      curlex = desc_nextidvar( curlex, &descvar );
      if ( !descvar.idtype ) break;
   }
   return curlex;
}