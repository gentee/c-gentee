/******************************************************************************
*
* Copyright (C) 2004-2008, The Gentee Group. All rights reserved. 
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
* Id: datetime L "Date & Time"
* 
* Summary: Functions for working with date and time.
* 
* List: *#lng/opers#,datetime_opeq,datetime_opadd,datetime_opsub,datetime_opdif,
         datetime_opsum,datetime_opeqeq,datetime_opless,datetime_opgr,
        *#lng/funcs#,abbrnameofday,days,daysinmonth,firstdayofweek,
        getdateformat,getdatetime,gettimeformat,isleapyear,nameofmonth,
        *#lng/methods#,datetime_dayofweek,datetime_dayofyear,datetime_fromstr,
         datetime_gettime,datetime_getsystime,datetime_normalize,
         datetime_setdate,datetime_tostr,
        *File time functions and operators,filetime_opeq,filetime_opeqeq,
         filetime_opless,filetime_opgr,datetimetoftime,
         ftimetodatetime,getfiledatetime, 
        *#lng/types#,tdatetime,tfiletime
* 
-----------------------------------------------------------------------------*/

define
{
   DT_SAVETIME    = 0x01 // save sec min hour
   DT_SAVEDATE    = 0x02 // save date
   DT_SAVEFULL    = 0x03 
   DT_REVERSE     = 0x10 // обратная запись
}


method str datetime.getstr( uint flags, str ret )
{
   if !flags : flags = 0x0F
   
   ret.clear()
   if flags & $DT_SAVETIME
   {
      if flags & $DT_SAVEDATE || this.hour 
      {
         ret.printf("%02i%02i%02i", %{ this.second, this.minute, this.hour })
      }
      elif this.minute : ret.printf("%02i%02i", %{ this.second, this.minute } )
      else : ret.printf("%02i", %{this.second} ) 
   }
   if flags & $DT_SAVEDATE
   {
/*      if *ret && ( this.year >= 2000 && this.year < 2100 )
      {
         ret.printf("%02i%02i%02i", %{ this.day, this.month, this.year - 2000 })
      }
      else
      {*/
         ret.printf("%02i%02i%04i", %{ this.day, this.month, this.year })
//      }      
   }   
   if flags & $DT_REVERSE
   {
      str  rev
      int i count
      
      count = *ret / 2
      if count == 7 || count == 4
      {
         rev.substr( ret, *ret - 4, 4 )
         count -= 2
      }
      for i = count, i > 0, i--
      {
         uint off = ( i - 1 ) << 1
          
         rev.appendch( ret[ off ])  
         rev.appendch( ret[ off + 1 ])  
      }       
      ret = "R\( rev )"
   }
   return ret
}

/*-----------------------------------------------------------------------------
* Id: datetime_tostr F2
*
* Summary: Convert a datetime structure to string like #b(SSMMHHDDMMYYYY). 
*  
* Params: ret - The result string the datetime to be converted to. 
* 
* Return: #lng/retpar( ret )  
*
-----------------------------------------------------------------------------*/

method str datetime.tostr( str ret )
{
   return this.getstr( $DT_SAVEFULL, ret )
}

method str datetime.tostrrev( str ret )
{
   return this.getstr( $DT_SAVEFULL | $DT_REVERSE, ret )
}

/*-----------------------------------------------------------------------------
* Id: datetime_fromstr F2
*
* Summary: Convert string like #b(SSMMHHDDMMYYYY) to datetime structure. 
*  
* Params: data - The string to be converted. 
* 
* Return: #lng/retobj#  
*
-----------------------------------------------------------------------------*/

method datetime datetime.fromstr( str data )
{
   uint len = *data
   str  stemp  tmp
   uint pdata
   
   mzero( &this, sizeof( datetime ))
   pdata as data
   if data[0] == 'R'
   {
      str  year
      int  i start 
      
      if len == 15 || len == 9
      {
         year.substr( data, 1, 4 )
         start = 4
      }
      for i = len - 1, i > start, i--
      {
         tmp.appendch( data[ i-1 ])  
         tmp.appendch( data[ i-- ])
      } 
      tmp += year
      len = *tmp
      pdata as tmp 
   }
   if len == 8
   {
      this.day = uint( stemp.substr( pdata, 0, 2 ))      
      this.month = uint( stemp.substr( pdata, 2, 2 ))      
      this.year = uint( stemp.substr( pdata, 4, 4 ))
      return this      
   }
   this.second = uint( stemp.substr( pdata, 0, 2 ))      
   if len > 2 : this.minute = uint( stemp.substr( pdata, 2, 2 ))  
   if len > 4 : this.hour = uint( stemp.substr( pdata, 4, 2 ))
   if len > 6
   { 
      this.day = uint( stemp.substr( pdata, 6, 2 ))  
      this.month = uint( stemp.substr( pdata, 8, 2 ))
      if len == 12 : this.year = uint( stemp.substr( pdata, 10, 2 )) + 2000
      else : this.year = uint( stemp.substr( pdata, 10, 4 ))
   }
 
   return this
}

/*-----------------------------------------------------------------------------
* Id: getdatetime F
*
* Summary: Getting date and time as strings. Get date and time in the current
           Windows string format.
*  
* Params: systime - Datetime structure. 
          date - The string for getting the date. It can be 0-&gt;str. 
          time - The string for getting time. It can be 0-&gt;str. 
*
-----------------------------------------------------------------------------*/

func  getdatetime( datetime systime, str date, str time )
{
   if date
   {
      date.setlen( GetDateFormat( 0, 0, systime, 0, date->buf.data, 
                                  date->buf.size ) - 1 )
   }
   if time
   {
      time.setlen( GetTimeFormat( 0, 0, systime, 0, time->buf.data, 
                                  time->buf.size ) - 1 )
   }
}

/*-----------------------------------------------------------------------------
* Id: getdateformat_param D
*
* Summary: Parameters for getdateformat
*
-----------------------------------------------------------------------------
#define dd   0 // Day as a number. 
#define ddd  0 // Weekday as an abbriviation. 
#define dddd 0 // The full name of a weekday. 
#define MM   0 // Month as a number.
#define MMM  0 // Month as an abbreviation. 
#define MMMM 0 // The full name of a month.
#define yy   0 // The last tow digits in a year. 
#define yyyy 0 // Year.

//---------------------------------------------------------------------------*/

/*-----------------------------------------------------------------------------
* Id: getdateformat F
*
* Summary: Get date in the specified format. 
*  
* Params: systime - The variable containing date. 
          format - Date format. It can contain the following values:/
                   $$[getdateformat_param]
          date - The string for getting the date.
* 
* Return: #lng/retpar( date ) 
*
-----------------------------------------------------------------------------*/

func str getdateformat( datetime systime, str format, str date )
{
   date.reserve( 64 )
   return date.setlen( GetDateFormat( 0, 0, systime, format.ptr(), 
                                     date.ptr(), 64 ) - 1 )
}

/*-----------------------------------------------------------------------------
* Id: gettimeformat_param D
*
* Summary: Parameters for gettimeformat
*
-----------------------------------------------------------------------------
#define hh    0 // Hours - 12-hour format. 
#define HH    0 // Hours -24-hour format. 
#define mm    0 // Minutes. 
#define ss    0 // Seconds. 
#define tt    0 // Time marker, such as AM or PM. 

//---------------------------------------------------------------------------*/

/*-----------------------------------------------------------------------------
* Id: gettimeformat F
*
* Summary: Get time in the specified format. 
*  
* Params: systime - The variable containing time. 
          format - Time format. It can contain the following values: / 
                   $$[gettimeformat_param]
          time - The string for getting time. 
* 
* Return: #lng/retpar( time ) 
*
-----------------------------------------------------------------------------*/

func str gettimeformat( datetime systime, str format, str time )
{
   time.reserve( 64 )
   return time.setlen( GetTimeFormat( 0, 0, systime, format.ptr(), 
                                     time.ptr(), 64 ) - 1 )
}

/*-----------------------------------------------------------------------------
* Id: datetime_opeq F4
* 
* Summary: Copying datatime structure.
*  
* Return: The result datetime.
*
-----------------------------------------------------------------------------*/

operator datetime =( datetime left, datetime right )
{
    left.year = right.year
    left.month = right.month
    left.day = right.day
    left.hour = right.hour 
    left.minute = right.minute
    left.second = right.second
    left.msec = right.msec
    return left
}

/*-----------------------------------------------------------------------------
* Id: datetime_opeqeq F4
* 
* Summary: Comparison operations.
*  
* Return: Returns #b(1) if the datetimes are equal. Otherwise, it returns #b(0).
*
-----------------------------------------------------------------------------*/

operator uint ==( datetime left, datetime right )
{
    if left.year != right.year : return 0
    if left.month != right.month : return 0
    if left.day != right.day : return 0
    if left.hour != right.hour : return 0
    if left.minute != right.minute : return 0
    if left.second != right.second : return 0
    if left.msec != right.msec : return 0
    return 1
}

/*-----------------------------------------------------------------------------
* Id: datetime_opeqeq_1 FC
* 
* Summary: Comparison operation.
*  
* Return: Returns #b(0) if the datetimes are equal. Otherwise, it returns #b(1).
*
* Define: operator uint !=( datetime left, datetime right ) 
*
-----------------------------------------------------------------------------*/

/*-----------------------------------------------------------------------------
* Id: datetime_opless F4
* 
* Summary: Comparison operation.
*
* Title: datetime < datetime 
*  
* Return: Returns #b(1) if the first datetime is less than the second one.
          Otherwise, it returns #b(0).
*
-----------------------------------------------------------------------------*/

operator uint <( datetime left, datetime right )
{
    if left.year < right.year : return 1
    if left.year > right.year : return 0
    if left.month < right.month : return 1
    if left.month > right.month : return 0
    if left.day < right.day : return 1
    if left.day > right.day : return 0
    if left.hour < right.hour : return 1
    if left.hour > right.hour : return 0
    if left.minute < right.minute : return 1
    if left.minute > right.minute : return 0
    if left.second < right.second : return 1
    if left.second > right.second : return 0
    if left.msec < right.msec : return 1
    return 0
}

/*-----------------------------------------------------------------------------
* Id: datetime_opless_1 FC
* 
* Summary: Comparison operation.
*  
* Title: datetime <= datetime 
*  
* Return: Returns #b(1) if the first datetime is less or equal the second one.
          Otherwise, it returns #b(0).
*
* Define: operator uint <=( datetime left, datetime right )
*
-----------------------------------------------------------------------------*/

/*-----------------------------------------------------------------------------
* Id: datetime_opgr F4
* 
* Summary: Comparison operation.
*
* Title: datetime > datetime 
*  
* Return: Returns #b(1) if the first datetime is greater than the second one.
          Otherwise, it returns #b(0).
*
-----------------------------------------------------------------------------*/

operator uint >( datetime left, datetime right )
{
    if left.year > right.year : return 1
    if left.year < right.year : return 0
    if left.month > right.month : return 1
    if left.month < right.month : return 0
    if left.day > right.day : return 1
    if left.day < right.day : return 0
    if left.hour > right.hour : return 1
    if left.hour < right.hour : return 0
    if left.minute > right.minute : return 1
    if left.minute < right.minute : return 0
    if left.second > right.second : return 1
    if left.second < right.second : return 0
    if left.msec > right.msec : return 1
    return 0
}

/*-----------------------------------------------------------------------------
* Id: datetime_opgr_1 FC
* 
* Summary: Comparison operation.
*  
* Title: datetime >= datetime 
*  
* Return: Returns #b(1) if the first datetime is greater or equal the second
          one. Otherwise, it returns #b(0).
*
* Define: operator uint >=( datetime left, datetime right )
*
-----------------------------------------------------------------------------*/

/*-----------------------------------------------------------------------------
* Id: isleapyear F
*
* Summary: Leap year check. 
*  
* Params: year - The year being checked.  
* 
* Return: Returns 1 if the year is a leap one and 0 otherwise. 
*
-----------------------------------------------------------------------------*/

func uint  isleapyear( ushort year )
{
   return ?( !( year % 4 ) && ( ( year % 100 ) || !( year % 400 )), 1, 0 )
}

/*-----------------------------------------------------------------------------
* Id: daysinmonth F
*
* Summary: The number of days in a month. Leap years are taken into account 
           for February. 
*  
* Params: year - Year. 
          month - Month. 
* 
* Return: Returns the number of days in the month. 
*
-----------------------------------------------------------------------------*/

func uint  daysinmonth( ushort year, ushort month )
{
   buf   months

   if !month : month = 1
   if month > 12 : month = 12

   months = '\i 31, \( byte( ?( isleapyear( year ), 29, 28))), 31, 30, 31,
             30, 31, 31, 30, 31, 30, 31'
   return uint( months[ month - 1 ] )
}

/*-----------------------------------------------------------------------------
* Id: datetime_dayofyear F3
*
* Summary: Get the number of a particular day in the year.   
*  
* Return: Returns the number of a particular day in the year. 
*
-----------------------------------------------------------------------------*/

method uint datetime.dayofyear
{
   uint  i  result

   fornum i = 1, this.month
   {
      result += daysinmonth( this.year, i )
   }                
   return result + this.day
}

/*-----------------------------------------------------------------------------
* Id: days F
*
* Summary: The number of days between two dates. 
*  
* Params: left - The first date for comparison. 
          right - The second date for comparison.  
* 
* Return: Returns the number of days between two dates. If the first date is
          greater than the second one, the return value will be negative.  
*
-----------------------------------------------------------------------------*/

func int days( datetime left, datetime right )
{
   uint  less great
   int   result
   uint  i
   
   less as left 
   great as right

   if left > right
   {
      less as right
      great as left 
   }   

   for  i = less.year, i < great.year, i++
   {
      result += ?( isleapyear( i ), 366, 365 )
   }
   result -= less.dayofyear()
   result += great.dayofyear()
   
   return ?( left > right, -result, result )
}

/*-----------------------------------------------------------------------------
* Id: datetime_gettime F3
*
* Summary: Getting the current date and time. The weekday is set automatically. 
*  
* Return: #lng/retobj# 
*
-----------------------------------------------------------------------------*/

method datetime datetime.gettime()
{
   GetLocalTime( this )
   return this
}

/*-----------------------------------------------------------------------------
* Id: datetime_getsystime F3
*
* Summary: Getting the current system date and time.
*  
* Return: #lng/retobj# 
*
-----------------------------------------------------------------------------*/

method datetime datetime.getsystime()
{
   GetSystemTime( this )
   return this
}

/*-----------------------------------------------------------------------------
* Id: datetime_dayofweek F3
*
* Summary: Get the weekday. 
*  
* Return: Returns the weekday. 0 is Sunday, 1 is Monday...  
*
-----------------------------------------------------------------------------*/

method uint datetime.dayofweek
{
   datetime curtime
   int  dif
      
   GetLocalTime( curtime )
   dif = days( this, curtime )
   this.dayofweek = ( 7 + curtime.dayofweek - ( dif % 7 )) % 7
   return uint( this.dayofweek )
}

/*-----------------------------------------------------------------------------
* Id: datetime_opadd F4
* 
* Summary: Adding days to a date.
*
* Return: The result datetime.
*
-----------------------------------------------------------------------------*/

operator datetime +=( datetime left, uint next )
{
   uint dif i
   uint curday = left.dayofyear()
   
   while ( dif = ?( isleapyear( left.year ), 366, 365 ) - curday ) < next 
   {
      left.year++
      next -= dif + 1
      left.month = 1
      left.day = 1
      curday = 1
   }
   while ( dif = daysinmonth( left.year, left.month ) - left.day ) < next
   {
      left.month++
      next -= dif + 1
      left.day = 1
   }
   left.day += next
   
   return left
}

/*-----------------------------------------------------------------------------
* Id: datetime_opsub F4
* 
* Summary: Subtracting days from a date.
*
* Return: The result datetime.
*
-----------------------------------------------------------------------------*/

operator datetime -=( datetime left, uint next )
{
   uint dif i
   uint curday = left.dayofyear()
   
   while curday <= next 
   {
      left.year--
      next -= curday
      left.month = 12
      left.day = 31
      curday = ?( isleapyear( left.year ), 366, 365 )
   }
   while left.day <= next
   {
      left.month--
      next -= left.day
      left.day = daysinmonth( left.year, left.month )
   }
   left.day -= next
   
   return left
}

/*-----------------------------------------------------------------------------
* Id: datetime_setdate F2
*
* Summary: Specifying a date. The weekday is set automatically. 
*  
* Params: day - Day. 
          month - Month. 
          year - Year. 
* 
* Return: #lng/retobj#  
*
-----------------------------------------------------------------------------*/

method  datetime  datetime.setdate( uint day, uint month, uint year )
{
   if !year : year = 1
   if year > 0xFFFF : year = 0xFFFF
   this.year = year
   if !month : month = 1
   if month > 12 : month = 12
   this.month = month
   if !day : day = 1
   if day > daysinmonth( year, month ) : day = daysinmonth( year, month )
   this.day = day
   this.dayofweek()   
   
   return this
}

func uint  makelangid( uint primary, uint sublang )
{
   return ( sublang << 10 ) | primary
}

func uint  makelcid( uint langid, uint sortid )
{
  return ( sortid << 16 ) | langid
}

func uint localeuser()
{
   uint langid = makelangid( $LANG_NEUTRAL, $SUBLANG_DEFAULT )
   return makelcid( langid, $SORT_DEFAULT)
}
   
func uint localesystem()
{
   uint langid = makelangid( $LANG_NEUTRAL, $SUBLANG_SYS_DEFAULT )
   return makelcid( langid, $SORT_DEFAULT )
}

/*-----------------------------------------------------------------------------
* Id: nameofmonth F
*
* Summary: Get the name of a month in the user's language. 
*  
* Params: ret - Result string. 
          month - The number of the month from 1. 
* 
* Return: #lng/retpar( ret )  
*
-----------------------------------------------------------------------------*/

func  str nameofmonth( str ret, uint month )
{
   if month > 12 : month = 12
   if !month : month = 1
   ret.reserve( 32 )
   GetLocaleInfo( localeuser(),
                  $LOCALE_SMONTHNAME1 + month - 1,
                  ret.ptr(), 32 )
   
   ret.setlenptr()
   return ret
}

/*-----------------------------------------------------------------------------
* Id: firstdayofweek F1
*
* Summary: Get the first day of a week for the user's locale.  
*  
* Return: Returns the number of the weekday. 0 is Sunday, 1 is Monday...   
*
-----------------------------------------------------------------------------*/

func  uint  firstdayofweek()
{
   str  ret
   
   ret.reserve( 8 )
   GetLocaleInfo( localeuser(),
                  $LOCALE_IFIRSTDAYOFWEEK,
                  ret.ptr(), 8 )
   ret.setlenptr()
   return ( uint( ret ) + 1 ) % 7

}

/*-----------------------------------------------------------------------------
* Id: abbrnameofday F
*
* Summary: Get the short name of a weekday in the user's language.  
*  
* Params: ret - The string for getting the result. 
          dayofweek - The number of the weekday. 0 is Sunday, 1 is Monday... 
*
* Return: #lng/retpar( ret )   
*
-----------------------------------------------------------------------------*/

func  str abbrnameofday( str ret, uint dayofweek )
{
   ret.reserve( 24 )

   dayofweek %= 7
   if !dayofweek : dayofweek = 7

   GetLocaleInfo( localeuser(),
                  $LOCALE_SABBREVDAYNAME1 + dayofweek - 1,
                  ret.ptr(), 24 )
   ret.setlenptr()
   return ret
}

/*-----------------------------------------------------------------------------
* Id: filetime_opeq F4
* 
* Summary: Copying filetime structure.
*  
* Return: The result filetime.
*
-----------------------------------------------------------------------------*/

operator filetime =( filetime left, filetime right )
{
   left.lowdtime = right.lowdtime
   left.highdtime = right.highdtime
   
   return left
}


/*-----------------------------------------------------------------------------
* Id: filetime_opeqeq F4
* 
* Summary: Comparison operations.
*  
* Return: Returns #b(1) if the filetimes are equal. Otherwise, it returns #b(0).
*
-----------------------------------------------------------------------------*/

operator uint ==( filetime left, filetime right )
{
   return !CompareFileTime( left, right )
}

/*-----------------------------------------------------------------------------
* Id: filetime_opeqeq_1 FC
* 
* Summary: Comparison operation.
*  
* Return: Returns #b(0) if the filetimes are equal. Otherwise, it returns #b(1).
*
* Define: operator uint !=( filetime left, filetime right ) 
*
-----------------------------------------------------------------------------*/

/*-----------------------------------------------------------------------------
* Id: filetime_opless F4
* 
* Summary: Comparison operation.
*
* Title: filetime < filetime 
*  
* Return: Returns #b(1) if the first filetime is less than the second one.
          Otherwise, it returns #b(0).
*
-----------------------------------------------------------------------------*/

operator uint <( filetime left, filetime right )
{
   return CompareFileTime( left, right ) < 0
}

/*-----------------------------------------------------------------------------
* Id: filetime_opless_1 FC
* 
* Summary: Comparison operation.
*  
* Title: filetime <= filetime 
*  
* Return: Returns #b(1) if the first filetime is less or equal the second one.
          Otherwise, it returns #b(0).
*
* Define: operator uint <=( filetime left, filetime right )
*
-----------------------------------------------------------------------------*/

/*-----------------------------------------------------------------------------
* Id: filetime_opgr F4
* 
* Summary: Comparison operation.
*
* Title: filetime > filetime 
*  
* Return: Returns #b(1) if the first filetime is greater than the second one.
          Otherwise, it returns #b(0).
*
-----------------------------------------------------------------------------*/

operator uint >( filetime left, filetime right )
{
   return CompareFileTime( left, right ) > 0
}

/*-----------------------------------------------------------------------------
* Id: filetime_opgr_1 FC
* 
* Summary: Comparison operation.
*  
* Title: filetime >= filetime 
*  
* Return: Returns #b(1) if the first filetime is greater or equal the second
          one. Otherwise, it returns #b(0).
*
* Define: operator uint >=( filetime left, filetime right )
*
-----------------------------------------------------------------------------*/

/*-----------------------------------------------------------------------------
* Id: ftimetodatetime F
* 
* Summary: Converting date from filetime into datetime.
*
* Params: ft - A structure of the filetime type. Can be taken from the finfo /
               structure. 
          dt - A datetime structure for getting the result. 
          local - Specify 1 if you need to take the local time into account.  
*   
* Return: #lng/retpar( dt )
*
-----------------------------------------------------------------------------*/

func datetime ftimetodatetime( filetime ft, datetime dt, uint local )
{
   filetime ftime = ft
      
   if local : FileTimeToLocalFileTime( ft, ftime )
   FileTimeToSystemTime( ftime, dt )
   return dt
}

/*-----------------------------------------------------------------------------
* Id: getfiledatetime F
* 
* Summary: Getting date and time as strings. Get the data and time of the last 
           file modification as strings.
*
* Params: ftime - A structure of the filetime type. Can be taken from /
                  the finfo structure. 
          date - The string for writing date. It can be 0-&gt;str. 
          time - The string for writing time. It can be 0-&gt;str. 
*   
-----------------------------------------------------------------------------*/

func  getfiledatetime( filetime ftime, str date, str time )
{
   datetime st
   
   ftimetodatetime( ftime, st, 1 )      
   getdatetime( st, date, time )
}

/*-----------------------------------------------------------------------------
* Id: datetimetoftime F
* 
* Summary: Converting date from datetime into filetime.
*
* Params: dt - Datetime structure. 
          ft - The variable of the filetime type for getting the result.
          local - If it equals 1 then parameter dt is a local time. 
*   
* Return: #lng/retf#
*
-----------------------------------------------------------------------------*/

func uint datetimetoftime( datetime dt, filetime ft, uint local )
{  
   filetime fsystime
   uint ret
   ret = SystemTimeToFileTime( dt, fsystime )
   if local : LocalFileTimeToFileTime( fsystime, ft )
   else : ft = fsystime
   return ret
   //return SystemTimeToFileTime( systime, ft )
}

/*-----------------------------------------------------------------------------
* Id: datetimetoftime F8
* 
* Summary: Converting date from datetime into filetime as local time.
*
* Params: dt - Datetime structure. 
          ft - The variable of the filetime type for getting the result. 
*   
-----------------------------------------------------------------------------*/

func uint datetimetoftime( datetime dt, filetime ft )
{
   return datetimetoftime( dt, ft, 1 )
}

method int short.toint()
{
   int res = this   
   if this & 0x8000
   {
      res = res | 0xFFFF0000   
   } 
   return res
}

/*-----------------------------------------------------------------------------
* Id: datetime_normalize F3
*
* Summary: Normalizing a datetime structure. For example, if the hour parameter is 32 hours, it will equal 8 and the day parameter is increased by 1.
*  
* Return: #lng/retobj#  
*
-----------------------------------------------------------------------------*/

method datetime datetime.normalize()
{
   .second += .msec.toint() / 1000;
   .msec = .msec.toint()  % 1000
   if .msec.toint() < 0
   {      
      .second--
      .msec = 1000 + .msec.toint()
   }
   
   .minute +=  .second.toint() / 60;
   .second = .second.toint() % 60
   if .second.toint() < 0
   {      
      .minute--
      .second = 60 + .second.toint()
   }   
   
   .hour +=  .minute.toint() / 60;
   .minute = .minute.toint() % 60
   if .minute.toint() < 0
   {      
      .hour--
      .minute = 60 + .minute.toint()
   }
   
   .day +=  .hour.toint()  / 24;
   .hour = .hour.toint() % 24 
   if .hour.toint() < 0
   {      
      .day--
      .hour = 24 + .hour.toint()
   }   
   if .year > 1000 
   {      
      .year += ( .month.toint() - 1 )/12;
      .month = ( .month.toint() - 1 ) % 12 + 1
      if .month.toint() < 1
      {      
         .year--
         .month = 12 + .month.toint()
      }
      
      int offdays = .day - daysinmonth( .year, .month )      
      .day = daysinmonth( .year, .month )
      if offdays > 0: this += offdays
      else : this -= -offdays
   }
   return this
}

/*-----------------------------------------------------------------------------
* Id: datetime_opsum F4
* 
* Summary: Adding two dates as days and time. All values are
           positive numbers.
*
* Return: The result datetime.
*
-----------------------------------------------------------------------------*/

operator datetime +<result>( datetime left, datetime right )
{
   uint nonorm
   if right.year.toint() >= 1000 && left.year.toint() >= 1000
   {
      result = left
      return     
   }
      
   result.hour   = left.hour   + right.hour  
   result.minute = left.minute + right.minute 
   result.second = left.second + right.second 
   result.msec   = left.msec   + right.msec
   
   result.year  = left.year  + right.year
   result.month = left.month + right.month
   result.day   = left.day   + right.day
   
   result.normalize()   
   return 
} 

/*-----------------------------------------------------------------------------
* Id: datetime_opdif F4
* 
* Summary: Difference between two dates as days and time. All values are
           positive numbers.
*
* Return: The result datetime.
*
-----------------------------------------------------------------------------*/

operator datetime -<result>( datetime left, datetime right )
{
   uint nonorm
   if right.year.toint() >= 1000 && left.year.toint() < 1000
   {
      result = right
      return     
   }
          
   result.hour   = left.hour   - right.hour  
   result.minute = left.minute - right.minute 
   result.second = left.second - right.second 
   result.msec   = left.msec   - right.msec
   
   result.day = days( right, left )
   /*result.year  = left.year  - right.year
   result.month = left.month - right.month
   result.day   = left.day   - right.day*/
   
   result.normalize()
   return 
}

/*-----------------------------------------------------------------------------
* Id: datetime_opsum_1 FC
* 
* Summary: Adding one datetime to another datetime structure.
*
* Return: The result datetime.
*
-----------------------------------------------------------------------------*/

operator datetime +=( datetime left, datetime right )
{
   return left = left + right
}


/*-----------------------------------------------------------------------------
* Id: datetime_opdif_1 FC
* 
* Summary: Difference between two dates as days and time. All values are
           positive numbers.
*
* Return: The result datetime.
*
-----------------------------------------------------------------------------*/

operator datetime -=( datetime left, datetime right )
{
   return left = left - right
}

/*
operator datetime -<result>( datetime left, datetime right )
{
   uint  dt  shift, xshift  

   dt as left
   result = right

   if left > right
   {
      result = left
      dt as right    
   }
   result.year = 0
   result.month = 0
   result.day = abs( days( left, right ))
   if result.msec < dt.msec
   {
      shift = 1
      result.msec += 1000
   }
   result.msec -= dt.msec
   if result.second < dt.second + shift
   {
      xshift = 1
      result.second += 60
   } 
   result.second -= dt.second + shift
   shift = 0

   if result.minute < dt.minute + xshift
   {
      shift = 1
      result.minute += 60
   } 
   result.minute -= dt.minute + xshift
   xshift = 0
   if result.hour < dt.hour + shift
   {
      xshift = 1
      result.hour += 24
   } 
   result.hour -= dt.hour + shift
   result.day -= xshift

   return //result
}
*/