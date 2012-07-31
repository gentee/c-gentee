/******************************************************************************
*
* Copyright (C) 2005, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* ID: calendar 17.10.06 0.0.A.
*
* Author: Alexey Krivonogov ( gentee )
*
******************************************************************************/

text  calendar( uint year )
\{ datetime  stime
   stime.setdate( 1, 1, year )
}<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML><HEAD><TITLE>Calendar for year \(stime.year)</TITLE>
<STYLE TYPE="text/css">
<!--
BODY {background: #FFF; font-family: Verdana;}
H1 {text-align: center; margin: 5px;}
TABLE {border: 0; border-spacing: 7px;}
TD {padding: 3px; border: 1px solid; text-align: center;}
#copy {font-size: smaller; text-align: center;}
-->
</STYLE>
</HEAD>
<BODY><H1>\(stime.year)</H1>
<TABLE ALIGN=CENTER>\{ 

   uint i j k month dayofweek firstday
   str  stemp
   
   firstday = firstdayofweek()
   dayofweek = stime.dayofweek
   fornum i = 0, 4
   {
      @"\l<TR>"
      fornum j = 1, 4
      {
         month = i * 3 + j
         @"\l<TD>\(nameofmonth( stemp,  month ))
<PRE>"
         fornum k = firstday, firstday + 7
         {
            @"  \( abbrnameofday( stemp, k ).setlen( 2 ))"
         }
         @"  \l"
         @"    ".repeat( ( 7 + dayofweek - firstday ) % 7 )

         uint day = 1
         uint lines
         while day <= daysinmonth( year, month )
         {
            if !dayofweek : @"<FONT COLOR=red>"
            @str( day++ ).fillspacel( 4 )
            if !dayofweek : @"</FONT>"

            dayofweek = ( dayofweek + 1 ) % 7
            if dayofweek == firstday 
            {
               @"  \l"
               lines++
            }
         }
         @"    ".repeat( ( 7 + firstday - dayofweek ) % 7 )

         while lines++ < 7 :  @"  \l"
         @"</PRE>"
      }   
   }
}
</TABLE>
<BR><DIV id="copy">Generated with Gentee Programming Language</DIV>
</BODY></HTML>\!

func main< main >
{
   str   out
   str   year
   
   congetstr( "Enter a year: ", year )
   out @ calendar( uint( year ))
   out.write( "calendar.htm" )
   shell( "calendar.htm" )
}
