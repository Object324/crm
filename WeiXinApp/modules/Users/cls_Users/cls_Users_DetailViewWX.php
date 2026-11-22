<?php
//gyq_117 reason:企业微信增加个人资料及修改密码  2019/5/30 13:54
crm_load_class_file('cls_DetailViewWX', 'WeiXinApp/detail');
class cls_Users_DetailViewWX extends cls_DetailViewWX
{
    protected function set_DetailView()
    {
        global $current_user,$adb;
        $_REQUEST['record'] = $current_user->id;
        parent::set_DetailView();
        $list = $this->jsonArr['list'];

        $user_base = array();
        foreach ($list as $key=>$content){
            foreach ($content['fieldinfo'] as $key2=>$value){
                $user_base[$value['fieldname']] = $value;
            }
        }
        
        if($this->action=='DetailView'){
            $maininfo_field = array('imagename','last_name','userlevel');
            $maininfo = array();
            foreach ($maininfo_field as $value){
                if(isset($user_base[$value])){
                    $maininfo['list'][$value] = $user_base[$value] ;
                }
                // 头像无值做默认头像 zxm 2020-1218 --详情
                if(!isset($user_base['imagename'])||empty( $user_base[$value]['options'])){
                    // ljj 20231201 XUQIU1000927 更换默认头像
                    $userfilepath=getDefaultAvatar($current_user->id);
                    $maininfo['list'][$value]['options'][0] = array('imgid'=>0,'value'=>$userfilepath);
                }
            }
            $list_field = array('user_name','groupid','phone_mobile','phone_home','email1','hire_date');
        }else{
            //reason:编辑界面，显示字段与明细界面不一样  2019/6/4 17:18
            $maininfo_field = array('imagename');
            $maininfo = array();
            foreach ($maininfo_field as $value){
                if(isset($user_base[$value])){
                    $maininfo['list'][$value] =$user_base[$value] ;
                }
                // 头像无值做默认头像 zxm 2020-1218 --详情
                if(!isset($user_base['imagename'])||empty( $user_base['imagename']['option'])){
                    // ljj 20231201 XUQIU1000927 更换默认头像
                    $userfilepath=getDefaultAvatar($current_user->id);
                    $maininfo['list'][$value]['option'][0] = array('imgid'=>0,'path'=>'','value'=>$userfilepath);
                }
            }
            if(isKehu001ServerPc()=='yes'){
                $list_field = array('phone_mobile','phone_home','email1');
            }else{
                $list_field = array('last_name','phone_mobile','phone_home','email1');
            }
        }
        foreach($current_user->fieldobj->getModuleFields() as $tmpfiedname=>$tmpfieldinfo)
        {
            if($tmpfieldinfo->getColumnName()=='user_name')
                continue;
           /* if($tmpfieldinfo->getKeywords()=='yes')
            {
                if(!in_array($tmpfiedname,$list_field))
                    $list_field[]=$tmpfiedname;
            }*/
        }
         
        $listinfo = array();
        $listinfo[0]['blocklabel'] = $list[0]['blocklabel'];
        $listinfo[0]['display_status'] = 1;
        foreach ($list_field as $key=>$value){
            if(isset($user_base[$value]))
                $listinfo[0]['fieldinfo'][] = $user_base[$value];
        }
       
        $this->jsonArr['list'] = $listinfo;
        $this->jsonArr['maininfo'] = $maininfo;
        if($this->action == 'DetailView'){
            $arrFixedLabel=array(
                'EDIT',//编辑
                'LOADING',//加载中...
                'PERSONALDATA',//个人资料
            );
            $arrfixedlabel = TransFieldlabel($arrFixedLabel,'no');
        }else if($this->action == 'EditView'){
            $arrFixedLabel=array(
                'MODIFYAVATAR',//修改头像
                'LBL_PLEASE_SELECT',//请选择
                'pleaseenter',//请输入
                'SAVE',//保存
                'MODIFYDATA',//修改资料
                'UPLOADFAILED',//上传失败
                'SUCCESSFULLYSAVED',//保存成功
            );
            $arrfixedlabel = TransFieldlabel($arrFixedLabel);
        }
        $this->jsonArr['arrFixedLabel'] = $arrfixedlabel;
        //unset($this->jsonArr['list2']);
        unset($this->jsonArr['relatedCreateList']);
        unset($this->jsonArr['version']);
        unset($this->jsonArr['relatedList']);
        //unset($this->jsonArr['commentpermit']);
    }
}