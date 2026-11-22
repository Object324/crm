<?php

crm_load_class_file('HomeBoardNew_40','modules/Home/HomeBoardNew');
class HomeBoardNew_114 extends HomeBoardNew_40
{
    public $viewStyle;
    public $stuffid;
    public $boardid;
    public $SalesGoalDefaultLabel = 'TargetAnalysis_SalesGoal';
    public function get_stuff_content_html($stuffinfo)
    {
        global $current_user,$languageType;
        $this->getStuffLabel($stuffinfo);
        $stuffid = $this->stuffid = $stuffinfo['stuffid'];
        $this->boardid = $boardid = $_REQUEST['boardid'];
        if ($stuffinfo['height'] != '') {
            $stuff_con_height = (int)explode('px', $stuffinfo['height'])[0];
            $stuff_con_height = ($stuff_con_height - 110);
        }
        $salesGoalList = $this->getSalesGoalList();
        $IS_ADMIN = 'no';
        if(is_admin($current_user))
            $IS_ADMIN = 'yes';

        $smarty = new lingdangCRM_Smarty();
        $smarty -> assign('stuffinfo',$stuffinfo);
        $smarty -> assign('boardid',$boardid);
        $smarty -> assign('languageType',$languageType);
        $smarty -> assign('IS_ADMIN',$IS_ADMIN);
        $smarty -> assign('stuff_con_height',$stuff_con_height.'px');
        $smarty -> assign('SetClick',$this->getSetClick());
        //获取页签Html内容
        $this->getPageTabHtml($smarty,$salesGoalList);

        if($this->viewStyle == 'Preview'){
            $viewStyle = strtolower($this->viewStyle) . '_';
            $smarty -> assign('viewStyle',$viewStyle);
            $stuff_content_html = $smarty -> fetch("Home/HomeBoardNew_Preview.tpl");
        } else {
            $stuff_content_html = $smarty -> fetch("Home/HomeBoardNewParent.tpl");
        }
        return $stuff_content_html;
    }

    public function getSetClick(){
        return "TargetAnalysisManage(event,$this->boardid,$this->stuffid)";
    }
}