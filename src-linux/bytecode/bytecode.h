/******************************************************************************
*
* Copyright (C) 2006, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* ID: bytecode 18.10.06 0.0.A.
*
* Author: Alexey Krivonogov ( gentee )
*
* Summary: The byte-code structures, defines and enums
* 
******************************************************************************/

/*-----------------------------------------------------------------------------
*
* ID: shifttype 19.10.06 0.0.A.
* 
* Summary: The shift type of the embedded commands. Hi - top shift Lo - cmd
  shift
*  
-----------------------------------------------------------------------------*/

enum
{      
//  SH_TYPE,  // type
          //  top  cmd
  SHN3_1 = 1, //   -3   1    
  SHN2_1, //   -2   1    
  SHN1_2, //   -1   2
  SHN1_1, //   -1   1    
  SH0_2,  //   0    2
  SH0_1,  //   0    1    
  SH1_3,  //   1    3
  SH1_2,  //   1    2
  SH1_1,  //   1    1
  SH2_1,  //   2    1
  SH2_3,  //   2    3
};

/*enum
{
 
   SMulII,
   SDivII,
   SModII,
   SLeftII,
   SRightII,
   SSignI,
   SLessII,
   SGreaterII,

   SMulI,           // *=
   SDivI,           // /=
   SModI,           // %=
   SLeftI,          // <<=
   SRightI,         // >>=

   SAddULUL,          
   SSubULUL,
   SMulULUL,
   SDivULUL,
   SModULUL,
   SAndULUL,
   SOrULUL,
   SXorULUL,
   SLeftULUL,
   SRightULUL,
   SLessULUL,
   SGreaterULUL,
   SEqULUL,
   SNotUL,

   SIncLeftUL,      // ++
   SIncRightUL,     // правый ++
   SDecLeftUL,      // --
   SDecRightUL,     // правый --
   SAddUL,          // +=
   SSubUL,          // -=
   SMulUL,          // *=
   SDivUL,          // /=
   SModUL,          // %=
   SAndUL,          // &=
   SOrUL,           // |=
   SXorUL,          // ^=
   SLeftUL,         // <<=
   SRightUL,        // >>=

   SMulLL,
   SDivLL,
   SModLL,
   SLeftLL,
   SRightLL,
   SSignL,
   SLessLL,
   SGreaterLL,

   SMulL,           // *=
   SDivL,           // /=
   SModL,           // %=
   SLeftL,          // <<=
   SRightL,         // >>=

   SAddFF,
   SSubFF,
   SMulFF,
   SDivFF,
   SSignF,
   SLessFF,
   SGreaterFF,
   SEqFF,
   
   SIncLeftF,      // ++
   SIncRightF,     // правый ++
   SDecLeftF,      // --
   SDecRightF,     // правый --
   SAddF,
   SSubF,
   SMulF,
   SDivF,
   
   SAddDD,
   SSubDD,
   SMulDD,
   SDivDD,
   SSignD,
   SLessDD,
   SGreaterDD,
   SEqDD,
   
   SIncLeftD,      // ++
   SIncRightD,     // правый ++
   SDecLeftD,      // --
   SDecRightD,     // правый --
   SAddD,
   SSubD,
   SMulD,
   SDivD,

   SIncLeftB,      // ++
   SIncRightB,     // правый ++
   SDecLeftB,      // --
   SDecRightB,     // правый --
   SAddB,          // +=
   SSubB,          // -=
   SMulB,          // *=
   SDivB,          // /=
   SModB,          // %=
   SAndB,          // &=
   SOrB,           // |=
   SXorB,          // ^=
   SLeftB,         // <<=
   SRightB,        // >>=

   SMulBS,         // *=
   SDivBS,         // /=
   SModBS,         // %=
   SLeftBS,        // <<=
   SRightBS,       // >>=

   SIncLeftUS,      // ++
   SIncRightUS,     // правый ++
   SDecLeftUS,      // --
   SDecRightUS,     // правый --
   SAddUS,          // +=
   SSubUS,          // -=
   SMulUS,          // *=
   SDivUS,          // /=
   SModUS,          // %=
   SAndUS,          // &=
   SOrUS,           // |=
   SXorUS,          // ^=
   SLeftUS,         // <<=
   SRightUS,        // >>=

   SMulS,           // *=
   SDivS,           // /=
   SModS,           // %=
   SLeftS,          // <<=
   SRightS,         // >>=

   // Команды конвертации
   Sd2f,
   Sd2i,
   Sd2l,
   Sf2d,
   Sf2i,
   Sf2l,
   Si2d,
   Si2f,
   Si2l,
   Sl2d, 
   Sl2f,
   Sl2i,
   Sui2d,
   Sui2f,
   Sui2l,
//   Sul2d,
//   Sul2f,
//   Sul2i,

   SSizeof,      // Размер типа
   SArgsCount,   // Возвратить количество параметров
   SArgsGet,     // Получить i-й параметр
   SGetText,     // Получить текущий вывод
   SGetID,       // Получение ID по имени
   SGetIDCall,   // Получение ID по имени и параметрам
   SGetVM,       // Получить идентификатор виртуальной машины

   SNop,         //  Метка - Пустая команда
   SVarsInit,    // Инициализациия блока переменных cmd 1 - номер блока
   SSubCall,     // Вызов локальной функции. cmd 1 - координаты для goto.
   SSubRet,      // определить количество возвращаемых dword  cmd 1
   SSubPar,      // Определить параметры у подфункции. cmd 1 - номер блока 
                 // переменных-параметров для данной подфункции.
                 // cmd 2 - количество копируемых dword
   SSubReturn,   // Выход из подфункции
   SPtrGlobal,   // Получить указатель на глобальную переменную cmd 1 - идентифкатор переменной
   SCmdLoad,     // Идентифкатор поместить в стэк. При загрузке конвертируется в SDwLoad 
   SCmdCall,     // Вызов функции по коду из стэка cmd 1 - количетсво dword занимаемых параметрами.
                 // код вызова находится перед ними
//   SSizeof,      // Размер типа
//   SArgsCount,   // Возвратить количество параметров
//   SArgsGet,     // Получить i-й параметр
//   SGetVM,       // Получить идентификатор виртуальной машины
   STypeInit,    // Инициализировать переменную указатель и id типа 
   STypeMustInit,// Данный тип имеет функции инициализации или деинициализации 0 init /1 deinit + id типа
   STypeMustDel, // Данный тип имеет функции инициализации или деинициализации 0 init /1 deinit + id типа
   STypeDelete,  // Освободить переменную указатель и id типа 
//   SGetText,     // Получить текущий вывод
   SSetTextPtr,  // Вывод текста по SPtrDataSize 
   SSetTextClear,// Вывод текста по str и очищение str
   SSetText,     // Вывод текста по str 
   SCollectAdd,  // Добавить значения к коллекции cmd - 1 - dword количество dwords в стэке на описание 
                 // добавляемых элементов
                 // В стэке val1 ... vali + < количество dwords под val( byte ) + type of val (3 байт) > 
   SException,   // Добавить функцию обработки исключения
   SThrow,       // Генерация исключения
   SCallFunc,
   SCallStd,
   SReturn,      //  Выход из функции

   // Базовые типы
   SByteSign,    // Не менять положение типов!
   SByte,
   SShort,
   SUShort,
   SInt,
   SUInt,
   SFloat,        
   SLong,         // 64-разрядные типы
   SULong,
   SDouble,
   SBuf,
   SStr,
   SCollection,   // Тип коллекция
   SReserved,     // Тип для резервирования места
//   SCollection,   // Тип коллекция
   SLast,

   SPtrStr = 253,    // Следом идет строка в тексте
}
*/