<style>
.leftmenusettinghomepage{
    margin-top:4px;
    margin-left:20px;
    cursor:default;
}
.setting_homepage_list{
    margin-top: 16px;
}
.setting_list_title{
    display: flex;
    align-items: center;
    margin-bottom:20px;
}
.setting_list_title_colomn{
    width: 4px;
    height: 20px;
    background: #3B7CFF;
}
.setting_list_title_name{
    font-weight: 600;
    height:20px;
    font-size: 20px;
    color: #333333;
    line-height: 20px;
    text-align: left;
    font-style: normal;
    margin-left: 8px;
}
.setting_list_content{
    display:flex;
    flex-wrap: nowrap; /* 不换行 */
}
.setting_list_content_contanier{
    margin-bottom: 16px;
    margin-right: 17px;
    margin-left: 3px;
    width: 281px;
    height: 208px;
    background: #FFFFFF;
    box-shadow: 0 0 4px 0 rgba(10,42,97,0.2);
    border-radius: 4px;
    min-width:217px;
}
.setting_container_title{
    display: flex;
    margin-left:16px;
    margin-top:12px;
    margin-bottom:12px;
    align-items: center;
}
.setting_container_title img{
    margin-right:4px;
    width:24px;
    height:24px;
}
.setting_container_title span{
    font-weight: 500;
    font-size: 18px;
    color: #333333;
    line-height: 18px;
    text-align: left;
    font-style: normal;
}
.setting_container_splitline{
    width:100%;
    height: 1px;
    border-top: 1px solid #EBEDF0;
}
.setting_container_content{
    margin-left: 16px;
    display: flex;
    flex-direction: column;
    height: calc(100% - 42px);
}
.setting_container_content li{
    font-weight: 400;
    font-size: 14px;
    line-height: 14px;
    text-align: left;
    font-style: normal;
    margin-top:16px;
}
.setting_container_content_dot{
    width: 4px;
    height: 4px;
    background: #333333;
    border-radius: 50%;
    margin-right:12px;
}
.setting_container_content a{
    color: #333333 !important;
    display:flex;
    align-items: center;
}
.setting_container_content a:hover{
    color: #3B7CFF !important;
}
</style>
<div class="main_grid_box leftmenusettinghomepage" name="leftmenusettinghomepage" style="overflow: auto;">
    <div class="setting_homepage_list">
        <div class="setting_list_title">
            <div class="setting_list_title_colomn"></div>
            <span class="setting_list_title_name">{'BASICSETTINGS'|@getFixedLabel}</span>
        </div>
        <ul class="setting_list_content">
            <li class="setting_list_content_contanier">
                <div class="setting_container_title">
                    <img src="{$IMAGEURL}themes/images/ld_settinghomepage_1.png?v={$GLOBALMINVERSION}">
                    <span>{'ENTERPRISESETTINGS'|@getFixedLabel}</span>
                </div>
                <div class="setting_container_splitline"></div>
                <ul class="setting_container_content">
                    <li fieldid="{$PARENTTABLIST['LBL_COMPANY_DETAILS']['fieldid']}" parenttab_name="{$PARENTTABLIST['LBL_COMPANY_DETAILS']['parenttab_name']}" action="{$PARENTTABLIST['LBL_COMPANY_DETAILS']['action']}">
                        <a><div class="setting_container_content_dot"></div>
                            <span>{'BUSINESSNAMEANDLOGOSETTINGS'|@getFixedLabel}</span>
                        </a>
                    </li>
                    {if $ISADMIN eq 'yes'}
                    <li data-name="{'ACCOUNTLOGINSECURITYSETTINGS'|@getFixedLabel}">
                        <a><div class="setting_container_content_dot"></div>
                            <span>{'ACCOUNTLOGINSECURITYSETTINGS'|@getFixedLabel}</span>
                        </a>
                    </li>
                    {/if}
                </ul>
            </li>
            <li class="setting_list_content_contanier">
                <div class="setting_container_title">
                    <img src="{$IMAGEURL}themes/images/ld_settinghomepage_2.png?v={$GLOBALMINVERSION}">
                    <span>{'STRUCTUREMANAGEMENT'|@getFixedLabel}</span>
                </div>
                <div class="setting_container_splitline"></div>
                <ul class="setting_container_content">
                    <li data-linkurl="index.php?pageto_module=Users&pageto_action=index">
                        <a><div class="setting_container_content_dot"></div>
                            <span>{'ENTERINGEMPLOYEESANDDEPARTMENTS'|@getFixedLabel}</span>
                        </a>
                    </li>
                    <li data-linkurl="index.php?pageto_module=Settings&pageto_action=loginpolicy">
                        <a><div class="setting_container_content_dot"></div>
                            <span>{'EMPLOYEELOGINMETHODCONTROL'|@getFixedLabel}</span>
                        </a>
                    </li>
                </ul>
            </li>
            <li class="setting_list_content_contanier">
                <div class="setting_container_title">
                    <img src="{$IMAGEURL}themes/images/ld_settinghomepage_3.png?v={$GLOBALMINVERSION}">
                    <span>{'PRIVILEGEMANAGEMENT'|@getFixedLabel}</span>
                </div>
                <div class="setting_container_splitline"></div>
                <ul class="setting_container_content">
                    <li data-linkurl="index.php?pageto_module=Settings&pageto_action=listroles">
                        <a><div class="setting_container_content_dot"></div>
                            <span>{'EMPLOYEEMODULEPERMISSIONSETTINGS'|@getFixedLabel}</span>
                        </a>
                    </li>
                    <li data-linkurl="index.php?pageto_module=Users&pageto_action=index">
                        <a><div class="setting_container_content_dot"></div>
                            <span>{'EMPLOYEEDATASCOPESETTINGS'|@getFixedLabel}</span>
                        </a>
                    </li>
                </ul>
            </li>
            <li class="setting_list_content_contanier">
                <div class="setting_container_title">
                    <img src="{$IMAGEURL}themes/images/ld_settinghomepage_4.png?v={$GLOBALMINVERSION}">
                    <span>{'INTERFACEMANAGEMENT'|@getFixedLabel}</span>
                </div>
                <div class="setting_container_splitline"></div>
                <ul class="setting_container_content">
                    <li fieldid="{$PARENTTABLIST['LBL_TABLIST']['fieldid']}" parenttab_name="{$PARENTTABLIST['LBL_TABLIST']['parenttab_name']}" action="{$PARENTTABLIST['LBL_TABLIST']['action']}">
                        <a><div class="setting_container_content_dot"></div>
                            <span>{'PCMENUMANAGEMENTSETTINGS'|@getFixedLabel}</span>
                        </a>
                    </li>
                    {if $ISADMIN eq 'yes'}
                    <li data-name="{'PCHOMEPAGECUSTOMIZATION'|@getFixedLabel}">
                        <a><div class="setting_container_content_dot"></div>
                            <span>{'PCHOMEPAGECUSTOMIZATION'|@getFixedLabel}</span>
                        </a>
                    </li>
                    {/if}
                    <li fieldid="{$PARENTTABLIST['MobileAppMenuCustomization']['fieldid']}" parenttab_name="{$PARENTTABLIST['MobileAppMenuCustomization']['parenttab_name']}" action="{$PARENTTABLIST['MobileAppMenuCustomization']['action']}">
                        <a><div class="setting_container_content_dot"></div>
                            <span>{'MOBILEFUNCTIONMENUMANAGEMENTSETTINGS'|@getFixedLabel}</span>
                        </a>
                    </li>
                    <li fieldid="{$PARENTTABLIST['mobile_home_setting']['fieldid']}" parenttab_name="{$PARENTTABLIST['mobile_home_setting']['parenttab_name']}" action="{$PARENTTABLIST['mobile_home_setting']['action']}">
                        <a><div class="setting_container_content_dot"></div>
                            <span>{'MOBILEWORKBENCHCUSTOMIZATION'|@getFixedLabel}</span>
                        </a>
                    </li>
                </ul>
            </li>
        </ul>
    </div>
    <div class="setting_homepage_list">
        <div class="setting_list_title">
            <div class="setting_list_title_colomn"></div>
            <span class="setting_list_title_name">{'BUSINESSCONFIGURATION'|@getFixedLabel}</span>
        </div>
        <ul class="setting_list_content">
            <li class="setting_list_content_contanier">
                <div class="setting_container_title">
                    <img src="{$IMAGEURL}themes/images/ld_settinghomepage_5.png?v={$GLOBALMINVERSION}">
                    <span>{'VTLIB_LBL_MODULE_MANAGER'|@getFixedLabel}</span>
                </div>
                <div class="setting_container_splitline"></div>
                <ul class="setting_container_content">
                    <li fieldid="{$PARENTTABLIST['VTLIB_LBL_MODULE_MANAGER']['fieldid']}" parenttab_name="{$PARENTTABLIST['VTLIB_LBL_MODULE_MANAGER']['parenttab_name']}" action="{$PARENTTABLIST['VTLIB_LBL_MODULE_MANAGER']['action']}">
                        <a><div class="setting_container_content_dot"></div>
                            <span>{'SYSTEMMODULEMANAGEMENT'|@getFixedLabel}</span>
                        </a>
                    </li>
                    <li fieldid="{$PARENTTABLIST['LBL_PRINT_TEMPLATE']['fieldid']}" parenttab_name="{$PARENTTABLIST['LBL_PRINT_TEMPLATE']['parenttab_name']}" action="{$PARENTTABLIST['LBL_PRINT_TEMPLATE']['action']}">
                        <a><div class="setting_container_content_dot"></div>
                            <span>{'MODULETEMPLATESETTINGS'|@getFixedLabel}</span>
                        </a>
                    </li>
                    <li fieldid="{$PARENTTABLIST['THEDOCUMENTTEMPLATE']['fieldid']}" parenttab_name="{$PARENTTABLIST['THEDOCUMENTTEMPLATE']['parenttab_name']}" action="{$PARENTTABLIST['THEDOCUMENTTEMPLATE']['action']}">
                        <a><div class="setting_container_content_dot"></div>
                            <span>{'RICHTEXTCONTENTTEMPLATESETTINGS'|@getFixedLabel}</span>
                        </a>
                    </li>
                    <li fieldid="{$PARENTTABLIST['LBL_WORK_TEMPLATE']['fieldid']}" parenttab_name="{$PARENTTABLIST['LBL_WORK_TEMPLATE']['parenttab_name']}" action="{$PARENTTABLIST['LBL_WORK_TEMPLATE']['action']}">
                        <a><div class="setting_container_content_dot"></div>
                            <span>{'WORKREPORTTEMPLATECUSTOMIZATION'|@getFixedLabel}</span>
                        </a>
                    </li>
                </ul>
            </li>
            <li class="setting_list_content_contanier">
                <div class="setting_container_title">
                    <img src="{$IMAGEURL}themes/images/ld_settinghomepage_6.png?v={$GLOBALMINVERSION}">
                    <span>{'PROCESSMANAGEMENT'|@getFixedLabel}</span>
                </div>
                <div class="setting_container_splitline"></div>
                <ul class="setting_container_content">
                    <li fieldid="{$PARENTTABLIST['LBL_APPROVE']['fieldid']}" parenttab_name="{$PARENTTABLIST['LBL_APPROVE']['parenttab_name']}" action="{$PARENTTABLIST['LBL_APPROVE']['action']}">
                        <a><div class="setting_container_content_dot"></div>
                            <span>{'APPROVALFLOWSETTINGS'|@getFixedLabel}</span>
                        </a>
                    </li>
                    <li fieldid="{$PARENTTABLIST['LBL_WORKFLOWCUSTOMIZATION_SET']['fieldid']}" parenttab_name="{$PARENTTABLIST['LBL_WORKFLOWCUSTOMIZATION_SET']['parenttab_name']}" action="{$PARENTTABLIST['LBL_WORKFLOWCUSTOMIZATION_SET']['action']}">
                        <a><div class="setting_container_content_dot"></div>
                            <span>{'WORKFLOWSETTINGS'|@getFixedLabel}</span>
                        </a>
                    </li>
                </ul>
            </li>
            <li class="setting_list_content_contanier">
                <div class="setting_container_title">
                    <img src="{$IMAGEURL}themes/images/ld_settinghomepage_7.png?v={$GLOBALMINVERSION}">
                    <span>{'DATARIGHTSMANAGEMENT'|@getFixedLabel}</span>
                </div>
                <div class="setting_container_splitline"></div>
                <ul class="setting_container_content">
                    <li data-linkurl="index.php?pageto_module=Users&pageto_action=index">
                        <a><div class="setting_container_content_dot"></div>
                            <span>{'MEMBERDATAPERMISSIONMANAGEMENT'|@getFixedLabel}</span>
                        </a>
                    </li>
                    <li fieldid="{$PARENTTABLIST['LBL_SHARING_ACCESS']['fieldid']}" parenttab_name="{$PARENTTABLIST['LBL_SHARING_ACCESS']['parenttab_name']}" action="{$PARENTTABLIST['LBL_SHARING_ACCESS']['action']}">
                        <a><div class="setting_container_content_dot"></div>
                            <span>{'MODULEDATASHARINGMANAGEMENT'|@getFixedLabel}</span>
                        </a>
                    </li>
                </ul>
            </li>
            {if ($ISACCOUNT eq 'yes'||$ISLEADS eq 'yes') && (($PUBLICACCOUNTSTATUS eq 'yes' && $PUBLIC_ACCOUNT_POOL_LABEL|@count neq 0) || ($PUBLICLeadsSTATUS eq 'yes' && $PUBLIC_Leads_POOL_LABEL|@count neq 0)) && ($PUBLIC_ACCOUNT.administrator eq 'yes' || $PUBLIC_Leads.administrator eq 'yes')}
            <li class="setting_list_content_contanier">
                <div class="setting_container_title">
                    <img src="{$IMAGEURL}themes/images/ld_settinghomepage_8.png?v={$GLOBALMINVERSION}">
                    <span>{'BUSINESSRULESMANAGEMENT'|@getFixedLabel}</span>
                </div>
                <div class="setting_container_splitline"></div>
                <ul class="setting_container_content">
                    {if $ISLEADS eq 'yes' && $PUBLIC_Leads.administrator eq 'yes' && $PUBLICLeadsSTATUS eq 'yes' && $PUBLIC_Leads_POOL_LABEL|@count neq 0}
                    <li data-name="{'SALESCLUEPUBLICPOOLMANAGEMENT'|@getFixedLabel}">
                        <a><div class="setting_container_content_dot"></div>
                            <span>{'SALESCLUEPUBLICPOOLMANAGEMENT'|@getFixedLabel}</span>
                        </a>
                    </li>
                    {/if}
                    {if $ISACCOUNT eq 'yes' && $PUBLIC_ACCOUNT.administrator eq 'yes' && $PUBLICACCOUNTSTATUS eq 'yes' && $PUBLIC_ACCOUNT_POOL_LABEL|@count neq 0}
                    <li data-name="{'CUSTOMERMANAGEMENTPUBLICPOOLMANAGEMENT'|@getFixedLabel}">
                        <a><div class="setting_container_content_dot"></div>
                            <span>{'CUSTOMERMANAGEMENTPUBLICPOOLMANAGEMENT'|@getFixedLabel}</span>
                        </a>
                    </li>
                    {/if}
                </ul>
            </li>
            {/if}
        </ul>
    </div>
</div>
<script>
    //@edit:zhaosk @date:2024/08/07 @reason:XUQIU20240626-11 后台设置--增加系统配置引导页
    //账号登录安全性设置
    var ACCOUNTLOGINSECURITYSETTINGS='{'ACCOUNTLOGINSECURITYSETTINGS'|@getFixedLabel}'
    //电脑端首页定制
    var PCHOMEPAGECUSTOMIZATION='{'PCHOMEPAGECUSTOMIZATION'|@getFixedLabel}'
    //销售线索公海池管理
    var SALESCLUEPUBLICPOOLMANAGEMENT='{'SALESCLUEPUBLICPOOLMANAGEMENT'|@getFixedLabel}'
    //客户管理公海池管理
    var CUSTOMERMANAGEMENTPUBLICPOOLMANAGEMENT='{'CUSTOMERMANAGEMENTPUBLICPOOLMANAGEMENT'|@getFixedLabel}'
    {literal}
    var CrmMenuobj = new ld_CrmMenu();
    var LayoutObj=ld('#pageleft #dropdownmenu .nav-menu-body ul.parenttab-items').get(0);
    ld('.setting_container_content li').each(function(){
        var that=this;
        ld(that).unbind('click').bind('click',function(evt){
            //如果要跳转到后台设置菜单项
            if(ld(this).attr('fieldid')&&ld(this).attr('parenttab_name')&&ld(this).attr('action')){
                //@edit:zhaosk @date:2024/08/14 @reason:BUG20240813-17 系统配置引导页点击打开新页签
                var action=ld(this).attr('action');
                var href=location.href;
                var hrefArr = href.split('&pageto_menufile');
                var newUrl=hrefArr[0]+"&pageto_menufile="+action;
                OpenNewWebTab(newUrl);
                /*var submenuobj = ld(LayoutObj).find("li.parenttab-li .parenttabrel-items").find('.parenttab-item .parenttabrel-item[fieldid='+ld(this).attr('fieldid')+']');
                submenuobj.click();
                if(ld(LayoutObj).find('li.parenttab-li[name='+ld(this).attr('parenttab_name')+']').hasClass('selected')){
                }else{
                    ld(LayoutObj).find('li.parenttab-li[name='+ld(this).attr('parenttab_name')+']').click();
                }*/
            }
            //如果要跳转到功能模块
            else if(ld(this).data("linkurl") !== undefined){
                OpenNewWebTab(ld(this).data("linkurl"));
            }
            //如果要显示弹窗
            else if(ld(this).data("name") !== undefined){
                switch (ld(this).data("name")){
                    //登录控制弹窗
                    case ACCOUNTLOGINSECURITYSETTINGS:
                        getJsScript('include/js/modules/Users/Users.js', function () {
                            var userobj=cls_Users.getInstance();
                            userobj.setLoginControlPopup();
                        });
                        break;
                    case PCHOMEPAGECUSTOMIZATION:
                        getJsScript('include/js/modules/Home/Home.js', function () {
                            HomeboardListview('Home');
                        });
                        break;
                    case SALESCLUEPUBLICPOOLMANAGEMENT:
                        AjaxJSPage('publicLeads.js','include/js/modules/Leads/publicLeads.js');
                        AjaxJSPage('Leads.js',' include/js/modules/Leads/Leads.js')
                        publicLeadslistobj = new publicLeads('');	//公海参数、公海池
                        publicLeadslistobj.edit_account_public_pool(evt.target,evt.target)
                        break;
                    case CUSTOMERMANAGEMENTPUBLICPOOLMANAGEMENT:
                        AjaxJSPage('publicAccounts.js','include/js/modules/Accounts/publicAccounts.js')
                        AjaxJSPage('Accounts.js','include/js/modules/Accounts/Accounts.js')
                        var cls_publicAccounts = new publicAccounts('');
                        cls_publicAccounts.edit_account_public_pool(evt.target,evt.target);
                        break;
                    default:
                        break;
                }
            }
        })
    })
    {/literal}
</script>