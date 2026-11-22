<?php
/**
 * User: Administrator
 * Project: crm
 * Date: 2020/4/29 9:11
 * Description:
 */
require_once($root_directory."modules/".$_REQUEST['relatedmodule']."/".$_REQUEST['relatedmodule'].".php");
/*
参数说明
columnname:是查询的列，
relatedtable:当查询统计字段没有使用该模块所对应表的字段时，在from子句中要添加的表
relatedfrom:子表查询，
pagetitle:报表标题
relatedmodule：表示报表所属模块
orderby:表示排序列
currency:表示是否是货币字段，yes:有,no:没有
*/

global $adb;

global $current_language;

global $current_user;

if($_REQUEST['relatedmodule']!='Calendar')
    $field_obj=Field::getInstance($_REQUEST['relatedmodule'],$adb);
else
    $field_obj=Field::getInstance('Events',$adb);

////图表需要查询字段
$_REQUEST['columnname'] = base64_decode($_REQUEST['columnname']);
$_REQUEST['queryfrom'] = base64_decode($_REQUEST['queryfrom']);
$_REQUEST['querywhere'] = base64_decode($_REQUEST['querywhere']);
$_REQUEST['relatedfrom'] = base64_decode((string)$_REQUEST['relatedfrom']);
$_REQUEST['queryowner'] = base64_decode($_REQUEST['queryowner']);



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

$ChartColumn= str_replace('//B/',' ',$_REQUEST['columnname']);
$ChartColumn=str_replace('//N/',"'",$ChartColumn);
$groupBy=str_replace('//N/',"'",(string)$_REQUEST['groupby']);
$groupbyordercol= $_REQUEST['groupbyordercol'];//合计排序字段
$countlabel = $_REQUEST['countlabel'];//合计字段别名

//模块列表的统计图  改用page_list_query做条件。原来的chartwhere不会随着筛选变化  BUG20240902-72
if(!empty($_REQUEST['page_list_query'])){
    crm_load_class_file('cls_MyCRMcrypt',"Register");
    $cls_MyCRMcryptobj=new cls_MyCRMcrypt();
    $page_list_query = $_REQUEST['page_list_query'];
    $page_list_query = $cls_MyCRMcryptobj->decode($page_list_query);
    $focus=CRMEntity::getInstance($_REQUEST['relatedmodule']);
    $page_list_query = " inner join ($page_list_query)tmpsql on tmpsql.$focus->table_index=$focus->table_name.$focus->table_index ";
}else{
    $page_list_query = $ChartWhere.$ChartOwner;
}

$arrOut=array();
if(stripos($ChartColumn,'ld_users.last_name')!==false)
{
    $ChartColumn.=',ld_users.wx_userid,ld_users.id as userid ';
}
if(stripos($ChartColumn,'users_assigned_user_id.last_name')!==false)
{
    $ChartColumn.=',users_assigned_user_id.wx_userid,users_assigned_user_id.id as userid ';
}

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
    if(!strpos($ChartFrom, 'ld_users')){
        $ChartFrom.=' LEFT JOIN ld_users ON ld_users.id = ld_account.smownerid ';
    }
}
if(isset($_REQUEST['relatedaction'])&& $_REQUEST['relatedaction']!=' ')
{
    include("modules/".$_REQUEST['relatedmodule']."/".$_REQUEST['relatedaction'].".php");
    $focus=new $_REQUEST['relatedaction']($ChartFrom,$page_list_query,'');
    $functname=$_REQUEST['functionname'];
    $strSQL=$focus->$functname();

}

else if(isset($_REQUEST['groupby']))
{
    //	0020372: 客户>列表>注册资金分布统计,排列顺序，不妥
    //20715: 客户>列表界面：注册资金分布统计、年营业额分布统计，跳转页面出现代码
    //Eidtor:gyq_64MS Reason:下拉框改进 Date:2018/3/16 0016 上午 11:20
    $orderby_fieldname = '';
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
    //zxm 20230505 BUG0065859   销售机会模块 进度漏斗商机阶段分布统计 点进去报表项目名称顺序错乱，不是按照下拉框顺序排列的
    if(!empty($_REQUEST['groupby']) && trim($_REQUEST['groupby'])=='ld_potential.sales_stage'){
        $ChartFrom  .= ' LEFT JOIN (
              SELECT
                id sales_stageid,listvalue,sequence
              FROM ld_picklist_values
                LEFT JOIN ld_picklist_set
                  ON ld_picklist_set.listid = ld_picklist_values.listid
              WHERE listname = \'sales_stage\' AND relatetable = \'ld_field\')
    AS ld_sales_stage ON ld_sales_stage.listvalue = ld_potential.sales_stage';
    }
    if(!empty($_REQUEST['groupby']) && trim($_REQUEST['groupby'])=='ld_potentialscf.possibility'){
        $groupby_arr = explode('.',$_REQUEST['groupby']);
        $orderby_fieldname = $groupby_arr[1];
    }

    //17359: 客户>列表>本次查询统计表：所有统计表显示数据没有与数据分类下的数据保持一致。
    $relate_focus=CRMEntity::getInstance($_REQUEST['relatedmodule']);

    if(!empty($_REQUEST['querytype']) && $_REQUEST['querytype'] == 1){
        $ChartFrom = str_replace('left join ld_users','right join ld_users',strtolower($ChartFrom));
        $strSQL="select $ChartColumn  $ChartFrom $page_list_query group by ".strtolower($groupBy);
    }else{
        $strSQL="select $ChartColumn  $ChartFrom  where $relate_focus->table_name.$relate_focus->table_index in( select distinct $relate_focus->table_name.$relate_focus->table_index".$ChartFrom.$page_list_query.")  group by ".strtolower($groupBy);
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
    //zxm 20230505 BUG0065859   销售机会模块 进度漏斗商机阶段分布统计 点进去报表项目名称顺序错乱，不是按照下拉框顺序排列的
    if(!empty($_REQUEST['groupby']) && trim($_REQUEST['groupby'])=='ld_potential.sales_stage'){
        $strSQL .=' order by ld_sales_stage.sequence asc,sales_stageid asc ';
    }
    //duan 20240226 统计图根据下拉框顺序显示,以销售机会可能性分布为例,读取下拉框顺序,然后使用field函数进行自定义排序
    //(理论上前面的排序都可以整合进来,但本着能跑尽量不要动的原则,希望后面加的可以考虑往这里面加)
    if(!empty($orderby_fieldname)){
        $tmp_sql = 'SELECT listvalue
            FROM ld_picklist_values LEFT JOIN ld_picklist_set ON ld_picklist_set.listid = ld_picklist_values.listid
            WHERE listname = ? AND relatetable = ?
            ORDER BY ld_picklist_values.sequence';
        $tmp_result = $adb->pquery($tmp_sql,[$orderby_fieldname,'ld_field']);
        $num_rows = $adb->num_rows($tmp_result);
        if($num_rows>0){
            $listvalue_arr = [];
            for ($i=0;$i<$num_rows;$i++){
                $tmp_value = $adb->query_result($tmp_result,$i,'listvalue');
                $listvalue_arr[] = "'".$tmp_value."'";
            }
        }
        $strSQL .=' ORDER BY FIELD('.$orderby_fieldname.','.implode(',',$listvalue_arr).') ';
    }
    else if(!empty($groupbyordercol))
    {
        //这个是排序 不是groupby......!!!!
        $strSQL='select * from ('.$strSQL.') as testtmp order by '.$groupbyordercol.' desc ';
    }else if(!empty($countlabel)&&!isset($_REQUEST['orderby'])){
        //zxm 20240717 BUG20240716-24 客户档案-负责人分布统计图的排序（占比从大到小排序），及统计图x轴分责任斜体显示。
        $strSQL='select * from ('.$strSQL.') as testtmp order by '.$countlabel.' desc ';
    }


}
else
{
    $strSQL= "select count( ld_".$_REQUEST['chartable'].".".strtolower($_REQUEST['columnname'])." ) as countname "."ld_".$_REQUEST['relatedtable'].".".$_REQUEST['fieldname']." ".$ChartFrom.$page_list_query." Group by " ."ld_".$_REQUEST['chartable'].".".$_REQUEST['columnname'];
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
//echo $strSQL;
//die();
$result=$adb->pquery($strSQL,array());
$lineName= array();
$index ='';         //值的索引
while ($row=$adb->fetch_array($result)){
    if(array_key_exists('last_name',$row)&&isKehu001ServerPc()=='yes')
    {
        $row['last_name']=getUserRealNameBywxuserid($row['wx_userid']);
    }
    //$index = count($row)/2-1;
    //edit: xll 2023/07/28 BUG0069779 跟进记录查看范围选人后，点击“跟进记录数量负责人/月度统计”图表，数据统计错误（通用问题）
    //edit: xll 2023/08/10 BUG0070698 销售机会--报表分析按钮--销售阶段分布统计，合计与占比显示不正确 补充，下面的几个报表占比、合计显示都不正确
    $index = isset($_REQUEST['countlabel']) ? $_REQUEST['countlabel'] : (count($row)/2-1);
    $arrOut['lists'][] = $row;
    $arrOut['allCount'] += intval($row[strtolower($_REQUEST['countlabel'])?:$index]);
    if($_REQUEST['style'] == 'cols'){
        $row[1] = $row[1] ?: '无';
        if (!in_array($row[1], $lineName)) {
            $lineName[] = $row[1];
        }
    }
}
if($_REQUEST['style'] == 'cols'){  //横向纵向都有输出 例如：客户类型客户状态分布统计表
    $lineNameLength = count($lineName);
    foreach ($arrOut['lists'] as $k=>$v){

        $fieldName = $v[strtolower($_REQUEST['countfield'])?:0] ?: '无';

//        初始化多个变量
//        for($i =0;$i<$index;$i++){
//            $varName = 'fieldValue'.$i;
//            $$varName = '';
//        }
        //第一项为fieldname的默认值 只统计第二列
//        循环判断查询到的数据是否含有其他列的名字
        if($v[1]){
            $i = array_search($v[1],$lineName);
            $varName = 'fieldValue'.$i;
            $$varName = intval($v[$index]);
            for ($j =0;$j<$lineNameLength;$j++){
                if($i != $j){
                    $varName = 'fieldValue'.$j;
                    $$varName = 0;
                }
            }
        }else{
            $varName = 'fieldValue0';
            $$varName = intval($v[$index]);
            for ($j =0;$j<$lineNameLength;$j++){
                if($j != 0){
                    $varName = 'fieldValue'.$j;
                    $$varName = 0;
                }
            }
        }


//        计算百分比
        //zxm 20220815 除数为0时候 做判断
        $proportion = $arrOut['allCount']==0?0:round(intval($v[$index])/$arrOut['allCount'],4)*100;
//        去除重复行名  第一列
        if(is_array($arrOut['fieldName'])&& in_array($fieldName,$arrOut['fieldName'])){
            foreach ($arrOut['fieldName'] as $key => $value){
                if($arrOut['fieldName'][$key] ==$fieldName){
                    $tempValue =0;
                    for ($i=0;$i<$lineNameLength;$i++){
                        $varName='fieldValue'.$i;
                        $arrOut[$varName][$key] += $$varName;
                        $tempValue +=(float) $arrOut[$varName][$key];
                    }
                    // 重新计算百分比
                    $arrOut['proportion'][$key] = $arrOut['allCount']==0?0:round($tempValue/$arrOut['allCount'],4)*100;
                }
            }
        }else{
//            不重复直接赋值
            for ($i=0;$i<$lineNameLength;$i++){
                $varName='fieldValue'.$i;
                $arrOut[$varName][] += $$varName;
            }
            $arrOut['fieldName'][] = $fieldName;
            $arrOut['proportion'][] = $proportion;
        }
    }
    //横向统计
    $arrOut['lineCount'] =array();
    for ($i=0;$i<$lineNameLength;$i++){
        $varName='fieldValue'.$i;
        for ($j=0;$j<count($arrOut['fieldName']);$j++){
            $arrOut['lineCount'][$j] += $arrOut[$varName][$j];
        }
    }
    //竖向统计
    $arrOut['colCount'] =array();
    for ($j=0;$j<count($arrOut['fieldName']);$j++){
        for ($i=0;$i<$lineNameLength;$i++){
            $varName='fieldValue'.$i;
            $arrOut['colCount'][$i] += $arrOut[$varName][$j];
        }
    }
    $arrOut['lineName'] = $lineName;
}else{
    foreach ($arrOut['lists'] as $k=>$v){
        $fieldName = $v[strtolower($_REQUEST['countfield'])?:0] ?: '无';
        $fieldValue = intval($v[strtolower($_REQUEST['countlabel'])?:1]);
        $proportion = $arrOut['allCount']==0?0:round($fieldValue/$arrOut['allCount'],4)*100;
   
        //多个空字段去重
        if(is_array($arrOut['fieldName']) && in_array($fieldName,$arrOut['fieldName'])){
            foreach ($arrOut['fieldName'] as $key => $value){
                if($arrOut['fieldName'][$key] ==$fieldName){
                    
                    $arrOut['fieldValue'][$key] += $fieldValue;
                    $arrOut['proportion'][$key] += $proportion;
                }
            }
        }else{
            if(array_key_exists('last_name',$v)&&stripos($ChartColumn,'ld_users.last_name')!==false&&isKehu001ServerPc()=='yes')
            {
                $fieldName=getUserRealNameBywxuserid($v['wx_userid']);
            }
            $arrOut['fieldName'][] = $fieldName;
            //wyt 221008 BUG0057349 在客户模块，最下面的统计图表中，金额字段没有使用千分位
            $arrOut['fieldValue'][] = $fieldValue;
            //wyt 220922 BUG0056819 在客户模块，最下面的统计图表中，金额字段没有使用千分位
            $arrOut['fieldValue2'][] = number_format($fieldValue);
            $arrOut['proportion'][] = $proportion;
        }

    }
}
//必须设置否则弹出层无法弹出 diony和ConvertTojsonString函数的输出有关
$_REQUEST['diony']='diony';
$arrOut['ratios'] = getFixedLabel('RATIOS');
$arrOut['total'] = getFixedLabel('TOTAL');
$arrOut['allCount'] = number_format($arrOut['allCount']);
$arrOut['title'] = getFixedLabel($_REQUEST['pagetitle']);
$arrOut['oktext'] = getFixedLabel('CLOSE');
$smarty=new lingdangCRM_Smarty();
if(!$_REQUEST['quantityUnit']){
    $arrOut['QUNANTITYUNIT'] = getFixedLabel('QUANTITY');//0044119: 本次查询统计图表：鼠标放到图表上的时候，显示的 tips 应该根据统计的数量或者金额显示为数量或金额，而不是图表名称
    $smarty->assign('QUNANTITYUNIT',getFixedLabel('QUANTITY')); //默认为数量
}else{
    $arrOut['QUNANTITYUNIT'] = getFixedLabel($_REQUEST['quantityUnit']);
    $smarty->assign('QUNANTITYUNIT',getFixedLabel($_REQUEST['quantityUnit'])); //外部传入
}
$lineNameLength ? $smarty->assign('lineNameLength' ,$lineNameLength) :'';
$smarty->assign('style',$_REQUEST['style']);
$smarty->assign('listViewReportArr',$arrOut);
$content=$smarty->fetch('ListViewReport.tpl');
$arrOut['content'] = $content;
ConvertTojsonString(1,$arrOut,"success");
exit();


