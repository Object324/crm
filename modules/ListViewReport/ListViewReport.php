
<html>
  <head>
    <title><?php getFixedLabel('CURQUERYCHART') ?></title>
    <meta http-equiv="X-UA-Compatible" content="IE=7">
    <script language='javascript' src='include/FusionCharts/FusionCharts.js'></script>
    <script language="javascript" src='include/js/ajax.js'></script>
    <script language="javascript" src='include/js/Chart.js'></script>
     
  </head>
  <body>

<?php

require_once($root_directory.'include/FusionCharts/class/FusionCharts_Gen.php');

require_once($root_directory."modules/".$_REQUEST['relatedmodule']."/".$_REQUEST['relatedmodule'].".php");
/*
参数说明
countlabel:是合计列的中文名称
columnname:是查询的列，第一列是横向列(x轴)，第二列是竖向列(y轴)
relatedtable:当查询统计字段没有使用该模块所对应表的字段时，在from子句中要添加的表
relatedfrom:子表查询，
charx:图形报表x轴显示的字段，y轴显示countlabel字段内容
pagetitle:报表标题
relatedmodule：表示报表所属模块
sequcence:表示是否有序号列
orderby:表示排序列
xtotal:表示x轴是否合计：1：合计
ytotal:表示y轴是否合计:1：合计
htmltabletype:0:表示x轴获取小计，1：表示y轴获取小计显示表格；2：表示按照sql查询结果显示表格
rotateNames:图形化报表文字方向0：水平，1：垂直
MultiSerials:对比报表，0：表示不对比，1：表示对比
currency:表示是否是货币字段，yes:有,no:没有
*/

global $adb;
global $current_language;

global $current_user;
if($_REQUEST['relatedmodule']!='Calendar')
  
    $field_obj=Field::getInstance($_REQUEST['relatedmodule'],$adb);
else

    $field_obj=Field::getInstance('Events',$adb);
$arrFixedLabel=$field_obj->getFieldLabelesByColumn();

$ChartFrom=str_replace('//B/',' ',$_REQUEST['queryfrom']);
$ChartFrom=str_replace("//,/","'",$ChartFrom);
$ChartFrom=str_replace("//,,/","%'",$ChartFrom);
$ChartFrom=str_replace("//shao/",'"',$ChartFrom);

$ChartWhere= str_replace('//B/',' ',$_REQUEST['querywhere']);
$ChartWhere=str_replace('//,/',"'",$ChartWhere);
$ChartWhere=str_replace('//tgt/',">",$ChartWhere);//>
$ChartWhere=str_replace('//lt/',"<",$ChartWhere);//<
$ChartWhere=str_replace('//!=/',"<>",$ChartWhere);
//bug 23792 edit cyb date:2016-07-28 替换掉"%";
$ChartWhere=str_replace("//lk/","%",$ChartWhere);//%
$ChartWhere=str_replace('//lteq/',"<=",$ChartWhere);//<=
$ChartOwner=str_replace('//B/',' ',$_REQUEST['queryowner']);


//columnname的第一列是横向列(x轴)，第二列是竖向列(y轴)
$ChartColumn= str_replace('//B/',' ',$_REQUEST['columnname']);
$ChartColumn=str_replace('//N/',"'",$ChartColumn);
$groupBy=str_replace('//N/',"'",$_REQUEST['groupby']);

$groupbyordercol= $_REQUEST['groupbyordercol'];//合计排序字段

$strSQL="";
if(isset($_REQUEST['relatedtable'])&&$_REQUEST['relatedtable']!='')
{
 
    if(strpos(strtolower($ChartFrom),'ld_'.strtolower($_REQUEST['relatedtable']))==false)
    {
        $relatedfrom=str_replace('//B/',' ',$_REQUEST['relatedfrom']);
        
        $ChartFrom .=" ".$relatedfrom." ";
    }
}
if(stripos($_REQUEST['columnname'],'users_assigned_user_id.last_name')!==false || (isset($_REQUEST['functionname']) && $_REQUEST['functionname'] == 'getPotentialsBySmowneridCreatetime'))
{
    $focus=CRMEntity::getInstance($_REQUEST['relatedmodule']);
    $smownercolumnname=$focus->getSmownerColumName();
    if(!strpos($ChartFrom, 'users_assigned_user_id')){
        $ChartFrom.=' LEFT JOIN ld_users AS users_assigned_user_id ON users_assigned_user_id.id =  '.$focus->table_name.".".$smownercolumnname;
    }
}
if($_REQUEST['relatedmodule']=='Potentials'){
    if(!strpos($ChartFrom, 'potentialscf')){
        $ChartFrom.=' LEFT JOIN ld_potentialscf ON ld_potential.potentialid = ld_potentialscf.potentialid ';
    }
    
  
}
if($_REQUEST['relatedmodule']=='Accounts' || $_REQUEST['relatedmodule']=='ServiceCharge'){
	if(!strpos($ChartFrom, 'LEFT JOIN ld_users ON')){
		$ChartFrom.=' LEFT JOIN ld_users ON ld_users.id = ld_account.smownerid ';
	}
}
//$mod_strings=return_module_language($current_language, $_REQUEST['relatedmodule']);

if(isset($_REQUEST['relatedaction'])&& $_REQUEST['relatedaction']!=' ')
{
    include("modules/".$_REQUEST['relatedmodule']."/".$_REQUEST['relatedaction'].".php");
   
    $focus=new $_REQUEST['relatedaction']($ChartFrom,$ChartWhere,$ChartOwner);
   // echo $_REQUEST['functionname'];
    //echo '<br>'.$_REQUEST['relatedmodule'];
    $functname=$_REQUEST['functionname'];
    $strSQL=$focus->$functname();
	
}

else if(isset($_REQUEST['groupby']))
{
	//	0020372: 客户>列表>注册资金分布统计,排列顺序，不妥
    //20715: 客户>列表界面：注册资金分布统计、年营业额分布统计，跳转页面出现代码
   //Eidtor:gyq_64MS Reason:下拉框改进 Date:2018/3/16 0016 上午 11:20
	if(!empty($_REQUEST['form_name']) && $_REQUEST['form_name'] == 'Accountsannualincome'){
		$ChartFrom .=' inner JOIN (
              SELECT
                id annualincomeid,listvalue
              FROM ld_picklist_values
                LEFT JOIN ld_picklist_set
                  ON ld_picklist_set.listid = ld_picklist_values.listid
              WHERE listname = \'annualincome\' AND relatetable = \'ld_field\')
    AS ld_annualincome ON ld_annualincome.listvalue = ld_accountscf.annualincome ';
	}
	if(!empty($_REQUEST['form_name']) && $_REQUEST['form_name']=='Accountsregisteredcapital'){
		//Eidtor:gyq_64M Reason:下拉框改进 Date:2018/3/19 0019 下午 1:55
        //$ChartFrom .=' inner join ld_registeredcapital on ld_registeredcapital.registeredcapital = ld_accountscf.registeredcapital ';
		$ChartFrom .=' INNER JOIN (
              SELECT
                id registeredcapitalid,listvalue
              FROM ld_picklist_values
                LEFT JOIN ld_picklist_set
                  ON ld_picklist_set.listid = ld_picklist_values.listid
              WHERE listname = \'registeredcapital\' AND relatetable = \'ld_field\')
    AS ld_registeredcapital ON ld_registeredcapital.listvalue = ld_accountscf.registeredcapital ';
	}
	//  Eidtor:gyq_64M Reason:下拉框改进 Date:2018/3/16 0016 上午 10:27
	if(!empty($_REQUEST['form_name']) && trim($_REQUEST['form_name'])=='accountsize'){
		//$ChartFrom  .= ' LEFT JOIN ld_accountsize on ld_accountsize.accountsize = ld_accountscf.accountsize';
		$ChartFrom  .= ' LEFT JOIN (
              SELECT
                id accountsizeid,listvalue
              FROM ld_picklist_values
                LEFT JOIN ld_picklist_set
                  ON ld_picklist_set.listid = ld_picklist_values.listid
              WHERE listname = \'accountsize\' AND relatetable = \'ld_field\')
    AS ld_accountsize ON ld_accountsize.listvalue = ld_accountscf.accountsize';
	}
   //17359: 客户>列表>本次查询统计表：所有统计表显示数据没有与数据分类下的数据保持一致。
    $relate_focus=CRMEntity::getInstance($_REQUEST['relatedmodule']);

	if(!empty($_REQUEST['querytype']) && $_REQUEST['querytype'] == 1){
		 $ChartFrom = str_replace('left join ld_users','right join ld_users',strtolower($ChartFrom));
		 $strSQL="select $ChartColumn  $ChartFrom $ChartWhere $ChartOwner group by ".strtolower($groupBy);	
	}else{
		 $strSQL="select $ChartColumn  $ChartFrom  where $relate_focus->table_name.$relate_focus->table_index in( select distinct $relate_focus->table_name.$relate_focus->table_index".$ChartFrom.$ChartWhere.$ChartOwner.")  group by ".strtolower($groupBy);
 }

	//	0020372: 客户>列表>注册资金分布统计,排列顺序，不妥
	if(!empty($_REQUEST['form_name']) && $_REQUEST['form_name'] == 'Accountsannualincome'){
		$strSQL .=' order by ld_annualincome.annualincomeid ';
	}
	if(!empty($_REQUEST['form_name']) && $_REQUEST['form_name'] == 'Accountsregisteredcapital'){
		$strSQL .=' order by ld_registeredcapital.registeredcapitalid ';
	}
	if(!empty($_REQUEST['form_name']) && $_REQUEST['form_name'] == 'accountsize'){
		$strSQL .=' order by ld_accountsize.accountsizeid ';
	}
     if(!empty($groupbyordercol))
     {
        $strSQL='select * from ('.$strSQL.') as testtmp group by '.$groupbyordercol;
     }
     
		
}
else 
{
    $strSQL= "select count( ld_".$_REQUEST['chartable'].".".strtolower($_REQUEST['columnname'])." ) as countname "."ld_".$_REQUEST['relatedtable'].".".$_REQUEST['fieldname']." ".$ChartFrom.$ChartWhere.$ChartOwner." Group by " ."ld_".$_REQUEST['chartable'].".".$_REQUEST['columnname'];
}
if(isset($_REQUEST['orderby'])&& $_REQUEST['orderby']!='')
{
    $orderby=str_replace('//N/',"'",$_REQUEST['orderby']);
    $strorderby=str_replace('//B/',' ',$orderby);
    $strSQL .=" order by " .$strorderby;
}


/*
edit:can
date:20130411
reason:非管理员用户创建临时表，因为在叙事簿查询的时候创建了临时表
*/
if(strtolower($current_user->is_admin)=="off")
{
    $focus= new $_REQUEST['relatedmodule']();
    if($_REQUEST['relatedmodule']=="Calendar")
    {
        require_once("modules/Calendar/Activity.php");
        $focus=new Activity();
    }
    //$focus->createTemporytableForChart($_REQUEST['relatedmodule'],$current_user);
   // sleep(20);
}
//echo $functname;
$result=$adb->pquery($strSQL,array());
$strTablecell="<table  class='rcfb_tb' >";
//<caption><span style='font-size:14px;color:red'>";
//$strTablecell .="<b>".$mod_strings[$_REQUEST['pagetitle']]."</b></span></caption>";
$totalx=0.0;//合计
$totaly=0.0;//合计
$tdArray= array();
$trArray=array();
$charttrArray=array();
$charttdArray=array();
$xrowhtml="<tr><th>&nbsp</th>";
$yrowhtml="";
$serialName="";
$onecolumnName=$adb->field_name($result,0)->name;
$twocolumnName=$adb->field_name($result,1)->name;
$serialName=$twocolumnName;
$serialIndex=$_REQUEST['chartx'];
$chartcategories="<categories> ";
$chartdataset="";
$chartColors=array('AFDBF8','F6BD0F','8BBA00','FF8E46',
                    '008E8E','D64646','8E468E',
                        '588526','B3AA00','008ED6','9D080D','A186BE');


$strGraph="<chart unescapeLinks='0' showValues='1'  canvasBorderThickness='1' rotateValues='1'  baseFontSize='11' baseFontcolor='#333' baseFontFamily='宋体' showName='1' showValues='3' caption='".getFixedLabel($_REQUEST['pagetitle'])."' rotateNames='".$_REQUEST['rotateNames']."' showNames='1' decimalPrecision='2' formatNumberScale='2'>";

$i=0;
$i=0;
$currency='yes';
$xmldata_show='yes';
if($_REQUEST['currency'])
{
    $currency=$_REQUEST['currency'];
}

if($_REQUEST['htmltabletype']==0)//x轴获取mysql:count的内容，y轴获取字段内容 (第一列获取字段内容，第二列获取count内容)
{    
	 $columnanme = $adb->field_name($result,1)->name;
	 if($columnanme == 'accountname')$columnanme = 'accountid';
	 $fieldlabel= $arrFixedLabel[$adb->field_name($result,1)->name];
     if(empty($fieldlabel))
     {
         switch($_REQUEST['relatedtable'])
         {
             case 'account':
                $field_obj=Field::getInstance('Accounts',$adb);
                break;
         }
        
        $arrFixedLabel=$field_obj->getFieldLabelesByColumn();
        $fieldlabel= $arrFixedLabel[$columnanme];
     }
     $strTablecell .="<tr>";
	 if($_REQUEST['pagetitle'] == 'RECEIVECHARGE'){
		$strTablecell .="<th>".$arrFixedLabel['smownerid'];
	 }else{
		$strTablecell .="<th>".$arrFixedLabel[$columnanme];
	 }
     $strTablecell .="</th><th></th></tr>";
    
     while($row=$adb->fetch_array($result))
         {
            /**
             * 2016/04/14 Liver
             * 0021565: 客户>列表：本次查询统计图表，金额字段应该右对齐。
             */
             if($currency=='yes')
                    $strTablecell .="<tr><td bgcolor='#f7f7f7'>".$row[1]."</td><td  align='right'>¥".setNumberFormat($row[0])."</td></tr>";
             else//35920: 客户/服务收费管理-本次查询统计图表-客户日程/联系记录TOP50，次数应该取整数
                    $strTablecell .="<tr><td bgcolor='#f7f7f7'>".$row[1]."</td><td align='right'>".($row[0])."</td></tr>";
             $xtotal=$xtotal+$row[0];
             $strGraph .="<set name='".$row[1]."' value='".$row[0]."' color='". $chartColors[$i] ."' />";
             $i++;
             if($i>=count($chartColors))
             {
                $i=0;
             }
         }
         
    if(isset($_REQUEST['xtotal'])&& $_REQUEST['xtotal']==1)
        {
            $strTablecell .="<tfoot><tr><td bgcolor='#f7f7f7'><p align='left'>";
            $strTablecell .="<b>".getFixedLabel('TOTAL')."</b></td>";
            $strTablecell .="<td bgcolor='#f7f7f7' align='left'><b><font face='Arial'>";
            if($currency=='yes')
                $strTablecell .="¥".setNumberFormat($xtotal)."</font></b></td></tr></tfoot>";
            else//35920: 客户/服务收费管理-本次查询统计图表-客户日程/联系记录TOP50，次数应该取整数
                $strTablecell .=($xtotal)."</font></b></td></tr></tfoot>";
        }
        
}
elseif($_REQUEST['htmltabletype']==1)//y轴获取mysql:count的内容，x轴获取字段内容(第一行获取字段内容，第二行获取count内容)
{
   
    //andrwe
    //20140715
   	//0009977: 刘总：客户统计图->客户来源分布统计：如图所示，希望在下面增加一个百分比统计
    $i=0;
    $firstrowhtml .="<tr><th >&nbsp</th>";
    $secondrowhtml .="<tr><td bgcolor='#f7f7f7'>".$arrFixedLabel[$adb->field_name($result,0)->name]."</td>";
    $threerowhtml .="<tr><td bgcolor='#f7f7f7'>".getFixedLabel('RATIOS')."</td>";
    $addTotal=0.0;
    $resultw = $adb->pquery($strSQL,array());               
    while ($rowfd<$adb->num_rows($resultw))
    {
       $rowd = $adb->fetch_array($resultw);
       $totalss=$totalss+$rowd[1];//合计
       $w++;
       if($w>=count($chartColors))
       {
           $w=0;
       }
       $rowfd++;
    }
    $empty_count_total=0;
    $empty_title='空';
    $rowf=0;
    $k=0;
    //求列头为空的合计17059: 客户—客户来源分布统计中有两列空的。
    while ($k<$adb->num_rows($result))
    {
        
       $row = $adb->fetch_array($result);
       
       if($row[0]=='')
       {
            $row[0]='空';
            $empty_count_total+=$row[1];
            $addTotal=$addTotal+$row[1];//合计
            $rowfs[]=$k;
            $rowf++;
       }
      
       $k++;
    }
    if($rowf>0)
    {
        //$firstrowhtml .="<th>".$empty_title."</th>";
       
        //$secondrowhtml .="<td >".$empty_count_total."</td>";
       // $threerowhtml .="<td>".number_format($empty_count_total/$totalss*100,2)."%</td>";
		$arr_data[] = array(
			'name' => '空',
			'value' => $empty_count_total,
			'color' => $chartColors[$i]
		);
		$table[] = array(
			'firstrowhtml' => $empty_title,
			'secondrowhtml' => $empty_count_total,
			'threerowhtml' => number_format($empty_count_total/$totalss*100,2),
		);
        $i++;      
    }
  
    $k=0;
    //求列头不为空的合计17059: 客户—客户来源分布统计中有两列空的。
    while ($k<$adb->num_rows($result)) 
    {
        if(in_array($k,$rowfs))
        {
            $k++;
           
            continue;
        }
        $row_zero = $adb->query_result($result,$k,0);
        $row_one=$adb->query_result($result,$k,1);
        //$firstrowhtml .="<th>".$row_zero."</th>";
        $addTotal=$addTotal+$row_one;//合计
        //$secondrowhtml .="<td >".$row_one."</td>";
       // $threerowhtml .="<td>".number_format($row_one/$totalss*100,2)."%</td>";
		$arr_data[] = array(
			'name' => strip_tags($row_zero),
			'value' => $row_one,
			'color' => $chartColors[$i]
		);
		$table[] = array(
			'firstrowhtml' => $row_zero,
			'secondrowhtml' => $row_one,
			'threerowhtml' => number_format($row_one/$totalss*100,2)
		);
        $i++;
        if($i>=count($chartColors))
        {
             $i=0;
        }
       
        $k++;
    }
	foreach($arr_data as $arr){
		$total_arr[] = $arr['value'];
	}
	foreach($total_arr as $key => $vals){
		$strGraph .= "<set name='".$arr_data[$key]['name']."' value='".$arr_data[$key]['value']."' color='". $arr_data[$key]['color'] ."' />";
		$firstrowhtml .="<th>".$table[$key]['firstrowhtml']."</th>";
		$secondrowhtml .="<th>".$table[$key]['secondrowhtml']."</th>";
		$threerowhtml .="<td>".$table[$key]['threerowhtml']."%</td>";
	}
    if($_REQUEST['ytotal']==1)
    $firstrowhtml .="<td bgcolor='#f7f7f7'><strong>".getFixedLabel('TOTAL')."</strong></td>";
    $firstrowhtml .="</tr>";
    if($_REQUEST['ytotal']==1)
    $threerowhtml .="<td bgcolor='#f7f7f7'><strong></strong></td>";
    $threerowhtml .="</tr>";    
    if($_REQUEST['ytotal']==1)
    {
        $secondrowhtml .="<td bgcolor='#f7f7f7'>".$addTotal."</td>";
    }
    $secondrowhtml .="</tr>";
    $strTablecell .=$firstrowhtml .$secondrowhtml.$threerowhtml;
}
elseif($_REQUEST['htmltabletype']==2)
{
    /*
    x轴和y轴都获取字段内容，坐标区域获取mysql:count的内容
    */
  $xmldata_show='no';
   $rowf=0;
   $isempty_column=false;
 
    while ($rowf<$adb->num_rows($result))
    {
        $row=$adb->fetch_array($result);
        if($row[0]=='')
        {
            $row[0]='空';
            $isempty_column=true;
        }
        $strtd=$row[0];
        if(in_array($strtd,$tdArray)==false)
        {
           
            array_push($tdArray,$strtd);
             $xrowhtml .="<th>".$row[0]."</th>";
            if($serialIndex==0)
            {
                //联系记录：负责人/月度客户跟踪数量
                $xmldata_show='yes';
                $chartcategories .="<category name='".$row[0]."'/>";
            }
                    
        }
        if(array_key_exists($row[1],$trArray)==false)
         {
			 if($row[1] == '' && !empty($_REQUEST['querytype']) && $_REQUEST['querytype'] == 1){
				 $rowf++;
				 $isempty_column=false;
				 continue;
			 }
            $trArray[$row[1]]=array($row[0]=>$row[2]);
             
         }
         else 
         {
             if($row[0]=='空')
             {
               //017394: 客户>列表>本次查询统计表：客户类型客户状态分布统计，没有显示“空”，并且统计的数据也不对。
               $trArray[$row[1]][$row[0]]+=$row[2];
               
             }
             else
                $trArray[$row[1]]=array_merge($trArray[$row[1]],array($row[0]=>$row[2]));
         }
         if(array_key_exists($row[0],$charttrArray)==false)
         {
			if($row[1] == '' && !empty($_REQUEST['querytype']) && $_REQUEST['querytype'] == 1){
				$rowf++;
				$isempty_column=false;
				continue;
			}
			if(($row[0] == '' || $row[0] == '空') && !empty($_REQUEST['querytype']) && $_REQUEST['querytype'] == 2){
				$rowf++;
				$isempty_column=false;
				continue;
			}
             $charttrArray[$row[0]]=array($row[1]=>$row[2]);
         }
         else 
         {
             if($row[0]=='空')
             {
               //017394: 客户>列表>本次查询统计表：客户类型客户状态分布统计，没有显示“空”，并且统计的数据也不对。
                $charttrArray[$row[0]][$row[1]]+=$row[2];
               
             }
             else
                $charttrArray[$row[0]]=array_merge($charttrArray[$row[0]],array($row[1]=>$row[2]));
         }
        
         if(in_array($row[1],$charttdArray)==false)
         {
              array_push($charttdArray,$row[1]);
            if($serialIndex==1)
            {
                $xmldata_show='yes';
                $chartcategories .="<category name='".$row[1]."'/>";
            }
                
         }
         
        
         $rowf++;
         $isempty_column=false;
    }
 
    $chartcategories .="</categories>";
    if(isset($_REQUEST['xtotal'])&& $_REQUEST['xtotal']==1)
    {
        $xrowhtml .="<th  ><strong>".getFixedLabel('TOTAL')."</strong></th>";
        
    }
    
    $ytotalArray=array();//竖向的合计
   
    foreach($trArray as $trKey=>$trtdCount)//$serialIndex==1
    {
        $yrowhtml .=" <tr><td bgcolor='#f7f7f7'> ".$trKey." </td> ";
        
        $chartdataset .="<dataset seriesName='".$trKey."' color='".$chartColors[$i]."' alpha='100'>";
         $i++;
         if($i>=count($chartColors))
         {
            $i=0;
         }
         $totalx=0;
        foreach($tdArray as $tdKey=>$tdValue)
        {
            if(array_key_exists($tdValue, $trtdCount))
            {
                $yrowhtml .=" <td > ".$trtdCount[$tdValue]." </td>";
                $totalx=$totalx+$trtdCount[$tdValue];
                $chartdataset .="<set value='".$trtdCount[$tdValue]."'/>";
               
            }
            else 
            {
				
				$yrowhtml .=" <td>0</td> ";
                $chartdataset .="<set value='0'/>";
            }
            
		   if(array_key_exists($tdValue,$ytotalArray)){
			   $ytotalArray[$tdValue]=$ytotalArray[$tdValue]+$trtdCount[$tdValue];
		   }else{
				$ytotalArray[$tdValue]=$trtdCount[$tdValue];
		   }
        }
        if(isset($_REQUEST['xtotal'])&& $_REQUEST['xtotal']==1)
        {
            $yrowhtml .="<td bgcolor='#CBD9FC' ><strong>".$totalx."</strong></td>";
            
        }
        $yrowhtml .=" </tr> ";
       
        $chartdataset .="</dataset>";
    }
    if(isset($_REQUEST['ytotal'])&& $_REQUEST['ytotal']==1)
    {
        $yrowhtml .="<tr><td bgcolor='#f7f7f7'><strong>".getFixedLabel('TOTAL')."</strong></td>";
        foreach($ytotalArray as $ytotalekey=>$ytotalValue)
        {
            $yrowhtml .="<td bgcolor='#f7f7f7'><strong>".$ytotalValue."</strong></td>";
            $totaly=$totaly+$ytotalValue;
        }
        $yrowhtml .="<td bgcolor='#f7f7f7'><strong>".$totaly."</strong></td>";
        $yrowhtml .="</tr>";
    }
    $i=0;
    if($serialIndex==1)
    {
        $chartdataset="";
       
        foreach($charttrArray as $chartKey=>$chartValue)
        {
             if($chartKey=='')
             {
                $chartKey='空';
             }
            $chartdataset .="<dataset seriesName='".$chartKey."' color='".$chartColors[$i]."' alpha='100'>";
            $i++;
             if($i>=count($chartColors))
             {
                $i=0;
             }
            
            foreach($charttdArray as $valueKey=>$valueCount)
            {
                if(array_key_exists($valueCount,$chartValue)==true)
                {
                    $chartdataset .="<set value='".$chartValue[$valueCount]."'/>";
                }
                else 
                {
                    $chartdataset .="<set value='0'/>";
                }
            }
            $chartdataset .="</dataset>";
        }
    }

    $strTablecell .=$xrowhtml.$yrowhtml;
    $strGraph .=$chartcategories . $chartdataset;
    //echo $strGraph;
    
}
elseif($_REQUEST['htmltabletype']==3)//客户联系次数TOP50
{
    //echo $strSQL;
   $sencondrowhtml="";
   $firstrowhtml="<tr><th>".getFixedLabel('SEQUENCE')."</th><th>".$arrFixedLabel[$adb->field_name($result,0)->name]."</th><th>".$arrFixedLabel[$adb->field_name($result,1)->name]."</th></tr>";
   $sequence=1;
   while($row=$adb->fetch_array($result))
   {
     $sencondrowhtml .="<tr><td>".$sequence."</td><td>".$row[0]."</td><td>".$row[1]."</td></tr>";
     $strGraph .="<set name='".$row[0]."' value='".$row[1]."' color='". $chartColors[$i] ."' />";
        $i++;
       if($i>=count($chartColors))
          {
                $i=0;
            }
     $sequence++;
   }
   $strTablecell .=$firstrowhtml .$sencondrowhtml;
}
//echo $strSQL;
$strTablecell .="</table>";
echo "<div class='charttj'>";

echo "<h3 class='red_t' style='margin:0px;padding:0px'>".getFixedLabel($_REQUEST['pagetitle'])."</h3>";

echo $strTablecell;
$strGraph .="</chart>";
echo " <div class='clearfix'></div>";
echo "<h3 class='red_t' style='margin-top:20px;'>";
echo getFixedLabel('DISPLAYTYPE'). '：<a href="javascript:ajaxchart(\''.'modules/ListViewReport/chartType.php?charttype=Column3D\')">3D'.getFixedLabel('COLUMNCHART').'</a>';
echo '　<a href="javascript:ajaxchart(\''.'modules/ListViewReport/chartType.php?charttype=Column2D\')">2D'.getFixedLabel('COLUMNCHART').'</a>';
echo '　<a href="javascript:ajaxchart(\''.'modules/ListViewReport/chartType.php?charttype=Line\')">'.getFixedLabel('LINECHART').'</a>';


if($_REQUEST['MultiSerials']==0)
{
     echo '　<a href="javascript:ajaxchart(\''.'modules/ListViewReport/chartType.php?charttype=Area2D\')">2D'.getFixedLabel('AREACHART').'</a>';
   echo '　<a href="javascript:ajaxchart(\''.'modules/ListViewReport/chartType.php?charttype=Bar2D\')">2D'.getFixedLabel('BARCHART').'</a>';
    echo '　<a href="javascript:ajaxchart(\''.'modules/ListViewReport/chartType.php?charttype=Pie3D\')">3D'.getFixedLabel('PIECHART').'</a>';
    echo '　<a href="javascript:ajaxchart(\''.'modules/ListViewReport/chartType.php?charttype=Pie2D\')">2D'.getFixedLabel('PIECHART').'</a>';
}
else 
{
    echo '　<a href="javascript:ajaxchart(\''.'modules/ListViewReport/chartType.php?charttype=Area\')">'.getFixedLabel('AREACHART').'</a>';
    echo '　<a href="javascript:ajaxchart(\''.'modules/ListViewReport/chartType.php?charttype=Bar3D\')">3D'.getFixedLabel('BARCHART').'</a>';
    echo '　<a href="javascript:ajaxchart(\''.'modules/ListViewReport/chartType.php?charttype=Bar2D\')">2D'.getFixedLabel('BARCHART').'</a>';
     
   
}
echo "</h3>";
//echo $strSQL;

echo "<div id='chartdiv' align='left'>The chart will appear within this DIV. This text will be replaced by the chart.</div>";

//绘制图形化报表
$strGraph =str_replace("'",'||N||',$strGraph);
$strGraph=str_replace("<","||M||",$strGraph);
$strGraph=str_replace(">","||V||",$strGraph);


if($adb->num_rows($result)>0&&$xmldata_show=='yes')
{
   
echo "<div id='chartxml' style='display:none'  width='100%'>".$strGraph."</div>";
}

echo "<input type='hidden' style='display:none' value='".$_REQUEST['MultiSerials']."' id='MultiSerials' />";
echo "<input type='hidden' value='".$_REQUEST['rotateNames']."' id='rotateNames' />";
echo "<input type='hidden' value='1' id='chartname'>";
echo "<script>chartRedraw('Column2D','".$strGraph."')</script>";

echo "</div>";

?>



  </body>
</html>