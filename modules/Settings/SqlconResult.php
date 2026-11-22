<?php
/*
{*修改编码格式:统一编码：UTF-8*}
*/ 
require_once("mssql/SqlServer.php");
require_once("include/Sqlsrv/sqlsrv.class.php");
$returnHtml= "&&&&&&&&&&&&//B/";

if(isset($_REQUEST['sa']) && isset($_REQUEST['pwd'])  &&isset($_REQUEST['hostname']) )
{
        
    $sa=$_REQUEST['sa'];
    $pwd=$_REQUEST['pwd'];
    $hostname=$_REQUEST['hostname'];
    $databasename=$_REQUEST['databasename'];
    $test_link=$_REQUEST['test_link'];
    //判断连接是否成功(配置连接)
    if($test_link == 2 ){
        if(isset($_REQUEST['connect_mode']) && $_REQUEST['connect_mode'] == 'ODBC'){
			 //ODBC连接
			odbc_connect($databasename,$sa,$pwd) or die($returnHtml.'error:##:ERROR');
            echo $returnHtml.'success:##:SUCCESS';
        }else if(isset($_REQUEST['connect_mode']) && $_REQUEST['connect_mode'] == 'DIRODBC'){
			//ODBC直接连接
			$connstr = "Driver={SQL Server};Server=$hostname;Database=$databasename"; 
			$link=odbc_connect($connstr,$sa,$pwd,SQL_CUR_USE_ODBC); 
			if ($link){ 
				echo $returnHtml.'success:##:SUCCESS';
			}else{ 
				echo $returnHtml.'error:##:ERROR';
			} 
		}else{
            //sqlsev连接
            $conResult = conSqlserver($hostname,$sa,$pwd,$databasename,false);
            if($conResult['conResult'] == 1){
                echo $returnHtml.'success:##:SUCCESS';
            }else{
                echo $returnHtml.'error:##:ERROR';
            }
        }
        exit();
    }else{
        //sqlsev连接
        $con = conSqlserver($hostname,$sa,$pwd,$databasename,false);
        $conResult = $con['conResult'];
        $SqlCon = $con['sqlcon'];
    }
    if($conResult=="1" && $test_link == 1)
    {
        //用友T+
        if($_REQUEST['facetype'] =='Tyy'){
            $sql ="SELECT DISTINCT right(cast(1000000+cAcc_Num as varchar),6) as cAcc_Num ,DsName 
                    FROM EAP_Account where  (Version='YYTPro' or isUninstall = 1) 
                    and convert(INT, replace( substring(versionno,0,7),'.',''))<= convert(INT, replace( substring('11.510.000.0000',0,7),'.',''))  
                    ORDER BY cAcc_Num";
            $result=$SqlCon->Query_result($sql);
            $noofrows=$SqlCon->num_rows($result);
            if($noofrows<=0){
                if($_REQUEST['facetype']=='Tyy'){
                    echo $returnHtml."error:##:没有检测到用友T+账套！";
                    exit();
                }
            }
        
        }else if($_REQUEST['facetype'] =='Tyu'){//用友U8
            $sql = "select ua_account.cAcc_name,ua_accountdatabase.cDatabase from ua_account left join ua_accountdatabase on ua_accountdatabase.cAcc_id = ua_account.cAcc_id";
            $result=$SqlCon->Query_result($sql);
            $noofrows=$SqlCon->num_rows($result);
            if($noofrows<=0){
                if($_REQUEST['facetype']=='Tyu'){
                    echo $returnHtml."error:##:没有检测到用友U8账套！";
                    exit();
                }
            }
        }else{//金蝶
            $sql="select 1 from dbo.sysobjects where id = object_id(N'[dbo].[T_KdAccount_GL]') and OBJECTPROPERTY(id, N'IsUserTable') = 1";
            $result=$SqlCon->Query_result($sql);
            $noofrows=$SqlCon->num_rows($result);
            if($noofrows<=0){
                if($_REQUEST['facetype']=='KThree')//k3
                {
                    echo $returnHtml."error:##:没有检测到金蝶K3账套！";
                    exit();
                }
                else {
                    echo $returnHtml."error:##:没有检测到金蝶专业版账套！";
                    exit();
                }
            }
             
            $sql="select a.cacc_name,a.cdbname  from t_kdaccount_gl as a left outer join sysdatabases as b on a.cdbname=b.name";
            $result=$SqlCon->Query_result($sql);
            $noofrows=$SqlCon->num_rows($result);
            
            if($noofrows<=0)
            {
                if($_REQUEST['facetype']=='KThree')//k3
                {
                    echo  $returnHtml."error:##:没有检测到金蝶K3账套！";
                    exit();
                }
                else 
                {
                    echo $returnHtml."error:##:没有检测到金蝶专业版账套！";
                    exit();
                }
            }
        }
        $returnHtml .="success:##:";
        $returnHtml  .="<table class='Ldstable0 listEntries' width='100%' cellspacing='1' cellpadding='0' border='0'>";
        $returnHtml .="<tr><th width='200'>帐套名称</th><th>帐套实体</th></tr>";
         for($i=0;$i<$noofrows;$i++)
         {          
            $row=$SqlCon->fetch_row($result);
            $sql="select 1 from  master..sysdatabases  where  name='".$row[1]."'";
            $databaseResult=$SqlCon->Query_result($sql);
            
            if($SqlCon->num_rows($databaseResult)<=0)//数据库是否存在
            {
                continue;
            }
            /*
            $KISSqlCon=new SqlServer($sa,$pwd,'AIS20101126160333',$hostname);
            $sql="select 1 from dbo.sysobjects where id = object_id(N'[dbo].[T_AP_TabInfo]') and OBJECTPROPERTY(id, N'IsUserTable') = 1";
            $KISSqlCon->Connect();
            $KISResult=$KISSqlCon->Query_result($sql);
            $KISRows=$KISSqlCon->num_rows($KISResult);
            */
            /*if($_REQUEST['facetype']=='KThree')//k3
            {
                $returnHtml .="<tr onmouseover='settdColor(this,event)' ><td style='color:#0099ff' onmouseover='settdColor(this,event)' ><a onmouseover='settdColor(this,event)' href='#' onclick='returnEdit(this)'>".iconv('GB2312','UTF-8',$row[0])."</a></td><td>".$row[1]."</td></tr>";
            }
            else  if($_REQUEST['facetype']=='KISMajor')//专业版
            {
                $returnHtml .="<tr onmouseover='settdColor(this,event)' ><td style='color:#0099ff' onmouseover='settdColor(this,event)' ><a onmouseover='settdColor(this,event)'  href='#' onclick='returnEdit(this)'>".iconv('GB2312','UTF-8',$row[0])."</a></td><td>".$row[1]."</td></tr>";
            }*/
            $returnHtml .="<tr onmouseover='settdColor(this,event)' ><td style='color:#0099ff' onmouseover='settdColor(this,event)' ><a onmouseover='settdColor(this,event)'  href='#' onclick='returnEdit(this)'>".iconv('GB2312','UTF-8',$row[0])."</a></td><td>".$row[1]."</td></tr>";
         }
         $returnHtml .="</table>";
    }
    else 
    {
        $returnHtml .="error:##:ERROR";
    }
    echo $returnHtml;
    exit();
}
?>