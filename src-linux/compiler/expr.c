/******************************************************************************
*
* Copyright (C) 2006, The Gentee Group. All rights reserved.
* This file is part of the Gentee open source project - http://www.gentee.com.
*
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT").
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS
* ACCEPTANCE OF THE AGREEMENT.
*
* ID: expr 22.01.07 0.0.A.
*
* Author: Alexander Krivonogov ( algen )
*
* Summary: Обработка выражений
*
******************************************************************************/

#include "func.h"
#include "bcodes.h"
#include "compinit.h"
#include "../vm/vmtype.h"
#include "alias.h"

/*-----------------------------------------------------------------------------
*
* ID: exptoken 22.01.07 0.0.A.
*
* Summary: Структура токенов
*
-----------------------------------------------------------------------------*/

typedef struct _exptoken
{
   plexem           lex;   //Указатель на лексему
   struct _exptoken *left; //Указатель на левый операнд
   uint             flg;   //Флаг FTOK_*
   union {
      uint  offlocvar;     //Смещение локальной переменной
      uint  idglobvar;     //Идентификатор глобальной переменной
      uint  idglobfunc;    //Идентификатор глобальной функции      
      uint  idalias;       //Идентификатор псевдонима функции
      uint  parofsize;     //Тип параметр для ofsize
      uint  cmdbytecode;   //Команда для байткода
      uint  val;           //Идентификатор в соответствующей таблице, в зависимости от flg
      pstr  strbin;        //Указатель на строку или бинарные данные
   };
   union {
      uint  offout;        //Смещение в байт коде
      uint  pars;          //Количество параметров для функции
   };
   uint     type;          //Результирующий тип
   uint     ol;            //Смещение в таблице меток для хранения переходов в случае && или ||
   uint     oftype;
   uint     msr;   
} exptoken, * pexptoken;

/*-----------------------------------------------------------------------------
*
* ID: expoper 22.01.07 0.0.A.
*
* Summary: Структура операции
*
-----------------------------------------------------------------------------*/
typedef struct
{
   uint      operid; //Код операции

   plexem    lex;    //Указатель на лексему
   pexptoken left;   //Указатель на левый операнд
   uint      flg;    
   uint      val;    
   uint      pars;   //Количество параметров
} expoper, * pexpoper;

//Типы токенов
#define FTOK_LOCVAR       0x01 //Локальная переменная
#define FTOK_GLOBVAR      0x02 //Глобальная переменная
#define FTOK_SUBFUNC      0x03 //Вызов локальной функции
#define FTOK_GLOBFUNC     0x04 //Вызов глобальной функции
#define FTOK_ADDRFUNC     0x05 //Вызов функции по её адресу
#define FTOK_METHODFUNC   0x06 //Вызов метода
#define FTOK_FIELD        0x07 //Поле структуры
#define FTOK_NUMBER       0x08 //Число
#define FTOK_OPER         0x09 //Оператор
#define FTOK_PTRTYPE      0x0A //Приведение к типу
#define FTOK_GLOBFUNCADDR 0x0B //Адрес глобальной функции
#define FTOK_STRBIN       0x0C //Строка или двоичные данные
#define FTOK_QUEST        0x0D //Операция ?(,,)
#define FTOK_ARR          0x0E //Массив
#define FTOK_SIZEOF       0x0F //Sizeof
#define FTOK_TYPE         0x10 //0x200000 //Тип
#define FTOK_BYTECODE     0x11 //0x400000 //Команда байткода
#define FTOK_COLLECT      0x12 //0x500000 //Загрузка коллекции
#define FTOK_COLLECTNEW   0x13 //0x600000 //Загрузка коллекции
#define FTOK_LATE         0x14 //Отложеный вызов
#define FTOK_ALIAS        0x15 //Псевдоним функции
//Маски для типов токенов
#define FTOK_NOFLAGS        0x0000FF//FF0000
#define FTOK_FLAGS          0xFFFF00//00FFFF
//Флаги токенов
#define FTOK_LVALUE         0x000100 //Текущий операнд должен быть lvalue
#define FTOK_FUNCPAR        0x000200 //Параметр функции
#define FTOK_OPAND          0x000400 //Операнд операции &&
#define FTOK_OPOR           0x000800 //Операнд операции ||
#define FTOK_FUNC           0x001000 //Функция
#define FTOK_QUESTFIRST     0x002000 //Первый операнд операции ?
#define FTOK_QUESTSECOND    0x004000 //Второй операнд операции ?
#define FTOK_QUESTTHIRD     0x008000 //Третий операнд операции ?
#define FTOK_ADDFUNCPAR     0x010000 //Требуется добавить параметр функции (для метода)
#define FTOK_LVALPROPERTY   0x020000 //Присваивание свойству
#define FTOK_TEXT           0x040000 //Функция является текстовой
#define FTOK_LVALLATE       0x080000 //Присваивание отложенному вызову
#define FTOK_COLLECTIONLATE 0x100000 //Новая коллекция создается для позднего вызова
#define FTOK_WITH           0x200000 //Опарация сокращенного вызова полей

//Макроопределения для загрузок фиктивных операций-функций
#define STACK_ADD( _ftok, _pars, _left, _lex ) \
stackc->operid = OpFunc;\
stackc->lex = _lex;\
stackc->flg = _ftok | FTOK_FUNC | FTOK_FUNCPAR;\
stackc->pars = _pars;\
stackc->left = _left;\
stackc++;\
state = L_UNARY_OPEN | L_FUNC;

#define STACK_ADDARR() \
STACK_ADD( FTOK_ARR, 1, tokc-1, lastlex )

#define STACK_ADDFUNC(_ftok)\
STACK_ADD( _ftok, 0, tokc-1, curlex )

#define STACK_ADDMETHOD(_ftok)\
STACK_ADD( _ftok, 1, tokc-1, curlex )


//Таблица команд для получения чисел
uint artypes[ TUlong + 1 ] = 
         { 0, CGetI, CGetI, CGetB, CGetUB, CGetS, CGetUS, CGetI, CGetL, CGetL, CGetL };

/*-----------------------------------------------------------------------------
*
* ID: f_exp 22.01.07 0.0.A.
*
* Summary: Обработка выражений
*
-----------------------------------------------------------------------------*/

plexem STDCALL f_expr( plexem curlex, uint flg, puint rettype, puint retoftype )
{
   plexem      lastlex;   //Предыдущая лексема
   plexem      lex;       //Обрабатываемая лексема
   plexem      firstlex;  //Первая лексема

   psoper      curop;     //Текущая операция
   psoper      stackop;   //Оператор из стэка

   pexpoper    stackb;    //Указатель на начало стэка операций
   pexpoper    stackc;    //Указатель на следующий элемент стэка операций

   pexptoken   tokb;    //Указатель на начало таблицы
   pexptoken   tokc;    //Указатель на следующий элемент таблицы
   pexptoken   toki;    //Указатель на текущий элемент таблицы
   pexptoken   toktmp;  //Временный указатель на операнд
   plexem      maxlex;

   uint        curop_flgs;
   uint        curop_before;
   uint        curop_id;
   uint        stackop_flgs;
   uint        stackop_after;
   uint        stackop_id;

   uint        state;     // Текущее состояние обработчика
   uint        laststate; // Предыдущее состояние обработчика
   uint        bropen;    // Количество открытых скобок
   uint        flgexp;    // Флаг продалжать обработку

   uint        off;       //Временная переменная для различных смещений
   uint        id;        //Временная переменная для хранения идентификаторов
   phashiuint  phitem;    //Элемент хэштаблицы с локальной переменной

   s_desctype  desctype;  //Описание типа
   pfvar       pvar;      //Указатель на структуру локальной переменной
   pfvaras     pvaras;    //Указатель на структуру as
   povmtype    ptype;     //Указатель на струкутру объекта
   pvartype    pglobvar;  //Указатель на структуру типа глобальной переменной
   pvmfunc     pfunc;     //Указатель на структуру байткода
   pfwith      pwith;     //Указатель на структуру with
   pvartype    field, isfield;//Поле структуры

   uint   flglvallate; //Флаг позднее связывание с lvalue операцией   
   uint   type;
   puint  parsc, parsb, parse, psrc;//Указатели в стэке параметров
   uint   numtypes;    //Количество различных типов для коллекции
   uint   num;         //Текущее количество
   uint   stsize;      //Размер текущего элемента коллекции
   pubyte name;         
   uint   len;
   uint   dwsize;      //Подсчет сумарного размера
   uint   i;   
   
D("Expr start\n" );
// Инициализация
   stackc = stackb = _compile->stkopers;
   parsc = _compile->stkpars;
   tokc = tokb = _compile->stkops;
   flgexp = 1;
   lastlex = 0;
   bropen = 0;
   flglvallate = 0;
   laststate = L_UNARY_OPEN;
   maxlex = curlex + min( STACK_OPERS / sizeof( soper ), min( STACK_OPS / sizeof( exptoken ), STACK_PARS / sizeof( uint ) ));   
   firstlex = curlex;

//Цикл первого прохода
   while ( 1 )
   {
   //Предварительная обработка
      if ( curlex->type == LEXEM_KEYWORD &&
           curlex->key == KEY_AS )
      {
         curlex->type = LEXEM_OPER;
         curlex->oper.operid = OpAs;
      }      

      switch ( curlex->type )
      {
         case LEXEM_OPER: 
            curop = (psoper)&opers[curop_id = curlex->oper.operid]; 
            curop_flgs = curop->flgs;
            curop_before = curop->before;
            //Первичная обработка оператора
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
            if ( curop_id == OpLine ) // Перенос строки
            {
               if ( laststate & L_BINARY || bropen > 0 )
                  goto next;
               flgexp = 0;
            }
            else
            if ( curop_id == OpComma && !bropen )//, - Запятая
            {
               if ( flg & ( EXPR_VAR | EXPR_COMMA ) )
                  flgexp = 0;
               else
                  msg( MSyntax | MSG_LEXNAMEERR, curlex );
            }
            else
            if ( curop_flgs & OPF_UNDEF ) //Неопределённый оператор
            {
               if ( laststate & ( L_OPERAND | L_POST_CLOSE ))
               {
                  curop = ( psoper )&opers[curop_id = ++curlex->oper.operid];
                  curop_flgs = curop->flgs;
                  curop_before = curop->before;
               }
            }
            
         //Установка текущего состояния
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
            
         //Цикл выталкивания из стека операций            
            while ( stackc != stackb )
            {               
               stackop_id = (stackc-1)->operid;
               stackop = (psoper)&opers[stackop_id];
               stackop_after = stackop->after;
               stackop_flgs = stackop->flgs;               
               if ( !flgexp || stackop_after >= curop_before )
               {
                  stackc--;
                  if ( stackop_flgs & OPF_OPEN )
                  {
                     if ( stackop_id != curop_id - 1 && 
                           ( stackop_id != OpCollect || curop_id != OpRcrbrack ) )
                        msg( MNotopenbr | MSG_LEXERR , curlex );
                  }
                  if ( !( stackop_flgs & ( OPF_OPEN | OPF_CLOSE ) ||
                       stackop_id == OpComma ) )
                  {
                     tokc->lex = stackc->lex;
                     //?Не проще будет tokc->left = stackc->left
                     if ( stackop_flgs & OPF_BINARY || stackc->flg & FTOK_FUNC )
                        tokc->left = stackc->left;
                     else
                        tokc->left = 0;

                     tokc->flg = stackc->flg;
                     tokc->val = stackc->val;
                     tokc->pars = stackc->pars;

                     if ( stackop_flgs & OPF_LVALUE )
                     {
                        if ( stackop_flgs & OPF_BINARY )
                           tokc->left->flg |= FTOK_LVALUE;
                        else
                           (tokc-1)->flg |= FTOK_LVALUE;
                     }
                     tokc++;
                  }
               }
               if ( flgexp && stackop_after <= curop_before )
               {  //Выход из цикла выталкивания
                  break;
               }
            }
            
         //Конечная обработка системной лексемы, добавление в стэк операций
            if ( flgexp )
            {

               if ( curop_id == OpLsqbrack )
               {
                  (tokc-1)->flg |= FTOK_ADDFUNCPAR;
                  STACK_ADDARR();
                  laststate = state;
               }
               else if ( curop_id == OpCollect )
               {
                  STACK_ADDFUNC( FTOK_COLLECT );
                  //laststate = state;
                  laststate = laststate | L_FUNC;
               }
               stackc->flg = FTOK_OPER;
               //Конечная обработка
               if ( stackc != stackb )
               {
                  if ( curop_flgs & OPF_OPEN && laststate & L_FUNC )
                  {
                     laststate = laststate & ~L_FUNC;
                     stackc->flg |= FTOK_FUNCPAR;
                     stackc->pars = bropen;
                     stackc->val = (uint)(stackc-1);
                  }
                  if ( curop_flgs & OPF_CLOSE &&
                       stackc != stackb &&
                       ( stackc-1)->flg & FTOK_FUNCPAR &&
                       lastlex->type == LEXEM_OPER &&
                       ((psoper)&opers[lastlex->oper.operid])->flgs & OPF_OPEN )
                  {                     
                     laststate = L_OPERAND;
                     if ( (stackc-1)->flg & FTOK_FUNC )
                        ( stackc-1)->flg &= ~FTOK_FUNCPAR;
                  }
                  else
                  if ( ( curop_id == OpComma ||
                         (curop_flgs & OPF_CLOSE) ) &&
                         stackc != stackb &&
                      ((stackc-1)->flg & FTOK_FUNCPAR) )
                  {                     
                     if ( !( curop_flgs & OPF_CLOSE ) ||
                        ( stackc-1)->flg & FTOK_FUNC ||
                        (stackc-1)->pars == bropen - 1 )
                     {
                        if ( ( stackc-1)->flg & FTOK_FUNC )
                        {
                           stackc->val = (uint)(stackc-1);
                           ( stackc-1)->flg &= ~FTOK_FUNCPAR;
                        }
                        else
                        {
                           stackc->val = (stackc-1)->val;
                           stackc->pars = bropen;
                        }
                        stackc->flg = FTOK_FUNCPAR;
                        ((pexpoper)(stackc->val))->pars++;
                        (tokc-1)->flg |= FTOK_FUNCPAR;
                        if ( ((pexpoper)(stackc->val))->lex->type == LEXEM_OPER  &&
                             ((pexpoper)(stackc->val))->lex->oper.operid == OpQuest )
                        {
                           if ( ((pexpoper)(stackc->val))->pars == 1 )
                              (tokc-1)->flg |= FTOK_QUESTFIRST;
                           else if ( ((pexpoper)(stackc->val))->pars == 2 )
                              (tokc-1)->flg |= FTOK_QUESTSECOND;
                           else if ( ((pexpoper)(stackc->val))->pars == 3 )
                              (tokc-1)->flg |= FTOK_QUESTTHIRD;
                        }
                        else if ( ( ((pexpoper)(stackc->val))->flg & FTOK_NOFLAGS ) == 
                                    FTOK_SIZEOF )
                        {
                           if ( (( tokc - 1 )->flg & FTOK_NOFLAGS ) == FTOK_TYPE )
                           {
                              tokc--;
                              ((pexpoper)(stackc->val))->val = tokc->type;                
                           }
                           else
                           {
                              ((pexpoper)(stackc->val))->val = 0;                   
                           }
                        }
                     }
                  }
               }

               if ( curop_id == OpLogand )
                  (tokc-1)->flg |= FTOK_OPAND;
               else
                  if ( curop_id == OpLogor )
                     (tokc-1)->flg |= FTOK_OPOR;
               if ( curop_id == OpQuest )
               {  //Создание фиктивной функции для операции ?                  
                  stackc->flg = FTOK_QUEST | FTOK_FUNC | FTOK_FUNCPAR;
                  stackc->pars = 0;
                  state = L_UNARY_OPEN | L_FUNC;
               }
               else if ( curop_id == OpCollect )
               {
                  //Фиктивного операнда для создания новой переменной-коллекции
                  tokc->lex = curlex;
                  tokc->flg = FTOK_COLLECTNEW | FTOK_ADDFUNCPAR;
                  tokc->val = 0;
                  tokc++;
               }
               else if ( curop_id == OpStrout )
               {
                  tokc->cmdbytecode = CGetText;
                  tokc->lex = curlex;
                  tokc->flg = FTOK_BYTECODE;
                  tokc->pars = 0;
                  tokc++;
               }
               else if ( curop_id == OpWith )
               {
                  tokc->lex = curlex;
                  tokc->flg = FTOK_LOCVAR | FTOK_WITH;
                  tokc->offlocvar = 0;
                  tokc++;
                  curop_id = OpPoint;
               }                  
               stackc->lex = curlex;
               stackc->operid = curop_id;
               stackc->left = tokc-1;
               stackc++;
            }            
            break;            

            // Обработка операндов
            case LEXEM_NAME://Идентификатор
               if ( stackc != stackb )
               {
                  if ( (stackc-1)->operid == OpPoint )
                  {
                     stackc--;
                     if ( curlex->flag & LEXF_CALL )
                     {  //Вызов метода                        
                        curlex->flag |= LEXF_METHOD;
                        //Добавляем в стэк фиктивную операцию
                        (tokc-1)->flg |= FTOK_ADDFUNCPAR;
                        STACK_ADDMETHOD( FTOK_METHODFUNC );
                     }
                     else
                     {  //Поле
                        tokc->lex = curlex;
                        tokc->flg = FTOK_FIELD;                        
                        tokc++;
                        state = L_OPERAND;
                     }
                     break;
                  }
                  else if ( (stackc-1)->operid == OpLate )
                  {   //Отложенный метод-свойство
                     stackc--;
                     if ( curlex->flag & LEXF_CALL )
                     {
                        //Позднее связываение в стэк операций
                        (tokc-1)->flg |= FTOK_ADDFUNCPAR;                        
                        stackc->val = 0;
                        curlex->flag |= LEXF_METHOD;                        
                        STACK_ADDFUNC( FTOK_LATE );
                        (stackc-1)->flg = FTOK_LATE | FTOK_FUNC;
                        
                        //Заголовок коллекции
                        tokc->lex = curlex;
                        tokc->flg = FTOK_COLLECTNEW | FTOK_COLLECTIONLATE;                        
                        tokc->val = 0;
                        tokc++;

                        //Коллекция в стэк операций
                        STACK_ADDFUNC( FTOK_COLLECT | FTOK_COLLECTIONLATE);
                        
                     }
                     else
                     {                        
                        //Заголовок коллекции
                        tokc->lex = curlex;
                        tokc->flg = FTOK_COLLECTNEW | FTOK_COLLECTIONLATE;
                        tokc->val = 0;
                        tokc++;

                        //Коллекция
                        tokc->lex = curlex;
                        tokc->flg = FTOK_FUNC | FTOK_COLLECT | FTOK_COLLECTIONLATE;
                        tokc->pars = 0;
                        tokc->val = 0;
                        tokc++;

                        //Позднее связывание
                        tokc->lex = curlex;
                        tokc->flg = FTOK_LATE;
                        tokc->val = 0;
                        tokc->pars = 0;
                        tokc++;
                        
                        state = L_OPERAND;                        
                     }
                     break;
                  }
               }
               if ( phitem = (phashiuint)hash_find( &fd.nvars, lexem_getname( curlex )) )
               {  //Идентификатор есть в таблице локальных переменных
                  if ( off = phitem->val )
                  {                     
                     pvar = ( pfvar)(fd.bvars.data+off);
                     if ( pvar->flg & FVAR_SUBFUNC )
                     {  // Подфункция
                        if ( !( curlex->flag & LEXF_CALL ) )
                           msg( MExpopenbr | MSG_LEXERR , curlex );
                        stackc->val = off;
                        //Добавляем в стэк фиктивную операцию
                        STACK_ADDFUNC( FTOK_SUBFUNC );
                     }
                     else
                     {  // Локальная переменная
                        tokc->lex = curlex;
                        tokc->flg = FTOK_LOCVAR;
                        tokc->offlocvar = off;
                        tokc++;
                        state = L_OPERAND;
                     }
                     break;
                  }
               }
               id = bc_getid( curlex );
               if ( id )
               //Проверка в глобальной таблице
               switch ( (( pvmobj )PCMD( id ))->type )
               {
                  case OVM_BYTECODE:
                  case OVM_EXFUNC:
                  case OVM_STACKCMD:                     

                     if ( curlex->flag & LEXF_CALL )
                     {  
                        //Добавляем в стэк фиктивную операцию
                        STACK_ADDFUNC(FTOK_GLOBFUNC);                        
                        if ( (( pvmobj )PCMD( id ))->flag & GHBC_TEXT )
                        {
                           (stackc-1)->flg |= FTOK_TEXT;
                        }
                     }
                     else
                     {  //Возможно взятие адреса функции
                        if ( (( pvmobj )PCMD( id ))->nextname )
                           msg( MNoaddrfunc | MSG_LEXNAMEERR, curlex );
                        tokc->idglobfunc = (( pvmobj )PCMD( id ))->id;
                        tokc->lex = curlex;
                        tokc->flg = FTOK_GLOBFUNCADDR;
                        tokc->pars = 0;
                        tokc++;
                        state = L_OPERAND;
                     }
                     break;
                  case OVM_TYPE:
                     if ( curlex->flag & LEXF_CALL )
                     {  //Преобразование типа
                        stackc->val = 0;
                        curlex->flag |= LEXF_METHOD;
                        //Добавляем в стэк фиктивную операцию
                        STACK_ADDFUNC( FTOK_GLOBFUNC );
                     }
                     else
                     {  //Тип для приведения
                        tokc->lex = curlex;
                        tokc->type = bc_type( curlex );
                        if ( lastlex && lastlex->type == LEXEM_OPER && lastlex->oper.operid == OpPtr )
                        {                           
                           tokc->flg = FTOK_PTRTYPE;
                           stackc--;
                        }
                        else                        
                           tokc->flg = FTOK_TYPE;
                        
                        curlex = desc_idtype( curlex, &desctype );
                        curlex--;
                        tokc->oftype = desctype.oftype;
                        
                        state = L_OPERAND;
                        tokc++;
                     }
                     break;
                  case OVM_GLOBAL://Глобальная переменная
                     tokc->lex = curlex;
                     tokc->idglobvar = id;
                     tokc->flg = FTOK_GLOBVAR;
                     state = L_OPERAND;
                     tokc++;
                     break;
                  case OVM_ALIAS:
                     tokc->lex = curlex;
                     tokc->idalias = alias_getid( id );
                     tokc->flg = FTOK_ALIAS;
                     state = L_OPERAND;
                     tokc++;
                     break;
               }
               else
                  msg( MUnkname | MSG_LEXNAMEERR, curlex );//Неизвестный идентификатор
               break;

            case LEXEM_NUMBER://Число
               tokc->lex = curlex;
               tokc->flg = FTOK_NUMBER;
               tokc->type = curlex->num.type;
               tokc->oftype = 0;
               tokc++;
               state = L_OPERAND;               
               break;

            case LEXEM_STRING://Строка                
               tokc->strbin = lexem_getstr( curlex );
               //print( "LEXEM_STRING %x %c\n", tokc->strbin->use, tokc->strbin->data[0] );
               tokc->flg = FTOK_STRBIN;
               tokc->lex = curlex;
               tokc->type = TStr;
               tokc->oftype = 0;
               tokc++;
               state = L_OPERAND;
               break;

            case LEXEM_BINARY://Двоичные данные
               tokc->strbin = lexem_getstr( curlex );
               tokc->flg = FTOK_STRBIN;
               tokc->lex = curlex;
               tokc->type = TBuf;
               tokc->oftype = 0;
               tokc++;
               state = L_OPERAND;               
               break;

            case LEXEM_KEYWORD:               
               if ( ( curlex->key == KEY_FUNC ||
                      curlex->key == KEY_STDCALL ||
                      curlex->key == KEY_CDECL ) &&
                    (stackc-1)->operid == OpPtr )
               {  //Вызов функции по адресу                  
                  stackc->val = 0;
                  //Добавляем в стэк фиктивную операцию
                  STACK_ADDFUNC( FTOK_ADDRFUNC );
               }
               else
               {
                  if ( curlex->key == KEY_SIZEOF )
                  {  
                     //Добавляем в стэк фиктивную операцию
                     STACK_ADDFUNC( FTOK_SIZEOF );
                  }                 
                  else
                     msg( MNokeyword | MSG_LEXERR, curlex );
               }
               break;
            default:
               msg( MUnkname | MSG_LEXNAMEERR, curlex );
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
                  msg( MMustoper | MSG_LEXERR, curlex );
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
      lastlex = curlex;
      curlex = lexem_next( curlex, 0 );
      if ( curlex > maxlex )
         msg( MExpmuch | MSG_LEXERR, curlex );
   }
   D( "Bytecode start\n" );
   if ( tokb != tokc )
   {
      out_debugtrace( firstlex );
   }
    /*  && _compile->flag & CMPL_DEBUG )
   {  
      out_adduints( 3, 
         CDwload, 
         str_pos2line( _compile->cur->src, firstlex->pos, 0 ) + 1, 
         CDbgTrace );
   }*/
//Цикл формирования байткода
   for ( toki = tokb; toki < tokc; toki++ )
   {
      lex = toki->lex;
      if ( toki->flg & FTOK_LVALUE &&
            (  ( toki->flg & FTOK_NOFLAGS ) == FTOK_NUMBER ||
               ( toki->flg & FTOK_NOFLAGS ) == FTOK_TYPE
            ) )
      {
         msg( MExplvalue | MSG_LEXERR, lex );
      }      

      switch( toki->flg & FTOK_NOFLAGS )
      {
         case FTOK_LOCVAR: //Локальная переменная
            toki->offout = fd.bout->use;
            if ( toki->flg & FTOK_WITH )
            {
               out_add2uint( CVarload, 0 );
            }
            else
            {               
               pvar = ( pfvar)(fd.bvars.data + toki->offlocvar);               
               toki->type = pvar->type;

               if ( toki->flg & FTOK_LVALUE &&
                     (( pvmobj )PCMD( toki->type ))->flag & GHTY_STACK )
                  out_adduint( CVarptrload );
               else
                  out_adduint( CVarload );
               out_adduint( pvar->num );
               toki->oftype = pvar->oftype;
            }
            break;

         case FTOK_GLOBVAR: //Глобальная переменная
            out_add2uint( CPtrglobal, toki->idglobvar );
            pglobvar = ((povmglobal)PCMD( toki->idglobvar ))->type;
            ptype = (( povmtype )PCMD( toki->type = pglobvar->type ));            
            if ( !(toki->flg & FTOK_LVALUE) &&
               (ptype->vmo.flag & GHTY_STACK ) )
            {
                out_adduint( ptype->stsize == 1 ? CGetI : CGetL );
            }
            toki->oftype = pglobvar->oftype;
            break;

         case FTOK_GLOBFUNCADDR://Взятие адреса функции
            if ( toki->flg & FTOK_LVALUE && toki + 1 < tokc  )
            {
               lex = (toki + 1)->lex;
               if ( lex->type == LEXEM_OPER && lex->oper.operid == OpAddr )
               {
                  out_add2uint( CCmdload, toki->idglobfunc );
                  break;
               }
            }
            msg( MExpopenbr | MSG_LEXERR, lex );
            break;

         case FTOK_METHODFUNC://Метод
            off = (uint)( parsc - 2 * toki->pars );
            //if ( (toki-1)->flg & FTOK_WITH )
            //D( "left %x %x %x\n", (toki->left-1)->flg, (toki->left)->flg, (toki->left+1)->flg );
            if ( (toki->left)->flg & FTOK_WITH )
            {               
               //D( "Method with\n" );
               isfield = 0;               
               for ( pwith = ( pfwith)( fd.bwith.data + fd.bwith.use ) - 1; 
                     pwith >= ( pfwith )fd.bwith.data; pwith-- )
               {
                  *(puint)off = pwith->type;
                  *((puint)off + 1 ) = pwith->oftype;                  
                  if ( pfunc = bc_method( lex, toki->pars, ( puint )off ) )
                      break;                  
               }               
               if ( pfunc )
               {                  
                  toki->left->type = pwith->type;
                  toki->left->oftype = pwith->oftype;
                  *( puint )(fd.bout->data + (toki->left)->offout + sizeof( uint )) = 
                           pwith->num;
               }
               else
               {                     
                  msg( MUnkoper | MSG_LEXNAMEERR, lex );               
               }
            }
            else
            {               
                off = ((( puint )off)+1);
               *((( puint )off)) = toki->left->type;
               *(puint)off = toki->left->oftype;
            }
         case FTOK_GLOBFUNC://Глобальная функция         
            parsc -= 2 * toki->pars;                        
            pfunc = bc_func( lex, toki->pars, parsc );            
            toki->type = pfunc->ret->type;
            toki->oftype = pfunc->ret->oftype;            
            if ( pfunc->vmo.flag & GHBC_RESULT )
            {
               //Заводим фиктивную локальную переменную
               out_add2uint( CVarload, var_addtmp( toki->type, toki->oftype ));
            }
            out_adduint( pfunc->vmo.id );

            if ( ((( pvmobj )PCMD( toki->type ))->flag & GHTY_STACK ) && 
                  ( toki->flg & FTOK_LVALUE ))
               msg( MExplvalue | MSG_LEXERR, lex );
            break;

         case FTOK_SIZEOF:                                    
            if ( toki->parofsize )
            {  
               if ( toki->pars != 1 )
                  msg( MCountpars | MSG_LEXNAMEERR, lex );                              
               out_add2uint( CDwload, (( povmtype )PCMD( toki->parofsize ))->size );               
            }
            else
            {               
               parsc -= 2 * toki->pars;
               out_adduint( bc_funcname( lex, "sizeof", toki->pars, parsc )->vmo.id);               
            }
            toki->type = TUint;
            toki->oftype = 0;            
            break;

         case FTOK_SUBFUNC: //Локальная функция
            //Подфункция
            //Проверка совпадения типов параметров
            parsc -= 2 * toki->pars;
            pvar = ( pfvar)(fd.bvars.data + toki->offlocvar );
            if ( pvar->pars == toki->pars )
            {
               psrc = (puint)(fd.bvardef.data + pvar->offbvardef );
               parsb = parsc;
               for ( i = 0; i < toki->pars; i++ )
               {
                  if ( *psrc != *parsb )
                     goto errpars;
                  parsb++;
                  psrc++;
                  psrc=((pubyte)psrc)+1;
                  if ( *( pubyte )( ((pubyte)psrc) ) & VAR_OFTYPE )
                  {
                     if ( *psrc != *parsb )
                        goto errpars;
                     psrc++;
                  }
                  else
                     if ( *parsb )
                        goto errpars;
                  parsb++;
                  continue;
errpars:
                  msg( MTypepars | MSG_LEXNAMEERR, lex );
               }
            }
            else
            {
               msg( MCountpars | MSG_LEXNAMEERR, lex );
            }
            toki->type = pvar->type;
            toki->oftype = pvar->oftype;
            out_add2uint( CSubcall, pvar->addr );
            if ( ((( pvmobj )PCMD( toki->type ))->flag & GHTY_STACK ) && 
                  ( toki->flg & FTOK_LVALUE ))
               msg( MExplvalue | MSG_LEXERR, lex );
            break;

         case FTOK_COLLECTNEW: //Создание переменной с типом коллекция
            //Заводим переменную и загружаем её в стэк            
            D( "FTOK_COLLECTNEW\n" );
            out_add2uint( CVarload, var_addtmp( TCollection, 0 ));
            break;

         case FTOK_COLLECT: //Загрузка коллекции             
            if ( toki->flg & FTOK_COLLECTIONLATE && (toki+1)->flg & FTOK_LVALUE )
               break;            
latecol:
            
            if ( flglvallate )
            {
               toktmp = toki;
               toki = toki->left - 1;
               lex = toki->lex;
               toki->pars++;
            }
            D( "FTOK_COLLECT\n" );
            if ( toki->pars )
            {
               parse = parsc;
               parsc -= 2 * toki->pars;             
               parsb = parsc;               
               parsc -= 2;
               type = 0; //Тип предыдущего элемента
               num = 0;//Количество dword одного типа
               off = fd.bout->use + sizeof( uint );
               out_add2uint( CDwsload, 0 );//Команда загрузки последовательности dword
                                        //Количество загружаемых dwords
               dwsize = 0;//Общий размер данных в dword, 1=последний тип
               numtypes = 1;//Количество описаний типов
               for ( ; parsb < parse; parsb += 2 )
               {
                  if ( *parsb )
                  {
                     dwsize += stsize = (( povmtype )PCMD( *parsb ))->stsize;
                     if ( *parsb != type || num == 0xFF )
                     {  //Смена типа или большой размер
                        if ( type )
                        {  //Запись типа и количества
                           out_adduint( ( num << 24 ) | type );
                           numtypes++;
                        }
                        type = *parsb;
                        num = 0;
                     }
                     num += stsize;
                  }
               }
               *( puint )( fd.bout->data + off ) = numtypes;// | ( 1 << 24 );
               //Запись последнего элемента
               out_adduints( 3, ( num << 24 ) | type, CCollectadd, dwsize + numtypes );
            }
            toki->type = TCollection;
            toki->oftype = 0;
            if ( flglvallate )
            {
               goto late;
            }
            break;

         case FTOK_LATE:             
            if ( toki->flg & FTOK_LVALUE )
            {               
               toki->flg |= FTOK_LVALLATE;
               break;
            }
late:
            D( "FTOK_LATE\n" );
            if ( flglvallate )
            {
               toki = toki + 1;               
            }                                    
            
            out_adduints( 3, CResload,
                        bc_resource( lexem_getname( toki->lex ) ),
                        bc_find( toki->lex, "res_getstr", 1, TUint));
            
            if ( toki->lex->flag & LEXF_METHOD )
            {
               parsc -= 2;
               type = toki->left->type;
            }
            else
            {
               type = (toki-3)->type;
            }

            //Вызов метода является отложенным
            if ( flglvallate )
            {
               name = "@setval";
            }
            else
            {
               if ( toki + 1 < tokc ) //является ли лексема последней нет операций в стэке
               {
                  //   является ли следующая лексема FTOK_LATE
                  if (  ((toki+1)->flg & FTOK_NOFLAGS) == FTOK_COLLECTNEW &&
                        (toki+1)->flg & FTOK_COLLECTIONLATE )
                  {
                     name = "@getobj";
                  }
                  else
                  {
                     name = "@getval";
                  }
               }
               else
               {
                  name = "@call";
               }
            }
            
            //Формируем параметры методов
            parsb = parsc;
            *(parsb++) = type;
            *(parsb++) = 0;            
            *(parsb++) = TCollection;
            *(parsb++) = 0;
            *(parsb++) = TStr;
            *(parsb++) = 0;
                        
            pfunc = bc_funcname( lex, name, 3, parsc );                        

            toki->type = pfunc->ret->type;
            toki->oftype = pfunc->ret->oftype;
            
            if ( pfunc->vmo.flag & GHBC_RESULT )
            {
               //Заводим фиктивную локальную переменную
               out_add2uint( CVarload, var_addtmp( toki->type, toki->oftype ) );
            }
            out_adduint( pfunc->vmo.id );
            
            if ( flglvallate )
            {               
               toki = toktmp;
               flglvallate = 0;
            }            
            break;

         case FTOK_ADDRFUNC://Вызов функции по указателю

            out_adduint( ( lex->key == KEY_FUNC) ? CCmdcall : CCallstd );
            dwsize = 0;
            parsb = parsc;
            parsc -= 2 * toki->pars;            
            while ( parsb > parsc )
            {
               parsb -= 2;
               dwsize += (( povmtype)PCMD( *parsb ))->stsize;
            }
            if ( lex->key == KEY_STDCALL )
               out_adduint( 0 );
            else if (lex->key == KEY_CDECL )
               out_adduint( 1 );
            out_adduint( dwsize );            
            toki->type = TUint;
            toki->oftype = 0;            
            break;

         case FTOK_ARR://Массив
            parsc -= 2 * toki->pars;
            
            pfunc = bc_funcname( lex, "@index", toki->pars, parsc );
            if ( pfunc->vmo.flag & GHBC_RESULT )
            {
               //Заводим фиктивную локальную переменную
               out_add2uint( CVarload, var_addtmp( pfunc->ret->type, pfunc->ret->oftype ));
            }
            out_adduint( pfunc->vmo.id );
            

            if ( !toki->left->oftype )
            {
               if ( !( toki->type = (( povmtype)PCMD( toki->left->type ))->index.type ))
               {
                  toki->type = TUint;
               }
            }
            else
            {
               toki->type = toki->left->oftype;
            }
            toki->oftype = 0;

            if ( !(toki->flg & FTOK_LVALUE) &&
                 (( pvmobj )PCMD( toki->type ))->flag & GHTY_STACK )
            {
               out_adduint( artypes[ toki->type ]  );
            }
            break;

         case FTOK_FIELD://Поле            
            if ( (toki-1)->flg & FTOK_WITH )
            {               
               isfield = 0;
               for ( pwith = ( pfwith)( fd.bwith.data + fd.bwith.use ) - 1; 
                     pwith >= ( pfwith )fd.bwith.data; pwith-- )
               {                  
                  if ( isfield = type_fieldname( pwith->type, lexem_getname( lex ) ) )
                      break;                
                  if ( toki->flg & FTOK_LVALUE )
                  {                     
                     pfunc = bc_isproperty( lex, pwith->type );                                      
                  }
                  else
                  {
                     parsb = parsc;
                     *( parsb++ ) = pwith->type;
                     *( parsb++ ) = 0;
                     pfunc = bc_method( lex, 1, parsc );
                  }
                  if ( pfunc )
                      break;
               }
               if ( isfield || pfunc )
               {                  
                  (toki-1)->type = pwith->type;
                  *( puint )(fd.bout->data + (toki-1)->offout + sizeof( uint )) = 
                           pwith->num;
               }
               else
               {
                   msg( MUnkoper | MSG_LEXNAMEERR, lex );
               }
            }            
            isfield = type_field( lex, (toki-1)->type );            
            if ( isfield )
            {               
               field = isfield;
               off = field->off;
               while ( toki + 1 < tokc && ((toki+1)->flg & FTOK_NOFLAGS ) == FTOK_FIELD )
               {
                  lex = (++toki)->lex;
                  isfield = type_field( lex, field->type );
                  if ( isfield )
                  {
                     field = isfield;
                     off += field->off;
                  }
                  else
                  {
                     toki--;
                     break;
                  }
               }
               toki->type = field->type;
               toki->oftype = field->oftype;
               if ( off )
               {
                  out_adduints( 3, CDwload, off, CAddUIUI );
               }
               if ( !( toki->flg & FTOK_LVALUE ) &&
                     (( pvmobj )PCMD( toki->type ))->flag & GHTY_STACK )
               {
                  out_adduint( artypes[ toki->type ] );
               }
               if (!isfield) toki++;
            }            
            if (!isfield)//Поле является свойством
            {                  
               if ( toki->flg & FTOK_LVALUE )
               {                  
                  toki->flg |= FTOK_LVALPROPERTY;
               }
               else
               {                                    
                  pfunc = bc_property( lex, (toki-1)->type, 0 );                                  
                  toki->type = pfunc->ret->type;
                  toki->oftype = pfunc->ret->oftype;                  
                  if ( pfunc->vmo.flag & GHBC_RESULT )
                  {  //Заводим фиктивную локальную переменную
                     out_add2uint( CVarload, var_addtmp( toki->type, toki->oftype ));
                  }
                  out_adduint( pfunc->vmo.id );                                    
               }
               
            }
            break;

         case FTOK_NUMBER:  //Число
            if ( (( povmtype)PCMD( toki->type ))->stsize == 2 )
            {
               out_adduint( CQwload );
               out_addulong( lex->num.vlong );
            }
            else
               out_add2uint( CDwload, lex->num.vint );
            break;

         case FTOK_TYPE: //Получение идентификатора типа
            //toki->oftype = 0;
            type = toki->type;
            if ( toki < tokc - 1 &&
                 ( (( toki+1 )->flg & FTOK_NOFLAGS ) == FTOK_OPER ) &&
                  ( toki+1 )->lex->oper.operid == OpAs )
            {               
               break;
            }
            out_add2uint( type >= KERNEL_COUNT ? CCmdload : CDwload, type );
            toki->oftype = 0;
            toki->type = TUint;
            break;

         case FTOK_PTRTYPE: //Приведение указателя к типу            
            if ( !( toki->flg & FTOK_LVALUE ) && 
                  (( pvmobj )PCMD( toki->type ))->flag & GHTY_STACK )
               out_adduint( artypes[ toki->type ] );            
            break;

         case FTOK_OPER: //Системная лексема, оператор,            
            curop = (psoper)&opers[curop_id = lex->oper.operid];			
            if ( curop_id == OpAs )
            {
               if ( ( toki->left->flg & FTOK_NOFLAGS ) == FTOK_LOCVAR )
               {
                  pvar = ( pfvar )(fd.bvars.data + toki->left->offlocvar );
                  if ( pvar->flg & FVAR_UINTAS || toki->left->type == TUint )
                  {
                     if ( toki->flg & FTOK_LVALUE )
                        msg( MExplvalue | MSG_LEXERR, lex );

                     buf_expand( &fd.bvarsas, sizeof( fvaras ));
                     pvaras = (( pfvaras )(fd.bvarsas.data + fd.bvarsas.use ));
                     fd.bvarsas.use += sizeof( fvaras );

                     pvaras->offbvar = toki->left->offlocvar;
                     pvaras->type = pvar->type;
                     pvaras->oftype = pvar->oftype;
                     pvaras->flg = pvar->flg;

                     pvar->type = (toki-1)->type;
                     pvar->oftype = (toki-1)->oftype;

                     if ( (toki-1)->type != TUint &&
                          (( pvmobj )PCMD( (toki - 1)->type ))->flag & GHTY_STACK )
                        msg( MAsright | MSG_LEXERR, lex );
                     pvar->flg |= FVAR_UINTAS;
                     if ( ((toki-1)->flg & FTOK_NOFLAGS) == FTOK_TYPE )
                     {
                        *(puint)(fd.bout->data + toki->left->offout ) = CVarload;
                     }
                     else
                     {
                        if ( toki->left->type != TUint )
                        {
                           *(puint)(fd.bout->data + toki->left->offout ) = CVarptrload;
                        }
                        out_adduint( CSetI );
                     }
                     toki->type = (toki-1)->type;
                     toki->oftype = (toki-1)->oftype;
                     break;
                  }
               }
               msg( MAsleft | MSG_LEXERR, lex );
            }
            else if ( curop_id == OpStrtext || curop_id == OpStrout ||
                       ( curop_id == OpStradd && !toki->left->type ) )//?
            {
               if ( type_isinherit( (toki-1)->type, TStr ) )
                  out_adduint( CSetText );
               else if ( !( ( (toki-1)->flg & FTOK_TEXT ) ||
                    (((toki-1)->flg & FTOK_NOFLAGS) == FTOK_OPER  &&
                    ((toki-2)->flg & FTOK_NOFLAGS) == FTOK_ADDRFUNC )))
                  msg( MVarstr | MSG_LEXERR, lex );
               toki->type = 0;
               toki->oftype = 0;
               break;
            }
            else  if ( curop_id == OpAddset &&
                          toki->left->type == TCollection )
            {
               out_adduints( 4, CCmdload, 
                    //(toki-1)->type >= KERNEL_COUNT ? CCmdload : CDwload,
                           /*( 1 << 24 ) |*/ (toki-1)->type,//Тип правого операнда
                           CCollectadd,
                           (( povmtype )PCMD( (toki-1)->type ))->stsize + 1 );
               toki->type = TCollection;
               toki->oftype = 0;
               break;
            }
            else if ( curop_id == OpStradd )
            {
               if ( (toki-1)->flg & FTOK_TEXT ||
                    (((toki-1)->flg & FTOK_NOFLAGS) == FTOK_OPER  &&
                    ((toki-2)->flg & FTOK_NOFLAGS) == FTOK_ADDRFUNC ))
               {
                  toki->type = TStr;
                  toki->oftype = 0;
                  break;
               }
               else
               {                    
                  lex->oper.operid = OpAddset;                  
               }
            }
            if ( (toki->left && ( toki->left->flg & FTOK_LVALPROPERTY )) ||
                 ((toki-1)->flg & FTOK_LVALPROPERTY ))
            {				
               if ( curop_id == OpSet )
               {                  
                  pfunc = bc_property( toki->left->lex, (toki->left-1)->type, 
                                       (toki-1)->type );                
                  out_adduint( pfunc->vmo.id );
                  toki->type = pfunc->ret->type;
                  toki->oftype = pfunc->ret->oftype;
               }
               else
               {
                  if ( curop_id == OpAddr )
                  {
                     pfunc = bc_property( (toki-1)->lex, (toki-2)->type, 0 );                                  
                     toki->type = pfunc->ret->type;
                     toki->oftype = pfunc->ret->oftype;                  
                     if ( pfunc->vmo.flag & GHBC_RESULT )
                     {  //Заводим фиктивную локальную переменную
                        out_add2uint( CVarload, var_addtmp( toki->type, toki->oftype ));
                     }
                     out_adduint( pfunc->vmo.id );

                     if ( ((( pvmobj )PCMD( toki->type ))->flag & GHTY_STACK ) )
                        msg( MExplvalue | MSG_LEXERR, lex );
                     toki->type = TUint; 
                     toki->oftype = 0;                                          
                  }
                  else
                  {                     
                     msg( MPropoper | MSG_LEXERR , toki->lex );    
                  }
               }
            }
            else if (toki->left && ( toki->left->flg & FTOK_LVALLATE ))
            {               
               *(parsc++) = (toki - 1)->type;
               *(parsc++) = (toki - 1)->oftype;
               flglvallate = 1;               
               goto latecol;
            }
            else
            {
               if ( !(curop->flgs & OPF_NOP) )
               {
                  if ( curop->flgs & OPF_ADDNOT )
                  {
                     lex->oper.operid--;
                  }

                  pfunc = bc_oper( lex,
                     toki->left ? toki->left->type : 0, (toki-1)->type,
                     toki->left ? toki->left->oftype : 0, (toki-1)->oftype);
 
                  toki->type = pfunc->ret->type;
                  toki->oftype = pfunc->ret->oftype;

                  if ( pfunc->vmo.flag & GHBC_RESULT )
                  {  //Заводим фиктивную локальную переменную
                     out_add2uint( CVarload, var_addtmp( toki->type, toki->oftype ));
                  }
                  out_adduint( pfunc->vmo.id );
                  if ( curop->flgs & OPF_ADDNOT )
                     out_adduint( CLognot );
               }
               else
               {	
                  toki->type = TUint;
                  toki->oftype = 0;
                  //toki->type   = (toki - 1)->type;
                  //toki->oftype = (toki - 1)->oftype;
               }
            }
            if ( curop_id == OpLogand )
            {
               if ( (( povmtype )PCMD( toki->type ))->stsize == 2 )
                  out_adduint( CLoglongtrue );
               if ( !( toki->flg & FTOK_OPAND ) )
               {
                  j_correct( toki->left->ol, j_label( LABT_LABELVIRT, -1));
               }
            }
            else
            if ( curop_id == OpLogor )
            {
               if ( (( povmtype )PCMD( toki->type ))->stsize == 2 )
                  out_adduint( CLoglongtrue );
               if ( !( toki->flg & FTOK_OPOR ) )
               {
                  j_correct( toki->left->ol, j_label( LABT_LABELVIRT, -1));
               }
            }
            if ( ((( pvmobj )PCMD( toki->type ))->flag & GHTY_STACK ) && 
                     ( toki->flg & FTOK_LVALUE ))
               msg( MExplvalue | MSG_LEXERR, lex );
            break;

         case FTOK_STRBIN:
            //print( "FTOK_STRBIN %x %x\n", toki->type, str_len( toki->strbin ) );
            //Получаем идентификатор типа buf                          
            len = ( toki->type == TStr ? str_len( toki->strbin ) : buf_len( toki->strbin ));                                    
            out_adduints( 4,
                        //Заводим переменную и загружаем её в стэк
                        CVarload, var_addtmp( toki->type, 0 ),
                        //Загрузка размера
                        CDatasize, len );            
            //Загрузка данных
            out_addptr( toki->strbin->data, len );            
            //Получение кода метода
            out_adduint( bc_find( lex, "@load", 3, toki->type, TUint, TUint ) );            
            break;

         case FTOK_QUEST:            
            parsc -= 8;
            if ( toki->flg & FTOK_LVALUE )
               msg( MExplvalue | MSG_LEXERR, lex );
            if ( toki->pars != 3 )
            {
               msg( MQuest | MSG_LEXERR, lex );//Ошибка операции ?
            }
            parsb = parsc + 3;
            parse = parsc + 6;
            if ( type_compfull( toki->type = *(parsb) ) != 
                     type_compfull( *( parse )) &&
                 type_compfull( toki->oftype =*(parsb + 1) ) != 
                     type_compfull( *( parse + 1)) )
            {
               msg( MParquest | MSG_LEXERR, lex );//Ошибка несовпадение типов в операции ?
            }
            break;

         case FTOK_BYTECODE:
            out_adduint( toki->cmdbytecode );
            break;

         case FTOK_ALIAS:                        
            out_add2uint( CCmdload, toki->idalias );
            toki->oftype = 0;
            toki->type = TUint;
            break;

      }      
      if ( toki->flg & FTOK_ADDFUNCPAR)
      {  
         *(parsc++) = toki->type;
         *(parsc++) = toki->oftype;
      }      
      if ( toki->flg & FTOK_FUNCPAR )
      {   
         if ( !toki->type )//Ошибка, пустое выражение, должен быть тип у параметра/элемента
            msg( MExpnonull | MSG_LEXERR, lex );       
         *(parsc++) = toki->type;
         *(parsc++) = toki->oftype;
         
         if ( toki->flg & FTOK_QUESTFIRST )
         {  //Первый операнд операции ?
            if ( !toki->type )
               msg( MExplogic | MSG_LEXERR, toki->lex ); 
            // Временно сохраняем метки переходов в стэке переменных
            if ( (( povmtype )PCMD( toki->type ))->stsize == 2 )
               out_adduint( CLoglongtrue );
            //Добавляем переход на иначе
            *(parsc++) = j_jump( CIfznocls, LABT_GTVIRT, -1 );
            //out_adduint( CPop );
         }
         else if ( toki->flg & FTOK_QUESTSECOND )
         {  //Второй операнд операции ?
            //Добавляем переход на конец
            *(parsc++) = j_jump( CGotonocls, LABT_GTVIRT, -1 );
            ((pflabel)( fd.blabels.data + *( parsc - 4 ) ))->link = j_label( LABT_LABELVIRT, -1);

            //Нужно очистить последний элемент в стэке виртуальной машины
            out_adduint( CPop );
         }
         else  if ( toki->flg & FTOK_QUESTTHIRD )
         {  //Третий операнд операции ?
            //Вытаскиваем и очищаем последний элемент стэка параметров со смещением перехода
            ((pflabel)( fd.blabels.data + *( parsc - 3 ) ))->link = j_label( LABT_LABELVIRT, -1);
         }
      } 
      if ( toki->flg & FTOK_OPAND )
      {
         if ( (( povmtype )PCMD( toki->type ))->stsize == 2 )
            out_adduint( CLoglongtrue );
         toki->ol = j_jump( CIfznocls, LABT_GTVIRT, ( lex->type == LEXEM_OPER && lex->oper.operid == OpLogand ) ? toki->left->ol : -1 );
      }
      else
      if ( toki->flg & FTOK_OPOR )
      {
         if ( (( povmtype )PCMD( toki->type ))->stsize == 2 )
            out_adduint( CLoglongtrue );
         toki->ol = j_jump( CIfnznocls, LABT_GTVIRT, ( lex->type == LEXEM_OPER && lex->oper.operid == OpLogor ) ? toki->left->ol : -1 );
      }      
   }
   type = 0;
   if ( retoftype )
      *retoftype = 0;
   if ( tokb != tokc )//Тип возвращаемого значения
   {
      type = (tokc-1)->type;
      if ( retoftype )
      {
         *retoftype = (tokc-1)->oftype;
      }
   }

   if ( flg & EXPR_BOOL )//Логическое выражение
   {
      if ( type )
      {
         if ( (( povmtype )PCMD( type ))->stsize == 2 )
            out_adduint( CLoglongtrue );
      }
      else
      {
         msg( MExplogic | MSG_LEXERR, tokb != tokc ? tokb->lex : curlex ); 
      }
   }
   else
   if ( flg & EXPR_NONULL && !rettype )//Должно возвращать тип
      msg( MExpnonull | MSG_LEXERR, lex );
   
   if ( rettype )
      *rettype = type;

D("Expr stop\n" );
   return curlex;
}