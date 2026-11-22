<?php
crm_load_class_file('HomeBoardNewParent','modules/Home/HomeBoardNew');
class  HomeBoardNew_100 extends  HomeBoardNewParent
{
    public function get_stuff_content_html($stuffinfo)
    {
        global $current_user,$languageType;
        $this->getStuffLabel($stuffinfo);
        $stuffid = $stuffinfo['stuffid'];
        $this->boardid = $boardid = $_REQUEST['boardid'];
        if ($stuffinfo['height'] != '') {
            $stuff_con_height = (int)explode('px', $stuffinfo['height'])[0];
            $stuff_con_height = ($stuff_con_height - 110);
        }

        $IS_ADMIN = 'no';
        if(is_admin($current_user))
            $IS_ADMIN = 'yes';

        crm_load_class_file('DragonTigerList','modules/Home/HomeBoardNew');
        $DragonTigerListObj=new DragonTigerList($boardid);
        $DragonTigerListObj->setStuffId($stuffid);
        $DragonTigerList = $DragonTigerListObj->getAllDragonTigerList();
        $this->DefaultSelName = 'dragontiger_NewContacts';
        $smarty = new lingdangCRM_Smarty();
        $smarty -> assign('stuffinfo',$stuffinfo);
        $smarty -> assign('boardid',$boardid);
        $smarty -> assign('languageType',$languageType);
        $smarty -> assign('IS_ADMIN',$IS_ADMIN);
        $smarty -> assign('SetClick',$this->getSetClick());
        //获取页签Html内容
        $this->getPageTabHtml($smarty,$DragonTigerList);
        $ChartRowNum = (int)$DragonTigerList[$this->PageTabListSelKey]['topnumber'];
        $ChartRowHeight = 52;
        $ChartHeight = $ChartRowNum*$ChartRowHeight;
        $smarty -> assign('ChartHeight',$ChartHeight.'px');
        $smarty -> assign('stuff_con_height',$stuff_con_height.'px');
        $viewStyle = '';
        if($this->viewStyle == 'Preview'){
            $viewStyle = strtolower($this->viewStyle) . '_';
            $smarty -> assign('viewStyle',$viewStyle);
            $stuff_content_html = $smarty -> fetch("Home/HomeBoardNew_Preview.tpl");
        } else {
            $stuff_content_html = $smarty -> fetch("Home/HomeBoardNewParent.tpl");
        }

        return $stuff_content_html;
    }

    /**
     * Edit: xll
     * Date: 2023/08/22
     * Reason: 过滤的数组为榜单数组 ( stuffdetail )
     * Params: homestuffdetailid,stufflabel,selected为空,$languageType
     * Params: 筛选键值used, 筛选值yes, 即只获取used值为yes的部分
     */
    public function getPageTabListKeyArr(){
        global $languageType;
        $PageTabListKeyArr = ['id'=>'homestuffdetailid','name'=>'stufflabel','selected'=>'',
            'label'=>$languageType,'filterKey'=>'selected','filterValue'=>['yes','1']];
        return $PageTabListKeyArr;
    }

    public function getPageTabDefaultSelName(){
        $DefaultStuffLabel = '';
        if(isset($_REQUEST['DefaultStuffLabel']) && !empty($_REQUEST['DefaultStuffLabel']) && $_REQUEST['DefaultStuffLabel'] != 'undefined'){
            $DefaultStuffLabel = $_REQUEST['DefaultStuffLabel'];
        }
        else{
            $DefaultStuffLabel = getUsersettingByLabel('Home','','DragonTigerList_PageTab');
        }
        if(!empty($DefaultStuffLabel) && $DefaultStuffLabel != '')
            $this->DefaultSelName = $DefaultStuffLabel;
    }

    public function getSetClick(){
        return "DragonTigerListManage(event,$this->boardid)";
    }
}

?>