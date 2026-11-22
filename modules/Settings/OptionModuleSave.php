<?php
/**
 * 修改编码格式:统一编码：UTF-8
 * @project 源单类型定制
 * @author xiaoshun 2016-07-29
 */
global $adb,$current_user;
//BUG0067244 yujun 2023-6-6 设置对数据库中presence与default的控制
if($_REQUEST['type'] == 'presence'){
    $tabid= getTabid($_REQUEST['frommodule']);
    $option_tabid=getTabid($_REQUEST['selectmodule']);
    if($option_tabid == 16){
        $option_tabid = 9;
    }
    $query = 'update ld_option_module set presence = ? where option_tabid = ? and tabid = ?';
    $adb->pquery($query, array($_REQUEST['presence_value'],$option_tabid, $tabid));
    ConvertTojsonString(1,array(),'success');
}
if($_REQUEST['type'] == 'default'){
    $tabid= getTabid($_REQUEST['frommodule']);
    $option_tabid=getTabid($_REQUEST['selectmodule']);
    if($option_tabid == 16){
        $option_tabid = 9;
    }
    $all_query = 'update ld_option_module set `default` = 0 where tabid = ?';
    $adb->pquery($all_query, array($tabid));
    $query = 'update ld_option_module set `default` = ? where option_tabid = ? and tabid = ?';
    $adb->pquery($query, array($_REQUEST['default_value'],$option_tabid, $tabid));
    ConvertTojsonString(1,array(),'success');
}


if(isset($_REQUEST['sortOption']) && $_REQUEST['sortOption'] == 'yes'){
    $options = $_REQUEST['option'];
    $tabid = $_REQUEST['selectTabid'];
    
    $options = explode(',',$options);

    foreach($options as $key=>$val){
        $query = 'update ld_option_module set sequence = ? where option_tabid = ? and tabid = ?';
        $adb->pquery($query,array($key+1,$val,$tabid));
    }
}
//拖动排序
if(isset($_REQUEST['dragmove']) && $_REQUEST['dragmove']=='yes')
{

    $frommodule=$_REQUEST['frommodule'];
    $optionmodule=$_REQUEST['selectmodule'];
    $oldsequence=$_REQUEST['oldsequence'];//旧位置
    $newsequence=$_REQUEST['newsequence'];//新位置
    $tabid = getTabid($frommodule);
    $option_tabid = getTabid($optionmodule);
    if($option_tabid == 16){
        $option_tabid = 9;
    }
    if($newsequence > $oldsequence){
        $update_sql1 = 'update ld_option_module set sequence=sequence-1 where tabid=? and sequence<=? and sequence>=?';
    }else{
        $update_sql1 = 'update ld_option_module set sequence=sequence+1 where tabid=? and sequence>=? and sequence<=?';
    }
    $adb->pquery($update_sql1,array($tabid,$newsequence,$oldsequence));
    $update_sql2 = 'update ld_option_module set sequence=? where tabid=? and option_tabid=?';
    $adb->pquery($update_sql2,array($newsequence,$tabid,$option_tabid));

    unsetCache('getOptionModuleData');
    $_REQUEST['diony']='yes';
    ConvertTojsonString(1,array(),'success');
    
}

if(isset($_REQUEST['editModule']) && $_REQUEST['editModule'] == 'yes'){
    if($_REQUEST['frommodule']!='')
    {
        $frommodule=$_REQUEST['frommodule'];
        $optionmodule=$_REQUEST['optionmodule'];
        
        $tabid = getTabid($frommodule);
        $optionid = getTabid($optionmodule);
        if($optionid == 16){
            $optionid = 9;
        }
        $maxrowsshow=$_REQUEST['maxrowsshow'];//选择列表显示的最大行数
        $datarang=$_REQUEST['datarang'];//显示的数据范围
        $withdetail=$_REQUEST['withdetail'];
        
    }
    else
    {
        $maxrowsshow=$_REQUEST['maxrowsshow'];//选择列表显示的最大行数
        $datarang=$_REQUEST['datarang'];//显示的数据范围
        $tabid = $_REQUEST['tabid'];
        $optionid =$_REQUEST['optionid'];
        $withdetail=$_REQUEST['withdetail'];

    }
    $presence =$_REQUEST['presence'];
    $default = $_REQUEST['default'];
    $approve = $_REQUEST['approve'];
    $autobalancecolumn=$_REQUEST['autobalancecolumn'];//自动带出源单剩余数量或金额
//    @edit:liushuai,2021-06-05,reason:【ID1001679】带产品分录的表单，选择源单字段->源单类型定制中增加字段属性参数“剩余数量为0时不自动带出,默认勾选 ：0
    $withbalanceqtycondition = $_REQUEST['withbalanceqtycondition'];//剩余数量为0时不用自动带出 默认0
     if($withdetail=='no')
     {
        $autobalancecolumn='';
         $withbalanceqtycondition = 0;
     }
     $StrictSourceBillColumn_arr=[];
     $column_highsearch_info = array();
	 //审批要求 - 其他设置
	if(!empty($_REQUEST['approve_advft_criteria']) && !empty($_REQUEST['approve_advft_criteria_groups'])){
		$column_highsearch_info['approve']['advft_criteria'] = $_REQUEST['approve_advft_criteria'];
		$column_highsearch_info['approve']['advft_criteria_groups'] = $_REQUEST['approve_advft_criteria_groups'];
	}
     if($withdetail=='yes')
     {
		//chj 2022/6/22 自动带出所选源单的分录明细   设置控制生效条件
		if(!empty($_REQUEST['withdetail_advft_criteria']) && !empty($_REQUEST['withdetail_advft_criteria_groups'])){
			$column_highsearch_info['withdetail']['advft_criteria'] = $_REQUEST['withdetail_advft_criteria'];
			$column_highsearch_info['withdetail']['advft_criteria_groups'] = $_REQUEST['withdetail_advft_criteria_groups'];
		}
         if (!empty($autobalancecolumn) && $autobalancecolumn == 'quantity' && $withbalanceqtycondition == 'yes') {
             $withbalanceqtycondition = 1;
         }else{
             $withbalanceqtycondition = 0;
         }

        //edit:can 20210318 严格参照原单控制
        $system_deploy_arr=getSys_deploy(279);
        
        $deploy_inputvalue_arr=ldcrm_json_decode(html_entity_decode($system_deploy_arr['inputvalue'])); 
         
        foreach($deploy_inputvalue_arr as $info)
        {
             $columnname=$info['value'];
            
             if(!empty($columnname))
             {
                if($_REQUEST[$columnname]=='yes')
                {
                    $StrictSourceBillColumn_arr[]=$columnname;
                    //保存原单限制字段高级查询条件
                    if(isset($_REQUEST[$columnname.'_advft_criteria'])&&!empty($_REQUEST[$columnname.'_advft_criteria'])){
                        $column_highsearch_info[$columnname]['advft_criteria'] = $_REQUEST[$columnname.'_advft_criteria'];
                    }
                    if(isset($_REQUEST[$columnname.'_advft_criteria_groups'])&&!empty($_REQUEST[$columnname.'_advft_criteria_groups'])){
                        $column_highsearch_info[$columnname]['advft_criteria_groups'] = $_REQUEST[$columnname.'_advft_criteria_groups'];
                    }
                }
             }
        }
        
     }
     $column_highsearch_info_json = '';
     if(sizeof($column_highsearch_info)>0){
        $column_highsearch_info_json = json_encode($column_highsearch_info);
     }
    // @edit:dong @date:2020/07/23 @reason: 签到源单类型定制功能优化 添加两个字段
    $required = $_REQUEST['required']; //是否必填
    $enablewhenadding = $_REQUEST['enablewhenadding']; //模块新增时启用
    $automaticallysign = $_REQUEST['automaticallysign']; //模块新增时自动签到
    $uploadwatermark = $_REQUEST['uploadwatermark']; //拜访签到上传图片添加水印

    $no_signin = $_REQUEST['no_signin'];    //超出误差范围，不允许签到
    $allowable_distance = $_REQUEST['allowable_distance'];  //允许误差
    $nosignout_cantsignin = $_REQUEST['nosignout_cantsignin'];  //当天有未签退的外勤时，不允许继续签到
    $allowsupsignout = $_REQUEST['allowsupsignout'];  //签退是否允许补签
    
    $signinmappingrule = $_REQUEST['signmappingrule'];  // 拜访地址映射规则
    $signinmappingcontent = $_REQUEST['signmappingcontent'];  // 拜访地址映射内容
    if($signinmappingrule == 'sql'){
        $cls_AESencryptionbykeyobj = cls_AESencryptionbykey::getInstance();
        $signinmappingcontent = $cls_AESencryptionbykeyobj->getdecryption($signinmappingcontent);// SQL解密
    }

    //edit: xll 2023/05/08 XUQIU1001203 选择源单 增加“显示超链接”字段属性
    $ShowHyperlinks = $_REQUEST['ShowHyperlinks'];  //显示超链接，no：不显示  yes：显示

    //edit: ljj 20240627 选择源单 增加"不允许重复"字段属性
    $unallowrepeat = $_REQUEST['unallowrepeat'];  //no：不启用  yes：启用
     
    $sql='select * from ld_option_module where tabid=? and option_tabid=?';
    $result=$adb->pquery($sql,array($tabid,$optionid));

    if($adb->num_rows($result)<=0)
    {
        
        $sql='select max(sequence) from ld_option_module where tabid=?';
         $result=$adb->pquery($sql,array($tabid));
         $max_sequence=$adb->query_result($result,0,0);
         
        $sql='insert into ld_option_module(tabid,option_tabid,sequence,maxrowsshow,datarang,approve_demand,autobalancevalue,
                             withbalanceqtycondition,effectivecondition,no_signin,allowable_distance,nosignout_cantsignin,
                             allowsupsignout,signinmappingrule,signinmappingcontent,unallowrepeat)
        value(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)';
      
        $adb->pquery($sql,array($tabid,$optionid,$max_sequence+1,$maxrowsshow,$datarang,$approve,$autobalancecolumn,$withbalanceqtycondition,$column_highsearch_info_json,$no_signin,$allowable_distance,
                        $nosignout_cantsignin,$allowsupsignout,$signinmappingrule,$signinmappingcontent,$unallowrepeat));
        if($frommodule == 'CashBill'||$frommodule=='SendCashBill'){
            //收付款单添加源单类型时，分录需要添加对应字段
            AddDetailFieldBySourceModuleName($tabid,$optionid);
        }
        
    }
    
	//至少有一个源单模块为启用，保存失败
	if($presence == 1){
		$query = 'select 1 from ld_option_module where tabid = ? and presence = 0 and option_tabid != ? ';
		$result = $adb->pquery($query,array($tabid,$optionid));
		$num_rows = $adb->num_rows($result);
		if($num_rows <= 0){
			echo 'error';exit();
		}
	}
	//把模块的所有源单模块取消默认
    if($default == '1'){
        $query = 'update ld_option_module set `default` = 0 where tabid = ?';
        $adb->pquery($query,array($tabid));
    }
    $query = 'update ld_option_module set presence=?,`default`=?,approve_demand=?
    ,maxrowsshow=?,datarang=?,required=?,automaticallysign=?,enablewhenadding=?
    ,withdetail=?,strictsourcebillcolums=?,autobalancevalue=?,uploadwatermark=?
    ,withbalanceqtycondition=?,effectivecondition=?,no_signin=?,allowable_distance=?
    ,showhyperlinks=?,nosignout_cantsignin=?,allowsupsignout=?,signinmappingrule=?,signinmappingcontent=?,unallowrepeat=?
    where tabid=? and option_tabid=?';
   
    $adb->pquery($query,array($presence,$default,$approve,$maxrowsshow,$datarang,$required,$automaticallysign
    ,$enablewhenadding,$withdetail,implode(',',$StrictSourceBillColumn_arr),$autobalancecolumn,$uploadwatermark,$withbalanceqtycondition,
    $column_highsearch_info_json,$no_signin,$allowable_distance,$ShowHyperlinks,$nosignout_cantsignin,$allowsupsignout,$signinmappingrule,$signinmappingcontent,$unallowrepeat,
    $tabid,$optionid));
    $sql='select 1 from ld_relatedlists where tabid=? and related_tabid=?';
    $result=$adb->pquery($sql,array($optionid,$tabid));
  
    if($adb->num_rows($result)<=0)
    {
        $sql='select max(id) as id from (select max(relation_id) as id from ld_relatedlists
                    union all
                    select id from ld_relatedlists_seq) as tt ';
        $tmpresult=$adb->pquery($sql,array());
        $tmpmaxid=$adb->query_result($tmpresult,0,'id');
        $tmpmaxid = $tmpmaxid+1;
                    
        $sql='insert into ld_relatedlists(relation_id,tabid,related_tabid,`name`,sequence,label,presence,actions,`type`,related_coltable,wx_presence,wx_sequence,related_advanceset)
                    value(?,?,?,?,?,?,?,?,?,?,?,?,?)';
        $tmpmodulename=getTabname($tabid);

        //ls 2021-07-23 签到源单类型定制保存时，单据详情相关信息页签有多余
        if ($tmpmodulename == 'Singin') {
            $adb->pquery($sql,array($tmpmaxid,$optionid,$tabid,'get_'.strtolower($tmpmodulename).'_list',1000,$tmpmodulename,1,'','signin_datacategory_sql','tmpsourcedetail.id',1,1000,'[{"columnname":"tmpsourcedetail.id","comparator":"e","columncondition":""}]'));
        }
        //zkt 20220919 BUG0056643费用报销单已经关联项目管理，项目管理相关信息，不显示费用报销单信息。
        else if($tmpmodulename == 'Expense'){
            $adb->pquery($sql,array($tmpmaxid,$optionid,$tabid,'get_'.strtolower($tmpmodulename),1000,$tmpmodulename,1,'add','datacategory_sql','expensedetail.id',1,1000,''));
        }
        else if($tmpmodulename == 'Commission'){
            $adb->pquery($sql,array($tmpmaxid,$optionid,$tabid,'get_'.strtolower($tmpmodulename),1000,$tmpmodulename,1,'add','datacategory_sql','commission2payment.id',1,1000,''));
        }
        //zkt 20230529 BUG0066929  费用报销单，点击进入详情，相关信息显示是有一张付款单单，但是点击到付款单之后没有显示数据，还有合同管理模块也是 
        else if($tmpmodulename == 'CashBill' ||$tmpmodulename == 'SendCashBill'){
            $adb->pquery($sql,array($tmpmaxid,$optionid,$tabid,'get_'.strtolower($tmpmodulename),1000,$tmpmodulename,1,'add',strtolower($tmpmodulename).'sourcebill_datacategory_sql','tmp_related_cashbill.entitytypeid',1,1000,''));
        }
        else{
            $adb->pquery($sql,array($tmpmaxid,$optionid,$tabid,'get_'.strtolower($tmpmodulename),1000,$tmpmodulename,1,'add','entitytype_datacategory_sql','tmpsourcedetail.id',1,1000,''));
        }
        $sql='update ld_relatedlists_seq set id=id+1';
        $adb->pquery($sql,array());
    }
    
}




unsetCache('getOptionModuleData');


//收付款单新增源单类型时，需要添加已经添加过的字段
function AddDetailFieldBySourceModuleName($tabid,$optionid)
{
    global $adb;
    if(empty($tabid)||empty($optionid)){
        return ;
    }
    $modulename = getTabname($tabid);
    $sourcemodulename = getTabname($optionid);
    $focus = CRMEntity::getInstance($modulename);
    $Detail_table_scf = $focus->Detail_table_scf;
    
    //收付款单新增源单时需要复制模块字段至当前sourcemodule，根据其他sourcemodule的字段值获取
    if($modulename == 'CashBill'){
        $copysourcemodulename = 'OutboundOrder';//出库单
    }
    else if($modulename == 'SendCashBill'){
        $copysourcemodulename = 'PurchaseInvoice';//采购发票
    }
    
    //非产品分录表添加字段(不包括新增自定义字段：tablename != '$Detail_table_scf')
    $query = "select ld_tabdetailfield.*,tranlable_zh.fieldlabel as zh_fieldlabel,tranlable_en.fieldlabel as en_fieldlabel from ld_tabdetailfield 
LEFT JOIN ld_tranlabel as tranlable_zh ON tranlable_zh.Relateid=tabdetailfieldid and tranlable_zh.trantable='ld_tabdetailfield' and tranlable_zh.languagetype='zh'
LEFT JOIN ld_tranlabel as tranlable_en ON tranlable_en.Relateid=tabdetailfieldid and tranlable_en.trantable='ld_tabdetailfield' and tranlable_en.languagetype='en'
 where ld_tabdetailfield.tabid=? and ld_tabdetailfield.sourcemodule=?  and ld_tabdetailfield.tablename <> '$Detail_table_scf' ORDER BY ld_tabdetailfield.sequence;";
    $result = $adb->pquery($query,array($tabid,$copysourcemodulename));
    $rows = $adb->num_rows($result);
    //zkt BUG0055786产品分录定制-收款单-源单类型报价单缺少显示字段
    if($rows>0){
        for($i=0;$i<$rows;$i++){
            $copy_tabdetailfieldid = $adb->query_result($result,$i,'tabdetailfieldid');
            $columnName = $adb->query_result($result,$i,'columnname');
            $fieldlabel = $adb->query_result($result,$i,'fieldlabel');
            $zh_fieldlabel = $adb->query_result($result,$i,'zh_fieldlabel');
            $en_fieldlabel = $adb->query_result($result,$i,'en_fieldlabel');
            $ispresence = $adb->query_result($result,$i,'presence');
            $selectFieldType = $adb->query_result($result,$i,'fieldtype');
            $typeofdata = $adb->query_result($result,$i,'typeofdata');
            $tableName = $adb->query_result($result,$i,'tablename');
            $width = $adb->query_result($result,$i,'width');
            $edit_permission = $adb->query_result($result,$i,'edit_permission');
            $inputModeType = $adb->query_result($result,$i,'input_type');
            $fieldid = $adb->query_result($result,$i,'fieldid');
            $defaultcolumn = $adb->query_result($result,$i,'defaultcolumn');
            $newline = $adb->query_result($result,$i,'newline');
            $nullfield = $adb->query_result($result,$i,'nullfield');
            $referencemodule = $adb->query_result($result,$i,'referencemodule');
            $datarange = $adb->query_result($result,$i,'datarange');
            $approve_demand = $adb->query_result($result,$i,'approve_demand');
            $maxrowsshow = $adb->query_result($result,$i,'maxrowsshow');
            $bigtype = $adb->query_result($result,$i,'bigtype');
            $savedatabase = $adb->query_result($result,$i,'savedatabase');
            $fieldplaceholder = $adb->query_result($result,$i,'fieldplaceholder');
            $fieldvaluecolor = $adb->query_result($result,$i,'fieldvaluecolor');
            $column_highsearch_info_json = $adb->query_result($result,$i,'effectivecondition');
            $parentbigtype = $adb->query_result($result,$i,'parentbigtype');
            //引用字段修改 
            $relatedmodulefield = $adb->query_result($result,$i,'relatedmodulefield');
            //zxm 20240808 新增一个原单类型未保存subtotal_attr的值
            $subtotal_attr = $adb->query_result($result,$i,'subtotal_attr');//是否计算小计合计

            $sql = 'select * from ld_tabdetailfield where tabid = ? and sourcemodule =? and columnname = ?';
            $select_result = $adb->pquery($sql,array($tabid,$sourcemodulename,$columnName));
            if($adb->num_rows($select_result)<=0){
                
                $query_sql = "insert into ld_tabdetailfield (columnname,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,fieldid,defaultcolumn,newline,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,fieldplaceholder,fieldvaluecolor,effectivecondition,parentbigtype,sourcemodule,relatedmodulefield,subtotal_attr)
                    values(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
                $adb->pquery($query_sql,array($columnName,$zh_fieldlabel,null,$ispresence,$selectFieldType,$typeofdata,$i+1,$tabid,$tableName,$width,$edit_permission,$inputModeType,$fieldid,$defaultcolumn,$newline,$nullfield,$referencemodule,$datarange,$approve_demand,$maxrowsshow,$bigtype,$savedatabase,$fieldplaceholder,$fieldvaluecolor,$column_highsearch_info_json,$parentbigtype,$sourcemodulename,$relatedmodulefield,$subtotal_attr));
                $tabdetailfieldid = $adb->getLastInsertID();
                $tempTablename = 'ld_tabdetailfield';
                $tempTablename_formula = 'ld_tabdetailfield_formula';
                $tempTablename_profile = 'ld_tabdetailprofile';
                $tempFieldid = 'tabdetailfieldid';
                $sqls = "insert into ld_tranlabel (languagetype,trantable,tabid,relateid,fieldlabel) values(?,?,?,?,?)";
                $qparam = array('zh',$tempTablename,$tabid,$tabdetailfieldid,$zh_fieldlabel);
                $qparamz = array('en',$tempTablename,$tabid,$tabdetailfieldid,$en_fieldlabel);
                $adb->pquery($sqls, $qparam);
                $adb->pquery($sqls, $qparamz);
                
                if($inputModeType == 2){
                    $sql="select * from  $tempTablename_formula  where tabid=? and $tempFieldid=";
                    $formula_result=$adb->pquery($sql,array($tabid,$copy_tabdetailfieldid));
                    if($adb->num_rows($formula_result)>0){
                        $formulastring = $adb->query_result($result,0,'formulastring');
                        $columnstring = $adb->query_result($result,0,'columnstring');
                        
                        $sql="select max(sequence) from  $tempTablename_formula  where $tempFieldid in(select $tempFieldid from $tempTablename where tabid=?) ";
                        $max_result_sequence=$adb->pquery($sql,array($tabid));
                        if($adb->num_rows($max_result_sequence)>0)
                            $max_sequence=$adb->query_result($max_result_sequence,0,0)+1;
                        else
                            $max_sequence=1;
                        $sql=" insert $tempTablename_formula(formulastring,columnstring,$tempFieldid,sequence)value(?,?,?,?)";
                        $param=array($formulastring,$columnstring,$tabdetailfieldid,$max_sequence);
        
                        $adb->pquery($sql,$param);
                    }
                }
                //引用字段
                if(in_array($columnName,array('tablesourcetype','tablesourceid','source_total','received_amount','pay_amount','amount')))
                {
                    $sql = "select * from ld_related_detailfield where modulename=? and effect_columnname=?;";
                    $related_result = $adb->pquery($sql,array($modulename,$columnName));
                    $num_rows = $adb->num_rows($related_result);
    				if($num_rows >= 1){
    					$fromvalue_info = $adb->query_result($related_result,0,'fromvalue_info');
    					$fromvalue_info_array = ldcrm_json_decode(decode_html($fromvalue_info));
                        if($columnName == 'billdate'){
                            
                        }
                        else
                        {
                            $optionmodule_column = $fromvalue_info_array[0]['column'];
                            $optionmodule_columntype = $fromvalue_info_array[0]['columntype'];
                            $fromvalue_info_array[] = array('module'=>$sourcemodulename,'column'=>$optionmodule_column,'columntype'=>$optionmodule_columntype);
                        }
                        $query = "update ld_related_detailfield set fromvalue_info = ? where modulename = ? and effect_columnname = ?";
						$adb->pquery($query,array(ldcrm_json_encode($fromvalue_info_array),$modulename,$columnName));
    				}
                }


                //hzx 分录字段权限
                $sql_profile = 'select * from ld_tabdetailprofile where tabdetailfieldid = ?;';
                $result_profile = $adb->pquery($sql_profile,array($copy_tabdetailfieldid));
                if($adb->num_rows($result_profile) > 0){
                    $fieldprofile_array = [];
                    for($i = 0;$i<$adb->num_rows($result_profile);$i++){
                        $userid = $adb->query_result($result_profile,$i,'userid');
                        $presence = $adb->query_result($result_profile,$i,'presence');
                        $profilefieldtype = $adb->query_result($result_profile,$i,'profilefieldtype');
                        $create_profile = $adb->query_result($result_profile,$i,'create_profile');
                        $edit_profile = $adb->query_result($result_profile,$i,'edit_profile');
                        $details_profile = $adb->query_result($result_profile,$i,'details_profile');
                        $fieldprofile_array[] = '('.$tabdetailfieldid.','.$tabid.','.$userid.',"'.$presence.'","'.$profilefieldtype.'","'.$create_profile.'","'.$edit_profile.'","'.$details_profile.'")';
                    }
                    $sql_insertprofile = 'insert into ld_tabdetailprofile(tabdetailfieldid,tabid,userid,presence,profilefieldtype,create_profile,edit_profile,details_profile) values '.implode(',',$fieldprofile_array);
                    $adb->pquery($sql_insertprofile,array());
                }
            }
        }
    }
    
    //产品分录表添加字段
    $query = "select ld_producttoolfield.*,tranlable_zh.fieldlabel as zh_fieldlabel,tranlable_en.fieldlabel as en_fieldlabel from ld_producttoolfield 
LEFT JOIN ld_tranlabel as tranlable_zh ON tranlable_zh.Relateid=producttoolfieldid and tranlable_zh.trantable='ld_producttoolfield' and tranlable_zh.languagetype='zh'
LEFT JOIN ld_tranlabel as tranlable_en ON tranlable_en.Relateid=producttoolfieldid and tranlable_en.trantable='ld_producttoolfield' and tranlable_en.languagetype='en'
 where ld_producttoolfield.tabid=? and ld_producttoolfield.sourcemodule=? ORDER BY ld_producttoolfield.sequence;";
    $result = $adb->pquery($query,array($tabid,$copysourcemodulename));
    $rows = $adb->num_rows($result);
    
    if($rows>0){
        for($i=0;$i<$rows;$i++){
            $copy_producttoolfieldid = $adb->query_result($result,$i,'producttoolfieldid');
            $columnName = $adb->query_result($result,$i,'columnname');
            $fieldlabel = $adb->query_result($result,$i,'fieldlabel');
            $zh_fieldlabel = $adb->query_result($result,$i,'zh_fieldlabel');
            $en_fieldlabel = $adb->query_result($result,$i,'en_fieldlabel');
            $ispresence = $adb->query_result($result,$i,'presence');
            $selectFieldType = $adb->query_result($result,$i,'uitype');
            $typeofdata = $adb->query_result($result,$i,'typeofdata');
            $tableName = $adb->query_result($result,$i,'tablename');
            $width = $adb->query_result($result,$i,'width');
            $edit_permission = $adb->query_result($result,$i,'edit_permission');
            $inputModeType = $adb->query_result($result,$i,'input_type');
            $fieldid = $adb->query_result($result,$i,'fieldid');
            $defaultcolumn = $adb->query_result($result,$i,'defaultcolumn');
            $newline = $adb->query_result($result,$i,'newline');
            $nullfield = $adb->query_result($result,$i,'nullfield');
            $referencemodule = $adb->query_result($result,$i,'referencemodule');
            $datarange = $adb->query_result($result,$i,'datarange');
            $approve_demand = $adb->query_result($result,$i,'approve_demand');
            $maxrowsshow = $adb->query_result($result,$i,'maxrowsshow');
            $bigtype = $adb->query_result($result,$i,'bigtype');
            $savedatabase = $adb->query_result($result,$i,'savedatabase');
            $fieldplaceholder = $adb->query_result($result,$i,'fieldplaceholder');
            $fieldvaluecolor = $adb->query_result($result,$i,'fieldvaluecolor');
            $column_highsearch_info_json = $adb->query_result($result,$i,'effectivecondition');
            $parentbigtype = $adb->query_result($result,$i,'parentbigtype');
            $relatedmodulefield = $adb->query_result($result,$i,'relatedmodulefield');
            
            $sql = 'select * from ld_producttoolfield where tabid = ? and sourcemodule =? and columnname = ?';
            $select_result = $adb->pquery($sql,array($tabid,$sourcemodulename,$columnName));
            if($adb->num_rows($select_result)<=0){
                $adb->pquery('update ld_producttoolfield_seq set id=(select max(producttoolfieldid) from ld_producttoolfield)');
                $max_fieldid = $adb->getUniqueID("ld_producttoolfield");//获取产品自定义表的最大键值
                
                $query_sql = "insert into ld_producttoolfield (producttoolfieldid,columnname,fieldlabel,defaultvalue,presence,uitype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,fieldid,defaultcolumn,newline,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,fieldplaceholder,fieldvaluecolor,effectivecondition,parentbigtype,sourcemodule,relatedmodulefield)
        					values(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
                $adb->pquery($query_sql,array($max_fieldid,$columnName,$zh_fieldlabel,null,$ispresence,$selectFieldType,$typeofdata,$i+1,$tabid,$tableName,$width,$edit_permission,$inputModeType,$fieldid,$defaultcolumn,$newline,$nullfield,$referencemodule,$datarange,$approve_demand,$maxrowsshow,$bigtype,$savedatabase,$fieldplaceholder,$fieldvaluecolor,$column_highsearch_info_json,$parentbigtype,$sourcemodulename,$relatedmodulefield));
                $producttoolfieldid = $max_fieldid;
                $sqls = "insert into ld_tranlabel (languagetype,trantable,tabid,relateid,fieldlabel) values(?,?,?,?,?)";
                $qparam = array('zh','ld_producttoolfield',$tabid,$producttoolfieldid,$zh_fieldlabel);
                $qparamz = array('en','ld_producttoolfield',$tabid,$producttoolfieldid,$en_fieldlabel);
                $adb->pquery($sqls, $qparam);
                $adb->pquery($sqls, $qparamz);
                
                $tempFieldid = 'producttoolfieldid';
                if($inputModeType == 2){
                    $sql="select * from  ld_producttoolfield_formula  where tabid=? and $tempFieldid=";
                    $formula_result=$adb->pquery($sql,array($tabid,$copy_producttoolfieldid));
                    if($adb->num_rows($formula_result)>0){
                        $formulastring = $adb->query_result($result,0,'formulastring');
                        $columnstring = $adb->query_result($result,0,'columnstring');
                        
                        $sql="select max(sequence) from  ld_producttoolfield_formula  where $tempFieldid in(select $tempFieldid from $tempTablename where tabid=?) ";
                        $max_result_sequence=$adb->pquery($sql,array($tabid));
                        if($adb->num_rows($max_result_sequence)>0)
                            $max_sequence=$adb->query_result($max_result_sequence,0,0)+1;
                        else
                            $max_sequence=1;
                        $sql=" insert ld_producttoolfield_formula(formulastring,columnstring,$tempFieldid,sequence)value(?,?,?,?)";
                        $param=array($formulastring,$columnstring,$producttoolfieldid,$max_sequence);
        
                        $adb->pquery($sql,$param);
                    }
                    
                }
                //引用字段
                if(in_array($columnName,array('productsourcetype','productsourceid','product_received_amount','product_pay_amount')))
                {    
                    $sql = "select * from ld_related_detailfield where modulename=? and effect_columnname=?;";
                    $related_result = $adb->pquery($sql,array($modulename,$columnName));
                    $num_rows = $adb->num_rows($related_result);
    				if($num_rows >= 1){
    					$fromvalue_info = $adb->query_result($related_result,0,'fromvalue_info');
    					$fromvalue_info_array = ldcrm_json_decode(decode_html($fromvalue_info));
                        $optionmodule_column = $fromvalue_info_array[0]['column'];
                        $optionmodule_columntype = $fromvalue_info_array[0]['columntype'];
                        $fromvalue_info_array[] = array('module'=>$sourcemodulename,'column'=>$optionmodule_column,'columntype'=>$optionmodule_columntype);
    				}
                    $query = "update ld_related_detailfield set fromvalue_info = ? where modulename = ? and effect_columnname = ?";
    				$adb->pquery($query,array(ldcrm_json_encode($fromvalue_info_array),$modulename,$columnName));
                }

                //hzx 分录字段权限
                $sql_profile = 'select * from ld_producttoolprofile where producttoolfieldid = ?;';
                $result_profile = $adb->pquery($sql_profile,array($copy_producttoolfieldid));
                if($adb->num_rows($result_profile) > 0){
                    $fieldprofile_array = [];
                    for($i = 0;$i<$adb->num_rows($result_profile);$i++){
                        $userid = $adb->query_result($result_profile,$i,'userid');
                        $presence = $adb->query_result($result_profile,$i,'presence');
                        $profilefieldtype = $adb->query_result($result_profile,$i,'profilefieldtype');
                        $create_profile = $adb->query_result($result_profile,$i,'create_profile');
                        $edit_profile = $adb->query_result($result_profile,$i,'edit_profile');
                        $details_profile = $adb->query_result($result_profile,$i,'details_profile');
                        $fieldprofile_array[] = '('.$max_fieldid.','.$tabid.','.$userid.',"'.$presence.'","'.$profilefieldtype.'","'.$create_profile.'","'.$edit_profile.'","'.$details_profile.'")';
                    }
                    $sql_insertprofile = 'insert into ld_producttoolprofile(producttoolfieldid,tabid,userid,presence,profilefieldtype,create_profile,edit_profile,details_profile) values '.implode(',',$fieldprofile_array);
                    $adb->pquery($sql_insertprofile,array());
                }
            
            }
                
            
        }
        $sql='update ld_producttoolfield_seq set id = (select max(producttoolfieldid) from ld_producttoolfield)';
        $adb->pquery($sql,array());
    }
    
    
}

?>