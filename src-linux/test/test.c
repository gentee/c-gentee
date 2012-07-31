/******************************************************************************
*
* Copyright (C) 2006, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* ID: test 06.10.06 0.0.A.
*
* Author: Alexey Krivonogov
*
******************************************************************************/

#include "../os/user/defines.h"
#include "../common/gentee.h"
#include "windows.h"
#include "../compiler/lextbl.h"

extern memory _memory;

enum   // Таблица для обработки GT данных
{
   GTDO_MAIN  = 0x010000, 
   GTDO_TEXT  = 0x020000,     // Простой текст.  Имеет флаг LEXF_ITEM 
   GTDO_SIGN  = 0x030000,     // Служебный символ '#' LEXF_ITEM
   GTDO_NAME  = 0x040000,     // Имя макроса после SIGN  LEXF_ITEM
   GTDO_AMP   = 0x050000,     // Символ '&'
   GTDO_ISHEX = 0x060000,     // Является ли шестнадцатеричным значением
   GTDO_HEXOK = 0x070000,     // Ждем ; у &xff;
   GTDO_ISPAR = 0x080000,     // Является ли параметром &#1;
   GTDO_PAROK = 0x090000,     // Ждем ; у &#1;
   GTDO_LP    = 0x0A0000,     // Пошла левая скобка после макроса LEXF_ITEM
   GTDO_PARTEXT = 0x0B0000,   // Обычный текст внутри скобок LEXF_ITEM
   GTDO_SPACE = 0x0C0000,     // <= ' ' внутри скобок LEXF_ITEM
   GTDO_DQ    = 0x0D0000,     // текст в двойных кавычках внутри скобок LEXF_ITEM
   GTDO_Q     = 0x0E0000,     // текст в одинарных кавычках внутри скобок LEXF_ITEM
   GTDO_AMPTRY = 0x0F000000,

   GTDO_DOT   = 0x01000000,   // Точка в имени макроса LEXF_ITEM
   GTDO_HEX   = 0x02000000,   // Шестнадцатеричное значение символа &xff; LEXF_ITEM
   GTDO_PAR   = 0x03000000,   // Номер параметра &#1; LEXF_ITEM
   GTDO_COMMA = 0x04000000,   // , у списка параметров LEXF_ITEM
   GTDO_RP    = 0x05000000,   // Правая скобка LEXF_ITEM
};

enum {
   GT_MAIN     = 0x010000,
   GT_ISBEGIN  = 0x020000,
   GT_TRYBEGIN = 0x03000000,
   GT_COMMENT  = 0x040000,    // Комментарий  LEXF_ITEM
   GT_VLINE    = 0x050000,    // <|
   GT_STAR     = 0x060000,    // Звездочка перед именем для совместимости
   GT_BEGIN    = 0x070000,    // Начало GT объекта.  Имеет флаг LEXF_ITEM
   GT_ATTRIB   = 0x080000,    // Разбор атрибутов.
   GT_NAME     = 0x090000,    // Идентификатор. LEXF_ITEM
   GT_EQUAL    = 0x0A0000,    // Равенство. LEXF_ITEM 
   GT_STRATTR  = 0x0B0000,    // Значение атрибута. LEXF_ITEM
   GT_STRDQ    = 0x0C0000,    // Строка в двойных кавычках. LEXF_ITEM
   GT_STRQ     = 0x0D0000,    // 10 Строка в одинарных кавычках. LEXF_ITEM
   GT_ISEND    = 0x0E0000,    // Возможное окончание объекта
   GT_TRYISEND = 0x0F000000,
   GT_ENDATTR  = 0x100000,    // Конец атрибутов
   GT_DATA     = 0x110000,    // Данные 
   GT_TRYENDDATA  = 0x12000000,
   GT_TRYWHAT     = 0x13000000,
   GT_TRYDATABEG  = 0x14000000,
/*   GT_ISATTREND,      
   GT_ISEND,
   GT_ENDATTR,    // Конец атрибутов
   GT_DATA,       // Данные GT объекта  LEXF_ITEM
   GT_SUBDATA,    // Возможное окончание данных или вхождение детей
   GT_SUBDATATRY, // Информация о перемещениях после try
   GT_SUBDATA1,    // Возможное окончание данных или вхождение детей
   GT_SUBDATA1TRY, // Информация о перемещениях после try
   GT_ISENDCMT,    // проверка на окончание комментария
   GT_ISENDCMTTRY,
*/
   GT_END   = 0x80000000            // Конец GT объекта  LEXF_ITEM
};

const uint tbl_gt[97] = { 20,
   // GT_MAIN
   1, LEX_SKIP, 0x3c3c, GT_TRYBEGIN | GT_ISBEGIN | LEXF_POS | LEXF_TRY | LEXF_PUSH,
   // GT_ISBEGIN
   4, LEXF_RET, 0x2d2d, GT_COMMENT | LEXF_ITSTATE,
        0x2a2a, GT_STAR,
        0x7c7c, GT_VLINE,
        0x3000, GT_BEGIN | LEXF_ITSTATE | LEXF_PUSHLI,
   // GT_TRYBEGIN
   0, LEXF_POP | LEX_SKIP,
   // GT_COMMENT
   1, LEX_OK, 0x3e2d, LEX_OK | LEXF_POP | LEXF_MULTI, 
   // GT_VLINE
   2, LEXF_RET, 0x2a2a, GT_STAR, 0x3000, GT_BEGIN | LEXF_ITSTATE | LEXF_PUSHLI,
   // GT_STAR
   1, LEXF_RET, 0x3000, GT_BEGIN | LEXF_ITSTATE | LEXF_PUSHLI,
   // GT_BEGIN Копим '0' - '9' '_' 'A'-'Z' 'a'-'z' и больше или равно 128
   1, GT_ATTRIB | LEXF_STAY, 0x3000, LEX_OK,
   // GT_ATTRIB                                                         
   4, LEX_SKIP, 0x4100, GT_NAME | LEXF_ITSTATE | LEXF_POS, 
         0x2f2f, GT_TRYISEND | GT_ISEND | LEXF_POS | LEXF_TRY, 
         0x3d3d, GT_EQUAL | LEXF_ITSTATE | LEXF_POS,
         0x3e3e, GT_ENDATTR,
   // GT_NAME
   1, GT_ATTRIB | LEXF_STAY, 0x3000, LEX_OK,
   // GT_EQUAL
   4, GT_STRATTR | LEXF_ITSTATE | LEXF_POS, 
         0x0120, LEX_SKIP, 
         0x3e2f2f, GT_ATTRIB | LEXF_STAY, 
         0x2222, GT_STRDQ | LEXF_ITSTATE | LEXF_POS,
         0x2727, GT_STRQ | LEXF_ITSTATE | LEXF_POS,
   // GT_STRATTR
   1, LEX_OK, 0x2f3e0120, GT_ATTRIB | LEXF_STAY, 
   // GT_STRDQ
   1, LEX_OK, 0x2222, LEX_OK | GT_ATTRIB,
   // GT_STRQ
   1, LEX_OK, 0x2727, LEX_OK | GT_ATTRIB,
   // GT_ISEND
   2, LEXF_RET,
         0x3e3e, GT_END | LEXF_ITCMD | LEXF_POP | LEXF_POPLI,
         0x3000, LEX_GTNAME, 
   // GT_TRYISEND
   0, LEX_SKIP | GT_ATTRIB,
   // GT_ENDATTRIB
   3, GT_DATA | LEXF_ITSTATE | LEXF_POS, 
         0x0120, LEX_SKIP, 
         0x3c3c, GT_ISBEGIN | LEXF_POS | LEXF_PUSH | LEXF_TRY | GT_TRYDATABEG, 
         0x2f3c, LEXF_MULTI | GT_ISEND | LEXF_TRY | GT_TRYWHAT,
   // GT_DATA
   1, LEX_OK, 
         0x2f3c, LEXF_MULTI | GT_ISEND | LEXF_TRY | GT_TRYENDDATA,
   // GT_TRYENDDATA
   0, LEX_OK | GT_DATA,
   // GT_TRYWHAT
   0, GT_DATA | LEXF_ITSTATE,
   // GT_TRYDATABEG
   0, GT_DATA | LEXF_ITSTATE | LEXF_POP,

/*   
   // GT_ISATTREND
   0x03, LEXF_RET | LEXF_STAY, 0x0000, LEXF_RET | LEXF_STAY, 
         0x3e3e, GT_ISEND | LEXF_POP | LEXF_STAY, 0x3000, LEX_GTNAME, 
   // GT_ISEND
   0x01, GT_END | LEXF_ITEM | LEXF_POP | LEXF_NAME | LEXF_RET, 
         0x0000, GT_END | LEXF_ITEM | LEXF_POP | LEXF_NAME | LEXF_RET, 
   // GT_ENDATTRIB
   0x02, GT_DATA | LEXF_ITEM | LEXF_POS, 0x0120, LEX_SKIP, 
         0x3c3c, GT_SUBDATA | LEXF_TRY | LEXF_POS, 
   // GT_DATA
   0x01, LEX_OK, 0x3c3c, GT_SUBDATA1 | LEXF_TRY | LEXF_POS,
   // GT_SUBDATA
   0x04, LEXF_RET | LEXF_STAY, 0x0000, LEXF_RET | LEXF_STAY, 
         0x2d2d, GT_COMMENT | LEXF_ITEM | LEXF_PUSH,
         0x2f2f, GT_ISATTREND, 0x3000, GT_ISBEGIN | LEXF_STAY,
   // GT_SUBDATATRY
   0x01, GT_DATA | LEXF_ITEM | LEXF_POS, 0x0000, GT_DATA,
   // GT_SUBDATA1
   0x02, LEXF_RET | LEXF_STAY, 0x0000, LEXF_RET | LEXF_STAY, 
         0x2f2f, GT_ISATTREND,
   // GT_SUBDATA1TRY
   0x01, LEX_OK, 0x0000, GT_DATA,
   0x0000,*/
};

/*
const ushort tbl_gt[115] = {
   0x01, LEX_SKIP, 0x3c3c, GT_ISBEGIN | LEXF_POS,
   // GT_ISBEGIN Смотрим начало на _ 'A'-'Z' 'a'-'z' и больше или равно 128
   0x02, LEXF_RET | LEXF_STAY, 0x2d2d, GT_COMMENT | LEXF_ITEM | LEXF_PUSH, 
         0x3000, GT_BEGIN | LEXF_ITEM | LEXF_PUSH | LEXF_NAME,
   // GT_BEGIN Копим '0' - '9' '_' 'A'-'Z' 'a'-'z' и больше или равно 128
   0x01, GT_ATTRIB | LEXF_PUSH | LEXF_STAY, 0x3000, LEX_OK,
   // GT_ATTRIB                                                         
   0x04, LEX_SKIP, 0x4100, GT_NAME | LEXF_ITEM | LEXF_POS, 0x2f2f, GT_ISATTREND | LEXF_POS, 
         0x3d3d, GT_EQUAL | LEXF_ITEM | LEXF_POS,
         0x3e3e, GT_ENDATTR | LEXF_POP | LEXF_PUSH,
   // GT_NAME
   0x01, LEXF_RET | LEXF_STAY, 0x3000, LEX_OK,
   // GT_ISATTREND
   0x03, LEXF_RET | LEXF_STAY, 0x0000, LEXF_RET | LEXF_STAY, 
         0x3e3e, GT_ISEND | LEXF_POP | LEXF_STAY, 0x3000, LEX_GTNAME, 
   // GT_ISEND
   0x01, GT_END | LEXF_ITEM | LEXF_POP | LEXF_NAME | LEXF_RET, 
         0x0000, GT_END | LEXF_ITEM | LEXF_POP | LEXF_NAME | LEXF_RET, 
   // GT_EQUAL
   0x05, GT_STRATTR | LEXF_ITEM | LEXF_POS, 0x0120, LEX_SKIP, 0x2f2f, LEXF_RET | LEXF_STAY, 0x3e3e, LEXF_RET | LEXF_STAY,
         0x2222, GT_STRDQ | LEXF_PUSH | LEXF_POS | LEXF_ITEM,
         0x2727, GT_STRQ | LEXF_PUSH | LEXF_POS | LEXF_ITEM,
   // GT_STRATTR
   0x03, LEX_OK, 0x0120, LEXF_RET | LEXF_STAY, 0x2f2f, LEXF_RET | LEXF_STAY, 
         0x3e3e, LEXF_RET | LEXF_STAY,
   // GT_STRDQ
   0x01, LEX_OK, 0x2222, LEX_OK | LEXF_POP | LEXF_RET,
   // GT_STRQ
   0x01, LEX_OK, 0x2727, LEX_OK | LEXF_POP | LEXF_RET,
   // GT_ENDATTRIB
   0x02, GT_DATA | LEXF_ITEM | LEXF_POS, 0x0120, LEX_SKIP, 
         0x3c3c, GT_SUBDATA | LEXF_TRY | LEXF_POS, 
   // GT_DATA
   0x01, LEX_OK, 0x3c3c, GT_SUBDATA1 | LEXF_TRY | LEXF_POS,
   // GT_SUBDATA
   0x04, LEXF_RET | LEXF_STAY, 0x0000, LEXF_RET | LEXF_STAY, 
         0x2d2d, GT_COMMENT | LEXF_ITEM | LEXF_PUSH,
         0x2f2f, GT_ISATTREND, 0x3000, GT_ISBEGIN | LEXF_STAY,
   // GT_SUBDATATRY
   0x01, GT_DATA | LEXF_ITEM | LEXF_POS, 0x0000, GT_DATA,
   // GT_SUBDATA1
   0x02, LEXF_RET | LEXF_STAY, 0x0000, LEXF_RET | LEXF_STAY, 
         0x2f2f, GT_ISATTREND,
   // GT_SUBDATA1TRY
   0x01, LEX_OK, 0x0000, GT_DATA,
   // GT_COMMENT
   0x01, LEX_OK, 0x2d2d, GT_ISENDCMT | LEXF_TRY, 
   // GT_ISENDCMT
   0x01, LEXF_RET | LEXF_STAY, 0x3e3e, LEX_OKDBL | LEXF_POP | LEXF_RET,
   // GT_ISENDCMTTRY
   0x01, LEX_OK, 0x0000, GT_COMMENT,
   0x0000,
};

const ushort tbl_gtdo[ 113 ] = {
   0x02, GTDO_TEXT | LEXF_ITEM | LEXF_POS, 0x2626, GTDO_AMP | LEXF_TRY | LEXF_POS, 
         0x2323, GTDO_SIGN | LEXF_POS | LEXF_ITEM,
//0x2323 можно менять вручную в таблице на нужный служебный символ
   // GTDO_TEXT накапливаем обычный текст 
//   0x01, LEX_OK, 0x2626, GTDO_AMP | LEXF_TRY | LEXF_POS, 
   0x02, LEX_OK, 0x2626, GTDO_MAIN | LEXF_STAY, 0x2323, GTDO_MAIN | LEXF_STAY, 
   // GTDO_AMP
   0x04, LEXF_RET, 0x0000, LEXF_RET, 0x2323, GTDO_PAR,
         0x5858, GTDO_HEX, 0x7878, GTDO_HEX,
   // GTDO_AMPTRY
   0x01, GTDO_TEXT | LEXF_ITEM | LEXF_POS, 0x0000, GTDO_TEXT,
   // GTDO_HEX
   0x02, LEXF_RET, 0x0000, LEXF_RET, 0x5800, GTDO_HEXOK,
   // GTDO_HEXOK
   0x02, LEXF_RET, 0x3B3B, GTDO_HEXOK2 | LEXF_ITEM, 
         0x5800, LEX_SKIP, 
   // GTDO_HEXOK2
   0x01, GTDO_MAIN | LEXF_STAY, 0x0, LEX_STOP,
   // GTDO_PAR
   0x02, LEXF_RET, 0x0000, LEXF_RET, 0x3039, GTDO_PAROK,
   // GTDO_PAROK
   0x02, LEXF_RET, 0x3B3B, GTDO_PAROK2 | LEXF_ITEM, 0x3039, LEX_SKIP, 
   // GTDO_PAROK2
   0x01, GTDO_MAIN | LEXF_STAY, 0x0, LEX_STOP,
   // GTDO_SIGN
   0x03, GTDO_MAIN | LEXF_STAY, 0x3000, GTDO_NAME | LEXF_POS | LEXF_ITEM, 
         0x2e2e, GTDO_DOT | LEXF_POS | LEXF_ITEM, 0x2f2f, GTDO_NAME | LEXF_POS | LEXF_ITEM, 
   // GTDO_NAME
   0x04, GTDO_MAIN | LEXF_STAY, 0x3000, LEX_OK, 0x2828, GTDO_LP | LEXF_ITEM | LEXF_POS,
         0x2f2f, LEX_OK, 0x2e2e, GTDO_SIGN | LEXF_STAY,
   // GTDO_LP 
   0x05, GTDO_PARTEXT | LEXF_ITEM | LEXF_POS, 0x0120, GTDO_SPACE | LEXF_ITEM | LEXF_POS,
         0x2c2c, GTDO_COMMA | LEXF_ITEM | LEXF_POS, 0x2929, GTDO_RP | LEXF_ITEM | LEXF_POS,
         0x2222, GTDO_DQ | LEXF_ITEM | LEXF_POS | LEXF_PUSH, 
         0x2727, GTDO_Q | LEXF_ITEM | LEXF_POS | LEXF_PUSH,
   // GTDO_PARTEXT
   0x03, LEX_OK, 0x0120, GTDO_LP | LEXF_STAY, 0x2c2c, GTDO_LP | LEXF_STAY,
         0x2929, GTDO_LP | LEXF_STAY,
   // GTDO_SPACE
   0x01, GTDO_LP | LEXF_STAY, 0x0120, LEX_OK,
   // GTDO_DQ
   0x01, LEX_OK, 0x2222, LEX_OK | LEXF_POP | LEXF_RET,
   // GTDO_Q
   0x01, LEX_OK, 0x2727, LEX_OK | LEXF_POP | LEXF_RET,
   // GTDO_RP
   0x01, GTDO_MAIN | LEXF_STAY, 0x0001, LEX_STOP,

   0x0000,
};
*/

const uint tbl_gtdo[81] = { 15,
   // GTDO_MAIN
   2, GTDO_TEXT | LEXF_ITSTATE | LEXF_POS, 
         0x2626, GTDO_AMP | LEXF_TRY | LEXF_POS | GTDO_AMPTRY, 
         0x2323, GTDO_SIGN | LEXF_POS | LEXF_ITSTATE,
   // GTDO_TEXT
   1, LEX_OK, 0x262323, GTDO_MAIN | LEXF_STAY,
   // GTDO_SIGN
   2, GTDO_MAIN | LEXF_STAY, 
         0x2f3000, GTDO_NAME | LEXF_POS | LEXF_ITSTATE, 
         0x2e2e, GTDO_DOT | LEXF_POS | LEXF_ITCMD,
   // GTDO_NAME
   3, GTDO_MAIN | LEXF_STAY, 0x2f3000, LEX_OK, 
         0x2828, GTDO_LP | LEXF_ITSTATE | LEXF_POS,
         0x2e2e, GTDO_SIGN | LEXF_STAY,
   // GTDO_AMP
   2, LEXF_RET, 0x785858, GTDO_ISHEX,
         0x2323, GTDO_ISPAR,
   // GTDO_ISHEX
   1, LEXF_RET, 
         0x5800, GTDO_HEXOK,
   // GTDO_HEXOK
   2, LEXF_RET, 
         0x3B3B, GTDO_HEX | LEXF_ITCMD | GTDO_MAIN, 
         0x5800, LEX_SKIP, 
   // GTDO_ISPAR
   1, LEXF_RET, 
         0x3039, GTDO_PAROK,
   // GTDO_PAROK
   2, LEXF_RET, 
         0x3B3B, GTDO_PAR | LEXF_ITCMD | GTDO_MAIN, 
         0x3039, LEX_SKIP, 
   // GTDO_LP 
   5, GTDO_PARTEXT | LEXF_ITSTATE | LEXF_POS, 
         0x0120, GTDO_SPACE | LEXF_ITSTATE | LEXF_POS,
         0x2c2c, GTDO_COMMA | LEXF_ITCMD | LEXF_POS, 
         0x2929, GTDO_RP | LEXF_ITCMD | LEXF_POS | GTDO_MAIN,
         0x2222, GTDO_DQ | LEXF_ITSTATE | LEXF_POS, 
         0x2727, GTDO_Q | LEXF_ITSTATE | LEXF_POS,
   // GTDO_PARTEXT
   1, LEX_OK, 0x2c290120, GTDO_LP | LEXF_STAY, 
   // GTDO_SPACE
   1, GTDO_LP | LEXF_STAY, 0x0120, LEX_OK,
   // GTDO_DQ
   1, LEX_OK, 0x2222, LEX_OK | GTDO_LP,
   // GTDO_Q
   1, LEX_OK, 0x2727, LEX_OK | GTDO_LP,
   // GTDO_AMPTRY
   0, GTDO_TEXT | LEXF_ITSTATE,// | LEXF_POS,
};

int __cdecl main( int argc, char *argv[] )
{
   lex ilex;
   plexitem pil;
   buf in;
   str fn;
   arr out;
   uint i;
   uint fout;

   gentee_init();
   printf("Start\n");
   str_init( &fn );

   str_copyzero( &fn, "gttbl.dat");
   fout = os_fileopen( &fn, FOP_CREATE );
   printf("Fout=%i %s\n", fout, str_ptr( &fn ));
   os_filewrite( fout, ( pubyte )&tbl_gt, 97 * sizeof( uint ));
   os_fileclose( ( pvoid )fout );

   str_copyzero( &fn, "gtdotbl.dat");
   fout = os_fileopen( &fn, FOP_CREATE );
   printf("Fout=%i %s\n", fout, str_ptr( &fn ));
   str_delete( &fn );
   os_filewrite( fout, ( pubyte )&tbl_gtdo, 81 * sizeof( uint ));
   os_fileclose( ( pvoid )fout );

   arr_init( &out, sizeof( lexitem ));
   buf_init( &in );
   buf_copyzero( &in, 
      "</r/&xfa;&#10;&#3;&#1&xfa; #ap/dfield( 'qwer ()ty' , \"my , name\" , qqq)#asdf.fgwsw/# se# &xaa;"
      "<2 qqq> </2><1 a2345=&xf0;> 223&</1><-qwe-rty->"
      "<mygt /asd = \"qwerty sese'\" qq21 = 'dedxd' 'esese;' aqaq=325623/>"
      "<a asdff /a>   <mygtdd><a /><-ooops-><ad />< qq</>"
      "xxx  </r/nm <_aa aqaqa /_aaaa /_a/_aa><a22222/ >"
      "<*abc ></abc><|*aaa = qqqq></aaa>ooops aaa</eee>\"\r\n</>");
//   buf_copyzero( &in, "<mygt > <aaa asdff>qqqq</>      </mygtdd>qq </> xxx  </r/nm <_aa aqaqa /_aaaa /_aa> <a22222/ /> </ >  ");
   printf("lex_init\n");
   lex_init( &ilex, (puint)&tbl_gtdo );
   printf("gentee_lex\n");
   gentee_lex( &in, &ilex, &out );
   if (arr_count(&ilex.state))
      printf("================= State=%x/%i \n", arr_getuint( &ilex.state,
          arr_count(&ilex.state) - 1 ), arr_count(&ilex.state));
   for ( i = 0; i < arr_count( &out ); i++ )
   {
      pil = ( plexitem )arr_ptr( &out, i );
      printf("ID=%x pos=%i len=%i \n", pil->type, pil->pos, pil->len,
             buf_ptr( &in ) + pil->pos );
   }
//   gentee_compile();
   lex_delete( &ilex );
   buf_delete( &in );
   arr_delete( &out );
   gentee_deinit();
   printf("OK\n");
   getch();
   return 0;
}
