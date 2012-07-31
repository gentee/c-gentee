include : $"dbf.g"
//include : $"..\Gentee Language\Libraries\dbf\dbf.g"

func main<main>
{
   dbf  base
   uint i num
   datetime dt
   str  sname sdate
   
   print("0\n")
   base.create( "base.dbf", "ID,N,2,0
                             NAME,C,30,0
                             DATE,D,8,0", 1 )
   print("1\n")
   fornum i, 10
   {
      base.append()
      num = base.recno()
      base.fw_int( num, 1 )   
      base.fw_str("Record \( num )", 2 )   
      dt.gettime()
      base.fw_date( dt, 3 )   
   }                      
   print("---------------\nCount of records = \(*base)\n---------------\n")    
   foreach cur,base
   {
      print("ID = \( base.f_int( 1 ))   Name = \( base.f_str( sname, 2 ))
\#         Date = \( base.f_date( sdate, 3 ))\n")   
   }
   print("Press any key...")
   getch()
   return
}
