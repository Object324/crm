<?php

/**
 * Class cls_PrintWX
 * 手机端增加另存为pdf格式按钮功能
 * zxm
 * 2020-1106
 */
class cls_PrintWX
{
    protected $module;
    protected $action;
    public $focus;
    public function __construct($module)
    {
        if (!empty($module)) {
            $this->module = $module;
            $this->action = $_REQUEST['action'];
            $this->focus = cls_Instance::get_module_Instance($module);
        }
    }

    /**
     * @return array
     * 获取模板列表
     */
    public function getTemplate()
    {
        // 打印模板 zxm 20201105 打印模板数据
        $module = $_REQUEST['frommodule'];
        $tabid = getTabid($module);
        $focus = CRMEntity::getInstance($module);
        $list = $focus->getPrintTemplate($tabid);
        $res = [];
        foreach($list as $k=>$v){
            $res[] = ['id'=>$v[2],'name'=>$v[0],'selected'=>$v[1]==1?'yes':'no'];
        }
        return $res;
    }

    /**
     * @throws Exception
     * 调用打印方法
     * 判断 -1 没有模板 返回提示
     * 1 只有一个模板或者参数有打印模板id （printid） 直接生成pdf返回
     * 2 有两个及两个以上模板  返回模板数组供选择
     */
    public function doPrint()
    {
        global $current_user,$adb;
        global $weixin_user;
        $_REQUEST['diony'] = 'yes';
        $weixin_user->environment = 'weixinh5';
        $printid = isset($_REQUEST['printid'])?$_REQUEST['printid']:0;
        if($printid == ''){
            $printid = 0;
        }
        if($printid<=0) {
            $prints = $this->getTemplate();
            $counts = count($prints);
            if (empty($prints)) {
                ConvertTojsonString(-1, [], getFixedLabel('HAVENOPRINTTEMPLATE'));
            } else if ($counts == 1) {
                $printid = $prints[0]['id'];
            } else {
                ConvertTojsonString(2, ['templateArr'=>$prints], 'success');
            }
        }
        if(!empty($_REQUEST['frommodule'])&&$_REQUEST['CreatePDF']==true){
            $module = $_REQUEST['frommodule'];
            //ls 2022-08-09  打印模板定制，增加参数“是否审批通过后才允许打印(移动端)
            $sql = 'select approvedallowprint,printfilename from ld_templateprint where tabid = ? and templateprintid = ?';
            $result = $adb->pquery($sql,array(getTabid($module), $printid));
            $approvedallowprint = $adb->query_result($result,0,'approvedallowprint');//是否审批通过后才允许打印
            $printfilename = $adb->query_result($result,0,'printfilename');
            if ($approvedallowprint == 'yes') {
                $focus = CRMEntity::getInstance($module);
                $query = 'select approvestatus from ' . $focus->table_name . ' where ' . $focus->table_index . ' = ' . $_REQUEST['record'] . ' limit 1 ';
                $result = $adb->pquery($query,array());
                $num_rows = $adb->num_rows($result);
                if($num_rows >= 1){
                    $approvestatus = $adb->query_result($result,0,0);
                }
                if($approvestatus != constant('D_A_S_APPROVED')){
                    ConvertTojsonString(-1, [], getFixedLabel('ApprovedAllowPrintRemindApp'));
                }
            }

            //获取doc名字
            include(globalStatic::$root_directory."Smarty_setup.php");
            //htmlname
            $htmlname = $module .'_' . $_REQUEST['record'] . '_'.$current_user->id;
            //word doc name
            $modulename = $module;
            $wordfilename=$modulename .'_'.$_REQUEST['record'];
			//chj 2021/1/26 44443: （https://61mis.com/kfbcrm [^]）（天娇网络）移动端使用导出成PDF，结果中不会显示logo、总计和大写金额。比如说SO241这个合同，使用合同预置模板。
			$_REQUEST['weixin_pdf'] = 'yes';
            $extension = pathinfo($printfilename, PATHINFO_EXTENSION);

            if($extension == 'doc' || $extension == 'docx' || $extension == 'xls' || $extension == 'xlsx'){// Word/Excel模板
                crm_load_class_file('TemplatePrintFile', 'include/TemplatePrint');
                $templateprintobj = TemplatePrintFile::getInstance($extension,$module,getTabid($module),$printid,$_REQUEST['record']);
                $outputFile = $templateprintobj->createFile($wordfilename);
                $pdfname = $templateprintobj->convertToPDF($outputFile);
            }else{
                $pdfname = CreatePdf($module,$printid,$_REQUEST['record'],$htmlname,$wordfilename,"no");
            }
            
            $res['pdfname'] = $pdfname;

            // 微信小程序特殊处理  分割完成路径成name与路径
            $res['file_name'] = mb_substr($pdfname, mb_strrpos($pdfname, '/') + 1);
            $file_url = pathinfo($pdfname, PATHINFO_DIRNAME);// 文件路径
            $res['file_url'] = $file_url.'/';
            
            ConvertTojsonString(1, $res, 'success');
        }else{
            ConvertTojsonString(-1, [], 'error');
        }
    }

}