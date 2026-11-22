<?php

crm_load_class_file("CommonView","modules/CustomView");
global $theme,$currentModule,$current_user,$adb;
$smarty=new lingdangCRM_Smarty();
$theme_path="themes/".$theme."/";
$image_path=$theme_path."images/";
if(isset($_REQUEST['returnModule']) && $_REQUEST['returnModule']!= "")
{
    $module = $_REQUEST['returnModule'];
}
$tabid = getTabid($module);

$productListViewAll=getProdcutListViewAll($tabid,$module);




/**
 *@edit:andy
 *@date:0916
 *@reason:左右结构改进，左边选择字段若右边已有则不显示
 *@version:
 */
$rightlist = getHaveProductListView($tabid,$productListViewAll);


if(!empty($rightlist))
{
    //zkt 20230309 BUG0062655 kfbcrm 客户页面---设置两个同名字段‘公司电话’---查询分类里只能选择到一个‘公司电话’
    $productListViewAll = array_diff_assoc($productListViewAll,$rightlist);
    /**
     * 服务收费时，有可能客户字段的标签名跟服务收费的标签名不一致，所以需要用键值进行查重（键值是一致的）
     * @reason 0014843: 服务收费>序时簿,关于新增数据分类的问题
     * @author Tujt 2015-05-11
     */
    if('ServiceCharge' == $module){
        $productListViewAll = array_diff_key($productListViewAll,$rightlist);
    }
}

$smarty->assign("PRODUCTLISTVIEWALL",$productListViewAll);//获取所有模块界面字段

$smarty->assign("HAVEPRODUCTLISTVIEWALL",$rightlist);//获取已选择列头
$pagewdith = 100;

function getProdcutListViewAll($tabid,$module)
{
    global $adb,$current_user;
    $languageType=getLanguageType($current_user);



    require_once(globalStatic::$root_directory.'include/ProductDetails/ProductToolFields.php');

    $tabIdAll = array();
    $templatearr=array();
    $ProductToolFields = new ProductToolFields($module);


    if(get_file_address($module,'ProductDetails')||get_file_address($module,'ContactsDetails')||get_file_address($module,'VendorsDetails'))
    {
        crm_load_class_file("ProductDetails",'include/ProductDetails');

        $focus=CRMEntity::getInstance($module);
        $main_module_fields=$focus->fieldobj->getModuleFields();
        $tranmodule = $module;
        $is_module = $module;
        $noPresenceFields = array();//特殊控制，不显示字段
        //单据分录定制隐藏“调整”后，单据列表还是显示“调整”字段
        if(get_file_address($module,'ProductDetails')){
            $ModuleProductToolField = $ProductToolFields->getModuleProductToolField($tabid,$languageType);
            if(empty($ModuleProductToolField['adjustment'])){
                $noPresenceFields[] = 'adjustment';
            }
        }

        foreach($main_module_fields as $fieldname=>$fieldinfo)
        {
            $tablename=$fieldinfo->getTableName();
            $columnname=$fieldinfo->getColumnName();
            if($fieldinfo&&($fieldinfo->getSaveDataBase()=='no'))
                continue;
            if(($module=='ServiceCharge' || $module=='Accounts')&&!in_array($tablename,$focus->tab_name)&&$tablename!='ld_attachments')
            {
                continue;//服务收费：过滤掉客户中联系人字段信息
            }
            $typeofdata=$fieldinfo->getTypeOfData();
            $types=explode('~',$typeofdata);
            $typeofname=$types[0];
            $fieldlabel=$fieldinfo->getFieldLabelKey();
            if(!empty($columnname)){
                if($is_module == 'ServiceCharge')$is_module = 'Accounts';
                $templatearr[$tablename.':'.$columnname.':'.$fieldname.':'.$is_module.'_fieldlabel:'.$typeofname]=getTranstab($tranmodule).'_'.$fieldlabel;
            }
        }

        $productDetails=ProductDetails::getInstance($module,$languageType);
        $modulefields=$productDetails->getModuleFields();



        foreach($modulefields as $fieldname=>$fieldinfo)
        {
            // edit: xll 2024/10/24 XUQIU20240909-02 选择产品增加产品属性的选择（需求暂停）
            // 列表界面该字段直接过滤
            if($fieldname === 'productdetail_lineitem_id') {
                continue;
            }
            if($fieldinfo->getTableName() != 'ld_crmentity')
            {

                $tablename=$fieldinfo->getTableName();
                $columnname=$fieldinfo->getColumnName();
                $typeofdata=$fieldinfo->getTypeOfData();
                $fieldlabel=$fieldinfo->getFieldLabelKey();
                $transmodule = $fieldinfo->getTranslatedModule();
                //BUG20240329-58 ls 240401 产品分录引用源单字段，不保存数据库，数据分类选择字段后，列表没数据（不应该可选）
                if($fieldinfo&&($fieldinfo->getSaveDataBase()=='no') && strtolower($fieldinfo->getTableName()) != 'ld_products' &&
                    strtolower($fieldinfo->getTableName()) != 'ld_productcf')
                    continue;
                //if($fieldinfo->getUIType()==69&&!in_array($tablename,$focus->tab_name))
                //{
                //28583: 图片字段可以在编辑数据分类的时候设置显示，但是设置之后无法显示图片
                //明细表的图片也要删除

                //图片要求导出第一张
                // continue;
                // }
                $types=explode('~',$typeofdata);
                $typeofname=$types[0];
                //0018681: 合同订单>列表：控制面板，单据分录自定义设置字段权限，对某用户不可见。该用户创建数据分类，结果：可选字段中还是显示了这个字段。
                if(!empty($productFieldArray)){
                    if(isset($productFieldArray[$columnname]) && $productFieldArray[$columnname] == $tablename){
                        continue;
                    }
                }
                //zkt 服务收费管理-》服务合同-附件 在数据分类选择字段中不显示
                if($tablename=='ld_attachments'&&$module == 'ServiceCharge'&&$transmodule=='ServiceContracts'){
                    continue;
                }
                //BUG20240628-37 240814 ls 客户管理的列表不允许放出联系人上的客户名称
                if ($module == 'Accounts' && $columnname == 'accountid' && $tablename == 'ld_contactdetails') {
                    continue;
                }
                $fieldlabelArray = array('haveinvoicecount','balanceinvoicecount','havepurchasecount','balancepurchasecount','balanceoutproductcount','haveoutproductcount');
                if(in_array($columnname,$fieldlabelArray))
                {

                    $templatearr[$tablename.':'.$columnname.':'.$fieldname.':'.$transmodule.'_fieldlabel:'.$typeofname]=getTranstab($transmodule).'_'.$fieldlabel;
                }
                else if(!empty($columnname))
                {
                    $templatearr[$tablename.':'.$columnname.':'.$fieldname.':'.$transmodule.'_fieldlabel:'.$typeofname]=getTranstab($fieldinfo->getTranslatedModule()).'_'.$fieldlabel;
                }

            }
        }

    }
    else if(get_file_address($module,$module.'DetailFieldsHtml')){
        //财务明细模块 - 费用报销
        crm_load_class_file('TabDetails','include/TabDetailFields');
        $TabDetails = new TabDetails($module,$languageType);
        $modulefields=$TabDetails->getModuleFields();
        $focus=CRMEntity::getInstance($module);
        $main_module_fields=$focus->fieldobj->getModuleFields();
        foreach($main_module_fields as $fieldname=>$fieldinfo)
        {
            if($fieldinfo&&($fieldinfo->getSaveDataBase()=='no'))
                continue;
            // displaytype = 5 在列表界面也不显示
            if($fieldinfo->getDisplaytype() == '5') {
                continue;
            }
            if(in_array($module,array('CashBill','SendCashBill')) && $fieldname == 'hdnSubTotal')continue;
            $tablename=$fieldinfo->getTableName();
            $columnname=$fieldinfo->getColumnName();
            $typeofdata=$fieldinfo->getTypeOfData();
            $types=explode('~',$typeofdata);
            $typeofname=$types[0];
            $fieldlabel=$fieldinfo->getFieldLabelKey();
            if(!empty($columnname)){
                $templatearr[$tablename.':'.$columnname.':'.$fieldname.':'.$module.'_fieldlabel:'.$typeofname]=getTranstab($module).'_'.$fieldlabel;
            }
        }
        foreach($modulefields as $fieldname=>$fieldinfo)
        {
            // displaytype = 5 在列表界面也不显示
            // 价格政策分录字段不可显示在列表界面
            if($fieldinfo->getDisplaytype() == '5' || $module === 'PricePolicy') {
                continue;
            }
            $tablename=$fieldinfo->getTableName();
            $columnname=$fieldinfo->getColumnName();
            $typeofdata=$fieldinfo->getTypeOfData();
            $fieldlabel=$fieldinfo->getFieldLabelKey();
            $transmodule = $fieldinfo->getTranslatedModule();
            $types=explode('~',$typeofdata);
            $typeofname=$types[0];
            //自定义字段用户访问权限
            if(!empty($productFieldArray)){
                if(isset($productFieldArray[$columnname]) && $productFieldArray[$columnname] == $tablename){
                    continue;
                }
            }
            $table_check = 'yes';
            //收付款单要能够选择产品属性字段
            if( ($module == 'CashBill' || $module == 'SendCashBill') && (strtolower($tablename) == 'ld_products' || strtolower($tablename) == 'ld_productcf')){
                $table_check = 'no';
            }

            //edit: xll 2023/06/29 XUQIU1000357 单据分录定制，增加“附件”字段类型 （设置字段弹窗显示附件类别的字段）
            if($fieldinfo->getSaveDataBase()=='no' && !in_array($fieldinfo->getBigType(),array('image','fileattachment')) && $table_check == 'yes')
            {
                continue;
            }
            if(!in_array($fieldinfo->getTableName(),$focus->tab_name)){
                $templatearr[$tablename.':'.$columnname.':'.$fieldname.':'.$transmodule.'_fieldlabel:'.$typeofname]=getTranstab($module).getFixedLabel('DETAIL').'_'.$fieldlabel;
            }else if(!empty($columnname)){
                //	$templatearr[$tablename.':'.$columnname.':'.$fieldname.':'.$transmodule.'_fieldlabel:'.$typeofname]=getTranstab($module).'_'.$fieldlabel;
            }

        }
    }
    else{
        $focus=CRMEntity::getInstance($module);
        $fieldobj=Field::getInstance($module,$adb);
        $modulefields=$fieldobj->getModuleFields();
        $modulenoshowfields['Users']=array('activity_view','lead_view','hour_format','end_hour'
        ,'start_hour','title','reports_to_id','phone_other'
        ,'secondaryemail','signature','address_street','address_city','address_state','address_postalcode'
        ,'address_country','accesskey','time_zone','currency_id','currency_grouping_pattern','currency_decimal_separator'
        ,'currency_grouping_separator','currency_symbol_placement','internal_mailer','theme','language'
        ,'reminder_interval','asterisk_extension','use_asterisk','attachmentsid','date_format','email2'
        ,'confirm_password','user_password','viewothers','editothers'
        ,'delothers','viewselfbills','edit_other_mobile','edit_me_mobile','is_mobile_style'
        ,'select_servicedetail','select_due_date','trackpostion','login_sms','telephone_view'
        ,'push_work_reminds','push_news_reminds','push_wx_reminds','scopeauthority','accountallview');
        if($module=='Users')
        {
            $deployarray=getSys_deploy(55);//呼叫中心类型
            $deploy_value=$deployarray['deploy_value']??'';
            if($deploy_value=='汉天EC2')
            {
                $modulenoshowfields['Users'][]='sopho_exten';
                $modulenoshowfields['Users'][]='sopho_queue';
                $modulenoshowfields['Users'][]='jw_user';

            }
            else  if($deploy_value=='苏州思孚')
            {
                $modulenoshowfields['Users'][]='hantian_exten';
                $modulenoshowfields['Users'][]='jw_user';
            }
            else if($deploy_value=='苏州九维')
            {
                $modulenoshowfields['Users'][]='hantian_exten';
                $modulenoshowfields['Users'][]='sopho_exten';
                $modulenoshowfields['Users'][]='sopho_queue';
            }
            else
            {
                $modulenoshowfields['Users'][]='hantian_exten';
                $modulenoshowfields['Users'][]='sopho_exten';
                $modulenoshowfields['Users'][]='sopho_queue';
                $modulenoshowfields['Users'][]='jw_user';
            }
        }

        foreach($modulefields as $fieldname=>$fieldinfo){
            if($fieldinfo&&($fieldinfo->getSaveDataBase()=='no'||in_array($fieldinfo->getUIType(),array(303))))
                continue;
            if(array_key_exists($module,$modulenoshowfields)&&in_array($fieldname,$modulenoshowfields[$module]))
            {
                continue;
            }
            $tablename=$fieldinfo->getTableName();
            $columnname=$fieldinfo->getColumnName();
            $typeofdata=$fieldinfo->getTypeOfData();
            $fieldlabel=$fieldinfo->getFieldLabelKey();
            $types=explode('~',$typeofdata);
            $typeofname=$types[0];
            //自定义字段用户访问权限
            if(!empty($productFieldArray)){
                if(isset($productFieldArray[$columnname]) && $productFieldArray[$columnname] == $tablename){
                    continue;
                }
            }
            //回款计划列表增加选择源单字段
            if(!empty($columnname)  && $fieldinfo->getUIType() !=201){
                $templatearr[$tablename.':'.$columnname.':'.$fieldname.':'.$module.'_fieldlabel:'.$typeofname]=getTranstab($module).'_'.$fieldlabel;
            }
        }
    }

    return $templatearr;

}
/**
 * @edit:chj
 * @date:2014-10-30
 * @reason:获取已选字段
 * @description:
 */
function getHaveProductListView($tabid,$productListViewAll)
{
    global $adb, $currentModule;
    $listView = array();
    if(!isset($_REQUEST['record']))
        return null;

    if(get_file_address($currentModule,'ProductDetails')|| $currentModule == 'ServiceCharge')
    {
        if($currentModule == 'ServiceCharge'){
            $deployarray=getSys_deploy(325);	//服务收费列表显示联系人还是合同明细
            $servicecharge_list_show = strtolower($deployarray['deploy_value']);
        }
        $sql = "select columns from ld_tabwithproductview where tabid = ? and cvid = '".$_REQUEST['record']."' order by sequence asc";
        $result=$adb->pquery($sql,array($tabid));
        /**
         * edit:chj
         * date:2014-3-1
         * reason:合同订单、采购订单、发票、出库单、入库单序时簿：预置的数据分类编辑界面，显示列设置区块中已选字段应该显示默认显示列字段
         **/
        if($adb->num_rows($result) <= 0)
        {
            $sql = "select columns from ld_tabwithproductview where tabid = ? and cvid = 0 order by sequence asc";
            $result=$adb->pquery($sql,array($tabid));
        }

        $productDetails=ProductDetails::getInstance($currentModule,$languageType);
        $modulefields=$productDetails->getModuleFields();

        for($i=0;$i<$adb->num_rows($result);$i++)
        {
            $moduleInfo = explode(':',$adb->query_result($result,$i,'columns'));
            $moduleName = explode('_',$moduleInfo[3]);
            if($moduleName[0] == 'Inventoryproductrel')
            {
                $moduleName[0] = 'Products';
            }
            //if($moduleName[0] == 'ServiceCharge')$moduleName[0] = 'Accounts';

            //40867: （http://51mis.com/demo/9912/ [^]）服务收费管理模块>序时簿界面：点击“管理分类”编辑全部，可用字段选择“产品-服务截止日期”移动至“已选字段”点击保存，然后在编辑“全部”数据分类，“产品-服务截止日期”还是显示在“可用字段”
            if(isProductTable($moduleInfo[0]) || ($currentModule == 'ServiceCharge' && ($moduleInfo[0] == 'ld_servicecontractsdetail'||$moduleInfo[0] =='ld_servicecontracts'||$moduleInfo[0] =='ld_servicecontractscf')))
            {
                //28132: 合同订单>列表：数据分类设置了 “产品_提出89”，编辑该数据分类，该字段又显示在可用字段中。
                //主要修改分录已有基础资料时，合同的产品标签名称和产品模块名称不一样
                if(empty($modulefields[$moduleInfo[2]])) {
                    continue;
                }
                $fieldlabel = $modulefields[$moduleInfo[2]]->getFieldLabelKey();
                $columns=$moduleInfo[0].':'.$moduleInfo[1].':'.$moduleInfo[2].':'.$moduleName[0].'_fieldlabel:'.$moduleInfo[4];

            }
            else
            {
                if($currentModule == 'ServiceCharge'){
                    if($servicecharge_list_show == 'servicecontracts'){
                        if(strtolower($moduleInfo[0])=='ld_contactdetails'||strtolower($moduleInfo[0])=='ld_contactscf')
                        {
                            continue;
                        }
                    }
                    $field=Field::getInstance('ServiceCharge',$adb);
                }else
                    $field=Field::getInstance($moduleName[0],$adb);
                $fieldlabel=$field->getFieldInfoBykeyValue('fieldname',$moduleInfo[2],'fieldlabel');
                $typeofdata=$field->getFieldInfoBykeyValue('fieldname',$moduleInfo[2],'typeofdata');
                if(!empty($typeofdata))
                {
                    $typeofdata_arr=explode("~",$typeofdata);

                    $columns=$moduleInfo[0].':'.$moduleInfo[1].':'.$moduleInfo[2].':'.$moduleName[0].'_fieldlabel:'.$typeofdata_arr[0];
                }
                else
                    $columns=$moduleInfo[0].':'.$moduleInfo[1].':'.$moduleInfo[2].':'.$moduleName[0].'_fieldlabel:'.$moduleInfo[4];

            }


            $fieldlabelArray = array('haveinvoicecount','balanceinvoicecount','havepurchasecount','balancepurchasecount','balanceoutproductcount','haveoutproductcount');
            if(!empty($fieldlabel))//14655: 服务收费>序时簿,关于编辑数据分类的问题
            {


                if(in_array($moduleInfo[2],$fieldlabelArray))
                {
                    $listView[$columns] = getTranstab('Products') . '_' . $fieldlabel;
                }
                else
                {
                    if($currentModule=='ServiceCharge'&&$moduleName[0]=='Accounts')
                    {
                        //23940: 服务收费管理>列表：数据分类可用字段显示错误。
                        $listView[$columns] = getTranstab('ServiceCharge') . '_' . $fieldlabel;
                    }
                    else
                        $listView[$columns] = getTranstab($moduleName[0]) . '_' . $fieldlabel;
                }
            }


            //$listView[$columns] = $productListViewAll[$columns];
        }
    }
    elseif($currentModule=='Attachment' || $currentModule=='Documents'){
        $sql = "select columns from ld_tabwithproductview where tabid = ? and cvid = '".$_REQUEST['record']."' order by sequence asc";
        $result=$adb->pquery($sql,array($tabid));
        $num_rows = $adb->num_rows($result);
        for($i=0;$i<$num_rows;$i++){
            $moduleInfo = explode(':',$adb->query_result($result,$i,'columns'));
            $moduleName = explode('_',$moduleInfo[3]);
            $columns=$moduleInfo[0].':'.$moduleInfo[1].':'.$moduleInfo[2].':'.$moduleName[0].'_fieldlabel:'.$moduleInfo[4];

            $field=Field::getInstance($moduleName[0],$adb);
            $fieldlabel=$field->getFieldInfoBykeyValue('fieldname',$moduleInfo[2],'fieldlabel');
            if(empty($fieldlabel)){
                continue;
            }

            if($moduleName[0] == ''.$currentModule.'Details'){
                $listView[$columns] = getTranstab($currentModule).getFixedLabel('DETAIL').'_'.$fieldlabel;
            }else{
                $listView[$columns] = getTranstab($moduleName[0]) . '_' . $fieldlabel;
            }
        }
    }
    else if(get_file_address($currentModule,''.$currentModule.'DetailFieldsHtml')){//财务 - 费用报销
        $sql = "select columns from ld_tabwithproductview where tabid = ? and cvid = '".$_REQUEST['record']."' order by sequence asc";
        $result=$adb->pquery($sql,array($tabid));
        $TabDetails=new TabDetails($currentModule,$languageType);
        $modulefields=$TabDetails->getModuleFields();
        $focus = CRMEntity::getInstance($currentModule);
        for($i=0;$i<$adb->num_rows($result);$i++){
            $moduleInfo = explode(':',$adb->query_result($result,$i,'columns'));
            $moduleName = explode('_',$moduleInfo[3]);
            if($moduleInfo[0] == $focus->Detail_table || $moduleInfo[0] == $focus->Detail_table_scf){
                if(empty($modulefields[$moduleInfo[2]])) {
                    continue;
                }
                $fieldlabel = $modulefields[$moduleInfo[2]]->getFieldLabelKey();
            }
            //zkt 20240129 BUG20240126-48 收款单--分录字段显示两次，字段启用后，列表会出现，但是再次打开设置会依旧显示未启用
            else if(($currentModule == 'CashBill'||$currentModule == 'SendCashBill')&&($moduleInfo[0] == 'ld_products' || $moduleInfo[0] == 'ld_productcf')){
                if(empty($modulefields[$moduleInfo[2]])) {
                    continue;
                }
                $fieldlabel = $modulefields[$moduleInfo[2]]->getFieldLabelKey();
            }
            else{
                $field=Field::getInstance($moduleName[0],$adb);
                $fieldlabel=$field->getFieldInfoBykeyValue('fieldname',$moduleInfo[2],'fieldlabel');
                if(empty($fieldlabel)){
                    continue;
                }
            }
            $columns=$moduleInfo[0].':'.$moduleInfo[1].':'.$moduleInfo[2].':'.$moduleName[0].'_fieldlabel:'.$moduleInfo[4];
            if($moduleName[0] == ''.$currentModule.'Details'){
                $listView[$columns] = getTranstab($currentModule).getFixedLabel('DETAIL').'_'.$fieldlabel;
            }else{
                $listView[$columns] = getTranstab($moduleName[0]) . '_' . $fieldlabel;
            }

        }
    }
    else
    {
        $query = 'select columnname from ld_cvcolumnlist where cvid = ? order by columnindex asc';

        $focus=CRMEntity::getInstance($currentModule);

        $result = $adb->pquery($query,array($_REQUEST['record']));
        $num_rows = $adb->num_rows($result);
        for($i = 0; $i<$num_rows; $i++)
        {
            $columns = $adb->query_result($result,$i,'columnname');
            $columnsInfo = !empty($columns)?explode(':',$columns):[];
            $fieldlabel = !empty($columnsInfo)?explode('_',$columnsInfo[3]):[];
            $type = !empty($columnsInfo)?explode('~',$columnsInfo[4]):[];

            if ($currentModule == 'Accounts' && $columnsInfo[1] == 'accountid' && $fieldlabel[0] == 'Contacts') {
                continue;
            }
            //zkt 20230718 BUG0069391 【苏州灵当】V8.5.0.6（http://szlingdang6.gnway.vip/crm/）人事中心->工资条模块中的查询分类“全部”点击编辑后，显示列字段中有两个“实发金额”  NN变为了N
            /*switch($type[0])
            {
                case DT:
                    //$typedata = 'D';
                    $tmpfieldobj=$focus->fieldobj->getFieldInfoobjBykey("columnname",$columnsInfo[1]);

                    if($tmpfieldobj)
                    {
                       //edit:can 20230609 67854 常用审批单，隐藏“创建时间”，再将“创建时间”显示后，查询分类显示列设置中显示了两个“创建时间”
                       if(stripos($tmpfieldobj->getTypeOfData(),'dt~')!==false)
                       {
                            $typedata = 'DT';
                       }
                       else{
                            $typedata = 'D';
                       }
                    }

                    break;
                case NN:
                    $typedata = 'N';
                    break;
                default:
                    $typedata = $type[0];
            }*/
            $typedata = $type[0];
            $columnname = $columnsInfo[0] . ':' . $columnsInfo[1] . ':' . $columnsInfo[2] . ':' . $fieldlabel[0] . '_fieldlabel:' . $typedata;
            //知识管理模块特殊控制
            if($fieldlabel[0] == 'Notes')
                $fieldlabel[0] = 'Documents';
            //13647: 客户服务单--数据分类编辑有问题,edit:can
            $fieldobj=Field::getInstance($fieldlabel[0],$adb);

            $modfieldlabel=$fieldobj->getFieldInfoBykeyValue('fieldname',$columnsInfo[2],'fieldlabel');
            //23599: 客户>列表：关闭联系人模块，数据分类中可用字段还是显示了联系人模块的字段，应该不显示联系人模块的字段。
            if(!empty($modfieldlabel)&&vtlib_isModuleActive($fieldlabel[0]))//如果数据库中没有该字段
                $listView[$columnname] = getTranstab($fieldlabel[0]) . '_' .$modfieldlabel ;
            //$listView[$columnname] = $productListViewAll[$columnname];
        }
    }
    return $listView;
}



?>