/******************************************************************************
*
* Copyright (C) 2004-2007, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* ID: vis.picture 12.11.08 0.0.A.
*
* Author: Alexander Krivonogov ( gentee )
*
******************************************************************************/
/* Компонента vProgressBar, порождена от vCtrl
События   
*/
type vProgressBar <inherit = vCtrl>
{
//Hidden fields
   int pMaximum
   int pMinimum
   int pPosition 
   uint pOrientation
}

define <export>{
//Orientation values:
   pboHorizontal = 0 //Горизонтальное
   pboVertical   = 1 //Вертикальное размещение
}

/*------------------------------------------------------------------------------
   Internal Methods
*/
method vProgressBar.iUpdateRange()
{
   .WinMsg( $PBM_SETRANGE32, .pMinimum, .pMaximum )    
}

method vProgressBar.iUpdatePos()
{
   .WinMsg( $PBM_SETPOS, .pPosition )    
}

/*------------------------------------------------------------------------------
   Properties
*/
/* Свойство int vProgressBar.Minimum - Get Set
Минимальное значение
*/
property int vProgressBar.Minimum()
{  
   return this.pMinimum
}

property vProgressBar.Minimum( int val)
{   
   if this.pMinimum != val
   {  
      this.pMinimum = val
      .iUpdateRange()       
   }
}

/* Свойство int vProgressBar.Maximum - Get Set
Максимальное значение
*/
property int vProgressBar.Maximum()
{  
   return this.pMaximum
}

property vProgressBar.Maximum( int val)
{   
   if this.pMaximum != val
   {  
      this.pMaximum = val
      .iUpdateRange()      
   }
}

/* Свойство int vProgressBar.Position - Get Set
Текущее значение
*/
property int vProgressBar.Position()
{  
   return this.pPosition
}

property vProgressBar.Position( int val)
{   
   if this.pPosition != val
   {  
      this.pPosition = val
      .iUpdatePos()      
   }
}


/* Свойство uint vProgressBar.Orientation - Get Set
Ориентация прогресс бара (возможные значения - pbo* )
*/
property uint vProgressBar.Orientation()
{  
   return this.pOrientation
}

property vProgressBar.Orientation( uint val)
{
   if this.pOrientation != val
   {    
      this.pOrientation = val
      .SetStyle( $PBS_VERTICAL, val == $pboVertical )
      .iUpdateRange()
      .iUpdatePos()
   }
}


/*------------------------------------------------------------------------------
   Virtual methods
*/
/*Виртуальный метод vProgressBar vProgressBar.mCreateWin - Создание окна
*/
method vProgressBar vProgressBar.mCreateWin <alias=vProgressBar_mCreateWin>()
{
   uint style =  $WS_CHILD | $WS_CLIPSIBLINGS;
   if .pOrientation == $pboVertical : style |= $PBS_VERTICAL   
   .CreateWin( "msctls_progress32".ustr(), 0, style )
   this->vCtrl.mCreateWin()
   .iUpdateRange()
   .iUpdatePos()
   return this
}


/*------------------------------------------------------------------------------
   Registration
*/
method vProgressBar vProgressBar.init( )
{
   this.pTypeId = vProgressBar
   this.pMinimum = 0
   this.pMaximum = 100
   this.pPosition = 0   
   this.flgRePaint = 1   
   this.flgXPStyle = 1
   return this 
}  

func init_vProgressBar <entry>()
{  
   regcomp( vProgressBar, "vProgressBar", vCtrl, $vCtrl_last,
      %{ %{$mCreateWin, vProgressBar_mCreateWin }
      },
      0->collection )

ifdef $DESIGNING {      
   cm.AddComp( vProgressBar, 1, "Windows", "progressbar" )
   
   cm.AddProps( vProgressBar, %{
"Minimum", int, 0,
"Maximum", int, 0,
"Position", int, 0,
"Orientation", uint, 0
   })

   cm.AddPropVals( vProgressBar, "Orientation", %{           
"pboHorizontal", $pboHorizontal,       
"pboVertical"  , $pboVertical } )
}
}