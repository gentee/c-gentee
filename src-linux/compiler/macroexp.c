/******************************************************************************
*
* Copyright (C) 2006, The Gentee Group. All rights reserved.
* This file is part of the Gentee open source project - http://www.gentee.com.
*
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT").
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS
* ACCEPTANCE OF THE AGREEMENT.
*
* ID: expmacro 18.10.06 0.0.A.
*
* Author: Alexander Krivonogov ( algen )
*
* Summary: Обработка макро выражений
*
******************************************************************************/

#include "macroexp.h"

/*-----------------------------------------------------------------------------
*
* ID: macroepr 18.10.06 0.0.A.
*
* Summary: The macro expression processing
*
-----------------------------------------------------------------------------*/
/*Возможны операции
с целыми числами        + - +ун -ун * / ! && || & | ~ > < >= <= == !=
с дробными числами     + - +ун -ун * / ! && ||       > < >= <= == !=
со строками и буфером                  ! && ||(Длина)          == != (значения)
*/
plexem STDCALL macroexpr( plexem curlex, pmacrores * mr )
{
   psoper      curop;    //Текущая операция
   psoper      stackop;  //Оператор из стэка

   uint        bropen;   //Количество открытых скобок ( и [
   uint        flgexp;   //Флаг определяющий конец разбора
   uint        state;    //Флаг типа текущей лексемы L_*
   uint        laststate; //Флаг типа предыдущей лексемы L_*

   pmacrooper  stackb;   //Указатель на начало стэка операций
   pmacrooper  stackc;   //Указатель на следующий элемент стэка операций

   pmacrores   tokb;     //Указатель на начало таблицы
   pmacrores   tokc;     //Указатель на следующий элемент таблицы
   pmacrores   tokleft;  //Указатель на левый операнд для IFDEF
   pmacrores   tokright; //Указатель на правый операнд для IFDEF
   plexem      maxlex;

   pbuf        bcol;     //Буфер с коллекцией
   pstr        strt;     //Указатель на строку
   pbuf        buft;     //Указатель на бинарные данные

   uint        curop_flgs;
   uint        curop_before;
   uint        curop_id;
   uint        stackop_flgs;
   uint        stackop_after;
   uint        stackop_id;

   uint   left_type, flg_resuint, flg_not;
   uint   left_numtype, right_numtype;
   uint   left_bvalue, right_bvalue;
   int    left_int, right_int;
   int    left_intl, left_intf, left_intd;
   long64 left_long, right_long;
   float  left_float, right_float;
   double left_double, right_double;

// Инициализация
   stackb = _compile->stkmopers;//Стэк операций
   stackc = stackb;
   tokb = _compile->stkmops;//Стэк операндов
   tokc = tokb;
   flgexp = 1;
   bropen = 0;
   laststate = L_UNARY_OPEN;
   maxlex = curlex + min( STACK_OPERS / sizeof( macrooper ), STACK_OPS / sizeof( macrores ) );
D("Macroexp start\n" );

//Цикл формирования байткода
   while ( 1 )
   {
// Обработка системной лексемы
      if ( curlex->type == LEXEM_OPER )
      {
         curop_id = curlex->oper.operid;
         curop = (psoper)&opers[curop_id]; 
         curop_flgs = curop->flgs;

// Первичная обработка
         if ( curop_flgs & OPF_OPEN )//Открывающие скобки
         {          
            if ( curop_id == OpLcrbrack )
               flgexp = 0;//Если в конце выражения откр. фиг. скобка, то выходим из цикла
            else
            {
               state = L_UNARY_OPEN;
               bropen++;
            }
         }
         else
         if ( curop_flgs & OPF_CLOSE )//Закрывающие скобки
         {    
            if ( bropen )
            {
               state = L_POST_CLOSE;
               bropen--;
            }
            else
            {
               if ( curop_id == OpRcrbrack ||
                    ( stackc != stackb ||
                    tokc != tokb ))
                  flgexp = 0;//Непарная скобка
               else
                  msg( MSyntax | MSG_LEXNAMEERR, curlex );
            }
         }
         else
         if ( curop_id == OpLine ) // ; - Точка с запятой - Перенос строки
         {
            if ( laststate & L_BINARY || bropen > 0 )
               goto next;
            flgexp = 0;
         }
         else
         if ( curop_id == OpComma )//, - Запятая
         {
            if ( !bropen )
            {
               flgexp = 0;
            }
         }
         else
         if ( curop_flgs & OPF_UNDEF ) //Неопределённый оператор
         {
            if ( laststate & ( L_OPERAND | L_POST_CLOSE ))
            {
               curop = ( psoper )&opers[curop_id = ++curlex->oper.operid];
               curop_flgs = curop->flgs;
            }
         }

// Дополнительная обработка
         if ( curop_flgs & OPF_BINARY )
         {
            state = L_BINARY;
         }
         else
         if ( curop_flgs & OPF_UNARY )
         {
            state = L_UNARY_OPEN;
         }
         else
         if ( curop_flgs & OPF_POST )
         {
            state = L_POST_CLOSE;
         }
         curop_before = curop->before;
// Цикл выталкивания из стека операций
         while ( stackc != stackb )
         {
            stackop_id = (stackc-1)->operid;
            stackop = (psoper)&opers[stackop_id];
            stackop_after = stackop->after;
            stackop_flgs = stackop->flgs;
            flg_not = 0;
            flg_resuint = 0;
            if ( !flgexp || stackop_after >= curop_before )
            {
               stackc--;
               if ( !( stackop_flgs & ( OPF_OPEN | OPF_CLOSE ) ||
                    stackop_id == OpComma ) )
               {
                  if ( stackop_flgs & OPF_BINARY )
                  {
                     tokleft = tokc - 2;
                     tokright = tokc - 1;
                     tokc--;
                  }
                  else
                  {
                     tokleft = tokc - 1;
                     tokright = 0;
                  }
                  if ( tokright && tokright < tokb + 1 )
                     msg( MSyntax | MSG_LEXNAMEERR, curlex );

                  left_type = tokleft->vallexem.type;
                  if ( left_type == LEXEM_NUMBER )
                  {
                     left_numtype = tokleft->vallexem.num.type;
                     if ( left_numtype == TUint )
                        left_numtype = TInt;
                     else if ( left_numtype == TUlong )
                        left_numtype = TLong;
                     left_int = tokleft->vallexem.num.vint;
                     left_long = tokleft->vallexem.num.vlong;
                     left_float = tokleft->vallexem.num.vfloat;
                     left_double = tokleft->vallexem.num.vdouble;
                  }
                  else left_numtype = 0;
                  left_bvalue = tokleft->bvalue;
                  if ( tokright )//Бинарная операция
                  {
                     right_bvalue = tokright->bvalue;
                     if ( stackop_id != OpLogand && stackop_id != OpLogor )
                     {
                        if ( left_type != tokright->vallexem.type )
                           goto nosup;                     
                        if ( left_numtype )
                        {
                           right_numtype = tokright->vallexem.num.type;
                           if ( right_numtype == TUint )
                              right_numtype = TInt;
                           else if ( right_numtype == TUlong )
                              right_numtype = TLong;
                           if ( left_numtype != right_numtype )
                              goto nosup;
                           right_int = tokright->vallexem.num.vint;
                           right_long = tokright->vallexem.num.vlong;
                           right_float = tokright->vallexem.num.vfloat;
                           right_double = tokright->vallexem.num.vdouble;
                        }
                     }
                     if ( left_bvalue == -1 || right_bvalue == -1 )
                        goto nosup;
                     switch ( stackop_id )
                     {
                        //Арифметические операции
                        case OpAdd:
                           if ( left_numtype )
                           {
                              left_int += right_int;
                              left_long += right_long;
                              left_float += right_float;
                              left_double += right_double;
                              break;
                           }
                           goto nosup;
                        case OpSub:
                           if ( left_numtype )
                           {
                              left_int -= right_int;
                              left_long -= right_long;
                              left_float -= right_float;
                              left_double -= right_double;
                              break;
                           }
                           goto nosup;
                        case OpMul:
                           if ( left_numtype )
                           {
                              left_int *= right_int;
                              left_long *= right_long;
                              left_float *= right_float;
                              left_double *= right_double;
                              break;
                           }
                           goto nosup;
                        case OpDiv:
                           if ( left_numtype )
                           {
                              left_int /= right_int;
                              left_long /= right_long;
                              left_float /= right_float;
                              left_double /= right_double;
                              break;
                           }
                           goto nosup;

                        //Двоичные операции
                        case OpBinand:
                           switch ( left_numtype )
                           {
                              case TInt:
                                 left_int &= right_int;
                                 break;
                              case TLong:
                                 left_long &= right_long;
                                 break;
                              default: goto nosup;
                           }
                           break;
                        case OpBinor:
                           switch ( left_numtype )
                           {
                              case TInt:
                                 left_int |= right_int;
                                 break;
                              case TLong:
                                 left_long |= right_long;
                                 break;
                              default: goto nosup;
                           }
                           break;
                        case OpBinxor:
                           switch ( left_numtype )
                           {
                              case TInt:
                                 left_int ^= right_int;
                                 break;
                              case TLong:
                                 left_long ^= right_long;
                                 break;
                              default:   goto nosup;
                           }
                           break;

                        //Логические операции
                        case OpLogand:
                           left_int = ( left_bvalue && right_bvalue ) ? 1 : 0;
                           flg_resuint = 1;
                           break;
                        case OpLogor:
                           left_int = ( left_bvalue || right_bvalue ) ? 1 : 0;
                           flg_resuint = 1;
                           break;

                        //Операции равенства
                        case OpNoteq:
                           flg_not = 1;
                        case OpEq:
                           if ( left_type == LEXEM_STRING || left_type == LEXEM_BINARY )
                           {
                              left_int = buf_isequal(
                                 (pstr)lexem_getstr( &tokleft->vallexem ),
                                 (pstr)lexem_getstr( &tokright->vallexem ));
                           }
                           /*else if ( left_type == LEXEM_BINARY )
                           {
                              buf_isequal(
                                 (pbuf)lexem_getstr( &tokleft->vallexem ),
                                 (pbuf)lexem_getstr( &tokright->vallexem ));
                           }*/
                           else if ( left_numtype )
                           {
                              left_int = left_int == right_int;
                              left_intl = left_long == right_long;
                              left_intf = left_float == right_float;
                              left_intd = left_double == right_double;
                           }
                           else goto nosup;
                           flg_resuint = 1;
                           break;

                        //Операции сравнения чисел
                        case OpGreateq:
                           flg_not = 1;
                        case OpLess:
                           if ( left_numtype )
                           {
                              left_int = left_int < right_int;
                              left_intl = left_long < right_long;
                              left_intf = left_float < right_float;
                              left_intd = left_double < right_double;
                              flg_resuint = 1;
                              break;
                           }
                           goto nosup;
                        case OpLesseq:
                           flg_not = 1;
                        case OpGreater:
                           if ( left_numtype )
                           {
                              left_int = left_int > right_int;
                              left_intl = left_long > right_long;
                              left_intf = left_float > right_float;
                              left_intd = left_double > right_double;
                              flg_resuint = 1;
                              break;
                           }
                        default: goto nosup;
                     }
                  }
                  else //Унарные операции
                  {
                     switch ( stackop_id )
                     {
                        //Арифметические унарные операции
                        case OpPlus:
                           if ( !left_numtype )
                              goto nosup;
                           break;
                        case OpMinus:
                           if ( left_numtype )
                           {
                              left_int = -left_int;
                              left_long = -left_long;
                              left_float = -left_float;
                              left_double = -left_double;
                              break;
                           }
                           goto nosup;

                        //Двоичная унарная операция
                        case OpBinnot:
                           switch ( left_numtype )
                           {
                              case TInt:
                                 left_int = !left_int;
                                 break;
                              case TLong:
                                 left_long = !left_long;
                                 break;
                              default:
                                 goto nosup;
                           }
                           break;

                        //Логическая унарная операция
                        case OpLognot:
                           left_int = !left_bvalue;
                           flg_resuint = 1;
                           break;

                        default:
                           goto nosup;
                     }
                  }

//Конец вычисления операции

                  switch ( left_numtype )
                  { //Корректировка значений для чисел
                     case TInt:
                        left_bvalue = (tokleft->vallexem.num.vint = left_int) ? 1 : 0;
                        break;
                     case TLong:
                        left_bvalue = (tokleft->vallexem.num.vlong = left_long) ? 1 : 0;
                        left_int = left_intl;
                        break;
                     case TFloat:
                        left_bvalue = (tokleft->vallexem.num.vfloat =
                                       left_float) ? 1 : 0;
                        left_int = left_intf;
                        break;
                     case TDouble:
                        left_bvalue = (tokleft->vallexem.num.vdouble =
                                       left_double) ? 1 : 0;
                        left_int = left_intd;
                        break;
                  }
                  if ( flg_resuint )
                  {   //Результат операции TUint
                     tokleft->vallexem.type = LEXEM_NUMBER;
                     tokleft->vallexem.num.type = TUint;
                     tokleft->vallexem.num.vint = left_bvalue =
                                       flg_not ? !left_int : left_int;
                  }

                  tokleft->bvalue = left_bvalue;
               }
               else
               {
                  if ( stackop_id == OpComma )
                  {
                     (stackc-1)->left->colpars++;
                  }
                  else
                  if ( ( curop_id == OpRcrbrack && stackop_id == OpCollect )  )
                  {
                     if ( stackc->left != tokc - 1 )
                     {
                        stackc->left->colpars++;
                     }
                     else
                     {
                        laststate = state;
                     }
                  }
                  else
                  {                  
                     if ( ( stackop_flgs & OPF_OPEN ) && ( stackop != curop - 1 ) )
                        msg( MNotopenbr | MSG_LEXERR , stackc->operlexem );
                  }
               }

            }
            if ( flgexp && stackop_after <= curop_before )
            {  //Выход из цикла
               break;
            }
            continue;
nosup:
            msg( MUnsmoper | MSG_LEXNAMEERR, stackc->operlexem );
         }
// Конец цикла выталкивания из стека операций

// Добавление в стэк последней операций
         if ( curop_id == OpCollect )
         {
            tokc->bvalue = 1;
            tokc->vallexem = *curlex;
            tokc->vallexem.type = LEXEM_COLLECT;
            tokc->colpars = 0;
            tokc++;
         }         
         stackc->operid = curop_id;
         stackc->operlexem = curlex;
         stackc->left = tokc-1;
         stackc++;
      }
// Конец обработки системной лексемы
      else
      {
// Обработка операндов
         tokc->vallexem = *curlex;
         state = L_OPERAND;
         switch ( curlex->type )
         {
            case LEXEM_NUMBER://Число
               switch ( curlex->num.type )
               {
                  case TUint:
                  case TInt:
                     tokc->bvalue = tokc->vallexem.num.vint ? 1 : 0;
                     break;
                  case TUlong:
                  case TLong:
                     tokc->bvalue = tokc->vallexem.num.vlong ? 1 : 0;
                     break;
                  case TFloat:
                     tokc->bvalue = tokc->vallexem.num.vfloat ? 1 : 0;
                     break;
                  case TDouble:
                     tokc->bvalue = tokc->vallexem.num.vdouble ? 1 : 0;
                     break;
               }
               break;

            case LEXEM_STRING://Строка
               tokc->bvalue = str_len( lexem_getstr( &tokc->vallexem )) ? 1 : 0;
               break;

            case LEXEM_BINARY://Двоичные данные
               tokc->bvalue = buf_len( lexem_getstr( &tokc->vallexem ))   ? 1 : 0;
               break;

            case LEXEM_NAME://Идентификатор
               tokc->bvalue = -1;
               break;

            case LEXEM_KEYWORD:
               msg( MNokeyword | MSG_LEXERR, curlex );

            default:
               msg( MUnsmoper | MSG_LEXNAMEERR, curlex );
         }
         tokc++;
      }      
// Проверка синтаксиса выражения
      if ( flgexp )
      {
         switch ( laststate )
         {
            case L_OPERAND:
            case L_POST_CLOSE:
               if ( state & L_OPERAND ||
                    state & L_UNARY_OPEN )
               {                  
                  msg( MUnexpoper | MSG_LEXERR, curlex );
               }
               break;
            default:
               if ( state & L_BINARY ||
                    state & L_POST_CLOSE )
               {
                  msg( MMustoper | MSG_LEXERR, curlex );
               }
         }
         laststate = state;
      }
      else
      {
         if ( ( laststate == L_UNARY_OPEN && tokc != tokb ) ||
              laststate == L_BINARY )
            msg( MMustoper | MSG_LEXERR, curlex );
         break;
      }

next:
      curlex = lexem_next( curlex, 0 );
      if ( curlex > maxlex )
         msg( MExpmuch | MSG_LEXERR, curlex );
   }

   //Возврат значения
   if ( tokb->vallexem.type == LEXEM_COLLECT )
   {
      bcol = buf_init( ( pbuf )arr_append( &_compile->binary ));
      tokb->vallexem.binid = arr_count( &_compile->binary ) - 1;
      buf_appenduint( bcol, tokb->colpars );

      for ( tokleft = tokb + 1; tokleft < tokc; tokleft++ )
      {

         switch ( tokleft->vallexem.type )
         {
            case LEXEM_NUMBER:
               buf_appendch( bcol, (ubyte)tokleft->vallexem.num.type );
               switch ( tokleft->vallexem.num.type )
               {
                  case TByte:
                  case TUbyte:
                     buf_appendch( bcol, (ubyte)tokleft->vallexem.num.vint );
                     break;
                  case TShort:
                  case TUshort:
                     buf_appendushort( bcol, (ushort)tokleft->vallexem.num.vint );
                     break;
                  case TUlong:
                  case TLong:
                  case TDouble:
                     buf_appendulong( bcol, tokleft->vallexem.num.vlong );
                     break;
                  default:
                     buf_appenduint( bcol, tokleft->vallexem.num.vint );
               }
               break;

            case LEXEM_STRING:
               buf_appendch( bcol, TStr );
               strt = lexem_getstr( &tokleft->vallexem );
               buf_append( bcol, strt->data, strt->use );
               break;

            case LEXEM_BINARY:
               buf_appendch( bcol, TBuf );
               buft = lexem_getstr( &tokleft->vallexem );
               buf_appenduint( bcol, buft->use );
               buf_append( bcol, buft->data, buft->use );
               break;

            case LEXEM_COLLECT:
               buf_appendch( bcol, TCollection );               
               buf_appenduint( bcol, tokleft->colpars );
               break;

            default:
               msg( MSyntax | MSG_LEXNAMEERR, &tokleft->vallexem );
         }
      }
   }
   else
   if ( tokc != tokb+1 )
   {
      msg( MSyntax | MSG_LEXNAMEERR, curlex );
   }

   *mr = tokb;

D("Macroexp stop\n" );
   return curlex;
}



