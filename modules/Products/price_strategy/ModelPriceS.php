<?php
//editor:gyq_84 reason:产品增加价格策略 2018/10/22 16:58
crm_load_class_file('cls_strategy','modules/Products');
class ModelPriceS
{
    public $price_obj;
    public function __construct(){
        $this->price_obj = new cls_strategy();
    }
    //获取策略设置界面
    public function get_setting_windows(){
        $record = $_REQUEST['record'];
        global $adb;
        $smarty = new lingdangCRM_Smarty();
        $arr = $this->price_obj->get_setting_windows($record);
        $smarty->assign('PSTYPE1', $arr['rows'][1]);
        $smarty->assign('PSTYPE2', $arr['rows'][2]);
        $smarty->assign('PSTYPE3', $arr['rows'][3]);
        $smarty->assign('RECORD', $record);
        $smarty->assign('PRICESTYPE', $arr['type']);
        $orign_rows1 = is_array($arr['rows'][1])?count($arr['rows'][1]):0;
        $orign_rows3 = is_array($arr['rows'][3])?count($arr['rows'][3]):0;
        $smarty->assign('NUMROW1', $orign_rows1);
        $smarty->assign('NUMROW3', $orign_rows3);

        $_REQUEST['diony']='diony';
        $arr['title']=getFixedLabel("PRICESTRATEGY");
        //获取帮助手册入口链接，为空则不显示
        //可能有多个帮助链接需要获取
        $helpHtmlArr = array();
        //企业号设置帮助
        $labels = array('PriceStrategy');
        foreach($labels as $label){
            $helpHtmlArr[$label] = getHelpUrlByLabel('Settings',1,'HelpUrl_'.$label);
        }
        if (!empty($helpHtmlArr['PriceStrategy'])) {
            $helpHtml = '<div class="ld-btn-icontext-items lfloat">' .
                '<a class="ld-btn-icontext-item padL16" href="' . $helpHtmlArr['PriceStrategy'] . '" target="_blank">' .
                '<i class="ld-fonticon ld-fonticon-helphover"></i>' .
                '<span>' . getFixedLabel('ONLINEHELP') . '</span>' .
                '</a>' .
                '</div>';
            $arr['helperhtml'] = $helpHtml;
        }
        $arr['oktext']=getFixedLabel("SAVE");
        $arr['canceltext']=getFixedLabel("CANCEL");
        $str=$smarty->fetch("modules/Products/price_strategy/setting_windows.tpl");
        if($orign_rows1 < 1){
            $NUMROW1 = 1;
        }else{
            $NUMROW1 = $orign_rows1;
        }
        if($orign_rows1 < 1){
            $NUMROW3 = 1;
        }else{
            $NUMROW3 = $orign_rows3;
        }
        $arr['NUMROW1']=$NUMROW1;
        $arr['NUMROW3']=$NUMROW3;
        $arr['content']=$str;
        ConvertTojsonString(1,$arr,"success");
    }
    //价格策略设置界面保存
    public function save_setting(){
        $this->price_obj->save_setting();
    }
}