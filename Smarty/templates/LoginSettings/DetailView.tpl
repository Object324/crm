{*<!--
/*********************************************************************************
  ** The contents of this file are subject to the lingdang CRM Public License Version 1.0
   * ("License"); You may not use this file except in compliance with the License
   * The Original Code is:  lingdang CRM Open Source
   * The Initial Developer of the Original Code is lingdang.
   * Portions created by lingdang are Copyright (C) lingdang.
   * All Rights Reserved.
  *
 ********************************************************************************/
-->*}
<!--修改编码格式:统一编码：UTF-8-->
<form action="index.php" method="post" name="company" onsubmit="puyoungJS_DialogBox.block();">
<script language="JAVASCRIPT" type="text/javascript" src="include/js/modules/Settings/OrganizationConfig.js"></script>
<input type="hidden" name="module" value="Settings"/>
<input type="hidden" name="parenttab" value="Settings"/>
<input type="hidden" name="action"/>
<input type="hidden" name="blockidsetting" value="6"/>
<input type="hidden" name="fieldidsetting" value="75"/>
<div class="main_grid">
    <div class="main_grid_top">
        <div class="grid-view-title lfloat overflow-hidden">
            <span class="grid-view-name dinline-block lfloat">
                {'LBL_LOGIN_SETTINGS'|@getFixedLabel}
            </span>
        </div>
        <div class="grid_tool">
        </div>
    </div>
    <div class="main_grid_box">
        <div class="grid-analysis-box" style="height: 100%;">
            <div class="grid-analysis-header">
                <div name="loginsettingsnavbar" style="height: 48px;width: 100%;border-bottom: 1px solid #ddd;padding-left: 5px;"></div>
            </div>
            <div id="CamCardViewDetail" class="cont_wrap clear_float" style="height: calc(100% - 48px);">
                {include file="LoginSettings/DisplayDetailView.tpl"}
            </div>
        </div>
    </div>
</div>
</form>
<script type="text/javascript">
{literal}

    var loginsetnavbarobj = ld('[name=loginsettingsnavbar]');
    if(loginsetnavbarobj.length > 0){
        var listnavbardata = {
            NavBarSelKey : 0,
            ShowAllItemInfo: true,
            WidthFixed : false,
            CssVarList: {
                NavBarItemMinWidth: '120px'
            },
            NavBarMoreDefaultText: arrJsPopLabel['MORE'],
            OnClick : function(evt){
                if(evt.NavBarItem.value == 'loginset'){
                    ldAjax("index.php?module=Settings&action=SettingsAjax&file=LoginSettings&ajax=yes",'',function (data) {
                        ld('#rptContentLoading').hide();
                        ld("#CamCardViewDetail").html(data.result.content);
                    })
                }
                else if(evt.NavBarItem.value == 'loginswiper'){
                    ldAjax("index.php?module=Settings&action=SettingsAjax&file=LoginSettingsSwiper",'',function (data) {
                        ld('#rptContentLoading').hide();
                        if(data.code == 1){
                            ld("#CamCardViewDetail").html(data.result.content);
                        }else if(data.code == 2){
                            var str = arrJsPopLabel['updateloginswiperfirst'];
                            str += '<br><a style="color: var(--ld-font-link-color);cursor: pointer;" onclick="newloginuipreview()">'+arrJsPopLabel['shownewloginui']+'</a>';
                            RemindsMsg("","LdPopWidth400px","","yes","yes",str);
                            ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
                                var surl = 'index.php?module=Settings&action=SettingsAjax&file=LoginSettingsSwiper&loginui=new';
                                ldAjax(surl,"",function(data){
                                    ld('#rptContentLoading').hide();
                                    if(data.code==1){
                                        ld("#CamCardViewDetail").html(data.result.content);
                                    }
                                })
                            })
                            ld('input[tagclick="msgConfirmCancel"]').unbind('click').on('click',function(){
                                ld('li.ld-NavBarItem').removeClass('cur');
                                ld('li.ld-NavBarItem').eq(0).addClass('cur');
                            })
                        }
                    })
                }
            },
        };
        ListViewNavbarlist = [{'label':arrJsPopLabel['loginuisetting'],'value':'loginset'},{'label':arrJsPopLabel['Carousel'],'value':'loginswiper'}];
        AjaxJSPage('ld_NavBar','include/js/component/ld_NavBar.js');
        ld_NavBar.ShowNavBar(loginsetnavbarobj.get(0),ListViewNavbarlist,listnavbardata);
    }
    
    function newloginuipreview() {
        OpenNewWebTab(`themes/softed/images/defaultloginuipreview.png`);
    }
{/literal}
  
</script>