/******************************************************************************
*
* Copyright (C) 2004-2008, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* ID: compiler 07.03.08 0.0.A.
*
* Author: Sergey Kurganov ( Pretorian )
*
******************************************************************************/
// Свойства:
// title [R](str) - заголовок консоли
// x [RW](uint) - x координата курсора		
// y [RW](uint) - y координата курсора
// length [RW](uint) - длинна консоли (буфера)
// height [RW](uint) - высота консоли (буфера)
// color [RW](uint) - текущий цвет символов
// background [RW](uint) - текущий фон символов
// cursoreShow [RW](uint) - видимость курсора 0/1
// cursoreSize [RW](uint) - размер курсора 0%-100%
// ctrlC [R](uint) - останавливать работу программы по Ctrl+C 0/1
// Методы:
// Print(str|ubute|byte|ushort|short|uint|int|ulong|long|float|double) - вывод на консоль
// uint Char() - код символа в текущих координатах
// Сhar(uint) - вывод символа по его коду на консоль
// Сhar(uint,uint) - вывод символа по его коду в указанном количестве на консоль
// Cls() - очистить экран
// Cls(uint,uint,uint,uint) - Очистить заданное окно в консоли
// Inversion() - инверсия фона и цвета
// Copy(uint,uint,uint,uint,uint,uint) - скопировать участок консоли в новые координаты
// ScrollUp() - скролировать всю консоль вверх
// ScrollDown() - скролировать всю консоль вниз
// ScrollLeft() - скролировать всю консоль влево
// ScrollRight() - скролировать всю консоль вправо

import "kernel32.dll"
{
	AllocConsole()
	uint GetStdHandle(int)
	FreeConsole()
	SetConsoleTitleA(uint)
	uint GetConsoleScreenBufferInfo(uint,uint)
	SetConsoleCursorPosition(uint,uint)
	SetConsoleScreenBufferSize(uint,uint)
	SetConsoleWindowInfo(uint,uint,uint)
	SetConsoleTextAttribute(uint,uint)
	GetConsoleCursorInfo(uint,uint)
	SetConsoleCursorInfo(uint,uint)
	FillConsoleOutputCharacterA(uint,uint,uint,uint,uint)
	FillConsoleOutputAttribute(uint,uint,uint,uint,uint)
	SetConsoleCtrlHandler(uint,uint)
	WriteConsoleA(uint,uint,uint,uint,uint)
	ReadConsoleOutputCharacterA(uint,uint,uint,uint,uint)
	ReadConsoleOutputA(uint,uint,uint,uint,uint)
	WriteConsoleOutputA(uint,uint,uint,uint,uint)
}

//Структура для работы с окном в консоли
type conrect
	{
	short left
	short top
	short right
	short bottom
	}

//Консоль	
type console <protected>
{
	short	column		//столбцов в экранном буфере консоли
	short	rows			//рядов в экранном буфере консоли
	short	xc				//координата x курсора
	short	yc				//координата y курсора
	uint	colorc		//атрибуты символа
	short left			//левый верхний угол окна буфера консоли на экране дисплея
	short	top
	short	right			//правый нижний угол окна буфера консоли на экране дисплея
	short	bottom
	short	maxcolumn	//максимальная длинна буфера консоли с учетом шрифта и размера дисплея
	short	maxrows		//максимальная высота буфера консоли с учетом шрифта и размера дисплея

	uint	cursize		// размер курсора
	uint	curvisible	// видимость курсора
	
	uint	hstdin	// дескриптор чтения с консоли
	uint	hstdout	// дескриптор записи в консоль
	uint	hstderr	// дескриптор вывода ошибок на консоль
}

//Установить название консоли
property console.title(str string)
{
	SetConsoleTitleA(string.ptr())
}

//Получить координату курсора x
property uint console.x
{
	GetConsoleScreenBufferInfo(.hstdout,&this)
	return uint(.xc)
}

//Получить координату курсора y
property uint console.y
{
	GetConsoleScreenBufferInfo(.hstdout,&this)
	return uint(.yc)
}

//Установить координату курсора в x
property console.x(uint x)
{
	SetConsoleCursorPosition(.hstdout,(uint(.y)<<16)+x)
}

//Установить координату курсора в y
property console.y(uint y)
{
	SetConsoleCursorPosition(.hstdout,(uint(y)<<16)+.x)
}

//Получить длину консоли
property uint console.length
{
	GetConsoleScreenBufferInfo(.hstdout,&this)
	return uint(.column)
}

//Получить высоту консоли
property uint console.height
{
	GetConsoleScreenBufferInfo(.hstdout,&this)
	return uint(.rows)
}

//Установить длину консоли
property console.length(uint length)
{
	if length>.length
	{
		SetConsoleScreenBufferSize(.hstdout,uint(.rows<<16)+length)
		.left=0; .top=0; .right=length-1; .bottom=.rows-1
		SetConsoleWindowInfo(.hstdout,1,&this.left)
	}
	else
	{
		.left=0; .top=0; .right=length-1; .bottom=.rows-1
		SetConsoleWindowInfo(.hstdout,1,&this.left)
		SetConsoleScreenBufferSize(.hstdout,uint(.rows<<16)+length)
	}
}

//Установить высоту консоли
property console.height(uint height)
{
	if height>.height
	{
		SetConsoleScreenBufferSize(.hstdout,uint(height<<16)+.column)
		.left=0; .top=0; .right=.column-1; .bottom=height-1
		SetConsoleWindowInfo(.hstdout,1,&this.left)
	}
	else
	{
		.left=0; .top=0; .right=.column-1; .bottom=height-1
		SetConsoleWindowInfo(.hstdout,1,&this.left)
		SetConsoleScreenBufferSize(.hstdout,uint(height<<16)+.column)
	}
}

//Установить цвет выводимых символов
property console.color(uint color)
{
	GetConsoleScreenBufferInfo(.hstdout,&this)
	SetConsoleTextAttribute(.hstdout,(.colorc&0xF0)+(color&0xF))
}
	
//Получить цвет выводимых символов
property uint console.color
{
	GetConsoleScreenBufferInfo(.hstdout,&this)
	return uint(.colorc&0xF)
}

//Установить фон выводимых символов
property console.background(uint background)
{
	GetConsoleScreenBufferInfo(.hstdout,&this)
	SetConsoleTextAttribute(.hstdout,(.colorc&0xF)+(background<<4&0xF0))
}
	
//Получить фон выводимых символов
property uint console.background
{
	GetConsoleScreenBufferInfo(.hstdout,&this)
	return uint(.colorc>>4&0xF)
}

//Возвращает видимость курсора 0/1
property uint console.cursoreShow
{
	GetConsoleCursorInfo(.hstdout,&.cursize)
	return .curvisible 
}	

//Возвращает размер курсора 0-100
property uint console.cursoreSize
{
	GetConsoleCursorInfo(.hstdout,&.cursize)
	return .cursize 
}	

//Установить видимость курсора 0/1
property console.cursoreShow(uint visible)
{
	GetConsoleCursorInfo(.hstdout,&.cursize)
	.curvisible=visible
	SetConsoleCursorInfo(.hstdout,&.cursize) 
}	
	
//Установить размер курсора 0-100
property console.cursoreSize(uint size)
{
	GetConsoleCursorInfo(.hstdout,&.cursize)
	.cursize=size
	SetConsoleCursorInfo(.hstdout,&.cursize) 
}	

//Очистить консоль
method console.Cls()
{
   FillConsoleOutputCharacterA(.hstdout,32,.length*.height,0,0)
   FillConsoleOutputAttribute(.hstdout,(.background<<4)+.color,.length*.height, 0, 0)
   .x=0;.y=0
}

//Печать str
method console.Print(str string) { print(string) }	

//Печать uint
method console.Print(uint string) { print(str(string)) }	

//Печать int
method console.Print(int string) { print(str(string)) }	

//Печать ubyte
method console.Print(ubyte string) { print(str(string)) }	

//Печать byte
method console.Print(byte string) { print(str(string)) }	

//Печать ushort
method console.Print(ushort string) { print(str(string)) }	

//Печать short
method console.Print(short string) { print(str(string)) }	

//Печать float
method console.Print(float string) { print(str(string)) }	

//Печать ulong
method console.Print(ulong string) { print(str(string)) }	

//Печать long
method console.Print(long string) { print(str(string)) }	

//Печать double
method console.Print(double string) { print(str(string)) }	

//Инверсия цветов
method console.Inversion()
{
	uint i
	i=.color
	.color=.background
	.background=i
}

//Останавливать работу программы по Ctrl+C 0/1
property console.ctrlC(uint num)
{
	if num : SetConsoleCtrlHandler(0,0)
	else : SetConsoleCtrlHandler(0,1)
}  
	
//Инициализация объекта
method console.init()
{
	AllocConsole()
	.hstdin=GetStdHandle(-10)
	.hstdout=GetStdHandle(-11)
	.hstderr=GetStdHandle(-12)
	.length=80
	.height=25
	.Cls()
}

//Удаление объекта
method console.delete() { FreeConsole() }

//Вывод символа по его коду на консоль
method console.char(uint sym)
{
	str string=" "
	string[0]=byte(sym)
	WriteConsoleA(.hstdout,string.ptr(),*string,0,0)
}

//Вывод символа по его коду в указанном количестве на консоль
method console.Char(uint sym, uint num)
{
	uint i
	byte sy=byte(sym)
	str string
	fornum i=0,num
	{
		string+=" "
		string[i]=sy
	}
	WriteConsoleA(.hstdout,string.ptr(),*string,0,0)
}

//Определить код символа в звдвнных координатах (символ выше 128 не гарантируется)
method uint console.char()
{
	uint i;str i2=" "
	GetConsoleScreenBufferInfo(.hstdout,&this)
   ReadConsoleOutputCharacterA(.hstdout,i2.ptr(),1,.xc,&i)
   return uint(i2[0])
}

//Очистить заданное окно в консоли (x,y,length,height)
method console.Cls(uint x y l h)
{
	uint i
	fornum i=0,h
   {
		FillConsoleOutputCharacterA(.hstdout,32,l,y+i<<16|x,0)
   	FillConsoleOutputAttribute(.hstdout,(.background<<4)+.color,l,y+i<<16|x,0)
	}
		.x=x; .y=y
}

//Скопировать участок консоли xyhl в новые координаты 
method console.Copy(uint x y l h x1 y1)
{
	conrect rect
	rect.left=x
	rect.top=y
	rect.right=x+l
	rect.bottom=y+h
	buf buff[l*h*4]
	ReadConsoleOutputA(.hstdout,buff.ptr(),(h<<16)|l,0,&rect)
	rect.left=x1
	rect.top=y1
	rect.right=x1+l
	rect.bottom=y1+h
	WriteConsoleOutputA(.hstdout,buff.ptr(),(h<<16)|l,0,&rect)
}

//Скролировать всю консоль вверх
method console.ScrollUp()
{
	uint i
	.Copy(0,1,.length,.rows-1,0,0)
	FillConsoleOutputCharacterA(.hstdout,32,.column,(.rows-1)<<16,&i)
	FillConsoleOutputAttribute(.hstdout,(.background<<4)+.color,.column,(.rows-1)<<16,0)
}

//Скролировать всю консоль вниз
method console.ScrollDown()
{
	uint i
	.Copy(0,0,.length,.rows-1,0,1)
	FillConsoleOutputCharacterA(.hstdout,32,.column,0,&i)
	FillConsoleOutputAttribute(.hstdout,(.background<<4)+.color,.column,0,0)
}

//Скролировать всю консоль влево
method console.ScrollLeft()
{
	uint i,j
	.Copy(1,0,.length,.rows,0,0)
	fornum j=0,.height
	{
		FillConsoleOutputCharacterA(.hstdout,32,1,(j<<16)+(.column-1),&i)
		FillConsoleOutputAttribute(.hstdout,(.background<<4)+.color,1,(j<<16)+(.column-1),0)
	}
}

//Скролировать всю консоль вправо
method console.ScrollRight()
	{
	uint i,j
	.Copy(0,0,.length-1,.rows,1,0)
	fornum j=0,.height
	{
		FillConsoleOutputCharacterA(.hstdout,32,1,j<<16,&i)
		FillConsoleOutputAttribute(.hstdout,(.background<<4)+.color,1,j<<16,0)
	}
		fornum j=0,.height
		{
			FillConsoleOutputCharacterA(.hstdout,32,1,(j<<16),&i)
		}
	}

/*
func main< main >
{
	console con
	datetime time_start, time_end, work_time
	time_start.gettime() //Время начала

	con.Inversion()
	con.Char(0xB0,1999)
	con.Cls(1,1,8,4)
	con.Print("dfdfdf")
	con.Copy(1,1,3,3,20,10)
	//con.Inversion()
	con.ScrollRight()
	time_end.gettime() //Время конца
	work_time = time_end - time_start
	print("Время работы : \(gettimeformat(work_time , "HH:mm:ss", "")).\( work_time.msec) \n")
	getch()
}
*/
