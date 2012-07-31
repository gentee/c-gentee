/******************************************************************************
*
* Copyright (C) 2008, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* Author: Alexey Krivonogov ( gentee )
*
******************************************************************************/

/*-----------------------------------------------------------------------------
* Id: math L "Math"
* 
* Summary: Mathematical functions.
*
* List: *, abs, acos, asin, atan, ceil, cos, exp, fabs, floor, ln, log, 
           modf, pow, sin, sqrt, tan 
* 
-----------------------------------------------------------------------------*/

/*-----------------------------------------------------------------------------
* Id: abs F
* 
* Summary: The absolute value for integers |x|. 
*  
* Params: x - An integer value.
*
* Return: The absolute value. 
*
-----------------------------------------------------------------------------*/

func uint abs( int x )

/*-----------------------------------------------------------------------------
* Id: acos F
* 
* Summary: Calculating the arc cosine. 
*  
* Params: x - A value for calculating the arc cosine.
*
* Return: The arc cosine of x within the range [ 0; PI ]. 
*
-----------------------------------------------------------------------------*/

func double acos( double x )

/*-----------------------------------------------------------------------------
* Id: asin F
* 
* Summary: Calculating the arc sine. 
*  
* Params: x - A value for calculating the arc sine.
*
* Return: The arc cosine of x within the range [ -PI/2 ; PI/2 ]. 
*
-----------------------------------------------------------------------------*/

func double asin( double x )

/*-----------------------------------------------------------------------------
* Id: atan F
* 
* Summary: Calculating the arc tangent. 
*  
* Params: x - A value for calculating the arc tangent.
*
* Return: The arc tangent of x within the range [ -PI/2 ; PI/2 ]. 
*
-----------------------------------------------------------------------------*/

func double atan( double x )

/*-----------------------------------------------------------------------------
* Id: ceil F
* 
* Desc:    Smallest double integer not less than given.
* Summary: Getting the smallest integer that is greater than or equal to x.  
*  
* Params: x - Floating-point value. 
*
* Return: The closest least integer. 
*
-----------------------------------------------------------------------------*/

func double ceil( double x )

/*-----------------------------------------------------------------------------
* Id: cos F
* 
* Summary: Calculating the cosine. 
*  
* Params: x - An angle in radians.
*
* Return: The cosine of x. 
*
-----------------------------------------------------------------------------*/

func double cos( double x )

/*-----------------------------------------------------------------------------
* Id: exp F
* 
* Summary: Exponential function. 
*  
* Params: x - A power for the number e.
*
* Return: The number e raised to the power of x. 
*
-----------------------------------------------------------------------------*/

func double exp( double x )

/*-----------------------------------------------------------------------------
* Id: fabs F
* 
* Summary: The absolute value for double |x|. 
*  
* Params: x - Floating-point value.
*
* Return: The absolute value. 
*
-----------------------------------------------------------------------------*/

func double fabs( double x )

/*-----------------------------------------------------------------------------
* Id: floor F
* 
* Desc:    Largest double integer not greater than given.
* Summary: Getting the largest integer that is less than or equal to x.  
*  
* Params: x - Floating-point value. 
*
* Return: The closest greatest integer. 
*
-----------------------------------------------------------------------------*/

func double floor( double x )

/*-----------------------------------------------------------------------------
* Id: ln F
* 
* Summary: Natural logarithm.  
*  
* Params: x - Floating-point value.
*
* Return: The natural logarithm ln( x ).  
*
-----------------------------------------------------------------------------*/

func double ln( double x )

/*-----------------------------------------------------------------------------
* Id: log F
* 
* Summary: Common logarithm.  
*  
* Params: x - Floating-point value.
*
* Return: The common logarithm log10( x ).  
*
-----------------------------------------------------------------------------*/

func double log( double x )

/*-----------------------------------------------------------------------------
* Id: modf F
* 
* Summary: Splitting into whole and fractional parts.  
*  
* Params: x - Floating-point value.
          y - A pointer to double for getting the whole part. 
*
* Return: The fractional part of x.  
*
-----------------------------------------------------------------------------*/

func double modf( double x, uint y )

/*-----------------------------------------------------------------------------
* Id: pow F
* 
* Summary: Raising to the power.  
*  
* Params: x - A base.
          y - A power. 
*
* Return: Raising x to the power of y.  
*
-----------------------------------------------------------------------------*/

func double pow( double x, double y )

/*-----------------------------------------------------------------------------
* Id: sin F
* 
* Summary: Calculating the sine. 
*  
* Params: x - An angle in radians.
*
* Return: The sine of x. 
*
-----------------------------------------------------------------------------*/

func double sin( double x )

/*-----------------------------------------------------------------------------
* Id: sqrt F
* 
* Summary: Square root. 
*  
* Params: x - A positive floating-point value.
*
* Return: The square root of x.  
*
-----------------------------------------------------------------------------*/

func double sqrt( double x )

/*-----------------------------------------------------------------------------
* Id: tan F
* 
* Summary: Calculating the tangent. 
*  
* Params: x - An angle in radians.
*
* Return: The tangent of x.  
*
-----------------------------------------------------------------------------*/

func double tan( double x )
