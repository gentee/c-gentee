/******************************************************************************
*
* Copyright (C) 2006, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project <http://www.gentee.com>. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* testasm.g 29.09.06
*
* Author: Alexey Krivonogov ( gentee ) 
*
* Description: Example of the using gentee analizer     
*
******************************************************************************/

	NOP
	CLC
	CLD
	CLI
	LAHF
	SAHF
	STC
	STD
	STI

	INC	eax
	INC	ebx
	INC	ecx
	INC	edx
	INC	esp
	INC	ebp
	INC	esi
	INC	edi

	DEC	eax
	DEC	ebx
	DEC	ecx
	DEC	edx
	DEC	esp
	DEC	ebp
	DEC	esi
	DEC	edi

	PUSH	eax
	PUSH	ebx
	PUSH	ecx
	PUSH	edx
	PUSH	esp
	PUSH	ebp
	PUSH	esi
	PUSH	edi
	PUSH	123456

	POP	eax
	POP	ebx
	POP	ecx
	POP	edx
	POP	esp
	POP	ebp
	POP	esi
	POP	edi

	MUL	eax
	MUL	ebx
	MUL	ecx
	MUL	edx
	MUL	esp
	MUL	ebp
	MUL	esi
	MUL	edi

	DIV	eax
	DIV	ebx
	DIV	ecx
	DIV	edx
	DIV	esp
	DIV	ebp
	DIV	esi
	DIV	edi

	NEG	eax
	NEG	ebx
	NEG	ecx
	NEG	edx
	NEG	esp
	NEG	ebp
	NEG	esi
	NEG	edi

	NOT	eax
	NOT	ebx
	NOT	ecx
	NOT	edx
	NOT	esp
	NOT	ebp
	NOT	esi
	NOT	edi
