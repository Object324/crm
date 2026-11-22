<!--修改编码格式:统一编码：UTF-8-->
{literal}
<script type='text/javascript'>
function vtlib_toggleModule(obj,module, action, type,BLOCKIDSETTING,FIELDIDSETTING) {

    var parenttdobj = Tools.getParentobjByChild(ld(obj),'tr');
    var operateTda = ld(parenttdobj).find("a[ifhide=1]");
	if(typeof(type) == 'undefined') type = '';
    if(action){
        var module_action = 'module_enable';
        operateTda.show();
    }else{
        var module_action = 'module_disable';
        operateTda.hide();
    }
	var data = "module=Settings&action=SettingsAjax&file=ModuleManager&module_name=" + encodeURIComponent(module) + "&" + module_action + "=true" + "&module_type=" + type+"&blockidsetting="+BLOCKIDSETTING+"&fieldidsetting="+FIELDIDSETTING;
    // $('status').show();
    //zkt 20231013 XUQIU1001341 SQL注入
    ldAjaxHtmlNoProgress('index.php?',data,function(response) {});
}

//绑定change事件，当下拉框内容发生变化时placeholder也改变
ld("#searchmoudel_select").bind("change",function(){
    var text = ld(this).find("option:selected").text();
    ld("#searchmoudel_input").attr("placeholder", arrJsPopLabel['SEARCHCAPITAL'] + text );
});
//清除搜索框输入内容，点击事件
function clearBasicSearch(obj){
    ld('#searchmoudel_input').val('');
    ld('.ld-icon-clearsearch').css('display','none');
    ld('#searchmoudel_input').focus();
}

//zsk 2024/3/11 BUG20240308-39 后台设置--模块管理，进入时光标没有停在搜索框 
if(empty(ld('#basicSearchNewDiv').find('[name=search_text]').val())){
    ld('#basicSearchNewDiv').find('[name=search_text]').focus();
}
</script>
{/literal}
<div id="vtlib_modulemanager" style="display:block;position:absolute;width:500px;"></div>

<div class="main_grid_top">
    <div class="grid-view-title lfloat overflow-hidden">
        <span class="grid-view-name dinline-block lfloat">
            {'VTLIB_LBL_MODULE_MANAGER'|@getFixedLabel}{if $HelpHtml.ModuleManager neq '' }{$HelpHtml.ModuleManager}{/if}
        </span>
    </div>
    <div class="grid_tool">
        <div class="create-entity-toolbar lfloat prelative">
            <div class="ld-flex-start ld-flex-wrap" id="basicSearchNewDiv">
                <div >
                    <select id="searchmoudel_select" class="commonSelectPop gwidth100" style="border-radius: 4px 0 0 4px;border-right:none;">
                        <option value="ALL">{'ALL'|@getFixedLabel}</option>
                        <option value="ZHPARENTMENUNMAE">{'ZHPARENTMENUNMAE'|@getFixedLabel}</option>
                        <option value="ENPARENTMENUNMAE">{'ENPARENTMENUNMAE'|@getFixedLabel}</option>
                        <option value="REMARK">{'REMARK'|@getFixedLabel}</option>
                        <option value="WHETHERTOENABLE">{'WHETHERTOENABLE'|@getFixedLabel}</option>
                    </select>
                    <input type="hidden" name="searchtype" value="BasicSearch">
                </div>
                <div class="ld-listview-basicsearch">
                    <input type="text" class="commonSelectPop gwidth100 padR40" id="searchmoudel_input" name="search_text" placeholder="{'SEARCHCAPITAL'|@getFixedLabel}{'ALL'|@getFixedLabel}" onkeyup="SearchModuleSubmit(event,this)" value="" autocomplete="off" style="border-radius: 0 4px 4px 0;padding-right:40px;">
                    <b style="position: absolute;right:30px;top:0;cursor: pointer;display:none" class="ld-icon-clearsearch" onclick="clearBasicSearch(this);"></b>
                    <div class="positionFirst" onclick="SearchModuleBefore(this);">
                        <i class="ld-fonticon ld-fonticon-search hlineheight30"></i>
                    </div>
                    <div style="position: absolute;right:0;top:30px;width:100%;background-color: #fff;z-index:902;">
                        <ol class="D_more_menua" id="basicSearchList">
                        </ol>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
<div class="main_grid_box">
    <div class="grid-analysis-box">
        <div class="grid-analysis-header">
        </div>
        <div id="vtlib_modulemanager_list" class="ld-table-container ld-table-container-line ld-table-container-bgcolor">
            {include file="Settings/ModuleManager/ModuleManagerAjax.tpl"}
        </div>
    </div>
</div>
<script>
{literal}
// BUG0069473 txy 20230714 后台设置，模块管理，鼠标定位到右上角的搜索框中时，搜索框没有显示选中效果
    ld('#basicSearchNewDiv .ld-listview-basicsearch input').unbind('focus').bind('focus',function(){
        ld('.create-entity-toolbar #basicSearchNewDiv select').addClass('ld-border-color-3b7cff');
        ld(this).addClass('ld-border-color-3b7cff');
    });
    ld('#basicSearchNewDiv .ld-listview-basicsearch input').unbind('blur').bind('blur',function(){
        ld('.create-entity-toolbar #basicSearchNewDiv select').removeClass('ld-border-color-3b7cff');
        ld(this).removeClass('ld-border-color-3b7cff');
    });
{/literal}
</script>