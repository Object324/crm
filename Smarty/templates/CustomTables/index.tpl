<link type="text/css" rel="stylesheet" href="themes/softed/CustomTable.css">
<script type="text/javascript">
    var frommobile = 'no';
    //翻译变量
    var dirname_exchange = "{'MAILFOLDER'|@getFixedLabel}{'MAILNAME'|@getFixedLabel}";
    var desc_exchange = "{'CAMCARDCAPTION'|@getFixedLabel}";
    var submit_exchange = "{'SUBMIT'|@getFixedLabel}";
    var newdir_exchange = "{'CREATE'|@getFixedLabel}{'MAILFOLDER'|@getFixedLabel}";
    var pleaseenter = "{'pleaseenter'|@getFixedLabel}";
    var required_exchange = "{'ACTIVITYMUSTFILL'|@getFixedLabel}";
    //编辑 删除 分配权限
    var create_permit = ("{$permit_create}"=="no")?'style="display:none;"':'';
    var delete_permit = ("{$permit_delete}"=="no")?'style="display:none;"':'';
    var allocate_permit = ("{$permit_allocate}"=="no")?'style="display:none;"':'';
    var permit_print = "{$permit_print}";
    var permit_export = "{$permit_export}";
</script>
<script type="text/javascript" type="text/javascript" src="{$JSURL}include/js/ScopePopup/ScopePopup_Details.js"></script>
<script type="text/javascript" src="{$JSURL}include/js/modules/CustomTables/CustomTablesResize.js"></script>
<script type="text/javascript" src="{$JSURL}include/js/freezecolumns.js"></script>
<!--中间-->
<div class="main_grid lfloat customtable" style="width: 100%;">
    {*    头部按钮以及搜索框*}
    <div class="main_grid_top">
        <div class="grid_tool report-header" >
            <div class="create-entity-toolbar lfloat prelative search-bar">
                <input class="lfloat" type="text" name="keyWords" onkeyup="CustomTablesObj.searchSubmit(event);" id="keyWords" placeholder="{'SEARCHNEW'|@getFixedLabel}{'ReportName'|@getFixedLabel}"/>
                <a title="{'SEARCHNEW'|@getFixedLabel}" class="pg-btn-blue dinline-block lfloat" onclick="CustomTablesObj.getReportList(0,'search')">
                    <span>{'SEARCHNEW'|@getFixedLabel}</span>
                </a>
            </div>
            <div class="create-entity-toolbar lfloat prelative">
                {if $permit_create!='no'}
                    <a title="{'MAILFOLDER'|@getFixedLabel}{'SORT'|@getFixedLabel}" class="pg-btn-blue dinline-block lfloat" id="sortDir" onclick="CustomTablesObj.sortDir()">
                        <span>{'MAILFOLDER'|@getFixedLabel}{'SORT'|@getFixedLabel}</span>
                    </a>
                    <a title="{'CREATE'|@getFixedLabel}{'MAILFOLDER'|@getFixedLabel}" class="pg-btn-blue dinline-block lfloat" id="creat_new_folder" onclick="CustomTablesObj.createNewDir(0,'','')">
                        <span>{'CREATE'|@getFixedLabel}{'MAILFOLDER'|@getFixedLabel}</span>
                    </a>
                    <a title="{'CREATE'|@getFixedLabel}{'Table'|@getFixedLabel}" class="pg-btn-blue dinline-block lfloat creat-new-table" id="creat_new_table" data-id=0 onclick="CustomTablesObj.creat_new_table(this,'selectfield')">
                        <span>{'CREATE'|@getFixedLabel}{'Table'|@getFixedLabel}</span>
                    </a>
                    <ol class="D_more_menua report-type-select" style="display:none;">
                        <li onclick="CustomTablesObj.creat_new_table(this,'selectfield')">
                            <a title="{'MODULE'|@getFixedLabel}{'Table'|@getFixedLabel}" style="padding:0 5px;margin:0;text-align: center;">{'MODULE'|@getFixedLabel}{'Table'|@getFixedLabel}</a>
                        </li>
                        <li onclick="CustomTablesObj.creat_new_table(this,'sql')">
                            <a title="SQL{'Table'|@getFixedLabel}" style="padding:0 5px;margin:0;text-align: center;">SQL{'Table'|@getFixedLabel}</a>
                        </li>
                    </ol>
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
                        <th>{'ReportName'|@getFixedLabel}</th>
                        <th>{'Person_in_charge'|@getFixedLabel}</th>
                        <th>{'reporttype'|@getFixedLabel}</th>
                        <th>{'CAMCARDCAPTION'|@getFixedLabel}</th>
                        <th>{'Createtime1'|@getFixedLabel}</th>
                        <th width="300">{'OPERATING'|@getFixedLabel}</th>
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
    //zxm 20220926 新建报表-- 类型下拉选择
    ld(".creat-new-table").hover(function (){
        ld(this).next().show();
    },function (){
        ld(this).next().hide();
    });
    ld(".report-type-select").hover(function (){
        ld(this).show();
    },function (){
        ld(this).hide();
    });
    CustomTablesObj.getReportList(0,'init');
</script>
<!--修改编码格式:统一编码：UTF-8-->

