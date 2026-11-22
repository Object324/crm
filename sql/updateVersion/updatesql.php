<?php

set_time_limit(0);
$dbport=$dbconfig['db_port'];
$dbports=explode(':',$dbconfig['db_port']);
$filedirectory="sql/updateVersion/";

if(sizeof($dbports)>1)
{
    $dbport=$dbports[1];
}
$mysqli=new mysqli($dbconfig['db_server'],$dbconfig['db_username'],$dbconfig['db_password'],$dbconfig['db_name'],$dbport);

if(mysqli_connect_errno())
{
      $filehandle=fopen('dataCache/sqlhandlers/update1.txt','w+');
      $update=2;
      fwrite($filehandle,$update);
      fclose($filehandle);
      echo '<script>alert("数据库连接失败，请检查服务器MySQL数据库是否启动或者联系供应商解决！")</script>';
    exit();
    
}

$mysqli->set_charset("utf8");
$regop=RegOp::getInstance();
$havelangague=$regop->isEnorZh();
$testFile=$regop->isExistFile();

if($testFile==0)//注册文件不存在
{
    require_once("VersionType.php");
    global $VersionNo;
    $RegisterVersionNo=$VersionNo;
}
else
{
    $RegisterVersionNo=$regop->GetVersionNo();
}

$code=false;

$query = "select linkurl from ld_links where linktype = 'updateversion' and linklabel = 'updatewaresql'";
$result=$mysqli->query($query);
$rows=$result->fetch_array();
$linkurl =$rows['linkurl']; 

global $dbversion;
$line=0;//当前正在执行的脚本行号

$updatevesions=array(
    0=>'V2.01',
    1=>'V2.02',
    2=>'V2.1',
    3=>'V2.2',
    4=>'V3.0',
    5=>'V3.1',
    6=>'V5.2',
    7=>'V5.3',
    8=>'V5.3.1',
    9=>'V5.3.2',
    10=>'V5.3.3',
    11=>'V5.4',
    12=>'V5.4.1',
    13=>'V5.5',
    14=>'V5.5.1',
    15=>'V5.6.0',
    16=>'V5.6.1',
    17=>'V5.7.0',
    18=>'V5.8.0',
    19=>'V5.8.1',
    20=>'V5.9.0',
    21=>'V5.9.1',
    22=>'V5.9.2',
    23=>'V6.0.0',
    24=>'V6.1.0',
    25=>'V6.1.1',
    26=>'V6.1.2',
    27=>'V6.1.3',
    28=>'V6.1.4',
    29=>'V6.1.5',
    30=>'V6.1.6',
    31=>'V6.1.7',
    32=>'V6.1.8',
    33=>'V6.1.9',
    34=>'V6.2.0',
    35=>'V6.2.1',
    36=>'V6.2.2');
    array_push($updatevesions,"V6.3.0");
    array_push($updatevesions,"V6.3.1");
    array_push($updatevesions,"V6.3.2");
    array_push($updatevesions,"V6.3.3");
    array_push($updatevesions,"V6.3.4");
    array_push($updatevesions,"V6.3.5");
    array_push($updatevesions,"V6.3.6");
    array_push($updatevesions,"V6.3.7");
    array_push($updatevesions,"V6.4.0");
    array_push($updatevesions,"V6.4.1");
    array_push($updatevesions,"V6.4.2");
    array_push($updatevesions,"V6.4.3");
    array_push($updatevesions,"V6.4.4");
    array_push($updatevesions,"V6.4.5");
    array_push($updatevesions,"V6.5.0");
    array_push($updatevesions,"V6.5.1");
    array_push($updatevesions,"V6.5.2");
    array_push($updatevesions,"V6.5.3");
    array_push($updatevesions,"V6.5.4");
    array_push($updatevesions,"V6.5.5");
    array_push($updatevesions,"V6.6.0");
    array_push($updatevesions,"V6.6.1");
    array_push($updatevesions,"V6.6.2");
    array_push($updatevesions,"V6.6.3");
    array_push($updatevesions,"V6.6.4");   
    array_push($updatevesions,"V6.6.5");
    array_push($updatevesions,"V6.6.6");
    array_push($updatevesions,"V6.6.7");
    array_push($updatevesions,"V6.6.8"); 
    array_push($updatevesions,"V6.7.0"); 
    array_push($updatevesions,"V7.0.0"); 
    array_push($updatevesions,"V7.0.1"); 
    array_push($updatevesions,"V7.0.2"); 
    array_push($updatevesions,"V7.0.3");
    array_push($updatevesions,"V7.0.4");  
    array_push($updatevesions,"V7.0.5"); 
    array_push($updatevesions,"V7.0.6");
    array_push($updatevesions,"V7.0.7");  
    array_push($updatevesions,"V7.0.8");    
    array_push($updatevesions,"V7.0.9");
    array_push($updatevesions,"V7.0.91");
    array_push($updatevesions,"V7.0.92");   
    array_push($updatevesions,"V7.1.0");  
    array_push($updatevesions,"V7.1.1");  
    array_push($updatevesions,"V7.1.2"); 
    array_push($updatevesions,"V7.1.3");  
    array_push($updatevesions,"V7.1.4");
    array_push($updatevesions,"V7.1.5");
    array_push($updatevesions,"V7.1.6");
    array_push($updatevesions,"V7.1.7"); 
    array_push($updatevesions,"V7.1.8");
    array_push($updatevesions,"V7.1.9");
    array_push($updatevesions,"V7.2.0");
    array_push($updatevesions,"V7.2.1");
    array_push($updatevesions,"V7.2.2");
    array_push($updatevesions,"V7.2.3");
    array_push($updatevesions,"V7.2.4");
    array_push($updatevesions,"V7.2.5");
    array_push($updatevesions,"V7.2.6");
    array_push($updatevesions,"V7.2.7");
    array_push($updatevesions,"V7.2.8");
    array_push($updatevesions,"V7.2.9");
    array_push($updatevesions,"V7.3.0");
    array_push($updatevesions,"V7.3.1");
    array_push($updatevesions,"V7.3.2");
    array_push($updatevesions,"V7.3.3");
    array_push($updatevesions,"V7.3.4");
    array_push($updatevesions,"V7.3.5");
    array_push($updatevesions,"V7.3.6");
    array_push($updatevesions,"V7.3.9");
    array_push($updatevesions,"V7.4.0");
    array_push($updatevesions,"V7.4.1");
    array_push($updatevesions,"V7.4.2");
    array_push($updatevesions,"V7.4.3");
    array_push($updatevesions,"V7.4.6");
    array_push($updatevesions,"V7.4.7");
    array_push($updatevesions,"V7.4.8");
    array_push($updatevesions,"V7.4.9");
    array_push($updatevesions,"V7.5.0");
    array_push($updatevesions,"V7.5.1");
    array_push($updatevesions,"V7.5.3");
    array_push($updatevesions,"V7.5.4");
    array_push($updatevesions,"V7.5.5");
    array_push($updatevesions,"V7.5.5.1");
    array_push($updatevesions,"V7.5.5.5");
    array_push($updatevesions,"V7.5.6");
    array_push($updatevesions,"V7.5.7");
    array_push($updatevesions,"V7.5.8");
    array_push($updatevesions,"V7.5.9");
    array_push($updatevesions,"V7.6.0");
    array_push($updatevesions,"V7.6.1");
	array_push($updatevesions,"V7.6.2");
    array_push($updatevesions,"V7.6.3");
    array_push($updatevesions,"V7.6.4");
    array_push($updatevesions,"V7.6.5");
    array_push($updatevesions,"V7.6.6");
    array_push($updatevesions,"V7.6.7");
    array_push($updatevesions,"V7.6.8");
    array_push($updatevesions,"V7.6.9");
    array_push($updatevesions,"V7.7.0");
    array_push($updatevesions,"V7.7.1");
    array_push($updatevesions,"V7.7.2");
    array_push($updatevesions,"V7.7.3");
    array_push($updatevesions,"V7.7.4");
    array_push($updatevesions,"V7.7.5");
    array_push($updatevesions,"V7.7.6");
    array_push($updatevesions,"V7.7.7");
    array_push($updatevesions,"V7.7.8");
    array_push($updatevesions,"V7.7.9");
    array_push($updatevesions,"V7.8.0");
    array_push($updatevesions,"V7.8.1");
    array_push($updatevesions,"V7.8.1.1");
    array_push($updatevesions,"V7.8.1.2");
    array_push($updatevesions,"V7.8.1.3");
    array_push($updatevesions,"V7.8.2");
    array_push($updatevesions,"V7.8.3");
    array_push($updatevesions,"V7.8.4");
    array_push($updatevesions,"V7.8.5");
    array_push($updatevesions,"V7.8.6");
    array_push($updatevesions,"V7.8.7");
    array_push($updatevesions,"V7.8.8");
    array_push($updatevesions,"V7.8.9");
    array_push($updatevesions,"V7.9.0");
    array_push($updatevesions,"V7.9.1");
    array_push($updatevesions,"V7.9.2");
    array_push($updatevesions,"V7.9.3");
    array_push($updatevesions,"V7.9.4"); 
    array_push($updatevesions,"V7.9.5"); 
    array_push($updatevesions,"V7.9.6");
    array_push($updatevesions,"V7.9.7");
    array_push($updatevesions,"V7.9.8");
    array_push($updatevesions,"V7.9.9");
    array_push($updatevesions,"V7.9.9.1");
    array_push($updatevesions,"V7.9.9.3");
    array_push($updatevesions,"V7.9.9.5");
    array_push($updatevesions,"V7.9.9.6");
    array_push($updatevesions,"V7.9.9.7");
    array_push($updatevesions,"V7.9.9.8");
    array_push($updatevesions,"V7.9.9.9");
    array_push($updatevesions,"V7.9.9.10");
    array_push($updatevesions,"V7.9.9.11");         
    array_push($updatevesions,"V7.9.9.12");
    array_push($updatevesions,"V7.9.9.13");
    array_push($updatevesions,"V7.9.9.14");
    array_push($updatevesions,"V7.9.9.15");
    array_push($updatevesions,"V7.9.9.16");
    array_push($updatevesions,"V7.9.9.17");
    array_push($updatevesions,"V8.0.0");
    array_push($updatevesions,"V8.0.0.1");
    array_push($updatevesions,"V8.0.0.2");
    array_push($updatevesions,"V8.0.0.3");
    array_push($updatevesions,"V8.0.0.4");
    array_push($updatevesions,"V8.0.0.5");
    array_push($updatevesions,"V8.0.0.6");
    array_push($updatevesions,"V8.0.0.7");
    array_push($updatevesions,"V8.0.0.8");
    array_push($updatevesions,"V8.0.0.9");
    array_push($updatevesions,"V8.0.0.10");
    array_push($updatevesions,"V8.0.0.11");
    array_push($updatevesions,"V8.0.0.12");
    array_push($updatevesions,"V8.0.1");
    array_push($updatevesions,"V8.0.2");
    array_push($updatevesions,"V8.0.3");
    array_push($updatevesions,"V8.0.4");
    array_push($updatevesions,"V8.0.5");
    array_push($updatevesions,"V8.0.6");
    array_push($updatevesions,"V8.0.7");
    array_push($updatevesions,"V8.0.8");
    array_push($updatevesions,"V8.0.9");
    array_push($updatevesions,"V8.1.0");
    array_push($updatevesions,"V8.1.1");
    array_push($updatevesions,"V8.1.2");
    array_push($updatevesions,"V8.1.3");
    array_push($updatevesions,"V8.1.4");
    array_push($updatevesions,"V8.1.5");
    array_push($updatevesions,"V8.1.6");
    array_push($updatevesions,"V8.1.7");
    array_push($updatevesions,"V8.1.8");
    array_push($updatevesions,"V8.1.9");
    array_push($updatevesions,"V8.2.0");
    array_push($updatevesions,"V8.2.1");
    array_push($updatevesions,"V8.2.2");
    array_push($updatevesions,"V8.2.3");
    array_push($updatevesions,"V8.2.4");
    array_push($updatevesions,"V8.2.5");
    array_push($updatevesions,"V8.2.6");
    array_push($updatevesions,"V8.2.7");
    array_push($updatevesions,"V8.2.8");
    array_push($updatevesions,"V8.2.9");
    array_push($updatevesions,"V8.3.0");
    array_push($updatevesions,"V8.3.1");
    array_push($updatevesions,"V8.3.1.1");
    array_push($updatevesions,"V8.3.1.2");
    array_push($updatevesions,"V8.3.2");
    array_push($updatevesions,"V8.3.3");
    array_push($updatevesions,"V8.3.4");
    array_push($updatevesions,"V8.3.5");
    array_push($updatevesions,"V8.3.6");
    array_push($updatevesions,"V8.3.7");
    array_push($updatevesions,"V8.3.7.1");
    array_push($updatevesions,"V8.3.7.2");
    array_push($updatevesions,"V8.3.7.3");
    array_push($updatevesions,"V8.3.7.4");
    array_push($updatevesions,"V8.3.7.5");
    array_push($updatevesions,"V8.3.7.6");
    array_push($updatevesions,"V8.3.8");
    array_push($updatevesions,"V8.3.9");
    array_push($updatevesions,"V8.4.0");
    array_push($updatevesions,"V8.4.1");
    array_push($updatevesions,"V8.4.2.0");
    array_push($updatevesions,"V8.4.2.1");
    array_push($updatevesions,"V8.4.2.2");
    array_push($updatevesions,"V8.4.2.3");
    array_push($updatevesions,"V8.4.2.4");
    array_push($updatevesions,"V8.4.2.5");
    array_push($updatevesions,"V8.4.2.6");
    array_push($updatevesions,"V8.4.2.7");
    array_push($updatevesions,"V8.4.2.8");
    array_push($updatevesions,"V8.4.2.9");
    array_push($updatevesions,"V8.4.3.0");
    array_push($updatevesions,"V8.4.3.1");
    array_push($updatevesions,"V8.4.3.2");
    array_push($updatevesions,"V8.4.3.4");
    array_push($updatevesions,"V8.4.3.5");
    array_push($updatevesions,"V8.4.3.6");
    array_push($updatevesions,"V8.4.3.7");
    array_push($updatevesions,"V8.4.3.8");
    array_push($updatevesions,"V8.4.3.9");
    array_push($updatevesions,"V8.4.4.0");
    array_push($updatevesions,"V8.4.4.1");
    array_push($updatevesions,"V8.4.4.2");
    array_push($updatevesions,"V8.4.4.3");
    array_push($updatevesions,"V8.4.4.4");
    array_push($updatevesions,"V8.4.5.0");
    array_push($updatevesions,"V8.4.5.1");
    array_push($updatevesions,"V8.4.5.2");
    array_push($updatevesions,"V8.4.5.3");
    array_push($updatevesions,"V8.4.5.4");
    array_push($updatevesions,"V8.4.5.5");
    array_push($updatevesions,"V8.4.5.5.1");
    array_push($updatevesions,"V8.4.5.6");
    array_push($updatevesions,"V8.4.5.7");
    array_push($updatevesions,"V8.4.5.8");
    array_push($updatevesions,"V8.4.5.8.1");
    array_push($updatevesions,"V8.4.5.8.2");
    array_push($updatevesions,"V8.4.5.8.3");
	array_push($updatevesions,"V8.4.5.8.4");
	array_push($updatevesions,"V8.4.5.8.5");
	array_push($updatevesions,"V8.4.5.8.6");
	array_push($updatevesions,"V8.4.5.9");
	array_push($updatevesions,"V8.4.6.0");
	array_push($updatevesions,"V8.4.6.1");
	array_push($updatevesions,"V8.4.6.2");
	array_push($updatevesions,"V8.4.6.3");
	array_push($updatevesions,"V8.4.6.4");
	array_push($updatevesions,"V8.4.6.5");
	array_push($updatevesions,"V8.4.6.6");
	array_push($updatevesions,"V8.4.6.6.1");
	array_push($updatevesions,"V8.4.6.6.2");
	array_push($updatevesions,"V8.4.6.6.3");
	array_push($updatevesions,"V8.4.6.6.4");
	array_push($updatevesions,"V8.4.6.6.5");
	array_push($updatevesions,"V8.4.6.6.6");
	array_push($updatevesions,"V8.4.6.6.7");
	array_push($updatevesions,"V8.4.6.6.8");
	array_push($updatevesions,"V8.4.6.6.9");
	array_push($updatevesions,"V8.4.6.6.10");
	array_push($updatevesions,"V8.4.7.0");
	array_push($updatevesions,"V8.4.7.1");
	array_push($updatevesions,"V8.4.7.2");
	array_push($updatevesions,"V8.4.7.3");
	array_push($updatevesions,"V8.4.7.4");
	array_push($updatevesions,"V8.4.7.5");
	array_push($updatevesions,"V8.4.7.6");
	array_push($updatevesions,"V8.4.7.7");
	array_push($updatevesions,"V8.4.7.8");
	array_push($updatevesions,"V8.4.7.9");
	array_push($updatevesions,"V8.4.8.0","V8.4.8.1","V8.4.8.2","V8.4.8.3","V8.4.8.4","V8.4.8.5","V8.4.8.6","V8.4.8.7","V8.4.8.8","V8.4.8.9","V8.4.9.0","V8.4.9.1","V8.4.9.2","V8.4.9.3");
	array_push($updatevesions,"V8.4.9.4","V8.4.9.5","V8.4.9.6","V8.4.9.7","V8.4.9.8","V8.4.9.9","V8.5.0.0","V8.5.0.1","V8.5.0.2","V8.5.0.3","V8.5.0.4","V8.5.0.5","V8.5.0.6","V8.5.0.7");
	array_push($updatevesions,"V8.6.0.0","V8.6.0.1","V8.6.0.2","V8.6.0.3","V8.6.0.4","V8.6.0.5","V8.6.0.6","V8.6.0.7","V8.6.0.8","V8.6.0.9","V8.6.1.0");
	array_push($updatevesions,"V8.6.1.1","V8.6.1.2","V8.6.1.3","V8.6.1.4","V8.6.1.5","V8.6.1.6","V8.6.1.7","V8.6.1.8","V8.6.1.9");
	array_push($updatevesions,"V8.6.2.0","V8.6.2.1","V8.6.2.2","V8.6.2.3","V8.6.2.4","V8.6.2.5","V8.6.2.6","V8.6.2.7","V8.6.2.8","V8.6.2.9","V8.6.3.0","V8.6.3.1","V8.6.3.2");
	array_push($updatevesions,"V8.6.3.3","V8.6.3.3.1","V8.6.3.3.2","V8.6.3.3.3","V8.6.3.3.4","V8.6.3.3.5","V8.6.3.3.6","V8.6.3.3.7","V8.6.3.3.8","V8.6.3.3.9","V8.6.3.3.10");
	array_push($updatevesions,"V8.6.3.3.11","V8.6.3.3.12","V8.6.3.3.13","V8.6.3.3.14","V8.6.3.3.15","V8.6.3.3.16");
	array_push($updatevesions,"V8.6.3.4","V8.6.3.5","V8.6.3.6","V8.6.3.7","V8.6.3.8","V8.6.3.9","V8.6.4.0","V8.6.4.1","V8.6.4.2","V8.6.4.3","V8.6.4.4","V8.6.4.5","V8.6.4.6","V8.6.4.7","V8.6.4.8","V8.6.4.9");
	array_push($updatevesions,"V8.6.5.0","V8.6.5.1");

if(!in_array($dbversion,$updatevesions))
{
    ?>
    <script>
        window.location='../../index.php?update=2';
    </script>
    
<?php
   
}
$dbindex=array_search($dbversion,$updatevesions)+1;
$codeindex=array_search($lingdang_current_version,$updatevesions);

if(!in_array($lingdang_current_version,$updatevesions))
{
    //echo '软件版本和升级脚本对应关系不一致，请检查程序文件是否缺失！';
    echo '<script>alert("软件版本和升级脚本对应关系不一致，请检查程序文件是否缺失！")</script>';
    exit();
}

$divlength=0;
if($dbindex<=$codeindex)
{
    for($dbindex;$dbindex<=$codeindex;$dbindex++)
    {
         if(!file_exists($filedirectory.$updatevesions[$dbindex].'.sql'))
             {
               // echo '升级脚本文件“'.$updatevesions[$dbindex].'.sql”不存在，请检查程序文件是否缺失！';
               echo '<script>alert("升级脚本文件'.$updatevesions[$dbindex].'.sql不存在，请检查程序文件是否缺失！")</script>';
                exit();
               
              
             }
            $content=file_get_contents($filedirectory.$updatevesions[$dbindex].'.sql');
            $arr = explode("delimiter;", $content);
            $divlength+=sizeof($arr);  //总共需要执行脚本数目
    }
        
}
$filehandle=fopen('dataCache/sqlhandlers/update1.txt','w+');
$sqlhandle=fopen('dataCache/sqlhandlers/sqlhandler.txt','w+');

$update=1;
 fwrite($filehandle,$update);
 fwrite($filehandle,$dbconfig['db_server']);
 fwrite($filehandle,$dbconfig['db_name']);
 fwrite($filehandle,$root_directory);
 fclose($filehandle);
if($divlength>410)
{
    $step=$divlength/410;

}
else
{
    $step=410/$divlength+1;
}


ignore_user_abort(true);
$dbindex=array_search($dbversion,$updatevesions)+1;
$codeindex=array_search($lingdang_current_version,$updatevesions);
updateWeiXinVersion($mysqli);//更新微信API端版本号缓存 editor:gyq_31 date:20170918
if($dbindex<=$codeindex)
{
     if(file_exists('storage/updatelog.txt'))
     {
        @unlink('storage/updatelog.txt');
     }
    $filelog=fopen('storage/updatelog.txt','w+');
    $dvwidth=1;
    for($dbindex;$dbindex<=$codeindex;$dbindex++)
    {
       try
       {
             if(!file_exists($filedirectory.$updatevesions[$dbindex].'.sql'))
             {
                //echo '文件'.$updatevesions[$dbindex].'.sql不存在';
                echo '<script>alert("文件'.$updatevesions[$dbindex].'.sql不存在")</script>';
                exit();
           
             }
            $content=file_get_contents("sql/updateVersion/".$updatevesions[$dbindex].'.sql');
            $arr = explode("delimiter;", $content);  
            $i=0;
            
            for($i;$i<count($arr);$i++)
            {  
                $sql=trim($arr[$i]);
                $line++;
                if($divlength>410)
                {
                      if($line%$step==0 )
                     {
                        $dvwidth=$dvwidth+1;
                     }
                }
                else
                {
                    $dvwidth=$line*$step;
                    
                }
               
                echo '<script> 
                     document.getElementById("dv").innerHTML="'.$line.'/'.$divlength.'";
                     document.getElementById("dvprogress").style.width = "'.$dvwidth.'px"</script>';
                ob_flush(); 
                flush();  
                if(empty($sql))
                {
                    continue;
                }
               if(strstr($sql,'||'))//存储过程
               {
                  $queryarr=explode('||',$sql);
                  for($j=0;$j<sizeof($queryarr);$j++)
                  {
                     $sql1=trim($queryarr[$j]);
                      if(empty($sql1))
                      {
                        continue;
                      }
                     if(strstr($sql1,'delimiter'))
                     {
                        $sqlarr=explode('delimiter',$sql1);
                        $ret=$mysqli->multi_query($sqlarr[0]);
                     }
                     else
                     {
                        $ret=$mysqli->multi_query($sql1);
                     }
                     if( mysqli_error($mysqli))
                        {
                             $filehandle=fopen('dataCache/sqlhandlers/update1.txt','w+');
                            $update=2;
                             fwrite($filehandle,$update);
                             fclose($filehandle);
                            ignore_user_abort(false); 
                             fwrite($filelog, '文件'.$updatevesions[$dbindex] .'错误脚本:');
                             fwrite($filelog,"\r\n");
                             fwrite($filelog,$sql1);
                             fwrite($filelog, mysqli_error($mysqli));
                             fclose($filelog);
                             $mysqli->close();
                            echo '<script>document.getElementById("dvc").innerHTML="执行脚本出错，请尝试手动升级！&nbsp;<a href=\'sql/updateVersion/sqllog.php\'>查看详情</a>"</script>';
                            exit();
                        } 
                        else
                        {
                                while(@$mysqli->next_result())
                                { 
                                       $result=$mysqli->store_result();
                                        if($result)
                                        $result->close();
                                }
        
                        } 
                  }
               }
               else
               {
                  $ret= $mysqli->multi_query($sql);
                    fwrite($sqlhandle,$sql);
                    if(mysqli_error($mysqli))
                    {
                         $filehandle=fopen('dataCache/sqlhandlers/update1.txt','w+');
                        $update=2;
                         fwrite($filehandle,$update);
                         fclose($filehandle);
                        ignore_user_abort(false);
                      
                        fwrite($filelog, '文件'.$updatevesions[$dbindex] .'错误脚本:');
                        fwrite($filelog,"\r\n");
                        fwrite($filelog,$sql);
                        fwrite($filelog,mysqli_error($mysqli));

                        fclose($filelog);
                        $mysqli->close();
                        echo '<script>document.getElementById("dvc").innerHTML="执行脚本出错，请尝试手动升级！&nbsp;<a href=\'sql/updateVersion/sqllog.php\'>查看详情</a>"</script>';
                        exit();
                        
                    }
                    else
                    {
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
                           
                    } 
             
               }
               
            }  
       }
       catch(Exception $ex)
       {
            $filehandle=fopen('dataCache/sqlhandlers/update1.txt','w+');
            $update=2;
             fwrite($filehandle,$update);
            
             fclose($filehandle);
            ignore_user_abort(false);
            //echo '文件'.$updatevesions[$dbindex].'.sql 第'.$i.'行脚本错误';
             echo '<script>document.getElementById("dvc").innerHTML="文件'.$updatevesions[$dbindex].'.sql 第'.$i.'行脚本错误"</script>';
             exit();
       }
    }
}

$mysqli->close();
$filehandle=fopen('dataCache/sqlhandlers/update1.txt','w+');
$update=2;
fwrite($filehandle,$update);
fclose($filehandle);
fclose($filelog);
fclose($sqlhandle);
ignore_user_abort(false);

clearCacheFiles();
clearMinifyFiles();
clearSmartyFiles();
clearDefaultFile();
unsetCacheDirectory('productfields');
unsetCacheDirectory('fields');
unsetCacheDirectory('profile');
@unlink('dataCache/sqlhandlers/update1.txt');
if(file_exists("../../dataCache/execDays/autoremind.txt"))
{
	@unlink("../../dataCache/execDays/autoremind.txt");
}
echo " <script type='text/javascript'>
	window.location='index.php';
</script>";
?>