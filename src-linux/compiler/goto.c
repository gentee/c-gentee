/******************************************************************************
*
* Copyright (C) 2006, The Gentee Group. All rights reserved.
* This file is part of the Gentee open source project - http://www.gentee.com.
*
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT").
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS
* ACCEPTANCE OF THE AGREEMENT.
*
* ID: goto 08.02.07 0.0.A.
*
* Author: Alexander Krivonogov ( algen )
*
* Summary: Конструкции goto, label
*
******************************************************************************/

#include "func.h"

/*-----------------------------------------------------------------------------
*
* ID: c_goto 08.02.07 0.0.A.
*
* Summary: The goto processing
*
-----------------------------------------------------------------------------*/
plexem STDCALL c_goto( plexem curlex )
{
   pflabel    curlabel; //Текущий элемент в стэке меток
   phashiuint phitem;   //Элемент хэштаблицы со смещением описания метки
   uint       offlabel; //Смещение в таблице меток

   out_debugtrace( curlex );

   if ( curlex->type == LEXEM_NAME )
   {
      out_add2uint( CGoto, 0 );
      phitem = (phashiuint)hash_create( &fd.nlabels, lexem_getname( curlex ) );
      //curlabel = newlabel;
      curlabel = (pflabel)buf_appendtype( &fd.blabels, sizeof( flabel ));

      curlabel->offbout = fd.bout->use - sizeof( uint );
      offlabel = phitem->val;
      if ( !offlabel || offlabel == -1)
      {  //Такого имени ещё нет
         curlabel->type = LABT_GTUNDEF;
         curlabel->hitem = phitem;//?phitem вроде постоянный
         curlabel->lex = curlex;
         phitem->val = -1;
      }
      else
      {         
         if ( (( pflabel )( fd.blabels.data + offlabel ))->type ==
               ( LABT_LABEL | (uint)( fd.bout == &fd.bsubout ? LABT_SUBFUNC : 0) ) )
         {  //Действующая метка
            curlabel->type = LABT_GTDEF;
            curlabel->link = offlabel;
         }
         else
         {            
            msg( MUnklabel | MSG_LEXNAMEERR, curlex );
         }
      }
   }
   else
      msg( MExpname | MSG_LEXERR, curlex );
   curlex = lexem_next( curlex, 0 );
   
   return curlex;
}


/*-----------------------------------------------------------------------------
*
* ID: c_label 08.02.07 0.0.A.
*
* Summary: The label processing
*
-----------------------------------------------------------------------------*/
plexem STDCALL c_label( plexem curlex )
{
   uint       offlabel; //Смещение в таблице меток
   phashiuint phitem;   //Элемент хэштаблицы со смещением описания метки

   if ( curlex->type == LEXEM_NAME )//Идентификатор
   {      
      phitem = (phashiuint)hash_create( &fd.nlabels, lexem_getname( curlex ) );
      if ( !phitem->val || phitem->val == -1 )
      {  //Такого имени ещё нет
         offlabel = j_label( LABT_LABEL |
                              (fd.bout == &fd.bsubout ? LABT_SUBFUNC : 0), (uint)phitem );
         phitem->val = offlabel;
      }
      else
         msg( MRedeflabel | MSG_LEXNAMEERR, curlex );
   }
   else
      msg( MExpname | MSG_LEXERR, curlex );
   return lexem_next( curlex, 0 );
}
