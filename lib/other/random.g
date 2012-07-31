/******************************************************************************
*
* Copyright (C) 2007, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* ID: Random 15.03.2007 1.0
*
* Author: pROCKrammer ,Pretorian
*
* Summary: Random library which creates random numbers. It's re writed version of Pretorians random class.
*			  His class works only on windows but my is multi-platform
*
******************************************************************************/

type random<protected>
{
	uint rand
	uint begin
	uint end
	datetime dt
}

/*-----------------------------------------------------------------------------
*
* ID: random.init() 15.03.2007 1.0
* 
* Summary: Get first params
*  
-----------------------------------------------------------------------------*/
method random.init()
{
	this.dt.gettime()
	this.end=0xFFFFFFFE
	this.rand = ( this.dt.msec + this.dt.second + this.dt.minute ) * this.dt.hour  
}

/*-----------------------------------------------------------------------------
*
* ID: random.randseed(uint b, uint e) 15.03.2007 1.0
* 
* Summary: Returns random number from b to e
*  
-----------------------------------------------------------------------------*/
method uint random.randseed(uint b, uint e)
{
	this.begin = b
	this.end = e
	return (this.rand=( 16807 * this.rand ) % 0x7FFFFFFF)%(this.end-this.begin+1)+this.begin 
}
/*-----------------------------------------------------------------------------
*
* ID: random.init 15.03.2007 1.0
* 
* Summary: Returns any number
*  
-----------------------------------------------------------------------------*/
method uint random.randseed()
{
	return (this.rand=( 16807 * this.rand ) % 0x7FFFFFFF)%(this.end-this.begin+1)+this.begin 
}