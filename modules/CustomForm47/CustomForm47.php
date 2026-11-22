<?php



class CustomForm47 extends CRMEntity {

    static  function require_file($requiremodules='')
    {
        globalStatic::$arr_module_require['CustomForm47']='CustomForm47';



        if(!empty($requiremodules)&&empty(globalStatic::$arr_module_require[$requiremodules]))
        {
            globalStatic::$arr_module_require[$requiremodules]=$requiremodules;
            include(globalStatic::$root_directory."modules/$requiremodules/$requiremodules.php");

        }

    }

    var $log;
    var $db;
    var $module_name='CustomForm47';
    var $table_name = "ld_customform47";
    var $table_index= 'customform47id';
    //'ld_contactaddress','ld_contactsubdetails','ld_customerdetails'
    //'ld_contactaddress'=>'contactaddressid','ld_contactsubdetails'=>'contactsubscriptionid',
    //'ld_customerdetails'=>'customerid'
    var $tab_name = Array('ld_crmentity','ld_customform47','ld_customform47scf');
    var $tab_name_index = Array('ld_crmentity'=>'crmid','ld_customform47'=>'customform47id','ld_customform47scf'=>'customform47id',);
    /**
     * Mandatory table for supporting custom fields.
     */
    var $customFieldTable = Array('ld_customform47scf', 'customform47id');

    var $column_fields = Array();

    var $sortby_fields = Array('lastname','firstname','title','email','phone','smownerid','accountname');

    var $list_link_field= 'lastname';
    var $relatedtab=array('accounts'=>'','customform47'=>'','users'=>'','company'=>'','vendors'=>'');


    var $table_code='customform47_no';
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
        $this->fieldobj=Field::getInstance('CustomForm47',$this->db);
        $this->column_fields =$this->fieldobj->getFieldArray('fieldname',$this);
        $entityname=getEntitynameByModulename('CustomForm47');
        $this->list_link_field=$entityname['fieldname'];
    }


    /** Function to handle module specific operations when saving a entity
     */
    function save_module($module)
    {


    }

    function restore($module, $id) {

        parent::restore($module,$id);

    }



    // Function to unlink an entity with given Id from another entity
    function unlinkRelationship($id, $return_module, $return_id) {


    }

    public function successApprove($crmid)
    {
        // 商贸批发小程序
        // 东贸特殊开发，微信公众号，行为记录推送
        $version_info = getVersionInfo();
        // 商贸批发小程序
        if($version_info['trade'] == 'dongmao' && $version_info['account'] == 'dongmao' && !empty($crmid)){
            global $adb;
            $query = "select accountid,cf_4540,cf_4546,cf_4543,DATE_FORMAT(createdtime,'%Y-%m-%d') as createdtime from ld_customform47 
			LEFT JOIN ld_customform47scf on ld_customform47.customform47id = ld_customform47scf.customform47id 
			where ld_customform47.customform47id = ?";
            $result = $adb->pquery($query,array($crmid));

            $cf_4540 = $adb->query_result($result,0,'cf_4540');	//行为记录类别
            $cf_4546 = $adb->query_result($result,0,'cf_4546');	//行为类型
            $cf_4543 = $adb->query_result($result,0,'cf_4543');	//事件记录
            $createdtime = $adb->query_result($result,0,'createdtime');
            $accountid = $adb->query_result($result,0,'accountid');
            if(!empty($accountid)){
                $query = "select unionid,wechatuserid from ld_wechatuser where accountid = ? and deleted = 0";
                $result = $adb->pquery($query,array($accountid));
                $unionid = $adb->query_result($result,0,0);
                $query = "select open_id,wechatuserid from ld_wechatuser where unionid = ? and deleted = 0 and userfromvalue = 'offiaccount_dmsh'";
                $result = $adb->pquery($query,array($unionid));
                $num_rows = $adb->num_rows($result);
                if($num_rows >= 1){
                    $open_id = $adb->query_result($result,0,'open_id');
                    $wechatuserid = $adb->query_result($result,0,'wechatuserid');
                    require_once (globalStatic::$root_directory.'include/weixinMsg/cls_DongmaoMerchantMessage.php');
                    require_once (globalStatic::$root_directory.'include/weixinMsg/cls_DMmessageMerchantDefault.php');
                    $dongmaoObj = new cls_DongmaoMerchantMessage();
                    $dmMsgData = cls_DMmessageMerchantDefault::$DMmessageData['BehaviorRecord'];
                    $dmMsgPage = cls_DMmessageMerchantDefault::$DMmessageJump['BehaviorRecord'];
                    //$open_id = 'oFb1D6vrhRAR99vOVhwslZTaJhKs';
                    //$wechatuserid = 227441;
                    $data = array(
                        'title' => '行为记录类别 - ' .$cf_4540,
                        'date' => $createdtime,
                        'place' => $cf_4546,
                        'remark' => $cf_4543
                    );

                    $dongmaoObj->send('BehaviorRecord',$open_id,$dmMsgPage['page'],$data,$wechatuserid,'HelpDesk',$crmid,$dmMsgPage['pageType'],$accountid);
                }
            }

        }
    }


}
CustomForm47::require_file();
?>