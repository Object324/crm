<?php
if(isset($_REQUEST['mode']) && $_REQUEST['mode']=='listview'){
    global $current_user;
    $smarty = new lingdangCRM_Smarty;
    //@edit:zhaosk @date:2024/08/09 @reason:前端页面列表项属性获取
    $SettingsBlocks = getSettingsBlocks();
    $SettingsFields = getSettingsFields();
    //20240614 hzx 后台设置分离
    $parenttablist = [];
    foreach ($SettingsBlocks as $blockid => $blockname){
        foreach ($SettingsFields[$blockid] as $index => $fieldinfo){
            if($fieldinfo['fieldid'] && $fieldinfo['fieldid']>0){
                $fieldinfo['label'] = getFixedLabel($fieldinfo['name']);
                $fieldinfo['parenttab_name'] = $blockname;
                $parenttablist[$fieldinfo['name']] = $fieldinfo;
            }
        }
    }
    //@edit:zhaosk @date:2024/08/09 @reason:公海参数设置增加权限判断
    //客户
    crm_load_class_file('cls_PublicAccounts', 'modules/Accounts');
    $cls_PublicAccounts = cls_PublicAccounts::getInstance('Accounts');
    $public_account = $cls_PublicAccounts->getPublicAccountConfig();
    if($public_account['status'] == 'yes') {
        $public_account_pool_label = array();
        $first_pool_id = 0;
        $create_commonaccount = 'yes';
        if ($cls_PublicAccounts->isHavePublicPage() == 'yes') {
            if (!empty($public_account['public_account_pool'])) {


                foreach ($public_account['public_account_pool'] as $pool_id => $pool_info) {
                    $administrators_arr = explode(',', $pool_info['administrators']);
                    if ($pool_info['allowget'] == 'yes' && !in_array($current_user->id, $administrators_arr)) {
                        $pool_info['accounttype'] = 'PUBLICALLOCATE';
                    } else {
                        $pool_info['accounttype'] = 'NOALLOCATE';
                    }
                    $public_account_pool_label[$pool_id] = $pool_info;
                }
            }
        }
    }
    //销售线索
    crm_load_class_file('cls_PublicLeads', 'modules/Leads');
    $cls_PublicLeadsObj = new cls_PublicLeads('Leads');
    $public_leads = $cls_PublicLeadsObj->getPublicAccountConfig();
    if($public_leads['status'] == 'yes') {
        $public_leads_pool_label = array();
        $first_pool_id = 0;
        $create_commonaccount = 'yes';
        if (!empty($public_leads['public_account_pool'])) {
            foreach ($public_leads['public_account_pool'] as $pool_id => $pool_info) {
                if (empty($first_pool_id)) {
                    $first_pool_id = $pool_id;
                }
                if ($pool_info['default_pool'] == 'yes') {
                    $first_pool_id = $pool_id;
                }
                $administrators_arr = explode(',', $pool_info['administrators']);
                if ($pool_info['allowget'] == 'yes' && !in_array($current_user->id, $administrators_arr)) {
                    $pool_info['accounttype'] = 'PUBLICALLOCATE';
                } else {
                    $pool_info['accounttype'] = 'NOALLOCATE';
                }
                $public_leads_pool_label[$pool_id] = $pool_info;
            }
        }
    }
    $is_admin='';
    if(is_admin($current_user))
        $is_admin='yes';
    else
        $is_admin='no';
    $is_account='';
    if(vtlib_isModuleActive('Accounts'))
        $is_account='yes';
    else
        $is_account='no';
    $is_leads='';
    if(vtlib_isModuleActive('Leads'))
        $is_leads='yes';
    else
        $is_leads='no';
    $smarty->assign('PUBLIC_ACCOUNT',$public_account);
    $smarty->assign('PUBLIC_Leads',$public_leads);
    $smarty->assign('PUBLICACCOUNTSTATUS',$public_account['status']);
    $smarty->assign('PUBLICLeadsSTATUS',$public_leads['status']);
    $smarty->assign('PUBLIC_ACCOUNT_POOL_LABEL',$public_account_pool_label);
    $smarty->assign('PUBLIC_Leads_POOL_LABEL',$public_leads_pool_label);
    $smarty->assign('PARENTTABLIST',$parenttablist);
    $smarty->assign('CURRENTUSER',$current_user->id);
    $smarty->assign('ISADMIN',$is_admin);
    $smarty->assign('ISACCOUNT',$is_account);
    $smarty->assign('ISLEADS',$is_leads);
    $arr['content']= $smarty->fetch('settings_homepage.tpl');
    ConvertTojsonString(1,$arr,"success");
}