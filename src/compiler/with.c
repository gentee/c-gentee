/******************************************************************************
*
* Copyright (C) 2006, The Gentee Group. All rights reserved.
* This file is part of the Gentee open source project - http://www.gentee.com.
*
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT").
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS
* ACCEPTANCE OF THE AGREEMENT.
*
* ID: with 16.02.07 0.0.A.
*
* Author: Alexander Krivonogov ( algen )
*
* Summary: The with statement
*
******************************************************************************/

#include "func.h"

/*-----------------------------------------------------------------------------
*
* ID: c_with 16.02.07 0.0.A.
*
* Summary: The with processing
*
-----------------------------------------------------------------------------*/
plexem STDCALL c_with( plexem curlex )
{
   uint       objnum;  //Номер дополнительной переменной хранящей объект
   uint       objtype; //Тип объекта
   pfwith     pwith;

//Обработка выражения-объекта
   objnum = var_addtmp( TUint, 0 ); //Создание переменной для хранения адреса объекта
   out_add2uint( CVarptrload, objnum );//Байт код для сохранения результата выражения
   curlex = f_expr( curlex, EXPR_NONULL, &objtype, 0 );
   out_adduint( CSetI );//Байт код загрузки значения

   pwith = ( pfwith )buf_appendtype( &fd.bwith, sizeof( fwith ));
   pwith->num = objnum;
   pwith->type = objtype;
   curlex = f_body( curlex );
   fd.bwith.use -= sizeof( fwith );

   return curlex;
}