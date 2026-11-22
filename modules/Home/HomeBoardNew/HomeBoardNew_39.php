<?php
crm_load_class_file('HomeBoardNewParent','modules/Home/HomeBoardNew');
class  HomeBoardNew_39 extends  HomeBoardNewParent
{
    public $viewStyle;
    public $DefaultLabel = 'new_reminds_modules';
    public $tablist;
    public function get_stuff_content_html($stuffinfo)
    {
        global $languageType,$current_user;
        $this->getStuffLabel($stuffinfo);
        if ($stuffinfo['height'] != '') {
            $stuff_con_height = (int)explode('px', $stuffinfo['height'])[0];
            $stuff_con_height = ($stuff_con_height - $this->title_height - 40);
        }
        $IS_ADMIN = 'no';
        if(is_admin($current_user))
            $IS_ADMIN = 'yes';


        $tablist = $this->getTablist($stuffinfo['stuffid']);
        $smarty = new lingdangCRM_Smarty();
        $smarty -> assign('stuffinfo',$stuffinfo);
        $smarty -> assign('languageType',$languageType);
        $smarty -> assign('stuff_con_height',$stuff_con_height.'px');
        $smarty -> assign('IS_ADMIN',$IS_ADMIN);
        $smarty -> assign('SetClick',$this->getSetClick($stuffinfo['stuffid']));
        //获取页签Html内容
        $this->getPageTabHtml($smarty,$tablist);

        if(isset($this->viewStyle) && $this->viewStyle == 'Preview'){
            $viewStyle = strtolower($this->viewStyle) . '_';
            $smarty -> assign('viewStyle',$viewStyle);
            //看板编辑界面的页面
            $stuff_content_html = $smarty -> fetch("Home/HomeBoardNew_Preview.tpl");
        } elseif (isset($this->viewStyle) && $this->viewStyle == 'oldboard') {
            //旧默认看板的页面（只获取页签html）
            $stuff_content_html = $this->PageTabHtml;
        } else {
            //组件展示页面
            $stuff_content_html = $smarty -> fetch("Home/HomeBoardNewParent.tpl");
        }
        return $stuff_content_html;
    }

    public function getTablist($stuffid){
        global $current_user,$adb;
        $DefaultModule = getUsersettingByLabel('Reminds',$current_user->id,$this->DefaultLabel);
        $this->tablist = [
            ['id'=>0,'name'=>'Pending','label'=>getFixedLabel('Pending'),'selected'=>'yes'],
            ['id'=>1,'name'=>'Processed','label'=>getFixedLabel('Processed'),'selected'=>'no'],
            ['id'=>3,'name'=>'isubmitted','label'=>getFixedLabel('isubmitted'),'selected'=>'no'],
            ['id'=>4,'name'=>'ApproveRejected','label'=>getFixedLabel('ApproveRejected'),'selected'=>'no']
        ];
        //客户管理、跟进记录、销售机会、合同订单、已读--默认的
        $selectedModule = 'Pending,Processed,isubmitted,ApproveRejected';
        $selectedModule_arr = explode(',',$selectedModule);

        foreach($this->tablist as $i=>$tmpmodule){
            $this->tablist[$i]['selected'] = ($DefaultModule==$tmpmodule['name'])?'yes':'no';
        }
        return $this->tablist;
    }
    public function getSetClick($stuffid){
        return "newRemindsListManage(event,$this->boardid,$stuffid)";
    }
}
?>