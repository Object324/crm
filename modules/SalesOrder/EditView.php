<?php
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global  $theme, $currentModule, $current_user, $adb;
require('user_privileges/user_language_'.$current_user->id.'.php');
$deployarrays=array();//系统参数
/*crm_load_class_file('cls_ProductDetailUitype_PageRecordValue','include/ProductDetailsHtml');

$obj=new cls_ProductDetailUitype_PageRecordValue('SalesOrder','create','','');
$dataHeaderInfos=$obj->getValues();
echo '<pre>';
print_r($dataHeaderInfos);
echo '</pre>';
exit();*/

$focus = CRMEntity::getInstance($currentModule);
$smarty = new lingdangCRM_Smarty();
//选择源单，获取多个源单模块
$sourcemodules=getSourceModule($currentModule);
if(sizeof($sourcemodules)>0)
{
	if((isset($_REQUEST['fromid']) && $_REQUEST['fromid'] >0) )
	{

			$salesorder_id = $_REQUEST['fromid'];
	   
		
	   foreach($sourcemodules as $tmp=>$sourcemoduleinfo)
		{
			if($_REQUEST['frommodule']==$sourcemoduleinfo['entitytype'])
			{
				$isfromsourcemodule='yes';
				break;
			}
		}
		if($isfromsourcemodule=='yes')
		{
		   $_REQUEST['selectsourcename'] = $_REQUEST['frommodule'];
		
			$sourcefocus=CRMEntity::getInstance($_REQUEST['selectsourcename']);
			$sourcedetailtable=$sourcefocus->Detail_table;
			$productsql=" select lineitem_id from $sourcedetailtable where id=? ";
			$productresult=$adb->pquery($productsql,array($salesorder_id));
			for($i=0;$i<$adb->num_rows($productresult);$i++)
			{
				$_REQUEST['listval'].=$adb->query_result($productresult,$i,'lineitem_id').',';
			}
		}
	}
    $smarty->assign('MODULE_ACTIVATE',true);
}
$smarty->assign('SOURCEMODULE',$sourcemodules);
foreach($sourcemodules as $val){
    if($val['default'] == 1){
        $isSelectModule = $val['entitytype'];
    }
}
//added to fix the issue4600
$searchurl = getBasic_Advance_SearchURL();
$smarty->assign("SEARCH", $searchurl);

$currencyid = 1;

//报价单合并创建合同订单
if(isset($_REQUEST['merge']) && $_REQUEST['merge']=='yes'){
    $select_id = $_REQUEST['select_id'];
    if($select_id == 'all'){
        $clran['viewname'] = $_REQUEST['viewname'];
        $clran['SearchScope'] = $_REQUEST['SearchScope'];
        $storearray=getSelectedRecords($clran,'Quotes','all','');
        $select_id = implode(';',$storearray).';';
    }
    crm_load_class_file('ModuleMergeCreate','data');
    $ModuleMergeCreate = new ModuleMergeCreate('Quotes','SalesOrder',$select_id);
    $qfocus = $ModuleMergeCreate->getMergeCreate();
    $productdetailhtml_focus=$qfocus;
    $productdetail_mode='module_create';
    $focus->column_fields['selectlistval']=implode(",",explode(";",$select_id));
    //edit:can 20220325 050622: （合创广虹）http://124.70.71.1:85/crm/index.php [^] 报价单合并创建合同订单，选择源单 为空，不显示。
    $_REQUEST['selectlistval']=$focus->column_fields['selectlistval'];
    //$smarty->assign('ASSOCIATEDPRODUCTS',$ProductDetailsHtml->getProductDetailsHtml($qfocus,'module_create'));
}

/**
 * 更新操作
 * edit:can
 * date:20131211
 * reason:6191: 合同订单、发票复制界面：报价单字段、合同订单字段选择值后页面刷新，结果页面名称复制中合同订单、发票变成了新增合同订单、发票
 * */
if(isset($_REQUEST['duplicate_from'])&&$_REQUEST['duplicate_from']!=''){
    $_REQUEST['isDuplicate']='true';
}
$smarty->assign('FROM_MODULE','');//关联创建合同订单，判断合同订单是从哪个模块创建的，字段公式会用到的,
                                  //  因为产品关联创建字段公式以不含税单价为基准
//产品关联创建 合同订单 和 相关信息创建合同订单，传入的ID值不一样
if($_REQUEST['frommodule']=='Products'&&$_REQUEST['fromid']>0)
{
    $_REQUEST['product_id']=$_REQUEST['fromid'];
}
if (isset ($_REQUEST['productid']) && $_REQUEST['productid'] != ''){
	$_REQUEST['product_id'] = $_REQUEST['productid'];

    
}
crm_load_function_file("getConvertQuoteToSoObject","include/utils",'EditViewUtils');
crm_load_function_file('getInventoryCurrencyInfo','include/utils','InventoryUtils');
if (isset ($_REQUEST['record']) && $_REQUEST['record'] != '') {
	if (isset ($_REQUEST['convertmode']) && $_REQUEST['convertmode'] == 'update_quote_val'){
		//Updating the Selected Quote Value in Edit Mode
		foreach ($focus->column_fields as $fieldname => $val) {
			if (isset ($_REQUEST[$fieldname])) {
				$value = $_REQUEST[$fieldname];
				$focus->column_fields[$fieldname] = $value;
			}
		}
		//Handling for dateformat in due_date lingdang_field
		if ($focus->column_fields['duedate'] != '') {
			$curr_due_date = $focus->column_fields['duedate'];
			$focus->column_fields['duedate'] = getValidDBInsertDateValue($curr_due_date);
		}

		$quoteid = $focus->column_fields['quote_id'];
       
		$smarty->assign("QUOTE_ID", $focus->column_fields['quote_id']);
		$quote_focus = CRMEntity::getInstance('Quotes');
		$quote_focus->id = $quoteid;
		$quote_focus->retrieve_entity_info($quoteid, "Quotes");
		$focus = getConvertQuoteToSoObject($focus, $quote_focus, $quoteid);
		$focus->id = $_REQUEST['record'];
		$focus->mode = 'edit';
		$focus->name = $focus->column_fields[$focus->list_link_field];
		$currencyid = $quote_focus->column_fields['currency_id'];
		$rate = $quote_focus->column_fields['conversion_rate'];

	}
    
    else if (isset ($_REQUEST['convertmode']) && $_REQUEST['convertmode'] == 'update_potential_val') 
    {       foreach ($focus->column_fields as $fieldname => $val) {
        			if (isset ($_REQUEST[$fieldname])) {
        				$value = $_REQUEST[$fieldname];
        				$focus->column_fields[$fieldname] = $value;
        			}
        		}
            $tmp_fromid=$focus->column_fields['potential_id'];
			$potentials_focus = CRMEntity::getInstance('Potentials');
			$quoteidstr = getLineitemId($tmp_fromid,$potentials_focus->moduleName);
			$potentials_focus->lineitemIds = $quoteidstr;
			$potentials_focus->mode = 'edit';
			$potentials_focus->id=$tmp_fromid;
			$potentials_focus->retrieve_entity_info($tmp_fromid, $frommodule);
			$currencyid = $potentials_focus->column_fields['currency_id'];
			$rate = $potentials_focus->column_fields['conversion_rate'];
		   $productdetailhtml_focus=$potentials_focus;
            $productdetail_mode='module_create';
			//$smarty->assign('ASSOCIATEDPRODUCTS',$ProductDetailsHtml->getProductDetailsHtml($potentials_focus,'module_create'));
			$smarty->assign("CONVERT_MODE", vtlib_purify($_REQUEST['convertmode']));
    }
     else {
		$focus->id = $_REQUEST['record'];
		$focus->mode = 'edit';
		$focus->retrieve_entity_info($_REQUEST['record'], "SalesOrder");
        $fieldinfo=$focus->fieldobj->getFieldInfoobjBykey('columnname',$focus->getSmownerColumName());
        if($focus->column_fields[$fieldinfo->getFieldName()]!=$current_user->id)
        {
                crm_load_class_file('cls_CurUserDataScope','include/ListView');
                $datascopeobj=cls_CurUserDataScope::getInstance($currentModule,'record');
                $datascopeobj->isMyViewData($_REQUEST['record']);
        }
		$focus->name = $focus->column_fields[$focus->list_link_field];
        //审批流程begin
        //判断单据的审批状态，如果是已审批或者审批中，小编辑功能失效
		//require_once('modules/Approve/Approve.php');
        //$approve=new Approve();
		$approve = Approve::getInstance($currentModule);
       /* if(isset($_REQUEST['ajax']) && $_REQUEST['ajax']==true){
            echo $approve->EditBlocks($focus->column_fields['assigned_user_id'],$focus->id);
            exit();
        }*/
        
         if($_REQUEST['isDuplicate'] != 'true')
        {
            //判断是否已批准（是否允许编辑)
           $retapproveinfo= $focus->getModuleLogic($currentModule)->checkEditInfo($currentModule,$_REQUEST['record']);
            if($retapproveinfo!=''&&strtolower($retapproveinfo)!='success')
           {
             $_REQUEST['diony']='yes';
             ConvertTojsonString("-1",array(),$retapproveinfo);
           }
            
        }
        //审批流程end
        
	}
}
else {
	if (isset ($_REQUEST['convertmode']) && $_REQUEST['convertmode'] == 'update_quote_val') {
		//Updating the Select Quote Value in Create Mode
		foreach ($focus->column_fields as $fieldname => $val) {
			if (isset ($_REQUEST[$fieldname])) {
				$value = $_REQUEST[$fieldname];
				$focus->column_fields[$fieldname] = $value;
			}
		}
		//Handling for dateformat in due_date lingdang_field
		if ($focus->column_fields['duedate'] != '') {
			$curr_due_date = $focus->column_fields['duedate'];
			$focus->column_fields['duedate'] = getValidDBInsertDateValue($curr_due_date);
		}
		$quoteid = $focus->column_fields['quote_id'];
		$quote_focus = CRMEntity::getInstance('Quotes');;
	//	$quoteidstr = substrTd($quoteid . ',',0,$quote_focus->moduleName);
      // $quote_focus->lineitemIds=$quoteidstr;
		$quote_focus->id = $quoteidstr;
		$quote_focus->retrieve_entity_info($quoteid, "Quotes");
		$focus = getConvertQuoteToSoObject($focus, $quote_focus, $quoteid);
		$currencyid = $quote_focus->column_fields['currency_id'];
		$rate = $quote_focus->column_fields['conversion_rate'];
		$smarty->assign("QUOTE_ID", $focus->column_fields['quote_id']);
	//	$smarty->assign('ASSOCIATEDPRODUCTS',$ProductDetailsHtml->getProductDetailsHtml($quote_focus,'module_create'));
       
		$smarty->assign("MODE", $quote_focus->mode);
                $selectAccountIDSQL='SELECT accountid,contactid
            FROM ld_quotes 
             where quoteid='.$focus->column_fields['quote_id'];
        $resultINFO = $adb->pquery($selectAccountIDSQL,array());
		$_REQUEST['fromid']=$quoteid;
	}
	//合同选择上级合同
	if (isset ($_REQUEST['convertmode']) && $_REQUEST['convertmode'] == 'update_so_val') {
		foreach ($focus->column_fields as $fieldname => $val) {
			if (isset ($_REQUEST[$fieldname])) {
				$value = $_REQUEST[$fieldname];
				$focus->column_fields[$fieldname] = $value;
			}
		}
		$_REQUEST['fromid']=$focus->column_fields['salesorder_id'];
		$_REQUEST['frommodule'] = 'SalesOrder';
	}
    if (isset ($_REQUEST['convertmode']) && $_REQUEST['convertmode'] == 'update_potential_val') {
		foreach ($focus->column_fields as $fieldname => $val) {
			if (isset ($_REQUEST[$fieldname])) {
				$value = $_REQUEST[$fieldname];
				$focus->column_fields[$fieldname] = $value;
			}
		}
		$_REQUEST['fromid']=$focus->column_fields['potential_id'];
		$_REQUEST['frommodule'] = 'Potentials';
	}
    
}

if (isset ($_REQUEST['fromid']) && $_REQUEST['fromid'] != ''&& $_REQUEST['fromid'] != 0) {
    if($_REQUEST['frommodule']=='')
		$frommodule = getSalesEntityType($_REQUEST['fromid']);
    else
        $frommodule=$_REQUEST['frommodule'];
    $isSourceModule='no';
  foreach($sourcemodules as $tmpsourceinfo)
  {
    if($frommodule==$tmpsourceinfo['entitytype'])
    {
        //edit:can 20210401 045254: （https://61mis.com/kfbcrm [^]）自定义表单11（带产品分类）相关信息中新建合同订单，源单编号和产品信息都没有带过去
        $isSourceModule='yes';
        $isSelectModule=$tmpsourceinfo['entitytype'];
        $focus->column_fields['quote_id']=$_REQUEST['fromid'];
    }
  }
    if($frommodule=='SalesOrder'||$isSourceModule=='yes')
    { 
        $quote_focus = new $frommodule();
        $quoteidstr = substrTd($_REQUEST['fromid'] . ',',0,$frommodule);
        $quote_focus->lineitemIds = $quoteidstr;
  		$quote_focus->retrieve_entity_info($_REQUEST['fromid'], $frommodule);
      
  		$quote_focus->mode = 'edit';
         $quote_focus->id=$_REQUEST['fromid'];
  	
      
  		$currencyid = $quote_focus->column_fields['currency_id'];
  		$rate = $quote_focus->column_fields['conversion_rate'];
        $productdetailhtml_focus=$quote_focus;
        $productdetail_mode='sourcemodule_create';
       // $smarty->assign('ASSOCIATEDPRODUCTS',$ProductDetailsHtml->getProductDetailsHtml($quote_focus,'sourcemodule_create'));
    }
      
}
 $potentialdeployarray=getSys_deploy(205);//设置销售机会是否显示产品分录明细:0是，1否
 $deploy_value=$potentialdeployarray['deploy_value'];
 $smarty->assign('DEPLOY_VALUE_205',$deploy_value);
 
 
 
if (isset ($_REQUEST['isDuplicate']) && $_REQUEST['isDuplicate'] == 'true') {
	$focus->id = $_REQUEST['record'];
	$smarty->assign("DUPLICATE_FROM", $focus->id);
    crm_load_function_file('getInventoryCurrencyInfo','include/utils','InventoryUtils');
    $inventory_cur_info = getInventoryCurrencyInfo($currentModule, $focus->id);
	$currencyid = $inventory_cur_info['currency_id'];
    //复制,产品明细丢失
    $productdetailhtml_focus=$focus;
     
    $productdetail_mode='edit';
    
	//$smarty->assign('ASSOCIATEDPRODUCTS',$ProductDetailsHtml->getProductDetailsHtml($focus,'edit'));//复制
   
	$focus->id = "";
	$focus->mode = '';
    $smarty->assign("MODE", $focus->mode);
    

	/**
	 * 复制时，负责人设置为自己
	 * @author Tujt 2015-07-20
	 */
      //单据复制，默认值设置,https://www.tapd.cn/my_worktable?source_user=2004112531&workspace_id=20699121&workitem_type=story&workitem_id=1120699121001000517#&filter_close=true
	//$focus->column_fields['assigned_user_id'] = $current_user->id;
}else{
	//报价单关联创建合同订单,选择报价单
	if(isset ($_REQUEST['quoteid']) && $_REQUEST['quoteid'] != ''){
		$_REQUEST['quote_id'] = $_REQUEST['quoteid'];
	}
    if($_REQUEST['frommodule']=='Quotes')
    {
        $_REQUEST['quote_id']=$_REQUEST['fromid'];
    }
    //报价单关联创建
    //$_REQUEST['frommodule']=='Quotes':先选择报价单，然后再选择销售机会（产品明细），要添加这个判断
	if ( $_REQUEST['frommodule']=='Quotes'&&isset ($_REQUEST['quote_id']) && $_REQUEST['quote_id'] != ''&& $_REQUEST['quote_id'] != 0) {
		$quoteid = $_REQUEST['quote_id'];
		$focus->column_fields['quote_id'] = $quoteid;
		$quote_focus = CRMEntity::getInstance('Quotes');
		$quoteidstr = getLineitemId($quoteid,$quote_focus->moduleName);
		$quote_focus->lineitemIds = $quoteidstr;
		$quote_focus->mode = 'edit';
        $quote_focus->id=$quoteid;
		$quote_focus->retrieve_entity_info($quoteid, "Quotes");
        //8664: 销售>合同订单明细界面:合同订单明细界面，点击【编辑】按钮，"基本信息"栏下，点击报价单名称后“+”按钮，点一条单据，页面自动刷新，单据没有保存在文本框中，
		//$focus->column_fields['quote_id']=$quote_focus->column_fields['quoteid'];
		$currencyid = $quote_focus->column_fields['currency_id'];
		$rate = $quote_focus->column_fields['conversion_rate'];
         $productdetailhtml_focus=$quote_focus;
        $productdetail_mode='module_create';
	//	$smarty->assign('ASSOCIATEDPRODUCTS',$ProductDetailsHtml->getProductDetailsHtml($quote_focus,'module_create'));
		$smarty->assign("CONVERT_MODE", vtlib_purify($_REQUEST['convertmode']));
        if($_REQUEST['record']>0)
        {
            //8664: 销售>合同订单明细界面:合同订单明细界面，点击【编辑】按钮，"基本信息"栏下，点击报价单名称后“+”按钮，点一条单据，页面自动刷新，单据没有保存在文本框中，
            $focus->mode='edit';
            $smarty->assign("MODE", $focus->mode);
        }
	}
    else if($potentialdeployarray['deploy_value']==0&&$frommodule=='Potentials')
    {       
        
            $tmp_fromid=$_REQUEST['fromid'];
			$potentials_focus = CRMEntity::getInstance($frommodule);
			$quoteidstr = getLineitemId($tmp_fromid,$potentials_focus->moduleName);
           
			$potentials_focus->lineitemIds = $quoteidstr;
			$potentials_focus->mode = 'edit';
			$potentials_focus->id=$tmp_fromid;
			$potentials_focus->retrieve_entity_info($tmp_fromid, $frommodule);
			$currencyid = $potentials_focus->column_fields['currency_id'];
			$rate = $potentials_focus->column_fields['conversion_rate'];
		    $productdetailhtml_focus=$potentials_focus;
            $productdetail_mode='module_create';
			//$smarty->assign('ASSOCIATEDPRODUCTS',$ProductDetailsHtml->getProductDetailsHtml($potentials_focus,'module_create'));
			$smarty->assign("CONVERT_MODE", vtlib_purify($_REQUEST['convertmode']));
    }
    else if ($frommodule == 'QuotesChange') {
	//	$frommodule = getSalesEntityType($_REQUEST['fromid']);
        
		if($frommodule == 'QuotesChange'){
			$quotechange_id = $_REQUEST['fromid'];
			$focus->column_fields['quote_id'] = $quotechange_id;
			$quotechange_focus = CRMEntity::getInstance('QuotesChange');
			$quoteidstr = getLineitemId($quotechange_id,$quotechange_focus->moduleName);
			$quotechange_focus->lineitemIds = $quoteidstr;
			$quotechange_focus->mode = 'edit';
			$quotechange_focus->id=$quotechange_id;
			$quotechange_focus->retrieve_entity_info($quotechange_id, "QuotesChange");
			$currencyid = $quotechange_focus->column_fields['currency_id'];
			$rate = $quotechange_focus->column_fields['conversion_rate'];
		    $productdetailhtml_focus=$quotechange_focus;
            $productdetail_mode='module_create';
			//$smarty->assign('ASSOCIATEDPRODUCTS',$ProductDetailsHtml->getProductDetailsHtml($quotechange_focus,'module_create'));
			$smarty->assign("CONVERT_MODE", vtlib_purify($_REQUEST['convertmode']));
		}
	}else if (isset ($_REQUEST['product_id']) && $_REQUEST['product_id'] != '') {
		$focus->column_fields['product_id'] = $_REQUEST['product_id'];
        $productdetailhtml_focus=$focus;
        $productdetail_mode='product_create';
		//$smarty->assign('ASSOCIATEDPRODUCTS',$ProductDetailsHtml->getProductDetailsHtml($focus,'product_create'));//产品关联创建
        $smarty->assign('FROM_MODULE','Products');//
	}else{
		if($_REQUEST['merge'] != 'yes'&&$_REQUEST['fromid']<=0){
			if(!empty($focus->id)){
			     $productdetailhtml_focus=$focus;
                $productdetail_mode='edit';
			//	$smarty->assign('ASSOCIATEDPRODUCTS',$ProductDetailsHtml->getProductDetailsHtml($focus,'edit'));//单据编辑
			}else{
			    $productdetailhtml_focus=$focus;
                $productdetail_mode='create';
			//	$smarty->assign('ASSOCIATEDPRODUCTS',$ProductDetailsHtml->getProductDetailsHtml($focus,'create'));//单据新增
                //zkt 20221219关联选择单据字段-相关创建带出产品详情
                if(isset($_REQUEST['frommodule'])&&get_file_address($_REQUEST['frommodule'],'ProductDetails')&&$_REQUEST['relatedcreate']=='yes'){
                    $infos=Field::getAllFieldTypeInfo($adb);
                    foreach($infos as $index=>$info)
                    {
                        if($info['type']!=''&&$info['type']!='Users'&&$info['fieldtype']=='reference'){
                            $reference_uitypes[$info['uitype']]=$info['type'];//获取相关的referencefield
                        }
                    }
                    $tmpfields = $focus->fieldobj->getModuleFields();
                    foreach($tmpfields as $tmpindex=>$tmpinfo)
                    {
                        if(!empty($tmpinfo))
                        {
                            $tmpuitype = $tmpinfo->getUIType();
                            if($tmpinfo->getBigType()=='reference'&&$tmpinfo->getadddetails()=='yes'
                            &&isset($reference_uitypes[$tmpuitype])&&$reference_uitypes[$tmpuitype] == $_REQUEST['frommodule']){
                                $frommodule=$_REQUEST['frommodule'];
                                $tmp_fromid=$_REQUEST['fromid'];
                    			$tmp_focus = CRMEntity::getInstance($frommodule);
                    			$tmpidstr = getLineitemId($tmp_fromid,$tmp_focus->moduleName);
                    			$tmp_focus->lineitemIds = $tmpidstr;
                    			$tmp_focus->mode = 'edit';
                    			$tmp_focus->id=$tmp_fromid;
                    		    $productdetailhtml_focus=$tmp_focus;
                                $productdetail_mode='module_create';
                                break;
                            }
                        }
                    }
                 }
			}
		}
        //ls 2022-04-27 0051306 财务菜单>项目审核表单模块>点击进入详细界面>相关信息：关联创建销售合同没有将产品信息自动带出，服务合同是可以的
        else if(empty($_REQUEST['productid'])){
            if(!empty($_REQUEST['fromid']) && $_REQUEST['fromid'] > 0){
                $frommodule=$_REQUEST['frommodule'];

                $frommodule_focus = CRMEntity::getInstance($frommodule);
                if(get_file_address($frommodule,'ProductDetails'))
                {
                    $frommodule= $_REQUEST['frommodule'];
                    $idstr = substrTd($_REQUEST['fromid'] . ',',0,$frommodule);

                    $frommodule_focus->lineitemIds = $idstr;
                    $frommodule_focus->retrieve_entity_info($_REQUEST['fromid'], $frommodule);
                    $frommodule_focus->mode = 'edit';
                    $frommodule_focus->id=$_REQUEST['fromid'];
                    $currencyid = $frommodule_focus->column_fields['currency_id'];
                    $rate = $frommodule_focus->column_fields['conversion_rate'];
                    $productdetailhtml_focus = $frommodule_focus;
                    $productdetail_mode = 'sourcemodule_create';
                }
                else
                {
                    $productdetailhtml_focus = $focus;
                    $productdetail_mode = 'create';
                }
            }
        }
		$smarty->assign("MODE", $focus->mode);
	}
}

//原单的单据名字
if(!empty($focus->column_fields['quote_id'])){
	$isSelectModule = getSalesEntityType($focus->column_fields['quote_id']);

	if(!empty($isSelectModule)){
		$smarty->assign('LISTVAL_PURCHASEORDER_NO',getModuleHref($isSelectModule,$focus->column_fields['quote_id']));
	}
	$smarty->assign('LISTVAL_RECORD',$focus->column_fields['quote_id']);
}

$smarty->assign('ISADMIN',$current_user->is_admin);
$smarty->assign('SELECTSOURCENAME',$isSelectModule);
$smarty->assign('ISSOURCEMODULE',$isSelectModule);
if(empty($_REQUEST['record']) && $focus->mode != 'edit'){
	setObjectValuesFromRequest($focus);
}

/**
 * 创建单据时，编号为自动生成后的编号
 * @project 创建单据时，自动生成编号
 * @author Tujt 2014-05-13
 */
if($focus->mode!='edit'){
	$value = $focus->Library('SystemCode')->getModuleSeqNumRecord($_REQUEST['module']);
	if(!$value) $value = getFixedLabel('MSG_AUTO_GEN_ON_SAVE');
	$focus->column_fields['salesorder_no'] = $value;
}
$theme_path = "themes/" . $theme . "/";
$image_path = $theme_path . "images/";
$disp_view = getView($focus->mode);
$mode = $focus->mode;


/* 关联创建单据统一处理方法 begin */
if(isset($_REQUEST['parent_id']) && $_REQUEST['parent_id'] > 0){
	$focus->getModuleLogic($currentModule)->setQuickCreateColumn($_REQUEST['parent_module'],$_REQUEST['parent_id']);
}
if(isset($_REQUEST['fromid']) && $_REQUEST['fromid'] > 0){
	$focus->getModuleLogic($currentModule)->setQuickCreateColumnValues($currentModule,$_REQUEST['fromid']);
}
//新增 - 中能
$VersionInfo = getVersionInfo();
if($VersionInfo['account'] == 'zhongneng' && $focus->mode == '' && empty($_REQUEST['isDuplicate']) && array_key_exists('wareid',$focus->column_fields)){
	$user_focus = CRMEntity::getInstance('Users');
	$user_focus->retrieve_entity_info($current_user->id, 'Users');
	$wareid = $user_focus->column_fields['wareid'];
	$focus->column_fields['wareid'] = $wareid;
}
if($VersionInfo['trade']=='zhongfu')
{
    
    $smarty->assign("sostatusImg",$focus->getSostatusImage());
}
if((isset ($_REQUEST['listval']) && $_REQUEST['listval'] != ""))
{
    $isSelectModule = $_REQUEST['selectsourcename'];
    $so_focus = CRMEntity::getInstance($isSelectModule);
    
    $so_focus->lineitemIds = rtrim($_REQUEST['listval'], ",");
    $so_focus->id=$_REQUEST['fromid'];
    $sourcedetailtable=$so_focus->Detail_table;
	
    $setListVal = count(explode(',',$so_focus->lineitemIds));
	//原单的单据名字
    $smarty->assign('LISTVAL_PURCHASEORDER_NO',getEditListValName($so_focus->lineitemIds,$isSelectModule));
    $smarty->assign("RELATEDORDERIDSTRING", $_REQUEST['fromid']);//源单id
	$fieldinfo=$focus->getSourceFieldInfo();
    if($fieldinfo&&$fieldinfo->getFieldName()!='')
        $focus->column_fields[$fieldinfo->getFieldName()]=$_REQUEST['fromid'];//关联创建原单
}
/**
 * 合同订单相关信息变更单子合同新建部分（主要是获取上级合同）
 **/
if($_REQUEST['fromid']&&$_REQUEST['fromid']>0&&$_REQUEST['frommodule']=='SalesOrder'&&($_REQUEST['relatedcreate']=='yes' || $_REQUEST['convertmode'] == 'update_so_val'))
{
    $sql="
            select 
                ld_account.accountid,ld_contactdetails.contactid ,
                accountname, ld_contactdetails.lastname,
                ld_salesorder.contactrecordsid 
            from ld_salesorder 
            left  join ld_account on ld_account.accountid=ld_salesorder.accountid 
            left join ld_contactdetails on ld_contactdetails.contactid=ld_salesorder.contactid 
            where salesorderid=? ";
    $result=$adb->pquery($sql,array($_REQUEST['fromid']));
    if($adb->num_rows($result)>0)
    {
        if(array_key_exists("account_id",$focus->column_fields))
        {
           
            $focus->column_fields['account_id']=$adb->query_result($result,0,'accountid');
        }
          if(array_key_exists("contact_id",$focus->column_fields))
        {
            $focus->column_fields['contact_id']=$adb->query_result($result,0,'contactid');
        }
        if(array_key_exists("contactrecordsid",$focus->column_fields))
        {
            $focus->column_fields['contactrecordsid']=$adb->query_result($result,0,'contactrecordsid');
        }
    }
    $focus->id = $_REQUEST['fromid'];
	
    $inventory_cur_info = getInventoryCurrencyInfo($currentModule, $focus->id);
	$currencyid = $inventory_cur_info['currency_id'];
	$focus->mode = 'create';
    //edit:can 2020-11-24 合同（改名维修单）下推 变更单（子合同）带不出原合同信息，表头信息及表体产品信息，客户原本一直使用子合同实现合同变更及转单需求
   // $productdetailhtml_focus=$focus;
   // $productdetail_mode='';
        
	//$smarty->assign('ASSOCIATEDPRODUCTS',$ProductDetailsHtml->getProductDetailsHtml($focus));
	$focus->id = "";
	$focus->mode = '';
	$smarty->assign("MODE", $focus->mode);
}
global $global_pick_list_values,$edit_column_fields_value;

$act_data=getBlocks($currentModule, $disp_view, $mode, $focus->column_fields);
$smarty->assign("COLUMN_FIELDS_VALUE",ldcrm_json_encode($edit_column_fields_value));
//edit:can 20200723 必须放在getBlocks后边（因为明细字段的布局规则）
$ProductDetailsHtml = crm_load_class_obj('cls_productDetailsHtml',"modules/$currentModule/ProductDetails",array($currentModule));
$ProductDetailsData = crm_load_class_obj('cls_productDetailsData',"modules/$currentModule/ProductDetails",array($currentModule));
 //复制,产品明细丢失
 if (isset ($_REQUEST['isDuplicate']) && $_REQUEST['isDuplicate'] == 'true') {
 

    $productdetailhtml_focus->id=$_REQUEST['record'];
    $productdetailhtml_focus->mode='edit';
}


$smarty->assign('ASSOCIATEDPRODUCTS',$ProductDetailsHtml->getProductDetailsHtml($productdetailhtml_focus,$productdetail_mode));
if (isset ($_REQUEST['isDuplicate']) && $_REQUEST['isDuplicate'] == 'true') {
 
 $focus->id='';   
 $focus->mode='create';//@edit:liushuai,2021-07-06,reason:0046728: （81mis.com/kfbcrm）销售管理-合同，单据编号SO78，该单据处于审批中，复制该单据时，界面没有“保存并提交审批”按钮
}
$productFields['fields']=$ProductDetailsData->moduleProductToolField;

$productFields['system_deploy']=$ProductDetailsData->system_deploy_formulas;	//单据分录明细中录入价税合计重算的字段
$systemmethod = $ProductDetailsData->getSystemMethod();

$versiontrade=getVersionTradeInfo();
$smarty->assign('TRADEJIJIN',$versiontrade['trade']);
$productFields['trade']=$versiontrade['trade'];
$productFields['lengthdecimaldigits'] = $systemmethod['lengthdecimaldigits'];
$productFields['lengthprice'] = $systemmethod['lengthprice'];
$productFields['SystemArgument'] = $systemmethod['SystemArgument'];
$productFields['addproductrow'] = $systemmethod['addproductrow'];

$smarty->assign('BASECOLUMN',$ProductDetailsData->module_productbasefield);//计算公式中基准字段


 /**
 * 更新操作
 * edit:can
 * date:20131223
 * reason:添加富文本框
 * */
if(isset($act_data['RichText']) && !empty($act_data['RichText'])){
	$richText=$act_data['RichText'];
	unset($act_data['RichText']);
	$smarty->assign('RICHTEXTBOX',implode(',',$richText));
	$smarty->assign('RICHTEXTCOUNT',sizeof($richText));
}else{
	$smarty->assign('RICHTEXTBOX','');
	$smarty->assign('RICHTEXTCOUNT','0');
}
$smarty->assign('BLOCKS',$act_data);
$smarty->assign("OP_MODE", $disp_view);

$smarty->assign("MODULE", $currentModule);
$smarty->assign("SINGLE_MOD", 'SalesOrder');


//$category = getParentTab();
//$smarty->assign("CATEGORY", $category);
//
if (isset ($focus->name))
	$smarty->assign("NAME", $focus->name);
else
	$smarty->assign("NAME", "");

if (isset ($cust_fld)) {
	$smarty->assign("CUSTOMFIELD", $cust_fld);
}
if (isset ($_REQUEST['return_module']))
	$smarty->assign("RETURN_MODULE", vtlib_purify($_REQUEST['return_module']));
else
	$smarty->assign("RETURN_MODULE", "SalesOrder");
if (isset ($_REQUEST['return_action']))
	$smarty->assign("RETURN_ACTION", vtlib_purify($_REQUEST['return_action']));
else
	$smarty->assign("RETURN_ACTION", "index");
if (isset ($_REQUEST['return_id']))
	$smarty->assign("RETURN_ID", vtlib_purify($_REQUEST['return_id']));
if (isset ($_REQUEST['return_viewname']))
	$smarty->assign("RETURN_VIEWNAME", vtlib_purify($_REQUEST['return_viewname']));
$smarty->assign("THEME", $theme);
$smarty->assign("IMAGE_PATH", $image_path);
$smarty->assign("MODULE", "SalesOrder");
$smarty->assign("PRINT_URL", "phprint.php?jt=" . session_id() . $GLOBALS['request_string']);
$smarty->assign("ID", $focus->id);
//$tabid = getTabid("SalesOrder");
//
$data =$focus->fieldobj->split_validationdataArray();
$smarty->assign("VALIDATION_DATA_FIELDNAME", $data['fieldname']);
$smarty->assign("VALIDATION_DATA_FIELDDATATYPE", $data['datatype']);
$smarty->assign("VALIDATION_DATA_FIELDLABEL", $data['fieldlabel']);

global $adb;

if ($focus->mode == 'edit') {
	$inventory_cur_info = getInventoryCurrencyInfo('SalesOrder', $focus->id);
	$smarty->assign("INV_CURRENCY_ID", $inventory_cur_info['currency_id']);
} else {
	$smarty->assign("INV_CURRENCY_ID", $currencyid);
}
$smarty->assign("DUPLICATE",vtlib_purify($_REQUEST['isDuplicate']));
$smarty->assign("RELATEDCREATE",vtlib_purify($_REQUEST['relatedcreate']));
$smarty->assign('CREATEMODE', vtlib_purify($_REQUEST['createmode']));
global $global_pick_list_depencyfield;
crm_load_class_file('lingdang_DependencyPicklist','modules/PickList');
$picklistDependencyDatasource = lingdang_DependencyPicklist::getPicklistDependencyDatasource($currentModule);
$smarty->assign("PICKIST_DEPENDENCY_DATASOURCE", ldcrm_json_encode($picklistDependencyDatasource));
$smarty->assign("PICKLISTDEPENCYFIELDS", ldcrm_json_encode($global_pick_list_depencyfield));
/*---仓库信息---*/
require_once ('include/Stock/CommonStock.php');
$wareresult = selWareAll($current_user->id);
for($i = 0; $i<$adb->num_rows($wareresult); $i++)
{
    $wareArray[$adb->query_result($wareresult, $i, "id")] = $adb->query_result($wareresult, $i, "name");
}
$smarty->assign("WAREALL", $wareArray);
/*
edit:can
date:20130530
reason:创建和编辑权限分开
*/

if( (isset($_REQUEST['Create'])&&($_REQUEST['Create']=='true' || $_REQUEST['Create']=='yes'))||$_REQUEST['relatedcreate']=='yes'||$_REQUEST['isDuplicate']=='true'){
	$smarty->assign('CREATE','true');
}
else{
	$smarty->assign('CREATE','false');
}
if (isset($_REQUEST['record']) && $_REQUEST['record'] != '') {
    $smarty->assign("ACCOUNTID", $focus->column_fields['account_id']);
    $smarty->assign("CONTACTID", $focus->column_fields['contact_id']);
    $smarty->assign("POTENTIALID", $focus->column_fields['potential_id']);
}
if($focus->mode != 'edit'){            
    //判断仓库是否为空，为空直接不创建，不为空继续判断仓库是否可用
    $deployarray=getSys_deploy('56');
    $warehouseid = $deployarray['deploy_value'];
    if(!empty($warehouseid)){
        //判断仓库是否可用，yes可用，如果为no不可用，在保存后做弹出
        crm_load_function_file('getWarehouseStatus','include/Stock','CommonStock');
        if(getWarehouseStatus($warehouseid) == 'no'){
            $wareresult = selWareAll();
            for($i = 0; $i<$adb->num_rows($wareresult); $i++){
                $wareArray[$adb->query_result($wareresult,$i,"id")] = $adb->query_result($wareresult, $i, "name");
            }
            $smarty->assign("WAREALL", $wareArray);
            $smarty->assign("WAREHOUSE", $wareArray[$warehouseid]);
            $smarty->assign("OUTBOUNDORDERCREATE","yes");
        }
    }
}
if(!empty($_REQUEST['frommodule']) && $_REQUEST['frommodule'] == 'Accounts' && $_REQUEST['account_id'] > 0){
	$smarty->assign('FROM_MODULE',$_REQUEST['frommodule']);
}
$smarty->assign('ACCOUNTID',$focus->column_fields['account_id']);
$smarty->assign('CONTACTID',$focus->column_fields['contact_id']);

$version_info = getVersionInfo();
$smarty->assign('VERSIONTRADE',$version_info['trade']);
$smarty->assign('VERSION_ACCOUNT',$VersionInfo['account']);
$smarty->assign('VERSIONINFO',$version_info);
/**
 * @by andy
 * @date 20140729
 * @reason 系统编号改进
 */ 
$isallow= $focus->Library('SystemCode')->getModentityfield('isallow',$currentModule);
$smarty->assign('ISALLOW',$isallow);
//获取客户和联系人区块信息
//$block_info = getBlockDisplayInfo('AccountContacts');
////显示位置
//$smarty->assign('DISPLAY_POSITION',$block_info['display_position']);
// //是否显示
//if($block_info['is_display'] == 0)
//    $smarty->assign('BESTATUS','YES');
//else
//    $smarty->assign('BESTATUS','NO');
/**
 * 编辑、创建页面，增加更多信息左边栏
 * @author Tujt 2014-04-10
 */
$smarty->assign('CURRENT_DATE',date('Y-m-d',time()));
//获取版本类型
$version_info = getVersionInfo();
$smarty->assign('VERSIONINFO',$version_info);
$smarty->assign('VERSIONTRADE',$version_info['trade']);
//源美特殊控制
if($version_info['account'] == 'yuanmei'){
	$smarty->assign('ordertype_onclick',$focus->getOrdertypeByField());
}



$relmodule = (isset($currentModule))?$currentModule:$_REQUEST['module'];
$fields=$focus->fieldobj->getFieldListArray();
$fields['module']=$currentModule;
$smarty->assign('FIELDINFOJSON',json_encode($fields['fields']));
$smarty->assign("MODULELINKFIELD",$focus->list_link_field);
$smarty->assign("SMOWNERCOLUMNNAME",$focus->getSmownerColumName());
//$smarty->assign("IS_REL_LIST",isPresentRelatedLists($relmodule));
$smarty->assign("PICKLISTCONTENT",ldcrm_json_encode($global_pick_list_values));


//echo '<pre>';
//print_r($cls_strategy->getstrategyByProductId($ProductDetailsHtml->ProductDetailsData->strategyproductids));
//echo '</pre>';

setGLobalURLSmarty($smarty);//设置js,css等访问路径
$ProductDetailsHtml->ProductDetailsData->productid;

//相关信息日期高级查询
Crm_load_class_file("CommonView","modules/CustomView");
$smarty->assign("DATETIMESTR",json_encode(CommonView::stdFilterDateTimeStr()));
$smarty->assign("ReferenceUitypes",cls_module_uitype::getAllUitypes());
$smarty->assign("UITYPEMODULES",cls_module_uitype::getUitypeModules());
//editor:gyq_161 reason:带分录模块弹出层   2019/11/20 11:30
$arr = $ProductDetailsHtml->detailPopup($smarty,$fields,$productFields,$data);
ConvertTojsonString(1,$arr,"success");
/*
	$smarty->display("DetailView/InventoryEditView.tpl");
else
	$smarty->display('DetailView/InventoryCreateView.tpl');
 if($focus->mode == 'edit')
        $str=$smarty->fetch("DetailView/PopupInventoryEditView.tpl");
 else
        $str=$smarty->fetch("DetailView/PopupInventoryCreateView.tpl");
 //wym BUG0074511 当关联创建模块包含附件或图片类型的引用字段时，focus对象上有fieldjsondata（此时foucs->id无值）
 $fieldjsondata = empty($focus->fieldjsondata)?array():$focus->fieldjsondata;
 if($focus->id>0&&$focus->fieldobj->getFieldInfoBykeyValue("uitype",1109,'fieldname')!='')
       $fieldjsondata[$focus->fieldobj->getFieldInfoBykeyValue("uitype",1109,'fieldname')]=json_decode( getAttachmentsTableInfo($focus->id,$currentModule));
 if($focus->id>0&&$focus->fieldobj->getFieldInfoBykeyValue("uitype",69,'fieldname')!='')
       $fieldjsondata[$focus->fieldobj->getFieldInfoBykeyValue("uitype",69,'fieldname')]= json_decode(getImageFileInfo($focus->id,$currentModule));

    $_REQUEST['diony']='diony';
    if($version_info['account'] == 'yuanmei'){
    	$arr['ordertype_onclick']=$focus->getOrdertypeByField();
    }
    else
    {
        $arr['ordertype_onclick']='no';
    }
    $arr['detailtablename']=$focus->Detail_table;
    $arr['detailtablenamescf']=$focus->Detail_table_scf;
    //明细字段
    $arr['productfieldinfo']=$productFields;
    $arr['detailfields']=$ProductDetailsHtml->ProductDetailsData->productToolFields->getFieldListArray();
    $arr['detailfieldmodudle']='Products';
    //价格策略
    crm_load_class_file("cls_strategy",'modules/Products');
    $cls_strategy=new cls_strategy();
    $arr["productstrategyobj"]=$cls_strategy->getstrategyByProductId($ProductDetailsHtml->ProductDetailsData->strategyproductids);
    $arr['title']=getTranstab($currentModule);
    $arr['oktext']=getFixedLabel("SAVE");
    $arr['canceltext']=getFixedLabel("CANCEL");
    $arr['content']='';
    $arr['detailfieldmodule']='Products';
    $arr['allcontent']=$str;
    $arr['fieldname']=$data['fieldname'];
    $arr['datatype']=$data['datatype'];
    $arr['fieldlabel']=$data['fieldlabel'];
    $arr['fields']=$fields['fields'];
    $arr['filejsondata']=$fieldjsondata;
    $arr['isadmin']=$current_user->is_admin;
    $arr['picklistDependencyDatasource']=$picklistDependencyDatasource;
    $arr['columnfields_value']=$focus->column_fields;
    $arr['picklistcontent']=$global_pick_list_values;
    $arr['picklistdepencyfields']=$global_pick_list_depencyfield;
	$arr['isduplicate'] ='yes';
    ///保存判断
    $arr["validatasave"]=getValidataSave($currentModule);

    //布局规则
    crm_load_class_file('cls_fieldrule','include/fields/fieldrule');
    $fieldruleobj=cls_fieldrule::getInstance($currentModule);
    $arr['fieldrulefieldnames']=$fieldruleobj->getAllFieldNameSetChangeEvent();//获取所有的触发字段

    ConvertTojsonString(1,$arr,"success");
*/
?>