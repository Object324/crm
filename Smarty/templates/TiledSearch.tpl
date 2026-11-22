{*/**
* @edit:dong
* @data:2020/08/19
* @reason:平铺查找模板文件
* @description:
*/*}
<!--修改编码格式:统一编码：UTF-8-->
<div id="tiledSearch" style="float:left; width: 100%;display: none">
    {if $JS_DATEFORMAT eq ''}
        {assign var="JS_DATEFORMAT" value='YYYY-mm-dd'}
    {/if}

    <input type="hidden" id="jscal_dateformat" name="jscal_dateformat" value="{$JS_DATEFORMAT}"/>
    <input type="hidden" id="image_path" name="image_path" value="{$IMAGE_PATH}"/>
    <input type="hidden" name="tiledsearch_criteria" id="tiledsearch_criteria" value=""/>
    <input type="hidden" name="tiledsearch_criteria_groups" id="tiledsearch_criteria_groups" value=""/>

    <script language="JavaScript" type="text/JavaScript">
        var jsnone = '{'NONE'|@getFixedLabel}';
        var reportid = '{$REPORTID}';
        var MODULE = '{$MODULE}';
        var is_admin = '{$is_admin}';//管理员才有保存条件按钮
        var tiledSearch = '{$tiledSearch}';
        var tmpstr='{$DATETIMESTR}';
        var datetimestr=  eval('('+ tmpstr +')')?eval('('+ tmpstr +')'):JSON.parse(tmpstr);
        //定义变量
        var tiled_column_index_count = -1;
        var tiled_group_index_count = 0;
        var tiled_column_index_array = [];
        var tiled_group_index_array = [];
        var autohideafterfinding = '{$autohideafterfinding}';

        function tiled_addColumnConditionGlue(columnIndex) {ldelim}
            var columnConditionGlueElement = document.getElementById('tiled_columnconditionglue_' + columnIndex);

            if (columnConditionGlueElement) {ldelim}
                ld('#tiledfiltershow').css('display', 'block');
                //--2021-1015-- zxm 【客户地图增加“平铺查找”功能】https://www.tapd.cn/63637123/prong/stories/view/1163637123001002063
                if(MODULE!='ChinaMap'||(MODULE=='ChinaMap'&&is_admin=='on')){
                    ld('#tiled_filter_div .delete_col_button').css('display', 'block');
                }else{
                    ld('#tiled_groupfooter_1').css('display', 'none');
                }
                columnConditionGlueElement.innerHTML = "<select name='tiled_fcon" + columnIndex + "' id='tiled_fcon" + columnIndex + "' class='commonSelectPop'>" +
                    "<option value='and'>{'SEARCHAND'|@getFixedLabel}</option>" +
                    "<option value='or'>{'OR'|@getFixedLabel}</option>" +
                    "</select>";
                {rdelim}
            {rdelim}

        function tiled_searchReport(event, type) {ldelim}
            var e = event || window.event;
            if (e.keyCode == 13) {ldelim}
                generateReport(1);
                {rdelim}
            {rdelim}

        function tiled_searchUseReport(event) {ldelim}
            var e = event || window.event;
            if (e.keyCode == 13) {ldelim}
                generateReport(this);
                {rdelim}
            {rdelim}

        //添加行
        function tiled_addConditionRow(groupIndex) {ldelim}
            var groupColumns = tiled_column_index_array[groupIndex];
            if (typeof (groupColumns) != 'undefined') {ldelim}
                for (var i = groupColumns.length - 1; i >= 0; --i) {ldelim}
                    var prevColumnIndex = groupColumns[i];
                    if (document.getElementById('tiled_conditioncolumn_' + groupIndex + '_' + prevColumnIndex)) {ldelim}
                        tiled_addColumnConditionGlue(prevColumnIndex);
                        break;
                        {rdelim}
                    {rdelim}
                {rdelim}

            var columnIndex = tiled_column_index_count + 1;
            var nextNode = document.getElementById('tiled_groupfooter_' + groupIndex);

            var newNode = document.createElement('tr');
            newNodeId = 'tiled_conditioncolumn_' + groupIndex + '_' + columnIndex;
            newNode.setAttribute('id', newNodeId);
            newNode.setAttribute('name', 'tiled_conditionColumn');
            nextNode.parentNode.insertBefore(newNode, nextNode);

            node1 = document.createElement('td');
            node1.setAttribute('align', 'left');
            node1.setAttribute('width', '25%');
            newNode.appendChild(node1);
            {if $SOURCE eq 'reports' || $SOURCE eq 'usereports'}
            node1.innerHTML = '<select style="width:200px;" name="tiled_fcol' + columnIndex + '" id="tiled_fcol' + columnIndex + '" onchange="updatefOptions(this, \'tiled_fop' + columnIndex + '\');tiled_addRequiredElements(' + columnIndex + ');updateRelFieldOptions(this, \'fval_' + columnIndex + '\');" class="commonSelectPop">' +
                '<option value="">--{'NONE'|@getFixedLabel}--</option>' +
                '{$COLUMNS_BLOCK}' +
                '</select>';
            {else}
            node1.innerHTML = "<select style='width:200px;' name='tiled_fcol" + columnIndex + "' id='tiled_fcol" + columnIndex + "' onchange='updatefOptions(this, \"tiled_fop" + columnIndex + "\");tiled_addRequiredElements(" + columnIndex + ");tiled_addConditionRowInitafter(" + columnIndex + ")' class='commonSelectPop'>" +
                "<option value=''>--{'NONE'|@getFixedLabel}--</option>" +
                "{$COLUMNS_BLOCK}"+
            "</select>";
            {/if}
			//wym 230505 平铺查找添加搜索功能
            var Listpagepopupobj=new CrmPopup();
            Listpagepopupobj.type=ListPagePopup.type;
            Listpagepopupobj.divid='pagecontent1';
            //var popupobj = CrmPopup.getlastPopupObjByType('listpage') ;
            var selectname = 'tiled_fcol'+columnIndex;
            if(document.getElementById(selectname).length>0){
                var selObj = document.getElementById(selectname);
                var cls_resetComboxHtmlobj=new cls_resetComboxHtml(selectname);
                cls_resetComboxHtmlobj.setPopupObj(Listpagepopupobj);
                cls_resetComboxHtmlobj.setSearchComboxWidthByhtml(selObj,180);
            }


            node2 = document.createElement('td');

            node2.setAttribute('align', 'left');
            node2.setAttribute('width', '20%');
            newNode.appendChild(node2);
            node2.innerHTML = '<select name="tiled_fop' + columnIndex + '" id="tiled_fop' + columnIndex + '" class="commonSelectPop" style="width:90%;" onchange="tiled_addRequiredElements(' + columnIndex + ');">' +
                '<option value="">--{'NONE'|@getFixedLabel}--</option>' +
                '{$FOPTION}' +
                '</select>';

            node3 = document.createElement('td');

            node3.setAttribute('align', 'left');
            //andy
            //node3.setAttribute('width', '30%');
            newNode.appendChild(node3);
            node3.innerHTML = '<input name="tiled_fval' + columnIndex + '" id="tiled_fval' + columnIndex + '" class="width150 commonTextBoxPop" type="text" onkeyup="searchSubmit(event,\'Advanced\')" value="">' +
                '<input class="icon-homeimg icon-clear inpb-advSearchreset marL5" style="display:none;" type="button" id="tiled_clear_text_ext' + columnIndex + '" onclick="document.getElementById(\'tiled_fval' + columnIndex + '\').value=\'\';return false;" title="{'CLEAR'|@getFixedLabel}"/>';

            node4 = document.createElement('td');

            node4.setAttribute('align', 'left');
            node4.setAttribute('id', 'tiled_columnconditionglue_' + columnIndex);
            node4.setAttribute('width', '60px');
            newNode.appendChild(node4);

            node5 = document.createElement('td');
            node5.setAttribute('width', '30px');
            node5.setAttribute('align', 'left');
            newNode.appendChild(node5);
            var delhidden ='';
            // @edit:dong @date:2020/08/21 @reason: 只有一行的时候 隐藏删除按钮
            //客户地图 平铺查找  zxm 2021-1015 不是管理员隐藏删除按钮
            if(ld('#tiled_conditiongrouptable_'+groupIndex+' tr[name=tiled_conditionColumn]').length ==1 || (MODULE=="ChinaMap"&&is_admin !="on")){
                delhidden = 'style="display:none"';
            }
            node5.innerHTML = '<a  class="delete_col_button" '+delhidden+' onclick="tiled_deleteColumnRow(' + groupIndex + ',' + columnIndex + ');chang_content_table_divid_height(\'delRow\','+groupIndex+')" href="javascript:;" title="{'DELETE'|@getFixedLabel}">' + arrJsPopLabel['DELETE'] +
                '</a>';

            if (document.getElementById('tiled_fcol' + columnIndex)) updatefOptions(document.getElementById('tiled_fcol' + columnIndex), 'tiled_fop' + columnIndex);
            if (typeof (tiled_column_index_array[groupIndex]) == 'undefined') tiled_column_index_array[groupIndex] = [];
            tiled_column_index_array[groupIndex].push(columnIndex);
            tiled_column_index_count++;

            // // 当前组条件最大5条 隐藏添加按钮
            // if(ld('#tiled_conditiongrouptable_'+groupIndex+' tr[name=tiled_conditionColumn]').length >=5){
            //     ld('#tiled_groupfooter_'+groupIndex).hide()
            // }
            // @edit:dong @date:2020/08/24 @reason: 初始化默认选择条件
            tiled_addConditionRowInit('add');
            {rdelim}

        function tiled_addGroupConditionGlue(groupIndex) {ldelim}

            var groupConditionGlueElement = document.getElementById('tiled_groupconditionglue_' + groupIndex);
            if (groupConditionGlueElement) {ldelim}
                groupConditionGlueElement.innerHTML = "<select name='tiled_gpcon" + groupIndex + "' id='tiled_gpcon" + groupIndex + "'>" +
                    "<option value='and'>{'SEARCHAND'|@getFixedLabel}</option>" +
                    "<option value='or'>{'OR'|@getFixedLabel}</option>" +
                    "</select>";
                {rdelim}
            {rdelim}

        function tiled_addConditionGroup(parentNodeId,MODULE,is_admin) {ldelim}
            for (var i = tiled_group_index_array.length - 1; i >= 0; --i) {ldelim}
                var prevGroupIndex = tiled_group_index_array[i];
                if (document.getElementById('tiled_conditiongroup_' + prevGroupIndex)) {ldelim}
                    tiled_addGroupConditionGlue(prevGroupIndex);
                    break;
                    {rdelim}
                {rdelim}

            var groupIndex = tiled_group_index_count + 1;
            var parentNode = document.getElementById(parentNodeId);

            var newNode = document.createElement('div');
            newNodeId = 'tiled_conditiongroup_' + groupIndex;
            newNode.setAttribute('id', newNodeId);
            newNode.setAttribute('name', 'tiled_conditionGroup');
            // @edit:dong @date:2020/11/10 @reason: 平铺查找 条件过多 出现滚动条
            newNode.setAttribute('style', 'width:100%;max-height:186px;overflow-y:auto');

            //newNode.innerHTML = "<table class='crmTable' border='0' cellpadding='5' cellspacing='1' width='100%' valign='top' id='conditiongrouptable_"+groupIndex+"'>"+
            newNode.innerHTML = "<table class='settingPopTable' border='0' cellpadding='0' cellspacing='0' width='100%'  id='tiled_conditiongrouptable_" + groupIndex + "'>" +
                "<tr id='groupheader_" + groupIndex + "'>" +
                // 删除组的代码
                /*						"<td colspan='5' align='right' style='height:24px;'>"+
                                        "<a class='icon-homeimg icon-close' href='javascript:void(0);' title='{'REMOVECOMBINATION'|@getFixedLabel}' onclick='deleteGroup(\""+groupIndex+"\");'></a>"+
                        "</td>"+*/
                "</tr>" +
                "<tr id='tiled_groupfooter_" + groupIndex + "'>" +
                "<td colspan='5' align='left'>" +
                "<a href='javascript:void(0);' onclick='tiled_addConditionRow(\"" + groupIndex + "\");chang_content_table_divid_height(\"addRow\",\"" + groupIndex + "\")'>{'NEWCONDITIONS'|@getFixedLabel}</a>" +
                "</td>" +
                "</tr>";

            // "<table class='settingPopTable' border='0' cellpadding='0' cellspacing='0' width='100%'>"+
            // 	"<tr><td align='center' id='tiled_groupconditionglue_"+groupIndex+"'>"+
            // 	"</td></tr>"+
            // "</table>"


            parentNode.appendChild(newNode);
            if(MODULE=='ChinaMap'&&is_admin!='on'){
                document.getElementById('tiled_groupfooter_'+groupIndex).style.display="none";
            }
            tiled_group_index_array.push(groupIndex);
            tiled_group_index_count++;
            {rdelim}
    </script>

    <div style="background-color: #fff;" id='tiled_filter_div' name='tiled_filter_div'
         onkeyup="searchSubmit(event,'Tiled')">
        {*	<table class="settingPopTable lasttdbordernon" border="0" cellpadding="0" cellspacing="0" width="100%">
                <tr>
                    <th style="text-align: right;"><input type="button" class="createauto" style="margin-right: 0px;" value="{'NEWCOMBINATION'|@getFixedLabel}" onclick="tiled_addNewConditionGroup('tiled_filter_div');"></th>
                </tr>
            </table>*}
        <div class="gwidth100 padT5">
            <ul class="test_ul" style="padding-left: 8px;">
                <li style="width: 25%;">
                    {if $MODULE=="ChinaMap"}
                    {*平铺查找点击 zxm 2021-1015 客户地图需求 【客户地图增加“平铺查找”功能】 https://www.tapd.cn/63637123/prong/stories/view/1163637123001002063*}
                    <div>{'QueryField'|@getFixedLabel}</div>
                    {else}
                    <div>{'Select_field'|@getFixedLabel}</div>
                    {/if}
                </li>
                <li style="width: 20%;">
                    <div>{'SELECTIONCRITERIA'|@getFixedLabel}</div>
                </li>
                <li style="width: 30%;">
                    <div>{'SEARCHKEY'|@getFixedLabel}</div>
                </li>
                <li style="float:right;width: 90px;">
                    <div id="tiledfiltershow"
                         style="float: left;display: none;">{'SCREENINGRELATIONSHIP'|@getFixedLabel}</div>
                </li>
            </ul>
        </div>
    </div>
</div>
<script>
    /**
     * @edit:dong
     * @data:2020/08/19
     * @reason:加载搜索页面
     * @description:通过已有搜索条件加载页面没有则添加空白组和行
     */
    function loadTiledSearchCondition(){

        //初始化已有条件加载页面
        var searchModule = MODULE;
        var criteriaConditions = JSON.parse(localStorage.getItem(tiled_column_key));
        if (criteriaConditions != null) criteriaConditions = criteriaConditions[searchModule];
        var criteriaGroups = JSON.parse(localStorage.getItem(tiled_group_key));
        if (criteriaGroups != null) criteriaGroups = criteriaGroups[searchModule];
        //ZXM 2021-1015【客户地图增加“平铺查找”功能】https://www.tapd.cn/63637123/prong/stories/view/1163637123001002063

        if(MODULE=="ChinaMap") {
            if (tiledSearch) {
                var tiledSearchObj = JSON.parse(tiledSearch);
                criteriaConditions = tiledSearchObj.advft_criteria;
                criteriaGroups = tiledSearchObj.advft_criteria_groups;
            } else {
                criteriaConditions = [];
                criteriaGroups = [];
            }
        }
        else{
            //zkt 2021/12/28 平铺查找条件显示
            if (tiledSearch) {
                var tiledSearchObj = JSON.parse(tiledSearch);
                criteriaConditions = tiledSearchObj.advft_criteria;
                criteriaGroups = tiledSearchObj.advft_criteria_groups;
            }
        }
        if (criteriaConditions != null && criteriaGroups !=null && criteriaConditions.length != 0 && criteriaGroups.length != 0) {
            for (var i = 0; i < criteriaGroups.length; i++) {
                if (criteriaGroups[i] == null) continue;
                // 加载div和点击按钮.
                tiled_addConditionGroup(tiled_filter_div,MODULE,is_admin);
                tiled_addSubmitButton(tiled_filter_div,MODULE,is_admin);
                //循环对应相应组的条件
                for (var j = 0; j < criteriaConditions.length; j++) {
                    if (criteriaConditions[j] == null) continue;
                    if (criteriaConditions[j].groupid == i) {
                        //添加行
                        tiled_addConditionRow(i);
                        //选择字段赋值
                        var conditionColumnRowElement = document.getElementById('tiled_fcol' + tiled_column_index_count);
                        conditionColumnRowElement.value = criteriaConditions[j].columnname;
                        // wym 230516 为下拉框赋值
                        var text = ld("#tiled_fcol" + tiled_column_index_count +" option:selected").text();
                        if(document.getElementById("cmb_span_optiontext_tiled_fcol"+tiled_column_index_count)){
                            document.getElementById("cmb_span_optiontext_tiled_fcol"+tiled_column_index_count).value=text;
                        }

                        //ZXM 2021-1015【客户地图增加“平铺查找”功能】https://www.tapd.cn/63637123/prong/stories/view/1163637123001002063
                        if(MODULE=='ChinaMap'&&is_admin!='on'){
                            conditionColumnRowElement.disabled = 'disabled';
                        }
                        //选择条件赋值
                        tiled_updatefOptions(conditionColumnRowElement, 'tiled_fop' + tiled_column_index_count);
                        document.getElementById('tiled_fop' + tiled_column_index_count).value = criteriaConditions[j].comparator;
                        //选择条件 改变关键字类型
                        tiled_addRequiredElements(tiled_column_index_count);
                        //关键字 赋值
                        var tmpConditon = criteriaConditions[j];
                        if ((tmpConditon.comparator == 'bw' || isExistsDateTimeStr(tmpConditon.comparator)=="yes") && tmpConditon.value != '') {
                            var values = tmpConditon.value.split(",");
                            document.getElementById('tiled_fval' + tiled_column_index_count).value = values[0];
                            if (values.length == 2 && document.getElementById('tiled_fval_ext' + tiled_column_index_count))
                                document.getElementById('tiled_fval_ext' + tiled_column_index_count).value = values[1];
                        } else {
                            if (tmpConditon.value == 'Accepted')
                                document.getElementById('tiled_fval' + tiled_column_index_count).value = alert_arr.Accepted;
                            else if (tmpConditon.value == 'Rejected')
                                document.getElementById('tiled_fval' + tiled_column_index_count).value = alert_arr.Rejected;
                            else {
                                var values = tmpConditon.value.split(",");
                                document.getElementById('tiled_fval' + tiled_column_index_count).value = values[0];
                            }
                        }
                        //条件关系赋值 tips:第二行显示后才能赋值第一行的条件关系 注意减1
                        if(document.getElementById('tiled_fcon' + (tiled_column_index_count-1)))
                        document.getElementById('tiled_fcon' + (tiled_column_index_count-1)).value = criteriaConditions[j-1].columncondition;


                    }

                }
            }
        }else{
            // 添加新组和两行 和按钮
            tiled_addNewConditionGroup(tiled_filter_div,MODULE,is_admin); //默认添加两行
            tiled_addSubmitButton(tiled_filter_div,MODULE,is_admin);
        }
    }
    ld(function () {
        {if $ISSALESFUNNEL neq 'yes'}//判断是否为销售漏斗
            loadTiledSearchCondition();
        //点击搜索后 搜索结果保持显示状态
        {if $SEARCHTYPE eq  'tiled'&& $SHOWtiledSearch neq 'no'}
            ld('#tiledSearch').show();
        {/if}
        {/if}
    })
</script>