/******************************************************************************
*
* Copyright (C) 2004-2009, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* ID: vis.timer 11.09.09 0.0.A.
*
* Author: Alexander Krivonogov ( gentee )
*
******************************************************************************/
/*------------------------------------------------------------------------------
   Import
*/


import "user32.dll" {
   uint SetTimer( uint, uint, uint, uint )
   uint KillTimer( uint, uint )
}


/* Компонент vTimer, порождена от vComp
События
   OnTimer - вызывается при срабатывании таймера  
*/

type vTimer <inherit = vComp>
{
//Hidden Fields
   uint     pEnabled
   uint     pInterval
   uint     flgDeleting
//Events     
   evEvent  OnTimer
}


global {
   uint pTimerProc
}

func TimerProc( uint hwnd, uint msg, uint id, uint time )
{
   if id 
   {
      id->vTimer.OnTimer.Run( id->vComp )
   }
}
/*------------------------------------------------------------------------------
   Internal Methods
*/
/* Метод iUpdateTray
Обновляет настройки иконки
*/
method vTimer.iUpdateTimer( )
{  
   uint form as .GetMainForm()->vForm
   if &form && form.hwnd
   {
      if .pEnabled
      {
         SetTimer( form.hwnd, &this, .pInterval, pTimerProc )
      }
      else
      {
         KillTimer( form.hwnd, &this )
      }
   }
}

/*------------------------------------------------------------------------------
   Properties
*/
/* Свойство str vTimer.Interval - Get Set
Интервал таймера в миллисекундах
*/
property uint vTimer.Interval
{
   return this.pInterval
}

property vTimer.Interval( uint val )
{
   if val != this.pInterval
   { 
      this.pInterval = val      
      .iUpdateTimer()
   }  
}

/* Свойство uint vTimer.Enabled - Get Set
Включен/выключен таймер
*/
property uint vTimer.Enabled
{   
   return .pEnabled
}

property vTimer.Enabled( uint val )
{
   if .pEnabled != val
   {
      .pEnabled = val      
      .iUpdateTimer()            
   }
}


/*------------------------------------------------------------------------------
   Virtual Methods
*/

method vTimer.mPreDel <alias=vTimer_mPreDel>
{  
   .flgDeleting = 1
   .iUpdateTimer()
   this->vComp.mPreDel()
}

method vTimer.mOwnerCreateWin <alias=vTimer_mOwnerCreateWin>
{  
   .iUpdateTimer()   
}

/*------------------------------------------------------------------------------
   Registration
*/
method vTimer vTimer.init( )
{
   this.pTypeId = vTimer
   this.pInterval = 1000
   return this 
}

func init_vTimer <entry>()
{     
   pTimerProc = callback( &TimerProc, 4 )
   regcomp( vTimer,      "vTimer", vComp, $vComp_last, 
      %{ %{$mPreDel,       vTimer_mPreDel },
         %{$mOwnerCreateWin,  vTimer_mOwnerCreateWin }
      },
      0->collection )
            
            
ifdef $DESIGNING {
   cm.AddComp( vTimer, 1, "Windows", "timer" )   
   
   cm.AddProps( vTimer, %{ 
"Interval", uint, 0,
"Enabled", uint, 0
   }) 
   
   cm.AddEvents( vTimer, %{
"OnTimer"      , "evparEvent"
   })
               
}
      
}
