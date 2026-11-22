<!--修改编码格式:统一编码：UTF-8-->
<script language="JAVASCRIPT" type="text/javascript" src="include/js/modules/Settings/CallRecordSetting.js?v={$GLOBALMINVERSION}"></script>
<script language="JAVASCRIPT" type="text/javascript" src="include/js/component/ld_NavBar.js?v={$GLOBALMINVERSION}"></script>
<script language="javascript" type="text/javascript" src="crmcommon/js/My97DatePicker/WdatePicker.js"></script>
<div id="vtlib_businessinformation" style="display:block;position:absolute;width:500px;"></div>

<div class="main_grid_top">
    <div class="grid-view-title lfloat overflow-hidden">
        <span class="grid-view-name dinline-block lfloat">
            {'CallRecordSetting'|@getFixedLabel}
        </span>
    </div>
    <div class="grid_tool">

    </div>
</div>
<div class="ld-operationlog-mainlist">
    <div class="grid-analysis-box">
        <div class="grid-analysis-header">
            <div class="D_Tab_div tabHieght LayoutBlocklistTable_stickytop marB5 blueFont"  id="CallRecordSettingHeader">
            </div>
        </div>
        <div id="CallRecordSettingContent" class="cont_wrap clear_float">
            {include file="Settings/CallRecordSettingContent.tpl"}
        </div>
    </div>
</div>
{*添加头部菜单*}
<script type="text/javascript">
    var headerarr = {$headerarrjson};

{literal}
    CrmPopup.global_listPopupObj = [];
    var obj = new Object();
    obj.divid="SettingRightContent";
    CrmPopup.global_listPopupObj.push(obj);
    obj.CancelEvent=function(){
        return false;
    }
    //声明对象
    var callrecordsetting = new CallRecordSetting();
    callrecordsetting.setPopupobj(obj);
    var headerobj = ld("#"+obj.divid).find('#CallRecordSettingHeader');
    var StuffNavBarList = [];
    var isselected = 'yes';
    ld.each(headerarr,function (index,headerid){
        StuffNavBarList[index] = { label:arrJsPopLabel[headerid], selected: isselected, id:headerid};
        isselected = 'no';
    })
    //功能设置，回填映射规则，工商日志查询，数据分析
    var NavBarSelKey=0;
    callrecordsetting.ld_navbarobj =ld_NavBar.ShowNavBar(headerobj.get(0),StuffNavBarList,{
        NavBarSelKey : NavBarSelKey,
        NavBarItemWidth: '160px',
        OnClick : function(evt){
            var selectNavBarItem = evt.NavBarItem;
            var selectpageid = selectNavBarItem.id;
            var selectpageindex = selectNavBarItem.NavBarIndex;
            var urlstring = 'module=Settings&action=SettingsAjax&file=CallRecordSetting&ajax=true';
            urlstring += '&selectpage='+selectpageid;
            ldAjax('index.php?',urlstring,function(ajaxdata){
                var CallRecordSettingContentObj = ld("#"+obj.divid).find("#CallRecordSettingContent");
                CallRecordSettingContentObj.html(ajaxdata.result.content);
                callrecordsetting.changeNavBar(selectpageid,ajaxdata);
                DelProgressObjs();
            })
        },
    });
    initRightContentHeight();
    callrecordsetting.changeNavBar(callrecordsetting.ld_navbarobj.NavBarList[0].id,'');

    {/literal}
</script>