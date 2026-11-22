<?php
/**
 * 更新操作
 * 操作人: gyq_06
 * 日期: 2016/3/8
 * 时间: 18:07
 * 说明:客户重复是否弹出对冲提醒  1:否，0:是
 */
class AccountsNameHedging{
    public $system_deply_value;
    public function __construct()
    {
        $this->system_deply_value = getSys_deploy(95);
        //25846: 客户：提醒参数设置，客户名称重复时启用报备提醒，新增客户单据，客户名称重复时没有提醒
        $this->system_deply_value =$this->system_deply_value['deploy_value'];
        
    }
    public function nameHedgingReminds(){
        global $current_user, $adb;
        $module = $_REQUEST['module'];
        $fieldname = $_REQUEST['fieldname']; // accountname
        $fieldvalue = $_REQUEST['fieldvalue'];
        $fieldid = $_REQUEST['record'];
        $opeatorid = $current_user->id;

        include globalStatic::$root_directory.'modules/lingdang/staticlingdang.class.php';

        $rest = staticlingdang::getFieldDuplicateInfo($module, $fieldname, $fieldvalue, $fieldid);

        $dialogcontent = '';
        if (strpos(',' . $rest, '##error##') > 0) {
            /*
              * editor:gyq_40_1 date:20170728 reason:对冲提醒
              * */
            require_once globalStatic::$root_directory . 'appCommon/include/piecesFunctionMC.php';
            $dialogcontent = set_duplicate_reminds_ac('accountname', $fieldvalue);
        }
        return $dialogcontent;
    }
}
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
crm_load_class_file('AccountsNameHedging','modules\Accounts');
$namehedg = new AccountsNameHedging();
if($namehedg->system_deply_value == 0) {
    $dialogcontent = $namehedg->nameHedgingReminds();
    if(strlen($dialogcontent) > 0){
        echo $dialogcontent;
    }else{
        echo '##NOTHING##';
    }
}else{
    echo '##NOTHING##';
}




