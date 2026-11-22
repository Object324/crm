<?php
crm_load_class_file('HomeBoardNewParent','modules/Home/HomeBoardNew');
class  HomeBoardNew_40 extends  HomeBoardNewParent
{
    public $viewStyle;
    public $SalesGoalDefaultLabel = 'CompanySixMonthSalesRate_SalesGoal';
    public $salesGoalList;
    public function get_stuff_content_html($stuffinfo)
    {
        global $languageType,$current_user;
        $this->getStuffLabel($stuffinfo);
        $stuffid = $stuffinfo['stuffid'];
        if ($stuffinfo['height'] != '') {
            $stuff_con_height = (int)explode('px', $stuffinfo['height'])[0];
            $stuff_con_height = ($stuff_con_height - $this->title_height - 40);
        }
        $salesGoalList = $this->getSalesGoalList();
        $smarty = new lingdangCRM_Smarty();
        $smarty -> assign('stuffinfo',$stuffinfo);
        $smarty -> assign('languageType',$languageType);
        $smarty -> assign('stuff_con_height',$stuff_con_height.'px');

        if($stuffid == 101){
            $datalabel_height = 30;
            $datalabel_num = 3;
            $datalabel_padding = ($stuff_con_height - $datalabel_num * $datalabel_height)/2;
            $smarty -> assign('DataLabelNum',$datalabel_num);
            $smarty -> assign('DataLabelHeight',$datalabel_height.'px');
            $smarty -> assign('DataLabelPadding',$datalabel_padding.'px 0 '.$datalabel_padding.'px');
        }
        //获取页签Html内容
        $this->getPageTabHtml($smarty,$salesGoalList);

        if(isset($this->viewStyle) && $this->viewStyle == 'Preview'){
            //看板编辑界面的页面
            $stuff_content_html = $smarty -> fetch("Home/HomeBoardNew_40_Preview.tpl");
        } elseif (isset($this->viewStyle) && $this->viewStyle == 'oldboard') {
            //旧默认看板的页面（只获取页签html）
            $stuff_content_html = $this->PageTabHtml;
        } else {
            //组件展示页面
            $stuff_content_html = $smarty -> fetch("Home/HomeBoardNew_40.tpl");
        }
        return $stuff_content_html;
    }

    public function getSalesGoalList(){
        $DefaultTargetId = getUsersettingByLabel('SalesGoal','',$this->SalesGoalDefaultLabel);
        //edit: xll 2023/08/14 XUQIU1001400 近六个与目标完成情况改为动态获取目标管理中的指标
        crm_load_class_file('SalesGoalNew.class','modules/SalesGoal');
        $SalesGoalNewObj = new SalesGoalNew();
        $this->salesGoalList = $SalesGoalNewObj->getPermitSalesGoal($DefaultTargetId);
        return $this->salesGoalList;
    }

    /**
     * Edit: xll
     * Date: 2023/08/22
     * Reason: 过滤的数组为目标管理中的指标数组
     * Params: 该数组的内容键值为targetid,targetname,selected,$PageTabLabelKey
     * Params: 过滤键值showtype, 过滤值board, 即数组中对应showtype键的值是否包含board
     */
    public function getPageTabListKeyArr(){
        global $languageType;
        $PageTabLabelKey = ($languageType == 'zh') ? 'zhlabel' : 'enlabel';
        $PageTabListKeyArr = ['id'=>'targetid','name'=>'targetname','selected'=>'selected',
            'label'=>$PageTabLabelKey,'filterKey'=>'showtype','filterValue'=>'board'];
        return $PageTabListKeyArr;
    }
    /**
     * Edit: xll
     * Date: 2023/08/22
     * Reason: 出库额需要判断模块权限
     */
    public function FilterPageTabInfo($PageTabInfo){
        $targetname = $PageTabInfo['targetname'];

        return false;
    }
}
?>