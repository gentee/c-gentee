/******************************************************************************
*
* Copyright (C) 2006, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project <http://www.gentee.com>. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* compl.g 02.11.06
*
* Author: Sergey Kurganov ( pretorian ) 
*
* Description: Example of the using assembler compiler for gentee     
*
******************************************************************************
*Commands:	NOP, CLC, CLD, CLI, LAHF, SAHF, STC, STD, STI,
*				INC reg32, DEC reg32, PUSH reg32/num32, pop reg32
*           MUL reg32, DIV reg32, NEG reg32, NOT reg32
*
*Register(reg32):	eax,ebx,ecx,edx,esp,ebp,esi,edi
******************************************************************************/
include
{
   $"..\..\lib\lex\lex.g"
   "lexasm.g"
}

type opcode
//опкод
{
	uint	len	//длина опкода
	byte	op1	//первый опкод
	byte	op2	//второй опкод
	byte	op3	//третий опкод
	byte	op4	//четвертый опкод
	byte	op5	//пятый опкод
}

method opcode.clear()
//очистить опкод
{ this.len=0 }

method opcode.print()
//вывести на консоль опкод
{
	str i
	if this.len>0:i = hex2stru( i, this.op1 )+" "
	if this.len>1:i = hex2stru( i, this.op2 )+" "
	if this.len>2:i = hex2stru( i, this.op3 )+" "
	if this.len>3:i = hex2stru( i, this.op4 )+" "
	if this.len>4:i = hex2stru( i, this.op5 )+" "

	print( "\t" + i + "\n" )
}

method opcode.save(uint opcod)
//записать следующий опкод
{
	this.len++
	switch this.len
	{
	 case 1 : this.op1=byte(opcod)
	 case 2 : this.op2=byte(opcod)
	 case 3 : this.op3=byte(opcod)
	 case 4 : this.op4=byte(opcod)
	 case 5 : this.op5=byte(opcod)
	}
}

method opcode.save32(uint opcod)
//Запись 32-битного числа в опкод
{
	this.save( byte(opcod & 0xff))
	this.save( byte(( opcod & 0xff00 ) >> 8 ))
	this.save( byte(( opcod & 0xff0000 ) >> 16 ))
	this.save( byte(( opcod & 0xff000000 ) >> 24 ))
}

method uint uint.arrfindtrue(arr myarr)
	//поиск в массиве числа uint
	{
	foreach i,myarr: if i==this: return 1
	return 0
	}
	
func main<main>
{
   str     in, stemp
   uint    lex, i, off, tempop
   arrout  out
	opcode	code
	arr op1 = %{0xC0, 0xC5, 0xC9, 0xC7, 0xC4, 0xC3, 0xC6, 0xCA, 0xC8}
	arr op2 = %{0x8C, 0x88, 0xB3, 0xAD, 0x8D, 0x89, 0x9B, 0x9A}

	subfunc printitem(lexitem li)
	//выводит на консоль расшифровку элемента лексики (для отладки)
	{
	   print("type=\( hex2stru("", li.ltype )) pos = \(li.pos) len=\(li.len ) 0x\(hex2stru("", li.value )) \n")
	}

	subfunc printcommand(lexitem li)
	//выводит на консоль команду ассемблера (для отладки)
	{
		stemp.substr( in, li.pos, li.len )
		print( " "+= stemp + " " )
	}
	
	subfunc command(lexitem li)
	//проверяет является ли элемент коммандой
	{
		if li.ltype != $ASM_NAME || li.value < 0x40
		{
			print("Wrong command ")
			getch()
			exit(1)
		}
	}
	
	subfunc lexitem nextli()
	//перейти на следующий элемент
   {
      off += sizeof( lexitem )
      i++
      return off->lexitem
   }
	 
	subfunc uint register32(uint ltype value)
	//Возращает добавочное число к опкоду для 32 битных регистров
	{
		if ltype != 0x50000 || value < 0x10 || value > 0x17
		{
			print("Wrong command ")
			getch()
			exit(1)
		}
	return value & 0b111 	
	}

	out.isize = sizeof( lexitem )
   in.read( "test.asm" )	//Текст программы
   lex = lex_init( 0, lexgasm.ptr())
	gentee_lex( in->buf, lex, out )
   off = out.data.ptr()	//начальный адрес разобранного текста

		//Разбор асм кода
   fornum i, *out
   {
      uint  li 
      li as off->lexitem	//берем один элемент из разобранного текста
		// ltype - тип элемента
		// pos - позиция в тексте
		// len - длина элемента
		// value - значение элемента
      if li.ltype == $ASM_LINE : off += sizeof( lexitem ); continue 
      //printitem(li)
		command(li)
		printcommand(li)
			
		if li.value.arrfindtrue(op1)
			{
			//Команды без операндов
			switch li.value
				{
				case 0xC0 : code.save(0x90) //NOP
				case 0xC5 : code.save(0xF8) //CLC
				case 0xC9 : code.save(0xFC) //CLD			
				case 0xC7 : code.save(0xFA) //CLI
				case 0xC4 : code.save(0x9F) //LAHF
				case 0xC3 : code.save(0x9E) //SAHF
				case 0xC6 : code.save(0xF9) //STC
				case 0xCA : code.save(0xFD) //STD
				case 0xC8 : code.save(0xFB) //STI
				}
			}
		if li.value.arrfindtrue(op2)
			{
			//Команды с одним операндом (регистром 32 бита)
			tempop=li.value
			li as nextli()
			printcommand(li)
			switch tempop
				{
				case 0x8C : code.save(0x40 + register32(li.ltype, li.value)) //INC
				case 0x88 : code.save(0x48 + register32(li.ltype, li.value)) //DEC
				case 0xB3 //PUSH
					{
					if li.ltype == $ASM_NUMBER
						{
						code.save(0x68)
						code.save32(uint(stemp.substr(in,li.pos,li.len)))
						}
					else : code.save(0x50 + register32(li.ltype, li.value))
					}							
				case 0xAD : code.save(0x58 + register32(li.ltype, li.value))//POP
				case 0x8D //MUL
					{
					code.save(0xF7)
					code.save(0xE0 + register32(li.ltype, li.value))
					}
				case 0x89 //DIV
					{
					code.save(0xF7)
					code.save(0xF0 + register32(li.ltype, li.value))
					}
				case 0x9B //NEG
					{
					code.save(0xF7)
					code.save(0xD8 + register32(li.ltype, li.value))
					}
				case 0x9A //NOT
					{
					code.save(0xF7)
					code.save(0xD0 + register32(li.ltype, li.value))
					}
				}
			}
		code.print()
		code.clear()
		off += sizeof( lexitem )
		
		//Здесь будет код для записи опкода в буфер
		
   }
	lex_delete( lex ) 
   congetch("Press any key...")
}
