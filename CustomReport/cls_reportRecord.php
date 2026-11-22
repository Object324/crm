<?php

class cls_reportRecord{
    
    
    
    public static function dencrypt($record)
    {
                $straplh=array('a'=>0,'b'=>1,'A'=>2,'E'=>3,'B'=>4,'C'=>5,'c'=>6,'f'=>7,'g'=>8,'H'=>9,'z'=>10,'X'=>11,'Y'=>12);
                  $len=strlen($record);
                   
                  $digit='';
                  for($tmpi=0;$tmpi<$len;$tmpi++)
                  {
                    $tmpalpha=substr($record,$tmpi,1);
                      $digit.=$straplh[$tmpalpha];
                  }
                    
                   $random=substr($digit,-1);
                    $lentmpuserid=substr(substr($digit,-3),0,2)-10;
                    $tmpuserid=substr(substr($digit,-(3+$lentmpuserid)),0,$lentmpuserid);
                    if($tmpuserid/$random!=$_SESSION['authenticated_user_id'])
                    {
                        exit('error');
                    }
                   
                    $record=substr($digit,0, strlen($digit)-$lentmpuserid-3)-$tmpuserid;
                   return $record;
    }
}

?>