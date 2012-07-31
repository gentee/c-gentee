/******************************************************************************
*
* Copyright (C) 2006, The Gentee Group. All rights reserved.
* This file is part of the Gentee open source project - http://www.gentee.com.
*
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT").
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS
* ACCEPTANCE OF THE AGREEMENT.
*
* ID: jump 07.02.07 0.0.A.
*
* Author: Alexander Krivonogov ( algen )
*
* Summary: Переходы и метки
*
******************************************************************************/

#include "func.h"

/*-----------------------------------------------------------------------------
*
* ID: j_jump 07.02.06 0.0.A.
*
* Summary: Добавление перехода в таблицу меток
*
-----------------------------------------------------------------------------*/
uint STDCALL j_jump( uint cmd, uint flag, uint link )
{
   uint      off;        //Смещение на элемент в таблице меток
   pflabel   curlabel;   //Текущий элемент в таблице меток

   out_add2uint( cmd, 0 );

   off = fd.blabels.use;
   curlabel = (pflabel)buf_appendtype( &fd.blabels, sizeof( flabel ));   

   curlabel->type = flag;
   curlabel->offbout = fd.bout->use - sizeof( uint );
   curlabel->link = link;
   return off;
}

/*-----------------------------------------------------------------------------
*
* ID: j_label 07.02.06 0.0.A.
*
* Summary: Добавление метки в таблицу меток
*
-----------------------------------------------------------------------------*/
uint STDCALL j_label( uint flag, uint link )
{
   uint      off;        //Смещение на элемент в таблице меток
   pflabel   curlabel;   //Текущий элемент в таблице меток

   off = fd.blabels.use;
   curlabel = (pflabel)buf_appendtype( &fd.blabels, sizeof( flabel ));

   curlabel->type = flag;
   curlabel->offbout = fd.bout->use;
   curlabel->link = link;
   return off;
}

/*-----------------------------------------------------------------------------
*
* ID: j_correct 07.02.06 0.0.A.
*
* Summary: Корректировка последовательности переходов
*
-----------------------------------------------------------------------------*/
void STDCALL j_correct( uint curoff, uint link )
{
   pflabel   curlabel;   // Текущий элемент в таблице меток
   while ( curoff != -1 )
   {
      curlabel = (pflabel)( fd.blabels.data + curoff );
      curoff = curlabel->link;
      curlabel->link = link;
   }
}
