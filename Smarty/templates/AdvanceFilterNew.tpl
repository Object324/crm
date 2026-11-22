<script language="JavaScript" type="text/javascript" src="include/js/advancefilternew.js?v={$GLOBALMINVERSION}"></script>
{if $JS_DATEFORMAT eq ''}
	{assign var="JS_DATEFORMAT" value='YYYY-mm-dd'}
{/if}
<input type="hidden" id="jscal_dateformat" name="jscal_dateformat" value="{$JS_DATEFORMAT}" />
<input type="hidden" id="image_path" name="image_path" value="{$IMAGE_PATH}" />
<input type="hidden" name="advft_criteria" value="" />
<input type="hidden" name="advft_criteria_groups" value="" />
<script language="JavaScript" type="text/JavaScript">
/*wym 240522 XUQIU1002181 新增查询条件，属于/不属于 条件可以输入多个字段，用“，”或“,”分辨注：中英文的“，”都可以做划分*/
/*目前只有列表界面的高级查找加属于条件,所以在这里删除*/
if(!typeofdata['E'].includes('belong')){
	typeofdata['E'].push("belong")
}
if(!typeofdata['E'].includes('notbelong')){
	typeofdata['E'].push("notbelong")
}
if(!typeofdata['V'].includes('belong')){
	typeofdata['V'].push("belong")
}
if(!typeofdata['V'].includes('notbelong')){
	typeofdata['V'].push("notbelong")
}
if(!fLabels.hasOwnProperty('belong')){
	fLabels['belong'] = '{'BELONG'|@getFixedLabel}';
}
if(!fLabels.hasOwnProperty('notbelong')){
	fLabels['notbelong'] = '{'NOTBELONG'|@getFixedLabel}';
}
var jsnone='{'NONE'|@getFixedLabel}';
var reportid = '{$REPORTID}';
var popupobj=CrmPopup.getPopupObj('last');
popupobj.advft_column_index_count = -1;
popupobj.advft_group_index_count = 0;
popupobj.column_index_array = [];
popupobj.group_index_array = [];
popupobj.criteriaConditions=[];
popupobj.type='advancesearch';
function New_addColumnConditionGlue(columnIndex) {ldelim}
	/*wym BUG0069927 提醒框跳出后会覆盖最新popobj，所以给高级查找popobj加了type，后续还是需要优化该代码，最好改成类文件*/
	if(popupobj!==undefined && popupobj.type!=='advancesearch'){
		popupobj=CrmPopup.getlastPopupObjByType('advancesearch');
	}
    if(popupobj==undefined)
    {
        return false;
    }

	var columnConditionGlueElement = ld("#"+popupobj.advanceSearchDivid+" [name=columnconditionglue_"+columnIndex+"]");;

	if(columnConditionGlueElement&&columnConditionGlueElement.length>0) {ldelim}
		ld("#"+popupobj.advanceSearchDivid+" #advfiltershow").css('display','block');

		columnConditionGlueElement.html("<select name='fcon"+columnIndex+"' id='fcon"+columnIndex+"' class='commonSelectPop'>"+
													"<option value='and'>{'SEARCHAND'|@getFixedLabel}</option>"+
													"<option value='or'>{'OR'|@getFixedLabel}</option>"+
												"</select>");
	{rdelim}
{rdelim}
function searchReport(event,type)
{ldelim}
    var e = event || window.event;
    if(e.keyCode == 13)
    {ldelim}
        generateReport(1);
    {rdelim}
{rdelim}
function searchUseReport(event)
{ldelim}
    var e = event || window.event;
    if(e.keyCode == 13)
    {ldelim}
        generateReport(this);
    {rdelim}
{rdelim}
function New_addConditionRow (groupIndex) {ldelim}


	if(popupobj!==undefined && popupobj.type!=='advancesearch'){
		popupobj=CrmPopup.getlastPopupObjByType('advancesearch');
	}
    if(popupobj==undefined)
    {
        return false;
    }
	var groupColumns = popupobj.column_index_array[groupIndex];
	if(typeof(groupColumns) != 'undefined') {ldelim}
		for(var i=groupColumns.length - 1; i>=0; --i) {ldelim}
			var prevColumnIndex = groupColumns[i];
            var tmpobj=ld("#"+popupobj.advanceSearchDivid+" [name=columnconditionglue_"+prevColumnIndex+"]");
			if(tmpobj!=undefined&&tmpobj.length>0) {ldelim}
				New_addColumnConditionGlue(prevColumnIndex);
				break;
			{rdelim}
		{rdelim}
	{rdelim}
    
	var columnIndex = popupobj.advft_column_index_count+1;

	var nextNode = ld("#"+popupobj.advanceSearchDivid+" [name=groupfooter_"+groupIndex+"]").get(0);
   
 
	var newNode = document.createElement('tr');
	newNodeId = 'conditioncolumn_'+groupIndex+'_'+columnIndex;
  	newNode.setAttribute('id',newNodeId);
  	newNode.setAttribute('name',newNodeId);
    newNode.setAttribute("tag",'conditionColumn');
    
	nextNode.parentNode.insertBefore(newNode, nextNode);

	node1 = document.createElement('td');
    node1.setAttribute('align', 'left');
	node1.setAttribute('width', '25%');
	newNode.appendChild(node1);
	//wym XUQIU1002478 高级查找条件--切换选择字段时，关键字填写的值清空
	{if $SOURCE eq 'reports' || $SOURCE eq 'usereports'}
		node1.innerHTML = '<select name="fcol'+columnIndex+'" id="fcol'+columnIndex+'" style="max-width:400px;" onchange="New_updatefOptions(this, \'fop'+columnIndex+'\');New_addRequiredElements('+columnIndex+');New_clearKeywordsinput("+columnIndex+"); updateRelFieldOptions(this, \'fval_'+columnIndex+'\');" class="commonSelectPop">'+
							'<option value="">--{'NONE'|@getFixedLabel}--</option>'+
	        				'{$COLUMNS_BLOCK}'+
						'</select>';
	{else}
		node1.innerHTML = "<select name='fcol"+columnIndex+"' id='fcol"+columnIndex+"' style='max-width:400px;' onchange='New_updatefOptions(this, \"fop"+columnIndex+"\");New_addRequiredElements("+columnIndex+");New_clearKeywordsinput("+columnIndex+");' class='commonSelectPop'>"+
							"<option value=''>--{'NONE'|@getFixedLabel}--</option>"+
	        				"{$COLUMNS_BLOCK}"
						"</select>";
	{/if}
	//wym 230505 高级查找添加搜索功能
	var selectname = 'fcol'+columnIndex;
	if( ld("#"+popupobj.divid+" #"+selectname).length>0){ldelim}
		var selObj = ld("#"+popupobj.divid+" #"+selectname);
       
		var cls_resetComboxHtmlobj=new cls_resetComboxHtml(selectname);
		cls_resetComboxHtmlobj.setPopupObj(popupobj);
		cls_resetComboxHtmlobj.setSearchComboxWidthByhtml(selObj,180);
	{rdelim}

	node2 = document.createElement('td');

    node2.setAttribute('align', 'left');
	node2.setAttribute('width', '20%');
	newNode.appendChild(node2);
	node2.innerHTML = '<select name="fop'+columnIndex+'" id="fop'+columnIndex+'" class="gwidth90 commonSelectPop" onchange="New_addRequiredElements('+columnIndex+');">'+
							'<option value="">--{'NONE'|@getFixedLabel}--</option>'+
							'{$FOPTION}'+
						'</select>';

	node3 = document.createElement('td');

    node3.setAttribute('align', 'left');
    //andy
    //node3.setAttribute('width', '30%');
   
	newNode.appendChild(node3);
	{if $SOURCE eq 'reports' }
		node3.innerHTML = '<input name="fval'+columnIndex+'" id="fval'+columnIndex+'" class="width150 commonTextBoxPop" type="text" value="" onkeyup="searchReport(event,'+reportid+')">'+
						'&nbsp;&nbsp;<img height=20 name="clear_text_ext'+columnIndex+'" width=20 class="marL5" align="absmiddle" style="cursor: pointer;" title="{'FIELDCOMPARE'|@getFixedLabel}" alt="{'FIELDCOMPARE'|@getFixedLabel}" src="themes/images/terms.png" onClick="hideAllElementsByName(\'relFieldsPopupDiv\'); fnvshobj(this,\'show_val'+columnIndex+'\');"/>'+
						'&nbsp;<input class="icon-homeimg icon-clear inpb-advSearchreset" type="button" onclick="ld(this).val(\'\');return false;" title="{'CLEAR'|@getFixedLabel}"/>'+
						'<div class="D_pop_box LdPopWidth350px" id="show_val'+columnIndex+'" name="relFieldsPopupDiv" style="position: absolute; width:300px; z-index: 50; display: none;">'+
                        ''+
                                ''+
                                        '<div class="E_pop_tit">'+
                                            '<strong class="E_ptita">{'Select_field'|@getFixedLabel}</strong>'+                                                   
                                            '<button class="E_ptitc" value="{'CLOSE'|@getFixedLabel}" title="{'CLOSE'|@getFixedLabel}" onclick="fninvshnew(\'show_val'+columnIndex+'\');"></button>'+
                                        '</div>'+
                                        ''+
										'<table class="D_pop_bod" width="100%" align="center" cellspacing="1" cellpadding="2" border="0" name="editColumnTable">'+
											'<tr>'+
												'<td width="20%" align="right">{"RelatedFields"|@getFixedLabel}</td>'+
												'<td width="30%" >'+
													'<select name="fval_'+columnIndex+'" id="fval_'+columnIndex+'" onChange="AddFieldToFilter('+columnIndex+',this);" style="border:1px solid #eee;">'+
														'<option value="">--{'NONE'|@getFixedLabel}--</option>'+
										        		'{$REL_FIELDS}'+
									        		'</select>'+
												'</td>'+
											'</tr>'+
										'</table>'+
                                        '<div class="E_pbtn">'+
                                            '<input type="button" class="E_pbtnok" value="{'Execution'|@getFixedLabel}" onclick="hideAllElementsByName(\'relFieldsPopupDiv\');"/><span>&nbsp;</span>'+
                                            ''+
                                        '</div>'+ 
						'</div>';
    {elseif $SOURCE eq 'usereports'}
    node3.innerHTML = '<input name="fval'+columnIndex+'" id="fval'+columnIndex+'" class="width150 commonTextBoxPop" type="text" value="" onkeyup="searchUseReport(event)">'+
						
						'<input class="icon-homeimg icon-clear inpb-advSearchreset" type="button" name="clear_text_ext'+columnIndex+'" onclick="ld(this).val(\'\');return false;" title="{'CLEAR'|@getFixedLabel}"/>'+
						'<div class="layerPopup" id="show_val'+columnIndex+'" name="relFieldsPopupDiv" style="border:0; position: absolute; width:300px; z-index: 50; display: none;">'+
							'<table width="100%" cellspacing="0" cellpadding="0" border="0" align="center" class="mailClient mailClientBg">'+
								'<tr>'+
									'<td>'+
										'<table width="100%" cellspacing="0" cellpadding="0" border="0" class="layerHeadingULine">'+
											'<tr background="themes/images/qcBg.gif" class="mailSubHeader">'+
												'<td width=100% class="genHeaderSmall"><b>{'Select_field'|@getFixedLabel}</b></td>'+
												'<td align=right>'+
													'<img border="0" align="absmiddle" src="themes/images/Close.png" style="cursor: pointer;diplay:none" alt="{'CLOSE'|@getFixedLabel}" title="{'CLOSE'|@getFixedLabel}" onclick="hideAllElementsByName(\'relFieldsPopupDiv\');"/>'+
	          	'</td>'+
											'</tr>'+
										'</table>'+

										'<table width="100%" cellspacing="0" cellpadding="0" border="0">'+
											'<tr>'+
												'<td>'+
													'<table width="100%" cellspacing="0" cellpadding="5" border="0" bgcolor="white">'+
														'<tr>'+
															'<td width="30%" align="left" class="cellLabel">{'RelatedFields'|@getFixedLabel}</td>'+
															'<td width="30%" align="left" class="cellText">'+
																'<select name="fval_'+columnIndex+'" id="fval_'+columnIndex+'" onChange="AddFieldToFilter('+columnIndex+',this);" class="commonSelectPop">'+
																	'<option value="">--{'NONE'|@getFixedLabel}--</option>'+
													        		'{$REL_FIELDS}'+
												        		'</select>'+
															'</td>'+
														'</tr>'+
													'</table>'+
													'<!-- save cancel buttons -->'+
													'<table width="100%" cellspacing="0" cellpadding="5" border="0" class="layerPopupTransport">'+
														'<tr>'+
															'<td width="50%" align="center">'+
																'<input type="button" style="width: 70px;" value="--{'NONE'|@getFixedLabel}--" name="button" onclick="hideAllElementsByName(\'relFieldsPopupDiv\');" class="create" accesskey="X" title="--{'NONE'|@getFixedLabel}"/>'+
															'</td>'+
														'</tr>'+
													'</table>'+
												'</td>'+
											'</tr>'+
										'</table>'+
									'</td>'+
								'</tr>'+
							'</table>'+
						'</div>';
	{else}
		node3.innerHTML = '<input name="fval'+columnIndex+'" id="fval'+columnIndex+'" class="width150 commonTextBoxPop" type="text" onkeyup="searchSubmit(event,\'Advanced\')" value="">'+
						'<input class="icon-homeimg icon-clear inpb-advSearchreset marL5" style="display:none;" type="button" id="clear_text_ext'+columnIndex+'"  name="clear_text_ext'+columnIndex+'" onclick="document.getElementById(\'fval'+columnIndex+'\').value=\'\';return false;" title="{'CLEAR'|@getFixedLabel}"/>';
	{/if}

	node4 = document.createElement('td');

    node4.setAttribute('align', 'left');
	node4.setAttribute('id', 'columnconditionglue_'+columnIndex);
    node4.setAttribute('name', 'columnconditionglue_'+columnIndex);
	node4.setAttribute('width', '60px');
	newNode.appendChild(node4);

	node5 = document.createElement('td');
    node5.setAttribute('width', '30px');
    node5.setAttribute('align', 'left');
	newNode.appendChild(node5);
	node5.innerHTML = '<a  onclick="New_deleteColumnRow('+groupIndex+','+columnIndex+');" href="javascript:;" title="{'DELETE'|@getFixedLabel}">'+arrJsPopLabel['DELETE']+
						'</a>';

	if(ld("#"+popupobj.divid+" [name='fcol"+columnIndex+"']").length>0) {
		//New_updatefOptions(ld("#" + popupobj.divid + " [name='fcol" + columnIndex + "']").get(0), 'fop' + columnIndex);
		//lius BUG0074706 20231030 在销售发票的关联出库单字段，高级查找时若第二个条件为筛选为区间，则关键字栏为输入框(原写法在客户服务器不生效)
		ld("#"+popupobj.divid+" [name='fcol"+columnIndex+"']").trigger("change");
	}
	if(typeof(popupobj.column_index_array[groupIndex]) == 'undefined') popupobj.column_index_array[groupIndex] = [];
	popupobj.column_index_array[groupIndex].push(columnIndex);
	popupobj.advft_column_index_count++;

{rdelim}
popupobj.column_index_array=[];
popupobj.advft_column_index_count=0;
function New_addGroupConditionGlue(groupIndex) {ldelim}
	if(popupobj!==undefined && popupobj.type!=='advancesearch'){
		popupobj=CrmPopup.getlastPopupObjByType('advancesearch');
	}
    if(popupobj==undefined)
    {
        return false;
    }
    var groupConditionGlueElement=ld("#"+popupobj.advanceSearchDivid+" [name=groupconditionglue_"+groupIndex+"]");
//	var groupConditionGlueElement = document.getElementById('groupconditionglue_'+groupIndex);
	if(groupConditionGlueElement.length>0) {ldelim}
		groupConditionGlueElement.html( "<select name='gpcon"+groupIndex+"' id='gpcon"+groupIndex+"' class='commonSelectPop'>" +
												"<option value='and'>{'SEARCHAND'|@getFixedLabel}</option>"+
												"<option value='or'>{'OR'|@getFixedLabel}</option>"+
											"</select>");
	{rdelim}
{rdelim}

function New_addConditionGroup(parentNodeId) {ldelim}
	if(popupobj!==undefined && popupobj.type!=='advancesearch'){
		popupobj=CrmPopup.getlastPopupObjByType('advancesearch');
	}
    if(popupobj==undefined)
    {
        return false;
    }
	for(var i=popupobj.group_index_array.length - 1; i>=0; --i) {ldelim}
		var prevGroupIndex = popupobj.group_index_array[i];
        var name='conditiongroup_'+prevGroupIndex;
        var tmpobj=ld("#"+popupobj.advanceSearchDivid+" [name="+name+"]");
		if(tmpobj.length>0) {ldelim}
			New_addGroupConditionGlue(prevGroupIndex);
			break;
		{rdelim}
	{rdelim}

	var groupIndex = popupobj.advft_group_index_count+1;
    var hidegroup='{$HideGroup}';
  
	var parentNode =ld("#"+popupobj.advanceSearchDivid+" [name="+parentNodeId+"]").get(0);
        if(parentNode==undefined)
        {
            return;
        }
	var newNode = document.createElement('div');
	newNodeId = 'conditiongroup_'+groupIndex;
  	newNode.setAttribute('id',newNodeId);
    newNode.setAttribute('name',newNodeId);
  	newNode.setAttribute('tag','conditionGroup');

  	//newNode.innerHTML = "<table class='crmTable' border='0' cellpadding='5' cellspacing='1' width='100%' valign='top' id='conditiongrouptable_"+groupIndex+"'>"+
    newNode.innerHTML = "<table class='settingPopTable lasttdbordernon' border='0' cellpadding='0' cellspacing='0' width='100%' name='conditiongrouptable_"+groupIndex+"'>"+
							"<tr name='groupheader_"+groupIndex+"'>"+
							"<td colspan='5' align='right'>"+
							"<a class='icon-homeimg icon-close' href='javascript:void(0);' title='{'REMOVECOMBINATION'|@getFixedLabel}' onclick='deleteGroup(\""+groupIndex+"\");'></a>"+			
							"</td>"+			
							"</tr>"+
							"<tr name='groupfooter_"+groupIndex+"'>"+
                                "<td colspan='5' align='left' class='padTB5'>"+
                                "<a href='javascript:void(0);' onclick='New_addConditionRow(\""+groupIndex+"\")'>{'NEWCONDITIONS'|@getFixedLabel}</a>"+
								"</td>"+
							"</tr>"+
						"<table class='settingPopTable lasttdbordernon' border='0' cellpadding='0' cellspacing='0' width='100%'"+
							"<tr><td align='center' name='groupconditionglue_"+groupIndex+"'>"+
							"</td></tr>"+
						"</table>";
					

	parentNode.appendChild(newNode);
    if(hidegroup=='yes')
    {ldelim}
        ld("#"+popupobj.divid+" [name='groupheader_"+groupIndex+"']").css("display",'none');
    {rdelim}
	popupobj.group_index_array.push(groupIndex);
	popupobj.advft_group_index_count++;
{rdelim}
</script>

<div style="overflow:auto;background-color: #fff;max-height:315px;"  name='pop_adv_filter_div' oonkeyup="searchSubmit(event,'Advanced')">
	{if $isselectsearchdetail eq 'yes'}
	<table class="settingPopTable lasttdbordernon" border="0" cellpadding="0" cellspacing="0" width="100%">
		<tr>
			<th style="text-align: left;font-size:15px;"><span >{'SEARCHHISTORY'|@getFixedLabel}</span></th>
			<th></th>
		</tr>
		<tr>
			<td  align="right">{'SEARCHHISTORY'|@getFixedLabel}</td>
			<td style="width: 85%;overflow:inherit;">
				<div name="SearchHistory" >
					<select class="commonSelectPop gwidth90" >
						<!--{*BUG0068082 txy 2023.06.12 英文版-高级查找框内提示信息应该是“not to exist Search History”*}-->
						<option>{'NOTSEARCHHISTORY'|@getFixedLabel}</option>
					</select>
				</div>
			</td>
		</tr>

	</table>
	{/if}

	<table class="settingPopTable lasttdbordernon" border="0" cellpadding="0" cellspacing="0" width="100%">
    	<tr>
    		<th style="text-align: right;">
    			<input type="button" name="addNewConditionGroup" class="ld-button ld-button-primary" value="{'NEWCOMBINATION'|@getFixedLabel}" onclick="New_addNewConditionGroup('pop_adv_filter_div');">
    		</th>
    	</tr>
    </table>
	<div style="width: 100%;">
	   <ul class="test_ul" style="padding-left: 8px;">
	      <li style="width: 25%;"><div>{'Select_field'|@getFixedLabel}</div></li>
	      <li style="width: 20%;"><div>{'SELECTIONCRITERIA'|@getFixedLabel}</div></li>
	      <li style="width: 30%;"><div>{'SEARCHKEY'|@getFixedLabel}</div></li>
	      <li style="float:right;width: 90px;"><div id="advfiltershow" style="display: none;">{'SCREENINGRELATIONSHIP'|@getFixedLabel}</div></li>
	    </ul>
	</div>	
	<!--{*
	   循环上次高级搜索的条件时，多组合听况下，$COLUMN_INDEX 每次循环结束清零，
		新组合 （且、或）下拉框无法赋值。现在换为自增参数 $fori。
	   @project 序时簿查询记住搜索条件
	   @author tujt 2014-04-24
	*}-->
	{assign var='fori' value='0'}
	<script type="text/javascript">
      	var fori=0;
      </script>
	{foreach key=GROUP_ID item=GROUP_CRITERIA from=$CRITERIA_GROUPS}
        	{assign var=GROUP_COLUMNS value=$GROUP_CRITERIA.columns}
		<script type="text/javascript">
            //zkt 20230328 BUG0063212  客户档案的工商信息查询设置，点击设置例外规则，页面就卡死 
            if(popupobj.advft_group_index_count+1 != {$GROUP_ID}){
                var tmp_index_count = popupobj.advft_group_index_count;
                for(var i=0;i<({$GROUP_ID}-tmp_index_count-1);i++){
                   popupobj.group_index_array.push(popupobj.advft_group_index_count+1);
	               popupobj.advft_group_index_count++;
                }
            }
			New_addConditionGroup('pop_adv_filter_div');
		</script>
		{foreach key=COLUMN_INDEX item=COLUMN_CRITERIA from=$GROUP_COLUMNS}
		<script type="text/javascript">
		
			New_addConditionRow('{$GROUP_ID}');

			var conditionColumnRowElement = ld("#"+popupobj.advanceSearchDivid+' [name=fcol'+popupobj.advft_column_index_count+"]").get(0);
			var tmp_value = '{$COLUMN_CRITERIA.columnname}';
			//duan 20231113 修复高级查询中，如果字段名称修改，编辑时无法选中的问题
			var tmp_arr = tmp_value.split(':');
			var new_value = ld(conditionColumnRowElement).find('option[value*="'+tmp_arr[1]+':'+tmp_arr[2]+'"]').val();

			conditionColumnRowElement.value =new_value;
			
			//wym 230505 新增字段--点击“其他条件” 显示保存的筛选条件
			var trobj = Tools.getParentobjByChild(conditionColumnRowElement,'tr');
			var aobj =  trobj.find("a[class=chzn-single]");
			var fldname = aobj.attr("dropdownname");

			//zxm 20230810 cmb_span_optiontext_fldname的值应当为下拉框option的text
			var selectedoption_text = trobj.find('option[value="'+new_value+'"]').text();
			trobj.find(" [name='cmb_span_optiontext_"+fldname+"']").val(selectedoption_text);
			
			/*var string_array = tmp_value.split(":");
			var fieldname = string_array[3];
			if(!empty(fieldname)){
				fieldname = fieldname.split("_");
				fieldname = fieldname[1];
				trobj.find(" [name='cmb_span_optiontext_"+fldname+"']").val(fieldname);
			}*/

			New_updatefOptions(conditionColumnRowElement, 'fop'+popupobj.advft_column_index_count);
		//	document.getElementById('fop'+advft_column_index_count).value = '{$COLUMN_CRITERIA.search_comparator}';
             ld("#"+popupobj.advanceSearchDivid+' [name=fop'+popupobj.advft_column_index_count+"]").val('{$COLUMN_CRITERIA.search_comparator}');
			//edit:can 2020-10-23 42782: (61mis.com/kfbcrm)客户管理-客户-详情；在详情界面进行高级查找操作，以日期时间字段为查找条件，设置区间后，查找；然后再次点开高级查找，设置的日期区间只剩开始日期，其他模块中也存在此状况。crm_php72版本也存在此状况。
            New_addRequiredElements(popupobj.advft_column_index_count);
			{if $SOURCE eq 'reports'|| $SOURCE eq 'usereports'}
				New_updateRelFieldOptions(conditionColumnRowElement, 'fval_'+popupobj.advft_column_index_count);
			{/if}

			var columnvalue = "{$COLUMN_CRITERIA.value|@addslashes}";
			var values = columnvalue.split(",");//BUG20241029-32 ls 241101 其他条件，设置过去180天，但是条件那里的时间好像不会自动更新，过去的180天，显示的是24-2-3到昨天
			if(columnvalue != '' && values.length == 2) {ldelim}
				//document.getElementById('fval'+advft_column_index_count).value = values[0];
                ld("#"+popupobj.advanceSearchDivid+' [name=fval'+popupobj.advft_column_index_count+"]").val(values[0]);
				if(ld("#"+popupobj.advanceSearchDivid+' [name=fval_ext'+popupobj.advft_column_index_count+"]").length>0)
					ld("#"+popupobj.advanceSearchDivid+' [name=fval_ext'+popupobj.advft_column_index_count+"]").val(values[1]);
			{rdelim} else {ldelim}
           
            if(columnvalue =='Accepted')
                ld("#"+popupobj.advanceSearchDivid+' [name=fval'+popupobj.advft_column_index_count+"]").val(alert_arr.Accepted);
			
                else if(columnvalue =='Rejected')
                ld("#"+popupobj.advanceSearchDivid+' [name=fval'+popupobj.advft_column_index_count+"]").val(alert_arr.Rejected);
                else{ldelim}
                var values = columnvalue.split(",");
                
                ld("#"+popupobj.advanceSearchDivid+' [name=fval'+popupobj.advft_column_index_count+"]").val(values[0]);
				
                {rdelim}
			{rdelim}
		</script>
		{/foreach}
       
		{foreach key=COLUMN_INDEX item=COLUMN_CRITERIA from=$GROUP_COLUMNS}
			<script type="text/javascript">
			   fori++;
				if(ld("#"+popupobj.advanceSearchDivid+' [name=fcon'+fori+']').length>0)
				{
					var condition=ld.trim('{$COLUMN_CRITERIA.columncondition|@html_entity_decode}');
			 		if(condition.indexOf("or")>=0)
			 		{
			 				condition="or";

			 		}
			 		  
	                ld("#"+popupobj.advanceSearchDivid+' [name=fcon'+fori+']').val(condition);
				}
	           

			</script>
			
	            
            
		{/foreach}
		
       
	{foreachelse}
    	<script type="text/javascript">
    		New_addNewConditionGroup('pop_adv_filter_div');
    	</script>
	{/foreach}

    {foreach key=GROUP_ID item=GROUP_CRITERIA from=$CRITERIA_GROUPS}
         <script>
       
        if(ld("#"+popupobj.advanceSearchDivid+' [name=gpcon{$GROUP_ID}]').length>0)
         ld("#"+popupobj.advanceSearchDivid+' [name=gpcon{$GROUP_ID}]').val('{$GROUP_CRITERIA.condition}');
        
        </script>
    {/foreach}

</div>