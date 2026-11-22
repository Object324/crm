<?php



class SocialPromotion extends CRMEntity {
    
    static  function require_file($requiremodules='')
    {
            globalStatic::$arr_module_require['SocialPromotion']='SocialPromotion';
         
            
           
            if(!empty($requiremodules)&&empty(globalStatic::$arr_module_require[$requiremodules]))
            {
                globalStatic::$arr_module_require[$requiremodules]=$requiremodules;
                include(globalStatic::$root_directory."modules/$requiremodules/$requiremodules.php");
                
            }

    }
    
	var $log;
	var $db;
    var $module_name='SocialPromotion';
	var $table_name = "ld_socialpromotion";
	var $table_index= 'socialpromotionid';
	//'ld_contactaddress','ld_contactsubdetails','ld_customerdetails'
	//'ld_contactaddress'=>'contactaddressid','ld_contactsubdetails'=>'contactsubscriptionid',
	//'ld_customerdetails'=>'customerid'
	var $tab_name = Array('ld_crmentity','ld_socialpromotion','ld_socialpromotionscf');
	var $tab_name_index = Array('ld_crmentity'=>'crmid','ld_socialpromotion'=>'socialpromotionid','ld_socialpromotionscf'=>'socialpromotionid',);
	/**
	 * Mandatory table for supporting custom fields.
	 */
	var $customFieldTable = Array('ld_socialpromotionscf', 'socialpromotionid');

	var $column_fields = Array();
    
	var $sortby_fields = Array('smownerid','accountname');

	var $list_link_field= 'lastname';
    var $relatedtab=array('accounts'=>'','socialpromotion'=>'','users'=>'','company'=>'','vendors'=>'');


    var $table_code='socialpromotion_no';//模块编号字段
	var $search_fields = Array(
	'Name' => Array('contactdetails'=>'lastname'),
	'Title' => Array('contactdetails'=>'title'),
	'Account Name'=>Array('contactdetails'=>'account_id'),
	'Assigned To'=>Array('crmentity'=>'smownerid'),
		);

	var $search_fields_name = Array(
	'Name' => 'lastname',
	'Title' => 'title',
	'Account Name'=>'account_id',
	'Assigned To'=>'assigned_user_id'
	);

	// This is the list of lingdang_fields that are required
	var $required_fields =  array("lastname"=>1);

	// Used when enabling/disabling the mandatory fields for the module.
	// Refers to ld_field.fieldname values.
	var $mandatory_fields = Array('assigned_user_id','createdtime' ,'modifiedtime');

	//Default Fields for Email Templates -- Pavani
	var $emailTemplate_defaultFields = array('firstname','lastname','salutation','title','email','department','phone','mobile','support_start_date','support_end_date');

	//Added these variables which are used as default order by and sortorder in ListView
	var $default_order_by = 'lastname';
	var $default_sort_order = 'ASC';

	// For Alphabetical search
	var $def_basicsearch_col = 'lastname';

	function __construct() {
	
		$this->db = PearDatabase::getInstance();
        $this->fieldobj=Field::getInstance('SocialPromotion',$this->db);
		$this->column_fields =$this->fieldobj->getFieldArray('fieldname',$this);
        $entityname=getEntitynameByModulename('SocialPromotion');
        $this->list_link_field=$entityname['fieldname'];
	}


	/** Function to handle module specific operations when saving a entity
	*/
	function save_module($module)
	{
	   
              
	}
	
	function restore($module, $id) {
		//鐠嬪啰鏁ょ敮顔藉灉閸氀勫复閸?
		parent::restore($module,$id); 
	
   	}
   
	

	// Function to unlink an entity with given Id from another entity
	function unlinkRelationship($id, $return_module, $return_id) {
	  	
		
	}


    /**
     * 重写方法  社交推广保存后需要特殊的返回值
     * */
    function ReturnAfterSave($before_columnfieldvalue)
    {
        $_REQUEST['diony']='yes';
        $record=$_REQUEST['record'];
        $module=$this->module_name;
        $column_fields=$this->column_fields;
        //特殊返回值 共享的用户ids
        $arr['shareUsers'] =$_REQUEST['newShareUsers'];
        $arr['socialpromotion_no'] =$_REQUEST['socialpromotion_no'];
        $arr['form'] = $_REQUEST['form'];
        //end
        $arr['fieldhrefname']=$this->list_link_field;
        $arr['modulebillnotip']=$_SESSION[$module.'_modulebillnotip'];
        $arr['fieldvalue']=$this->column_fields;
        $arr['fieldvalue']['maintable_id']=$this->id;
        crm_load_function_file('getDataInfoAfterSave','include/utils','DetailViewUtils');
        $column_fields['record_id']=$this->id;
        // getDataInfoAfterSave($currentModule,'',$focus->column_fields,getTabid($currentModule));
        $datainfo=array();
        if(!in_array($module,$this->refreshlistmodules)||!in_array($module,$this->refreshdetailmodules))
        {
            //40710: （51mis.com/kfbtest）客户查看详情界面，编辑数据保存后，该界面没有立即刷新
            $datainfo=getDataInfoAfterSave($module,'',$column_fields,getTabid($module),'listpage');
        }

        if($this->fieldobj->getFieldInfoBykeyValue('bigtype','fileattachment','fieldname')!='')
        {


            $smarty=new lingdangCRM_Smarty();
            $smarty->assign("MODULE",$module);
            $smarty->assign("ID",$record);

            foreach($datainfo as $tmpfieldname => $tmpvalueinfo)
            {

                $fileinfos=$valueinfo['value'][$record];

                $tmpfieldinfo=$this->fieldobj->getFieldInfoobjBykey("fieldname",$tmpfieldname);

                if($tmpfieldinfo->getUIType()=='1109'||$tmpfieldinfo->getUIType()==1108)
                {
                    $smarty->assign("keyid",$tmpfieldinfo->getUIType());
                    // dump($tmpvalueinfo);
                    if($tmpfieldinfo->getUIType()==1108)
                    {
                        $smarty->assign("keyval",$tmpvalueinfo['value']);
                    }
                    else{
                        $smarty->assign("keyval",$tmpvalueinfo['value']);
                    }
                    $strcontent=$smarty->fetch("DetailView/AttachmentField.tpl");


                    //明细界面附件字段
                    $valueinfo['DetailView_Attachmenthtml']=($strcontent);// $smarty->fetch("DetailView/AttachmentField.tpl");

                    $showvalue=array();
                    $showvalue['rawvalue']=$record;
                    foreach($fileinfos as $fileid =>$fileinfo)
                    {
                        $fileinfo['attachmentsid']=$fileid;
                        $fileinfo['filepath']=$fileinfo['path'];
                        $fileinfo['filename']=$fileinfo['name'];
                        $showvalue['value'][]=$fileinfo;
                    }
                    $showvalue['parentmodule']='';

                    //列表附件字段html
                    $valueinfo['list_html']= getAttachmentListViewHtml($showvalue,$module,$record);
                    $datainfo[$tmpfieldname]=$valueinfo;

                }
                else if($tmpfieldinfo->getUIType()=='69')
                {
                    //图片
                    //crm_load_class_file('DetailView_69');
                    $imageinfos=DetailView_69::$imageinfos[$module][$tmpfieldname];
                    $showvalue=array();
                    $showvalue['rawvalue']=$record;

                    foreach($imageinfos as $tmpimginfo)
                    {
                        $showvalue['value'][]=$httppath;//.$tmpimginfo['newfile_name'];
                    }
                    $valueinfo['list_html']= getImageListViewHtml($showvalue,$module,$record);
                    $datainfo[$tmpfieldname]=$valueinfo;

                }
            }
        }

        $arr['datainfo']=$datainfo;
        if($this->mode=='edit')
        {
            if(get_file_address($module,"ProductDetails")&&$module!='ServiceCharge')
            {
                if(!in_array($module,$this->refreshlistmodules))
                {
                    //40683: （http://www.51mis.com/demo/panlulu15/演示账套 [^]）客户管理->客户查看详情界面，相关信息->出库单界面，编辑单据保存后，该界面列值行错位
                    /*crm_load_class_file('InventoryListTrById','include/ListView/ProductDetail');
                    $obj=new InventoryListTrById($record,$module);
                    if(is_array($this->before_sumdetailvalues))
                        $arr['before_sumdetailvalues']=$this->before_sumdetailvalues;
                    else
                        $arr['before_sumdetailvalues']=array();


                    $arr['recordlisthtml']=$obj->getHtml();
                    $arr['after_sumdetailvalues']=$obj->sum_values;*/
                }
                if(!in_array($module,$this->refreshdetailmodules))
                {
                    $tmpmode=$this->mode;
                    $ProductDetailsHtml = crm_load_class_obj('cls_productDetailsHtml',"modules/$module/ProductDetails",array($module));
                    $this->mode='';
                    $arr['DetailViewListHtml']=$ProductDetailsHtml->getProductDetailsHtml($this,'details');
                    $this->mode=$tmpmode;
                }


            }
            else if(get_file_address($module,$module.'DetailFieldsHtml'))
            {
                if(!in_array($module,$this->refreshlistmodules))
                {
                    //40683: （http://www.51mis.com/demo/panlulu15/演示账套 [^]）客户管理->客户查看详情界面，相关信息->出库单界面，编辑单据保存后，该界面列值行错位
                    /* crm_load_class_file('TabDetailListTrById','include/ListView/TabDetail');
                    $obj=new TabDetailListTrById($record,$module);
                     if(is_array($this->before_sumdetailvalues))
                        $arr['before_sumdetailvalues']=$this->before_sumdetailvalues;
                    else
                        $arr['before_sumdetailvalues']=array();
                    $arr['recordlisthtml']=$obj->getHtml();
                    $arr['after_sumdetailvalues']=$obj->sum_values;*/
                }
                if(!in_array($module,$this->refreshdetailmodules))
                {

                    if($module=='CashBill')
                    {
                        crm_load_class_file('cls_CashBill_EntityHtml','modules/CashBill/EntityData');
                        $isSourceModule = $_REQUEST['selectsource'];//$this->getSourceField('entitytype',$this->id);
                        $obj_entity=new cls_CashBill_EntityHtml( $_REQUEST['record'],'',$isSourceModule,'detail');

                        $arr['DetailViewListHtml']=$obj_entity->createHtml();
                    }
                    else if($module=='SendCashBill')
                    {
                        crm_load_class_file('cls_SendCashBill_EntityHtml','modules/SendCashBill/EntityData');
                        $obj_entity=new cls_SendCashBill_EntityHtml($focus->id,'',$selectSourceModuleName,'detail');
                        $isSourceModule = $_REQUEST['selectsource'];//$this->getSourceField('entitytype',$this->id);
                        $arr['DetailViewListHtml']=$obj_entity->createHtml();//付款信息明细html
                    }
                    else
                    {
                        $classname=$module.'DetailFieldsHtml';
                        crm_load_class_file("$classname","modules/$module");
                        $mode=$this->mode;
                        $this->mode='Details';//佣金单
                        $detailhtmlobj = new $classname($this,$module);

                        $arr['DetailViewListHtml']=$detailhtmlobj->getTabDetailFieldsHtml();
                        $this->mode=$mode;
                    }
                }
            }
            $beforedatainfo=array();

            if(!in_array($module,$this->refreshlistmodules)&&!in_array($module,$this->refreshdetailmodules)&&$focus->mode!='edit')
                $beforedatainfo=getDataInfoAfterSave($module,'',$before_columnfieldvalue,getTabid($module),'listpage');
        }
        else
            $beforedatainfo=array();
        $arr['beforedatainfo']=$beforedatainfo;
        $arr['refreshdetailmodules']=array();
        $arr['refreshlistmodules']=array();
        $refreshdetailmodules=array();
        $refreshlistmodules=array();


        if($this->mode!='edit')
        {
            if(!is_array($this->refreshlistmodules)){
                $this->refreshlistmodules=array();
            }
            $this->refreshlistmodules[]=$module;
            $arr['sysdeploy']=$this->getSysDeployAftersave();

        }
        if(is_array($this->refreshdetailmodules) && count($this->refreshdetailmodules) > 0){
            $arr['refreshdetailmodules']=$this->refreshdetailmodules;
        }
        if(is_array($this->refreshlistmodules) && count($this->refreshdetailmodules) > 0){
            $this->refreshlistmodules=array_unique($this->refreshlistmodules);
            $arr['refreshlistmodules']=$this->refreshlistmodules;
        }

        $_SESSION[$module.'_modulebillnotip']='no';
        ConvertTojsonString(1,$arr,"success");
    }
 

}
SocialPromotion::require_file();
?>