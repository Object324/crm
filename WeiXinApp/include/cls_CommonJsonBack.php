<?php
/**
 * reason:这个类供优化前端渲染使用，减少前端代码，前端获取到返回值进行循环实现
 * editor:xxs
 * date:20180411
 */
class cls_CommonJsonBack
{
    //更多权限设置页
    public function getJurisdictionSet(){
        // $entity = array();
        // $entity['header'] = '更多权限，灵活管理';
        // $entity['list'][] = array('a'=>'ico1','b'=>'菜单定制和页面设置','c'=>'配置系统菜单和单据字段显示');
        // $entity['list'][] = array('a'=>'ico2','b'=>'管理数据分类','c'=>'设置数据分类筛选序时簿显示数据');
        // $entity['list'][] = array('a'=>'ico3','b'=>'设置角色权限与数据范围','c'=>'管理不同角色人员的操作权限和数据查看范围');
        // $entity['list'][] = array('a'=>'ico4','b'=>'审批流程管理','c'=>'设置不同的审批流程');
        // $entity['footer'] = '更多权限设置，请用管理员账号登录电脑web端设置';
        // return $entity;

        //通用设置 zxm 2021-0407
        global $adb,$current_user,$MobileLanguageType;
        $entity = array();
        $entity['currency'] = 'yes';
        $entity['commonset'] = array();
        
        //edit: xll 20230104 XUQIU1000984 移动端图标增加显示简易风格，显示在最上方
        $changeSimple = array();
        $deployarr_13 = getAppsys_deploy(13);
        $is_open13 = ($deployarr_13 != '') ? $deployarr_13['is_open'] : 'no';
        $changeSimple['content'] = getFixedLabel('WHETHERICONSIMPLESTYLE');
        $changeSimple['describe'] = '';
        $changeSimple['bigtype'] = 'boolean';
        $changeSimple['is_open'] = $is_open13;
        $changeSimple['deploy_type'] = 13;
        $entity['commonset'][] = $changeSimple;
        
        $listBtn = array();
        $sql_common = 'select userid,is_open from ld_appsystem where userid= ? and deploy_type =7';
        $result_common = $adb->pquery($sql_common,array($current_user->id));
        if($adb->num_rows($result_common)>0){
            $is_open = $adb->query_result($result_common,0,'is_open');
        } else{
            $is_open = 'no';
        }
        $listBtn['content'] = getFixedLabel('DISPLAYQUICKOPERATIONBUTTONS');//单据列表是否显示快速操作按钮
        $listBtn['describe'] = '';//开启后，单据列表界面将显示相关信息快速创建和更多操作按钮
        $listBtn['bigtype'] = 'boolean';
        $listBtn['is_open'] = $is_open;
        $listBtn['deploy_type'] = 7;
        $entity['listBtn'] = $listBtn;
        $entity['commonset'][] = $listBtn;
        
        //移动端明细是否折叠显示---去掉该参数 zxm 20230317 XUQIU1001134 移动端详情界面定制，增加“分录明细显示样式”参数（郭良峰）
        /**$DisplayBtn = array();
        $sql_common = 'select userid,is_open from ld_appsystem where userid= ? and deploy_type =11';
        $result_common = $adb->pquery($sql_common,array($current_user->id));
        if($adb->num_rows($result_common)>0){
            $is_open = $adb->query_result($result_common,0,'is_open');
        } else{
            $is_open = 'no';
        }
        $DisplayBtn['content'] = getFixedLabel('DETAILSISCOLLAPSEDISPLAY');//单据列表是否显示快速操作按钮
        $DisplayBtn['describe'] = '';//开启后，单据列表界面将显示相关信息快速创建和更多操作按钮
        $DisplayBtn['is_open'] = $is_open;
        $DisplayBtn['deploy_type'] = 11;
        $entity['CollapseDisplay'] = $DisplayBtn;
        $entity['commonset'][] = $DisplayBtn;*/
        
        $sql_8 = 'select userid,is_open from ld_appsystem where userid= ? and deploy_type =8';
        $result_8 = $adb->pquery($sql_8,array($current_user->id));
        if($adb->num_rows($result_8)>0){
            $is_open8 = $adb->query_result($result_8,0,'is_open');
        } else{
            $is_open8 = 'no';
        }
        $searchBtn['content'] = getFixedLabel('ENABLESGLOBALSEARCH');//功能菜单是否启用全局查找
        $searchBtn['describe'] = '';
        $searchBtn['bigtype'] = 'boolean';
        $searchBtn['deploy_type'] = 8;
        $searchBtn['is_open'] = $is_open8;
        $entity['searchBtn'] = $searchBtn;
        $entity['commonset'][] = $searchBtn;
        
        $sql_9 = 'select userid,is_open from ld_appsystem where userid= ? and deploy_type =9';
        $result_9 = $adb->pquery($sql_9,array($current_user->id));
        if($adb->num_rows($result_9)>0){
            $is_open9 = $adb->query_result($result_9,0,'is_open');
        } else{
            $is_open9 = 'no';
        }
        $scanBtn['content'] = getFixedLabel('SCANFUNCTIONISENABLED');//功能菜单是否启用扫一扫功能
        $scanBtn['describe'] = '';
        $scanBtn['bigtype'] = 'boolean';
        $scanBtn['is_open'] = $is_open9;
        $scanBtn['deploy_type'] = 9;
        $entity['scanBtn'] = $scanBtn;
        $entity['commonset'][] = $scanBtn;

        //字段显示样式为多行显示
        $virify_accounts = vtlib_isModuleActive('Accounts');
        $virify_vendors = vtlib_isModuleActive('Vendors');
        if($virify_accounts||$virify_vendors){
            $sql_10 = 'select userid,is_open from ld_appsystem where userid= ? and deploy_type =10';
            $result_10 = $adb->pquery($sql_10,array($current_user->id));
            if($adb->num_rows($result_10)>0){
                $is_open10 = $adb->query_result($result_10,0,'is_open');
            } else{
                $is_open10 = 'no';
            }
            $multiLineShowBtn['content'] = getFixedLabel('DISPLAYSTYLEISMULTILINE');//字段显示样式为多行显示
            //描述
            $describe = [];
            if($virify_accounts){
                $describe[] = getTranstab('Accounts')."'".gettranslabelfields('Accounts','accountname')."'";
            }
            if($virify_vendors){
                $describe[] = getTranstab('Vendors')."'".gettranslabelfields('Vendors','vendorname')."'";
            }
            if($MobileLanguageType == 'en'){
                $describe = implode(' and ',$describe);
            }else{
                $describe = implode('和',$describe);
            }
            
            $multiLineShowBtn['describe'] = sprintf(getFixedLabel('TMPDISPLAYSTYLEISMULTILINE'),$describe);
            $multiLineShowBtn['bigtype'] = 'boolean';
            $multiLineShowBtn['is_open'] = $is_open10;
            $multiLineShowBtn['deploy_type'] = 10;
            $entity['multiLineShowBtn'] = $multiLineShowBtn;
            $entity['commonset'][] = $multiLineShowBtn;
        }

        //是否启用快捷返回页签首页按钮
        $quickreturnHome = array();
        $sql_common = 'select userid,is_open from ld_appsystem where userid= ? and deploy_type =12';
        $result_common = $adb->pquery($sql_common,array($current_user->id));
        if($adb->num_rows($result_common)>0){
            $is_open = $adb->query_result($result_common,0,'is_open');
        } else{
            $is_open = 'no';
        }
        $quickreturnHome['content'] = getFixedLabel('ENABLEQUICKRETURNHOME');
        $quickreturnHome['describe'] = '';
        $quickreturnHome['bigtype'] = 'boolean';
        $quickreturnHome['is_open'] = $is_open;
        $quickreturnHome['deploy_type'] = 12;
        $entity['commonset'][] = $quickreturnHome;

        //附近客户地图默认可见范围
        $nearbyCustomerVisible = array();
        $sql_14 = 'select userid, is_open,deploy_value from ld_appsystem where userid= ? and deploy_type = 14';
        $result_14 = $adb->pquery($sql_14,array($current_user->id));
        if($adb->num_rows($result_14)>0){
            $is_open = $adb->query_result($result_14,0,'deploy_value');
        } else{
            $is_open = '';
        }
        $nearbyCustomerVisible['content'] = getFixedLabel('NEARBYCUSTOMERVISIBLE');
        $nearbyCustomerVisible['describe'] = '';
        $nearbyCustomerVisible['bigtype'] = 'picklist';
        $ncvArr = [];
        $ncvArr[] = array("label"=>'1'.getFixedLabel('KILOMETRE'),"value"=>'1',"selected"=>'no');
        $ncvArr[] = array("label"=>'2'.getFixedLabel('KILOMETRE'),"value"=>'2',"selected"=>'no');
        $ncvArr[] = array("label"=>'3'.getFixedLabel('KILOMETRE'),"value"=>'3',"selected"=>'no');
        $ncvArr[] = array("label"=>'5'.getFixedLabel('KILOMETRE'),"value"=>'5',"selected"=>'no');
        $ncvArr[] = array("label"=>'10'.getFixedLabel('KILOMETRE'),"value"=>'10',"selected"=>'no');
        $ncvArr[] = array("label"=>'50'.getFixedLabel('KILOMETRE'),"value"=>'50',"selected"=>'no');
        $ncvArr[] = array("label"=>'100'.getFixedLabel('KILOMETRE'),"value"=>'100',"selected"=>'no');
        $ncvArr[] = array("label"=>'200'.getFixedLabel('KILOMETRE'),"value"=>'200',"selected"=>'no');
        $ncvArr[] = array("label"=>'300'.getFixedLabel('KILOMETRE'),"value"=>'300',"selected"=>'no');
        $ncvArr[] = array("label"=>'400'.getFixedLabel('KILOMETRE'),"value"=>'400',"selected"=>'no');
        $ncvArr[] = array("label"=>'500'.getFixedLabel('KILOMETRE'),"value"=>'500',"selected"=>'no');
        if($is_open == ''){
            $ncvArr[3]['selected'] = 'yes';
            $label = '5'.getFixedLabel('KILOMETRE');
            $is_open = 5;
        }
        else{
            for($i=0;$i<count($ncvArr);$i++){
                if($is_open == $ncvArr[$i]['value']){
                    $ncvArr[$i]['selected'] = 'yes';
                    $label = $ncvArr[$i]['label'];
                    break;
                }
            }
        }
        $nearbyCustomerVisible['options'] = $ncvArr;
        $nearbyCustomerVisible['label'] = $label;
        $nearbyCustomerVisible['is_open'] = $is_open;
        $nearbyCustomerVisible['deploy_type'] = 14;
        $entity['commonset'][] = $nearbyCustomerVisible;
        
        return $entity;
    }
    
    //版本切换页
    public function getVersionPage(){
        $entity['list'][] = array('a'=>'biaozhunRadio','b'=>'55','c'=>getFixedLabel('ZHUHUABASICEDITION'));
        $entity['list'][] = array('a'=>'xiaoshouRadio','b'=>'56','c'=>getFixedLabel('ZHUHUAENHANCEDEDITION'));
        $entity['list'][] = array('a'=>'fuwuRadio','b'=>'57','c'=>getFixedLabel('ZHUHUASERVICEENHANCEDEDITION'));
        return $entity;
    }
}