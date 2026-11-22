<?php
global $current_user;
if($current_user->getHaveSetProfile("Settings")!="yes")
{
    exit();
}
global $adb;
if(!$adb)
{
    exit();
}

$_REQUEST['diony']='yes';
require globalStatic::$root_directory. 'sqlparser/vendor/autoload.php';
set_time_limit(0);

$dbport=$dbconfig['db_port'];
$dbports=explode(':',$dbconfig['db_port']);
if(sizeof($dbports)>1)
{
    $dbport=$dbports[1];
}
/*$mysqli=new mysqli($dbconfig['db_server'],$dbconfig['db_username'],$dbconfig['db_password'],"mysql",$dbport);

if(mysqli_connect_errno())
{
     
     ConvertTojsonString("-1",array(),'数据库连接失败，请检查服务器MySQL数据库是否启动或者联系供应商解决');
      
}
$mysqli->set_charset("utf8");
$mysqli->multi_query("CREATE DATABASE IF NOT EXISTS test DEFAULT CHARSET utf8;");
$mysqli->multi_query(" set global sql_mode=NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION");

$mysqli->close();*/
//$dbconfig['db_name']
$_SESSION['restoredata']='yes';

$mysqli=new mysqli($dbconfig['db_server'],$dbconfig['db_username'],$dbconfig['db_password'],$dbconfig['db_name'],$dbport);
$mysqli->multi_query("SET FOREIGN_KEY_CHECKS=0;");
$mysqli->set_charset("utf8");
//$mysqli->multi_query("CREATE DATABASE IF NOT EXISTS test DEFAULT CHARSET utf8;");
$mysqli->multi_query(" set global sql_mode=NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION");


if(mysqli_connect_errno())
{
    
     ConvertTojsonString("-1",array(),'数据库连接失败，请检查服务器MySQL数据库是否启动或者联系供应商解决');
      
}







$filelog=fopen(globalStatic::$root_directory.'restoreupdatelog.txt','w+');

$dvwidth=1;
if(!is_numeric($_REQUEST['restoreid']))
{
    ConvertTojsonString("-1",array(),'id参数错误');
}
$query = "select * from ld_industrydemo where id = ".$_REQUEST['restoreid'];
$result=$mysqli->query($query);
$templatefile_path='';

if($result)
    $rows=$result->fetch_array();
if($rows>0)
{
    $datasql_path =$rows['datasql_path']; 
    $templatefile_path=$rows['templatefile_path'];
    $_SESSION['restorefilename']=$datasql_path;
    $_SESSION['restoretemplatefile_path']=$templatefile_path;
}
else if($_SESSION['restorefilename'])
{
    $datasql_path=$_SESSION['restorefilename'];
    $templatefile_path=$_SESSION['restoretemplatefile_path'];
}
else

    $datasql_path='002_it.sql';
 
$serverself=$_SERVER['PHP_SELF'];
$http_host=$_SERVER['HTTP_HOST'];

if(strpos($http_host,"http://")!==false&&strpos($http_host,"http://")<=5)
{
    $http_host=substr($http_host,strlen("http://"));
    
}
if(strpos($http_host,"https://")!==false&&strpos($http_host,"https://")<=5)
{
    $http_host=substr($http_host,strlen("https://"));
    
}


if(strpos($http_host,"www.")!==false&&strpos($http_host,"www.")<=5)
{
    $http_host=substr($http_host,strlen("www."));
    
}

$http_host=trim($http_host);
        
global $global_dnsname,$global_ips;
if(file_exists(globalStatic::$root_directory."globalConfig/global_saascrm_config.php"))
    require_once(globalStatic::$root_directory."globalConfig/global_saascrm_config.php");

 $datasql_path_arr=explode("/",$datasql_path);
 $filename= $datasql_path_arr[sizeof($datasql_path_arr)-1];
 
 $isrentserver='no';   
 $rentserverpath='';      
if( in_array($http_host,$global_dnsname)||in_array($http_host,$global_ips)||strtolower($http_host)=='kehu001.com')
{
    $isrentserver='yes';
    $rentserverpath=__DIR__;
    $tmpi=0;
    while(true&&$tmpi<20)
    {
        if(file_exists($rentserverpath.'/IndustryDemo/'.$filename))
        {
            break;
        }
        $rentserverpath=dirname($rentserverpath);
      
        if(empty($rentserverpath))
        {
            break;
        }
        $tmpi++;
    }
   
    if(!file_exists($rentserverpath.'/IndustryDemo/'.$filename))
    {
        ConvertTojsonString("-1",array(),'行业账套不存在，请联系供应商!');
        
    }
    $content=file_get_contents($rentserverpath.'/IndustryDemo/'.$filename);
}
else
    $content=file_get_contents(globalStatic::$root_directory.'sql/IndustryDemo/'.$filename);
//$content=file_get_contents(globalStatic::$root_directory.'sql/IndustryDemo/003.sql');
$content = str_replace([";\r\n", ";\r"], ";\n", $content);
   
$arr = explode(";\n", $content);
$totalLine=sizeof($arr);  //总共需要执行脚本数目
$i=0;

ignore_user_abort(true);
$startrow=$_REQUEST['startrow'];
$endtime=0;
$line=$startrow;
$inserintotable='';
$deletetable='';
for($i=$startrow;$i<$totalLine;$i++)
{  
   
    
   
    $sql=trim($arr[$i]);
    $line++;
    file_put_contents(globalStatic::$root_directory.'modules/Settings/a.txt',$i."aaa\r\n",FILE_APPEND);
    $endtime++;
   
    if($endtime>=10)
    { 
       if($deletetable=='ld_users'&&$inserintotable!='ld_users')
       {
        
       }
       else
        break;
    }
    
    
  
    if(empty($sql))
    {
        continue;
    }
    $parser = new PhpMyAdmin\SqlParser\Parser($sql);
    
    if(sizeof($parser->statements)<=0)
    {
        continue;
    }
    $iscreatetable='no';
    if($parser->statements[0] instanceof  PhpMyAdmin\SqlParser\Statements\CreateStatement)
    {
        if(strtolower($parser->statements[0]->options->options[6])=="table")
        {
            $iscreatetable='yes';
          
        }
        if(strtolower($parser->statements[0]->options->options[6])=="view")
        {
            $iscreatetable='yes';
        }
        
        
    }
   
  if($parser->statements[0] instanceof  PhpMyAdmin\SqlParser\Statements\InsertStatement)
  {
        $inserintotable=$parser->statements[0]->into->dest->table;
  }
  
   if($iscreatetable=='no'&&$parser->statements[0] instanceof  PhpMyAdmin\SqlParser\Statements\CreateStatement)//存储过程
   {
        $isend='no';
        if(substr(trim($sql),-1)==';')
        {
            
        }
        else
            $sql.=";";
        if($parser->statements[0]->options&&$parser->statements[0]->options->options)
        {
            if(array_key_exists('6',$parser->statements[0]->options->options))
            {
                if(strtolower($parser->statements[0]->options->options[6])=='event')
                {
                    $ret=$mysqli->multi_query($sql);
                    if( mysqli_error($mysqli))
                    {
                        
                        
                         
                        ignore_user_abort(false); 
                        
                         fwrite($filelog,"\r\n");
                         fwrite($filelog,$sql1);
                         fwrite($filelog, mysqli_error($mysqli));
                         fclose($filelog);
                         
                       
                    } 
                    else
                    {
                            while(@$mysqli->next_result())
                            { 
                               // exit('f');
                                   $result=$mysqli->store_result();
                                    if($result)
                                    $result->close();
                            }
        
                    }
                    continue;
                }
            }
        }    
        while(true&&$i<$totalLine)
        {
            $i++;
             $line++;
            $tmpsql=$arr[$i];
        
           
             if(stripos($tmpsql,"end")!==false)
             {
                $isend='yes';
             }
            if(stripos($tmpsql,"delimiter")!==false&&$isend)
            {
              
                break;
            }
            
            if (preg_match("/^(#|--)/", $sql)) {
                    continue;
            }
            $sql.=$tmpsql.';';
            
           
            
           
        }
       
    
         $sql1=$sql;
          if(empty($sql1))
          {
            continue;
          }
        
            $ret=$mysqli->multi_query($sql1);
        
         if( mysqli_error($mysqli))
            {
            
                 ignore_user_abort(false); 
                
                 fwrite($filelog,"\r\n");
                 fwrite($filelog,$sql1);
                 fwrite($filelog, mysqli_error($mysqli));
                 fclose($filelog);
                 
               
            } 
            else
            {
                    while(@$mysqli->next_result())
                    { 
                       // exit('f');
                           $result=$mysqli->store_result();
                            if($result)
                            $result->close();
                    }

            } 
      
   }
   else if($parser->statements[0] instanceof PhpMyAdmin\SqlParser\Statements\SetStatement)
   {
   }
   else if($parser->statements[0] instanceof PhpMyAdmin\SqlParser\Statements\DropStatement)
   {
        //删除 表
        $deletetable=$parser->statements[0]->fields[0]->table;
        
         $sql = str_replace(["\r\n", "\r"], "\n", $sql);
         
         $sql_arr = explode("\n", $sql);
        
         foreach($sql_arr as $sql)
         {
            if(empty($sql))
            {
                continue;
            }
            
             if (preg_match("/^(#|--)/", $sql)&&sizeof($sql_arr)>1) {
                    continue;
                }
                $ret= $mysqli->multi_query($sql);
                
                if(@$mysqli->more_results())
                    {
                        while(@$mysqli->next_result())
                        {
                             // exit('d');
                               $result=$mysqli->store_result();
                                if($result)
                                $result->close();
                        }
                    }
                    else
                    {
                         $result=$mysqli->store_result();
                         if($reuslt)
                         {
                            while($result->fetch_row())
                            {
                               // exit('a');
                            }
                         }
                        
                    }
         }
        
   }
   else
   {
            
             if (preg_match("/^(#|--)/", $sql)) {
                   
                   $sql = str_replace(["\r\n", "\r"], "\n", $sql);
                     
                     $sql_arr = explode("\n", $sql);
                    
                     foreach($sql_arr as $sql)
                     {
                        if(empty($sql))
                        {
                            continue;
                        }
                         if (preg_match("/^(#|--)/", $sql)) {
                                continue;
                            }
                            $ret= $mysqli->multi_query($sql);
                            if(@$mysqli->more_results())
                                {
                                    while(@$mysqli->next_result())
                                    {
                                         // exit('d');
                                           $result=$mysqli->store_result();
                                            if($result)
                                            $result->close();
                                    }
                                }
                                else
                                {
                                     $result=$mysqli->store_result();
                                     if($reuslt)
                                     {
                                        while($result->fetch_row())
                                        {
                                           // exit('a');
                                        }
                                     }
                                    
                                }
                     }
                    continue;
                }
            $ret= $mysqli->multi_query($sql);
          
            if(mysqli_error($mysqli))
            {
            
                fwrite($filelog,"\r\n");
                fwrite($filelog,$sql);
                fwrite($filelog,mysqli_error($mysqli));

                fclose($filelog);
            
                
            }
            else
            {
                if(@$mysqli->more_results())
                    {
                        while(@$mysqli->next_result())
                        {
                              //exit('c');
                               $result=$mysqli->store_result();
                                if($result)
                                $result->close();
                        }
                    }
                    else
                    {
                         $result=$mysqli->store_result();
                         if($reuslt)
                         {
                            while($result->fetch_row())
                            {
                                //exit('b');
                            }
                         }
                        
                    }
                    if(strtolower($parser->statements[0]->options->options[6])=="table")
                    {
                        $iscreatetable='yes';
                       
                      
                    }
                   
            } 
        
        
 
   }
   
}  
       
      
         
if($i<$totalLine)
{
    ignore_user_abort(false);
    $mysqli->close();
    ConvertTojsonString(1,array("nextstartrow"=>$line-1,'totalline'=>$totalLine,'finished'=>'no'),'success');
}

$demodata='yes';
if($_REQUEST['chooserestoretype']=='withoutdemodata')
{
        //删除演示数据
        $demodata='no';
       $sql= file_get_contents(globalStatic::$root_directory.'sql/InitializationScript/CleanData.sql');
     //  $sql= html_entity_decode($sql, ENT_QUOTES, $default_charset);
     $sql=str_replace(["DELIMITER ;",'delimiter ;',"DELIMITER;"],'delimiter;',$sql);
     $sql=str_replace(["end ;;",'END ;;',"end;;"],'end;',$sql);
       $sql_arr=explode("delimiter;",$sql);
   
       $linecount=sizeof($sql_arr);
       $i=0;
     
       while($i<$linecount&&$i<20)
       {
            $sql=$sql_arr[$i];
          
           
              $parser = new PhpMyAdmin\SqlParser\Parser($sql);
                if(sizeof($parser->statements)<=0)
                {
                    $i++;
                    continue;
                }
                $iscreatetable='no';
                if($parser->statements[0] instanceof  PhpMyAdmin\SqlParser\Statements\CreateStatement)
                {
                        $sql = str_replace([";\r\n", ";\r"], ";\n", $sql);
       
                        $tmpsql_arr = explode(";\n", $sql);
                        $sql='';
                        foreach($tmpsql_arr as $tmpsql)
                        {
                            if(trim($tmpsql)=='')
                            continue;
                            $sql.=$tmpsql.';';
                        }
                          
                }
             
                
                  $ret= $mysqli->multi_query($sql);
            
                if(@$mysqli->more_results())
                {
                    while(@$mysqli->next_result())
                    {
                          //exit('c');
                           $result=$mysqli->store_result();
                            if($result)
                            $result->close();
                    }
                }
                else
                {
                     $result=$mysqli->store_result();
                     if($reuslt)
                     {
                        while($result->fetch_row())
                        {
                            
                        }
                     }
                    
                }
         
            $i++;
            
       }
       
    }   

ignore_user_abort(false);

clearAllCaCheFiles();//清除緩存
if(!empty($templatefile_path))
{
    //拷贝打印模板
    if($isrentserver=='no')
        restoredir_copy(globalStatic::$root_directory.'sql/'.$templatefile_path,globalStatic::$root_directory);
    else
        restoredir_copy($rentserverpath.'/'.$templatefile_path,globalStatic::$root_directory);
}
$user_name=$current_user->user_name;

$sql='CREATE TABLE if not exists `ld_industryhistory` (
  `id` int(19) NOT NULL AUTO_INCREMENT,
  `user_name` varchar(50) DEFAULT NULL,
  `createdtime` datetime DEFAULT NULL,
  `datasql_path` varchar(100) DEFAULT NULL,
  `demodata` varchar(20) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;';
$mysqli->multi_query($sql);
if(@$mysqli->more_results())
{
    while(@$mysqli->next_result())
    {
         
           $result=$mysqli->store_result();
            if($result)
            $result->close();
    }
}
else
{
     $result=$mysqli->store_result();
     if($reuslt)
     {
        while($result->fetch_row())
        {
          
        }
     }
    
}

$sql="call AddColumn('ld_loginhistory','login_check','varchar',30,NULL);";
$mysqli->multi_query($sql);
if(@$mysqli->more_results())
{
    while(@$mysqli->next_result())
    {
         
           $result=$mysqli->store_result();
            if($result)
            $result->close();
    }
}
else
{
     $result=$mysqli->store_result();
     if($reuslt)
     {
        while($result->fetch_row())
        {
          
        }
     }
    
}

$sql=" insert into ld_industryhistory(user_name,createdtime,datasql_path,demodata)value('$user_name',now(),'$datasql_path','$demodata')";
$mysqli->multi_query($sql);
$mysqli->close();
ConvertTojsonString(1,array("nextstartrow"=>$line,'totaline'=>$totalLine,'finished'=>'yes'),'success');

function restoredir_copy($src = '', $dst = '')
{
    global $i;
    
    if (empty($src) || empty($dst))
    {
        return false;
    }
 
    $dir = opendir($src);
    $str=substr($dst,'-1');
    if($str=='/'||$str=='\\')
    {
     
        $dst=substr($dst,0,strlen($dst)-1);
    }
  
  
  
    while (false !== ($file = readdir($dir)))
    {
        $i++;
        if($i>1000)
        {
            break;
        }
        if (($file != '.') && ($file != '..'))
        {
          
            if (is_dir($src . '/' . $file))
            {
                restoredir_copy($src . '/' . $file, $dst. '/' . $file );
            }
            else
            {
                
                copy($src . '/' . $file, $dst . '/' . $file);
            }
        }
    }
    closedir($dir);
 
    return true;
}
?>

