#!/usr/bin/bash  
# CSV to HTML 
cat << END
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">  
<html>  
    <head>  
        <title>  
            Information  
        </title>  
    </head>  
  
    <body>  
        <table  BORDER=1 WIDTH='100%'>  
END
  
sed -e 's/,/<\/td><td>/g' -e 's/^/<tr><td>/' -e 's/$/<\/td><\/tr>/'  $1 |sed \
-e 's/<tr><td>time/<TR BGCOLOR=#ccddee><TD>time/' \
-e 's#<td>E</td>#<td BGCOLOR=red align=center><FONT COLOR=white>E</FONT>#g' \
-e 's#<td>S</td>#<td BGCOLOR=green align=center><FONT COLOR=white>S</FONT>#g'
#awk 'BEGIN{FS=":";OFS="</td><td>"} gsub(/^/,"<tr><td>") gsub(/$/,"</td></tr>") {print $1,$2,$3}'  $1
  
cat << END
        </table>  
    </body>  
</html>  
END