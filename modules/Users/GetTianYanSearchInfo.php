<?php
if(!empty($_REQUEST['keywords'])){
    $cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
    $cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
	$keywords = $_REQUEST['keywords'];
    crm_load_class_file('cls_BusinessInformation', 'modules/Users');
    $open_type = $_REQUEST['open_type'];
    crm_load_class_file('cls_GetTianYanCha', 'modules/Users');
    $cls_GetTianYanCha = new cls_GetTianYanCha($open_type,$keywords);
    //permit为模糊询时是否进行工商查询的判断状态，yes进行工商查询，no不进行工商查询
    if(!empty($_REQUEST['permit'])&&$_REQUEST['open_type']=='list'){//是否允许模糊匹配查询
        $permit=$_REQUEST['permit'];
        $businessinformationobj = cls_BusinessInformation::getInstance($_REQUEST['selectmodule']);
        //分词，并对分词结果进行判断，是否要前往进行工商查询
        crm_load_class_file('phpanalysis.class','modules/Users/PHPAnalysis');
        $pa = new PhpAnalysis('utf-8','utf-8',false);

        $analysis_tags = $pa->GetTianYanSearchByKeywords($keywords);
        $analysis_tags_arr = explode(",", $analysis_tags);

        if(!$businessinformationobj->IsEnableBusinessfuzzyquery()){
            $permit = 'no';
        }
        else{
            $analysiis_words_len = 0;
            $noblackwordsstr = "";
            foreach($analysis_tags_arr as $index => $analysis_tagstr)
            {
                global $adb;
                $sql="SELECT * FROM ld_business_wordslist WHERE wordkey=? AND wordtype='blackkey'";
                $result=$adb->pquery($sql,array($analysis_tagstr));
                $rows = $adb->num_rows($result);
                if($rows<=0){
                    $permit='yes';
                    if(mb_strlen($analysis_tagstr)>=2) {
                        $noblackwordsstr = $analysis_tagstr;
                        break;
                    }
                }
                $analysiis_words_len +=strlen($analysis_tagstr);
            }
            if($businessinformationobj->getBusinessfuzzyquerytosearchnum()>mb_strlen($keywords)){
                $permit='no';
            }
        }
        $data['permit'] = $permit;
        if($permit=='no'){

            $data['noblackwordsstr'] = $noblackwordsstr;
            $data['keywordslen'] = mb_strlen($keywords);
            $data['IsEnableBusinessfuzzyquery'] = $businessinformationobj->IsEnableBusinessfuzzyquery();
            ConvertTojsonString(1,$data,"success");
        }
        $cls_GetTianYanCha->setSearchtype('advance');
        $cls_GetTianYanCha->setOperationType("list");
        $cls_GetTianYanCha->setNoblackwordsstr($noblackwordsstr);
        if(isset($_REQUEST['selectmodule'])){
            $cls_GetTianYanCha->setModulename($_REQUEST['selectmodule']);
        }
    }
    else
    {
        $businessinformationobj = cls_BusinessInformation::getInstance($_REQUEST['frommodule']);
        if(!$businessinformationobj->IsEnableBusiness()){
            ConvertTojsonString(-1,array(),getFixedLabel('BUSINESSQUERYPARAMETERSNOTENABLED'));
        }
        $cls_GetTianYanCha->setModulename($_REQUEST['frommodule']);
        $cls_GetTianYanCha->setOperationType("businesssearchbtn");
    }
	$result = $cls_GetTianYanCha->getCurlResult();
    $code = $cls_GetTianYanCha->getCode();
    $reason = $cls_GetTianYanCha->getReason();
	$res = '';
	$state = 'no';
	if(!empty($result)){
		$res = $result;
		$state = 'ok';
	}
	if($open_type == 'info'){
		$data['title'] = getFixedLabel('business') . getFixedLabel('INFORMATION');
	}
    global $current_user;
    //工商查询按钮，返回查询结果
    if(isset($_REQUEST['frommodule']))
    {
        $frommodule = $_REQUEST['frommodule'];
        $businessinformationobj = cls_BusinessInformation::getInstance($frommodule);
        $tabid = getTabid($frommodule);
        $backfillfields_arr = $businessinformationobj->getBackFillfields();
        //工商信息结果界面可回填字段前打钩
        $display_arr = array();
        $displaylabel_arr = array();
        foreach($backfillfields_arr as $key => $backfillinfo)
        {
            $tianyanchaname = $backfillinfo['tianyanchaname'];
            $trancolumnname = $backfillinfo['trancolumnname'];
            $display = 'display:inline;';
            if($trancolumnname == 'null')$display='visibility: hidden;';
            $display_arr[$tianyanchaname] = $display;
            $displaylabel_arr[$tianyanchaname] = $backfillinfo['label'];
        }
        foreach($res as $tmptianyanchaname=>$tmpvalue){
            if(!array_key_exists($tmptianyanchaname,$display_arr)){
                $display_arr[$tmptianyanchaname] = 'visibility: hidden;';
            }
        }
        $data['backfillarr'] = $backfillfields_arr;
        $data['backfilllabelarr'] = $displaylabel_arr;
        if(isset($_REQUEST['stype']))
        {
            $data['displayarr'] = $display_arr;
        }
        if($_REQUEST['stype']=='edit'&&is_admin($current_user)){
            $data['admin'] = 'on';
        }
    }

	$poi_address = $result['poi_address'];
	$data['poi_address'] = $poi_address;
	$data['state'] = $state;
	$data['entries'] = $res;
    $data['code'] = $code;
    $data['reason'] = $reason;
    $business_insterfacekey_deploy_value = cls_BusinessInformation::getBinsterfacedeployvalue();
    $data['business_insterfacekey_deploy_value'] = $business_insterfacekey_deploy_value;
	$data['oktext'] = getFixedLabel('Backfill');
	$data['canceltext'] = getFixedLabel('CANCEL');
	$_REQUEST['diony']='diony';
	ConvertTojsonString(1,$data,"success");
}

//没有工商信息不允许保存设置查询及例外条件匹配
function getSaveBusiness($module,$requestvalues_arr,$savetype='')
{
    global $adb;
    global $current_user;
    $keywords = '';
    $state = 'no';//是否允许保存

    crm_load_class_file('cls_BusinessInformation', 'modules/Users');
    $businessinformationobj = cls_BusinessInformation::getInstance($module);
    $keywords_columnname = $businessinformationobj->getModuleBusinessQueryField('columnname');
    //工商查询字段为空则不进行判断，直接允许保存
    if(empty($keywords_columnname)){
        $state = 'yes';
        return $state;
    }
    //没有工商信息不允许保存参数是否开启
	if(!$businessinformationobj->IsNoBusinessnosave()){
        $state = 'yes';
        return $state;
	}
    $keywords = $requestvalues_arr[$keywords_columnname];
    
    //查询是否满足例外条件
    crm_load_class_file('BusinessCustomView','modules/Users');
    $customview = BusinessCustomView::getInstance($module);
    $queryGenerator =  QueryGenerator::getInstance($module, $current_user,$customview);
    //设置customview高级查询条件，
    $tabid=getTabid($module);
    $viewid = $tabid;
    $queryGenerator->initForCustomViewById($viewid);
    
    $wheresql = $queryGenerator->getWhereClause();
    $baseTableIndex=$queryGenerator->moduleobj->table_index;//主表主键名
    
    //查询sql
    $sql = 'select * from (select 0 as deleted, 1 as '.$baseTableIndex.', ';
    $columnname = '';

    foreach($requestvalues_arr as $key=>$value)
    {
        //zkt 20231129 BUG0076402 客户设置了必须有工商信息才能保存，除了一些国外的客户，通过工商查询类型控制，但是当客户地址中出现引号‘ 时，客户会直接判定没有工商验证，跳过了我们的设置
        if(strpos((string)$value,"'")!== false){
            $value = str_replace("'","\'",(string)$value);
        }
        $value="'".$value."'";
        $columnname .= $value.' as '.$key.',';
    }
    $columnname = trim($columnname,',');
    
    //zkt 20220720 BUG0054013	客户模块设置了无工商信息允许保存的例外条件是：管理员和陈负责的客户可以不设工商信息，该例外规则没生效，管理员仍然需要工商
    $trantablename = 'ld_users';
    if(!empty($queryGenerator->moduleobj->table_name)){
        $trantablename = $queryGenerator->moduleobj->table_name;
    }
    $sql .=$columnname.' from  '.$trantablename;
    
    $sql .=' limit 1) as '.$trantablename.' ';
    //zkt 20220804 BUG0054686（http://218.28.182.50:8082/crmtest/）（河南新特）网页端，客户工商查询设置了【客户类型】不是“个人客户”时“没有工商信息不允许保存”，但是创建客户时，客户类型选择“企业客户”，录入不完整的公司名字依然能够保存客户。以单据编号为ACC8 的客户为例。
    $tablename_arr = $customview->getTablename_arr();
    if(!empty($queryGenerator->whereFieldTables)){
        foreach ($queryGenerator->whereFieldTables as $tmplefttab => $tmpleftsql ){
            //users_assigned_user_id等表关联要添加在sql中，where条件中会用到
            if(!in_array($tmplefttab,$tablename_arr)){
                foreach($tablename_arr as $table_name)
                {
                    //left jion 的表应该为转化后的表名$trantablename:ld_accout、ld_vendord等
                    $tmpleftsql = str_replace($table_name.'.',$trantablename.'.',$tmpleftsql);
                }
                $sql .=' left join '.$tmpleftsql.' ';
            }
            
        }
    }
    
    foreach($tablename_arr as $table_name)
    {
        //where条件中，$tablename_arr内的表名都要替换为转化后的表名$trantablename:ld_accout、ld_vendord
        $wheresql = str_replace($table_name.'.',$trantablename.'.',$wheresql);
    }
    $sql .=$wheresql;
    $sql=str_replace(DATACATEGORYSEACHEMPTYVALUE,'',$sql);
    $result = $adb->pquery($sql,array());
    $rows = $adb->num_rows($result);
    if($rows>0){
        $state = 'yes';
        return $state;
    }
    else{
        //查询工商信息
        crm_load_class_file('cls_GetTianYanCha', 'modules/Users');
    	$cls_GetTianYanCha = new cls_GetTianYanCha('info',$keywords);
        $cls_GetTianYanCha->setOperationType($savetype);
        
        if($savetype == 'import'){
            $cls_GetTianYanCha->setSearchtype('advance');
        }
    	$result = $cls_GetTianYanCha->getCurlResult();
    	$res = '';
    	
    	if(!empty($result)){
    		$res = $result;
    		$state = 'yes';
    	}
        return $state;
    }
}
?>