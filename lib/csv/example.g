include {
	"csv.g"
}

func ex_csv<main>
{
 	csv src_csv, dest_csv
	uint i

   src_csv.read( "src.csv")
	src_csv.settings( ';', '#', '#' )
   foreach ar, src_csv
   {
		print( "---------------------------------------------\l" )
    	fornum i=0, *ar
		{
			print( ar[i] + "\l" )
		}
		dest_csv.append( ar )
	}
	dest_csv.write( "dest.csv" )	
   print( "Press any key" )
   getch()
} 
/*   str out
   uint i
   fornum i, 1000
   {
      uint k
      str  line = "Line \(i)"
      fornum k, 10
      { 
         if k & 1 : line += ",\"Column, comma \( k )\""
         else : line += ",Column \( k )"
      }
      out += "\(line)\l"
   }
   out.write("test.csv")
   return*/
