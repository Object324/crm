<?php
//zkt 20231122 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
//@edit:liushuai,2020-09-04,reason:【ID1001073】销售订单、报价单选择产品，输入数量后自动带出价格(后台计算公式)
global $adb,$current_user;
$_REQUEST['diony'] = 'yes';
$param = json_decode($_REQUEST['param'],true);
$relatedproducttoolfield=getRelatedProducttoolfield($_REQUEST['modulename']);

$requestvalues = $_REQUEST['requestvalues'];

$list_ret=array();
if(is_array($relatedproducttoolfield) && isset($requestvalues) && !empty($requestvalues)){
    $need_triggercolumn =array();
    if(!empty($_REQUEST['triggercolumn'])){
        $need_triggercolumn[] =$_REQUEST['triggercolumn'];
    }
    foreach($relatedproducttoolfield as $tmprelatesqlinfo){
        $tmptrigger_columnname_arr = $tmprelatesqlinfo['trigger_columnname'];
        $tmpeffect_columnname_arr = $tmprelatesqlinfo['effect_columnname'];
        if(is_array($tmptrigger_columnname_arr)){
            foreach ($tmptrigger_columnname_arr as $tmpcolumnname){
                if(in_array($tmpcolumnname,$need_triggercolumn)){
                    foreach($tmpeffect_columnname_arr as $tmpeffectcolumnname){
                        if(!in_array($tmpeffectcolumnname,$need_triggercolumn)){
                            $need_triggercolumn[] = $tmpeffectcolumnname;
                        }
                    }
                    break;
                }
            }
        }
    }
    if(isset($_REQUEST['requestvalue_arr'])){
        $requestvalues_arr = $_REQUEST['requestvalue_arr'];
    }else{
        $requestvalues_arr = ldcrm_json_decode($requestvalues);  //字段对应的值
        if(empty($requestvalues_arr)){
            $requestvalues_arr = json_decode($requestvalues,true);
        }
    }

    foreach($relatedproducttoolfield as $relatesqlinfo)
    {
        $tmptrigger_columnname = $relatesqlinfo['trigger_columnname'];
        if(!empty($_REQUEST['triggercolumn'])&&!empty($tmptrigger_columnname)&&!empty($need_triggercolumn)){
            if(empty(array_intersect($tmptrigger_columnname, $need_triggercolumn))){
                continue;
            }
        }
        //BUG20240624-85 ls 240626 只带出当前触发字段相关的sql，不用全部带出（路总）
        /*
        if (!empty($_REQUEST['triggercolumn']) && $_REQUEST['triggercolumn'] != 'undefined' && !in_array($_REQUEST['triggercolumn'],$relatesqlinfo['trigger_columnname'])) {
            continue;
        }
        */
        $module = $relatesqlinfo['modulename'];
   
        $focus = CRMEntity::getInstance($module);
        $related_table = $focus->tab_name;  //模块相关表
        $arr=array();
        $query_sql = $relatesqlinfo['query_sql'];  //待替换sql字符串

    //    旧的需求sql
    //    select listprice from ld_salesorderdetail where productid={hdnProductId} or quantity>{quantity} limit 1;
    //    新的需求sql
    //    SELECT b.discount_percent FROM ld_quotes a LEFT JOIN ld_quotesdetail b ON b.id=a.quoteid WHERE a.deleted=0 AND a.approvestatus<>'已拒绝' AND b.productid='{hdnProductId}' AND a.accountid='{ld_salesorder.accountid}'ORDER BY a.modifiedtime DESC LIMIT 1;
        if (!empty($query_sql)) {
            //sql  替换  1、先替换{hdnProductId} 不带表前缀的
            foreach ($param as $key=>$val){
                 $detailfieldinfo=$focus->detailfieldobj->getFieldInfoobjBykey("columnname",$key);
                if($detailfieldinfo&&$detailfieldinfo->getBigType()=='multipicklist')
                {
                    $val=implode(" |##| ",$val);
                }
                
                $query_sql =  str_replace('{'.$key.'}',addslashes($val),$query_sql);//处理取值带单引号字符
            }
    
            //2、在替换{ld_salesorder.accountid}，带表前缀的。
            foreach ($related_table as $tab_name){
                foreach ($requestvalues_arr as $columnname=>$value){
                    $query_sql =  str_replace('{'.$tab_name.'.'.$columnname.'}',addslashes($value),$query_sql);
                }
            }
        }
		$query_sql=str_replace('{uuid}',$current_user->id,$query_sql);
        $query_sql=str_replace('{inventory_currency}',$_REQUEST['inventory_currency'],$query_sql);
     
        $result = $adb->pquery(html_entity_decode($query_sql,ENT_QUOTES,'utf-8'), array());
       
        $num_rows=$adb->num_rows($result);
        
        $arr['effect_columnname_value']=array();
        $rows=0;
        if($num_rows>0)
        {
            $custom_field_values = $adb->fetch_array($result);
            do{
                //zkt 20231227 BUG0077909销售合同分录新增文本字段保存产品的“规格型号”，用于可修改操作，选择产品后特殊字符显示异常，如图所示
                if(is_array($custom_field_values)){
                    foreach($custom_field_values as $tmpkey=>$tmpvalue){
                        if($tmpkey!=$_REQUEST['triggercolumn']){
                            $custom_field_values[$tmpkey] = html_entity_decode(stripslashes($tmpvalue), ENT_QUOTES);
                        }
                    }
                }
                $arr['effect_columnname_value'][] = $custom_field_values;
                //duan 20221110 多次带出关联字段时，使用带出的字段值作为下一轮查询的值
                for($i=0;$i<sizeof($relatesqlinfo['effect_columnname']);$i++){
                    $tmp_columnname = $relatesqlinfo['effect_columnname'][$i];
                    //触发字段 不是 当前触发字段 ,则取其他触发条件生成的值
                    //zkt 20240725 BUG20240722-31 升级新版本（V8.6.3.3.7）后分录中产品划分无法级联产品细分。（暂时无法外网访问系统）。。 ld_related_producttoolfield表中做的关联关系。
                    if($tmp_columnname!=$_REQUEST['triggercolumn']&&$rows==0){
                        $param[$tmp_columnname] = $custom_field_values[$tmp_columnname];
                    }
                }
                    
                $rows++;
            } while ($custom_field_values = $adb->fetch_array($result));
            
        }
        else{
            for($i=0;$i<sizeof($relatesqlinfo['effect_columnname']);$i++)
             $arr['effect_columnname_value'][]=array($relatesqlinfo['effect_columnname'][$i]=>'');
        }
        $arr['trigger_columnname'] = $relatesqlinfo['trigger_columnname'];
       for($i=0;$i<sizeof($relatesqlinfo['effect_columnname']);$i++)
       {
         $arr['effect_columnname'][]=array('effect_columnname'=>$relatesqlinfo['effect_columnname'][$i],'rows'=>$rows);
       }
    // echo $query_sql."<br>";
            // $arr['effect_columnname'][] = array('effect_columnname'=>$tmpeffect_column,'rows'=>$rows);
        $list_ret['list'][]=$arr;
    }
//dump($query_sql);
    ConvertTojsonString(1,$list_ret,"success");
}
ConvertTojsonString(1,array('list'=>array()),"success");
?>
