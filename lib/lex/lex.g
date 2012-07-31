/******************************************************************************
*
* Copyright (C) 2006, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* ID: lex 18.10.06 0.0.A.
*
* Author: Alexey Krivonogov ( gentee )
*
* Summary: Interface to the lexcal analizer.
*
******************************************************************************/

type lexitem
{
   uint    ltype
   uint    pos  
   uint    len
   uint    value  
} 

type arrout
{
   buf   data
   uint  isize
   byte  isobj  // Each item is a memory block
}

/*type hashout
{
   arrout   values
   arrout   names
   uint     isize
   byte     ignore
}*/

type lexmulti
{
   uint    chars   // Последовательность символов.
   uint    value   // результирующая команда
   byte    len     // количество символов
}

/*type lex
{
   buf      tbl
   arrout   state   // Стэк состояний в котором хранится история состояний.
   arrout   litems  // Хранятся номера lexitem при занесение в стэк state. 
   arrout   mitems  // Массив multi определений
                    // Резервируется 64 блока на всю таблицу по 8 элементов в 
                    // каждом блоке. Каждый элемент lexmulti.
   uint     imulti  // Текущий свободный номер в массиве multi
   hashout  keywords
}
*/
import $"..\..\projects\msvisual6.0\gentee2\release\gentee2.dll"<link>
{
   uint  gentee_lex( buf, uint, arrout )
   uint  lex_tbl( uint, uint )
   uint  gentee_deinit()
   uint  gentee_init( uint )
   uint  lex_init( uint, uint )
         lex_delete( uint )
}

/*method lex.init
{
   uint size = 512 * sizeof( lexmulti )
   this.mitems.isize = sizeof( lexmulti )
   this.mitems.data.expand( size )
   this.mitems.data.use = size
   mzero( this.mitems.data.ptr(), size )
   lex_init( this, 0 )
}

method lex.delete
{
   uint size = 512 * sizeof( lexmulti )
   this.mitems.isize = sizeof( lexmulti )
   this.mitems.data.expand( size )
   this.mitems.data.use = size
   mzero( this.mitems.data.ptr(), size )
   lex_delete( this )
}
*/
method arrout arrout.init
{
   this.isize = sizeof( uint )
   return this
}

operator uint *( arrout left )
{
   return left.data.use / left.isize
}

func lex_init<entry>
{
   gentee_init( 0 )   
}

