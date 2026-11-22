<?php
error_reporting(E_ALL^E_NOTICE^E_WARNING);
global $adb,$current_user;
//打印
if(isset($_REQUEST['order_no'])){
    $connect_mode=getDatainterface('connect_mode');//连接方式
    $sa=getDatainterface('sa');
    $pwd=getDatainterface('pwd');
    $hostname=getDatainterface('hostname');
    $databasename=getDatainterface('databasename');
    $conResultInfo = conSqlserver($hostname,$sa,$pwd,$databasename);
    $col_field = array();    
    if($conResultInfo['conResult'] != 1){
        echo '数据库连接失败';
        exit();
    }
    $SqlCon = $conResultInfo['sqlcon'];
    if(isset($_REQUEST['type']) && $_REQUEST['type'] == 'SalesOrder'){
        $file_handle=fopen('templatePrintFile/SalesOrder_kingdee_k3.html','r');
        $order = iconv("UTF-8","gb2312",'[Sales Order]');
        $sql_Kingdeeorders="SELECT TOP 1 * FROM dbo.Vw_LDCRM_So where $order = '".$_REQUEST['order_no']."'";
        $sql_weight = "select sum(Weigth) as subWeigth from dbo.Vw_LDCRM_So where $order = '".$_REQUEST['order_no']."'";
        $weight_Result=$SqlCon->Query_result($sql_weight);
        $Kingdeeorders_row = sqlsrv_fetch_array($weight_Result, SQLSRV_FETCH_ASSOC);
        $subWeigth = $Kingdeeorders_row['subWeigth'];
    }else{
        $file_handle=fopen('templatePrintFile/Quots_kingdee_k3.html','r');
        $order = iconv("UTF-8","gb2312",'[Quots No]');
        $sql_Kingdeeorders="SELECT TOP 1 * FROM dbo.Vw_LDCRM_Price where $order = '".$_REQUEST['order_no']."'";
        $sql_weight = "select sum(Weigth) as subWeigth from dbo.Vw_LDCRM_Price where $order = '".$_REQUEST['order_no']."'";
        $weight_Result=$SqlCon->Query_result($sql_weight);
        $Kingdeeorders_row = sqlsrv_fetch_array($weight_Result, SQLSRV_FETCH_ASSOC);
        $subWeigth = $Kingdeeorders_row['$Kingdeeorders_row'];
    }
    
    $Kingdeeorders_Result=$SqlCon->Query_result($sql_Kingdeeorders);
    $Kingdeeorders_row = sqlsrv_fetch_array($Kingdeeorders_Result, SQLSRV_FETCH_ASSOC);
    $data = $SqlCon->fetch_all($sql_Kingdeeorders);
    foreach($Kingdeeorders_row as $Kingdeeorders_key=>$Kingdeeorders_value){
        $list_header[]=iconv("gb2312","UTF-8",$Kingdeeorders_key);          
    }
    //计算total
    $stotal = $data[0]['Material Total'] + $data[0]['Sea Freight']+$data[0]['Air Freight']+$data[0]['Oversize Packing/Feight Extra Charge'];
    foreach($data[0] as $header =>$value){
        $valie_object = gettype($value);
        if($valie_object == 'object'){
            $d_value = (array)$value;
            $value = explode(' ',$d_value['date']);
            $value = $value[0];
        }
        $list_entries[] = iconv("gb2312","UTF-8",$value);
    }
    foreach($list_entries as $key=>$value){
        $list[$list_header[$key]] = $value;
    }
   
    $Kingdeeorders_row = sqlsrv_fetch_array($Kingdeeorders_Result, SQLSRV_FETCH_ASSOC);
    $kk = 0;
    while (!feof($file_handle)) 
    {
        $fieldname='';
        if(strpos(strtolower($line),'<td')>0)
            $prevtdline=$line;
        $line = fgets($file_handle);
        $printcolumns=getPrintColumnInfo($line);
        if((strpos(strtolower($line),'</table')>0||(strpos(strtolower($line),'tr>')>0))&&$bolProduct==true)
        {
            if(isset($_REQUEST['type']) && $_REQUEST['type'] == 'SalesOrder'){
                $sql_Kingdeeorders="SELECT * FROM dbo.Vw_LDCRM_So where $order = '".$_REQUEST['order_no']."' order by Item asc";
            }else{
                $sql_Kingdeeorders="SELECT * FROM dbo.Vw_LDCRM_Price where $order = '".$_REQUEST['order_no']."' order by Item asc";
            }
            $Kingdeeorders_Result=$SqlCon->Query_result($sql_Kingdeeorders);
            $Kingdeeorders_row = sqlsrv_fetch_array($Kingdeeorders_Result, SQLSRV_FETCH_ASSOC);
            $productrows = $SqlCon->num_rows($Kingdeeorders_Result);//产品明细总行数
            $list_data = $SqlCon->fetch_all($sql_Kingdeeorders);
            for($producti=1;$producti<$productrows;$producti++){
                $printhtml .='<tr>';
                if($col_field[0] == '序号'){
                    $row_no = $producti+1;
                    $printhtml .= '<td class="font2">' .$row_no. '</td>';
                }
                foreach($list_data[$producti] as $header =>$value){
                    if(in_array(iconv("gb2312","UTF-8",$header),$col_field)){
                        $value = iconv("gb2312","UTF-8",$value);
                        if(!empty($value)){
                            $printhtml .= '<td class="font2" align="left">'.$value.'</td>';
                        }else{
                            $printhtml .= '<td class="font2">&nbsp;</td>';
                        }
                        
                    }
                }
                $printhtml .='</tr>';
                
            }
        }
        
        if(count($printcolumns)>0)//如果该行有[]
        {
            $printcols=preg_split("/(\[Var.|\[var.|\[VAR.|\[vAR.|\[VAr.|\[VaR.|\[vaR.|\[vAr.)/",$line);
            for($i=0;$i<count($printcols);$i++)
            { 
               
                $fieldname='';
                if(strpos($printcols[$i],']')>0)//找到需要打印的列
                {
                    $endcol=strpos($printcols[$i],']');
                    $colsinfo=substr($printcols[$i],0,$endcol);
                    $fieldname = $colsinfo;
                    if(!empty($fieldname))
                    {  
                        //公司信息打印
                        if($fieldname == 'company_logoname')
                        {
                            $sqlcompany='select * from ld_organizationdetails';
                            $companyResult=$adb->pquery($sqlcompany,array());
                            $logoname = explode('_',$fieldname);
                            $colvalue=$adb->query_result($companyResult,$logoname[1]);
							global $site_URL;
                            if(isset($_REQUEST['CreatePDF'])&&$_REQUEST['CreatePDF']==true)
                                $printhtml.='<img src="'.$site_url[0].'dataCache/test/logo/'.$colvalue.'" border="0" style="width: 110px;height: 40px;margin:5px 5px 0 0px;" title="logo.png" alt="logo.png" >'.substr($printcols[$i],$endcol+1);
                            else
                                $printhtml.='<img border="0" style="width: 110px;height: 40px;margin:5px 5px 0 0px;" title="logo.png" alt="logo.png" src="'.$site_url[0].'dataCache/test/logo/'.$colvalue.'">'.substr($printcols[$i],$endcol+1);
                             continue;
                        }else{
                            $cols_fieldnames = explode('_',$fieldname);
                            if(count($cols_fieldnames) == 1){
                                $fieldname = $cols_fieldnames[0];
                            }else{
                                $fieldname = $cols_fieldnames[1];
                                if($cols_fieldnames[0] == 'productdetails'){   
                                    $col_field[] = $cols_fieldnames[1];
                                    $bolProduct = true;
                                    if($cols_fieldnames[0] == 'productdetails' && $cols_fieldnames[1] =='序号')
                                        $list[$fieldname] = 1;
                                }
                            }
                           // echo $fieldname .'--' .$list['Date'] .'--' .'<br>';
                           if($fieldname == 'sTotal'){
                                $printhtml .= $stotal;
                           }else if($fieldname == 'subWeigth'){
                                $printhtml .=$subWeigth;
                           }
                           else{
                                $printhtml .= $list[$fieldname];
                           }
                                
                        }
                         
                    }else{
                         $col_field[] = '';
                         $bolProduct = false;
                        
                    }
                    
                }else
                {
                    $bolProduct =false;
                    
                    $printhtml .= $printcols[$i];
					if($bolBomPrint && $bolProduct){
						if(strpos($printcols[$i],'rowspan')>0){
							$bomprinthtml = $printcols[$i];
						}
					}
                }
            }
        }
        else
        {
            $bolProduct =false;
            $col_field = array();
            $printhtml.=$line;
        }
        /*if(count($col_field) >= 1){
            $bolProduct = true;
        }*/
        
    }
    echo $printhtml;
    //require_once('include/TemplatePrint/TemplatePrint.php');
	//$template=new TemplatePrint($module,$tabid,$_REQUEST['printid'],$_REQUEST['record'],$adb);
	//echo $template->createPrintHtml();
	//echo "<script>window.print()</script>";
	//exit();
}
function getPrintColumnInfo($str)
{
    $result = array();
   preg_match_all("/(?:\[)(.*)(?:\])/i",$str, $result);
   return $result;
}
?>