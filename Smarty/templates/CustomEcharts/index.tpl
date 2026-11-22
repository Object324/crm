<link type="text/css" rel="stylesheet" href="{$CSSURL}themes/softed/CustomEcharts.css">
<script type="text/javascript">
    var frommobile = '';
    //翻译变量
    var dirname_exchange = "{'MAILFOLDER'|@getFixedLabel}{'MAILNAME'|@getFixedLabel}";
    var desc_exchange = "{'CAMCARDCAPTION'|@getFixedLabel}";
    var submit_exchange = "{'SUBMIT'|@getFixedLabel}";
    var newdir_exchange = "{'CREATE'|@getFixedLabel}{'MAILFOLDER'|@getFixedLabel}";
    var pleaseenter = "{'pleaseenter'|@getFixedLabel}";
    var required_exchange = "{'ACTIVITYMUSTFILL'|@getFixedLabel}";
    //权限数组
    var permit = '{$permit}';
    permit = JSON.parse(permit);
    //编辑 删除 分配权限
    var create_permit = (permit.Create=="no")?'style="display:none;"':'';
    var delete_permit = (permit.Delete=="no")?'style="display:none;"':'';
    var allocate_permit = (permit.Allocate=="no")?'style="display:none;"':'';
</script>
<script type="text/javascript" type="text/javascript" src="{$JSURL}include/js/ScopePopup/ScopePopup_Details.js"></script>
<!--中间-->
<div class="main_grid lfloat" style="width: 100%;">
{*    头部按钮以及搜索框*}
    <div class="main_grid_top">
        <div class="grid_tool report-header" >
            <div class="create-entity-toolbar lfloat prelative search-bar">
                <input class="lfloat" type="text" name="keyWords" id="keyWords" placeholder="{'SEARCHNEW'|@getFixedLabel}{'chartName'|@getFixedLabel}"/>
                <a title="{'SEARCHNEW'|@getFixedLabel}" class="pg-btn-blue dinline-block lfloat" onclick="CustomEchartsObj.getReportList(0,'search')">
                    <span>{'SEARCHNEW'|@getFixedLabel}</span>
                </a>
            </div>
            <div class="create-entity-toolbar lfloat prelative">
                {if $permit_create!='no'}
                <a title="{'MAILFOLDER'|@getFixedLabel}{'SORT'|@getFixedLabel}" class="pg-btn-blue dinline-block lfloat" id="creat_new_folder" onclick="CustomEchartsObj.sortDir()">
                    <span>{'MAILFOLDER'|@getFixedLabel}{'SORT'|@getFixedLabel}</span>
                </a>
                <a title="{'CREATE'|@getFixedLabel}{'MAILFOLDER'|@getFixedLabel}" class="pg-btn-blue dinline-block lfloat" id="creat_new_folder" onclick="CustomEchartsObj.createNewDir(0,'','')">
                    <span>{'CREATE'|@getFixedLabel}{'MAILFOLDER'|@getFixedLabel}</span>
                </a>
                <a title="{'CREATE'|@getFixedLabel}{'statisticalGraphics'|@getFixedLabel}" class="pg-btn-blue dinline-block lfloat" id="creat_new_chart" data-id=0 onclick="CustomEchartsObj.creat_new_chart(this)">
                    <span>{'CREATE'|@getFixedLabel}{'statisticalGraphics'|@getFixedLabel}</span>
                </a>
                {/if}
            </div>
        </div>
    </div>
{*    列表*}
    <div class="main_grid_box">
        <div class="grid-analysis-box">
        <div class="cont_wrap clear_float">
            <table class="listEntries fir-center mb20" border="0" cellspacing="1" cellpadding="0" width="100%" >
                <thead>
                <tr>
                    <th width="25">#</th>
                    <th>{'chartName'|@getFixedLabel}</th>
                    <th>{'Person_in_charge'|@getFixedLabel}</th>
                    <th>{'CAMCARDCAPTION'|@getFixedLabel}</th>
                    <th>{'Createtime1'|@getFixedLabel}</th>
                    <th width="200">{'OPERATING'|@getFixedLabel}</th>
                </tr>
                </thead>
                <tbody id="reportList">
                </tbody>
            </table>
        </div>
    </div>
    </div>
</div>
<div id="folder_sortview" class="E_pop_box LdPopWidth290px" style="display:none;">
    <div id="folder_sortview_content_div"></div>
</div>
<script>
    CustomEchartsObj.getReportList(0,'init');
</script>
<!--修改编码格式:统一编码：UTF-8-->

