<!--修改编码格式:统一编码：UTF-8-->
<script language="JAVASCRIPT" type="text/javascript" src="include/js/modules/Settings/BusinessInformation.js?v={$GLOBALMINVERSION}"></script>
<script language="JAVASCRIPT" type="text/javascript" src="include/js/component/ld_NavBar.js?v={$GLOBALMINVERSION}"></script>
<script language="javascript" type="text/javascript" src="crmcommon/js/My97DatePicker/WdatePicker.js"></script>
<div id="vtlib_businessinformation" style="display:block;position:absolute;width:500px;"></div>

<div class="main_grid_top">
    <div class="grid-view-title lfloat overflow-hidden">
        <span class="grid-view-name dinline-block lfloat">
            {'LBI_BUSINESS_SETTINGS'|@getFixedLabel}
        </span>
    </div>
    <div class="grid_tool">

    </div>
</div>
<div class="main_grid_box" style="overflow-y: hidden">
    <div class="grid-analysis-box">
        <div class="grid-analysis-header">
            <div class="D_Tab_div tabHieght LayoutBlocklistTable_stickytop" id="businessinformationlistheader">
            </div>
        </div>
        <div id="vtlib_businessinformation_list" class="cont_wrap clear_float">
            {include file="Settings/BusinessSettings/BusinessInformationEntries.tpl"}
        </div>
    </div>
</div>
{*添加头部菜单*}
<script type="text/javascript">
    var headerarr = {$headerarrjson};
    var nobusinessheaderarr = {$nobusinessheaderarrjson};
    var business_insterfacekey_deploy_value = {$business_insterfacekey_deploy_value};
{literal}
    CrmPopup.global_listPopupObj = [];
    var obj = new Object();
    obj.divid="SettingRightContent";
    CrmPopup.global_listPopupObj.push(obj);
    obj.CancelEvent=function(){
        return false;
    }
    //声明对象
    var BusinessInformationobj=new BusinessInformation();
    BusinessInformationobj.headerarr = headerarr;
    BusinessInformationobj.nobusinessheaderarr = nobusinessheaderarr;
    var selectheaderarr = headerarr;
    if(business_insterfacekey_deploy_value == 0){
        selectheaderarr = nobusinessheaderarr;
    }
    obj.businessInformationobj = BusinessInformationobj;
    BusinessInformationobj.setPopupobj(obj);
    var informationheaderobj = ld('#businessinformationlistheader');
    var StuffNavBarList = [];
    var isselected = 'yes';
    var headerindex = 0;
    ld.each(selectheaderarr,function (index,headerid){
        StuffNavBarList[headerindex] = { label:arrJsPopLabel[headerid], selected: isselected, id:headerid};
        headerindex++;
        isselected = 'no';
    })
    //功能设置，回填映射规则，工商日志查询，数据分析
    var NavBarSelKey=0;
    BusinessInformationobj.ld_navbarobj =ld_NavBar.ShowNavBar(informationheaderobj.get(0),StuffNavBarList,{
        NavBarSelKey : NavBarSelKey,
        NavBarItemWidth: '160px',
        OnClick : function(evt){
            var selectNavBarItem = evt.NavBarItem;
            var selectpageid = selectNavBarItem.id;
            var selectpageindex = selectNavBarItem.NavBarIndex;
            var urlstring = 'module=Settings&action=SettingsAjax&file=BusinessInformation&ajax=true';
            urlstring += '&selectpage='+selectpageid;
            ldAjax('index.php?',urlstring,function(ajaxdata){
                var vtlib_businessinformation_listobj = ld("#vtlib_businessinformation_list");
                vtlib_businessinformation_listobj.html(ajaxdata.result.content);
                BusinessInformationobj.BusinessPageChangeSetEvent(selectpageid,ajaxdata);
                DelProgressObjs();
                // 系统设置-监听窗口改变-修改内容高度、宽度
                settingWindowResize();
            })
        },
    });
    BusinessInformationobj.BusinessPageChangeSetEvent(BusinessInformationobj.ld_navbarobj.NavBarList[0].id,{'result':{'business_insterfacekey_deploy_value': business_insterfacekey_deploy_value}});
    initRightContentHeight();


    {/literal}
</script>