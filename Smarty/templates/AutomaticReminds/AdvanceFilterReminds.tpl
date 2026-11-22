<!--*+********************************************************************************
 * The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 *********************************************************************************/
-->
<!--修改编码格式:统一编码：UTF-8-->
<!--<script src="include/js/json.js" type="text/javascript" charset="utf-8"></script>-->

<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/advancefilter.js"></script>
{if $JS_DATEFORMAT eq ''}
	{assign var="JS_DATEFORMAT" value='YYYY-mm-ddd'|@parse_calendardate}
{/if}
<input type="hidden" id="jscal_dateformat" name="jscal_dateformat" value="{$JS_DATEFORMAT}" />
<input type="hidden" id="image_path" name="image_path" value="{$IMAGE_PATH}" />
<input type="hidden" name="advft_criteria" id="advft_criteria" value="" />
<input type="hidden" name="advft_criteria_groups" id="advft_criteria_groups" value="" />

<script language="JavaScript" type="text/JavaScript">
var jsnone='{'NONE'|@getFixedLabel}';
function addColumnConditionGlue(columnIndex) {ldelim}

	var columnConditionGlueElement = document.getElementById('columnconditionglue_'+columnIndex);

	if(columnConditionGlueElement) {ldelim}
		columnConditionGlueElement.innerHTML = "<select name='fcon"+columnIndex+"' id='fcon"+columnIndex+"' class='commonSelectPop'>"+
													"<option value='and'>{'SEARCHAND'|@getFixedLabel}</option>"+
													"<option value='or'>{'OR'|@getFixedLabel}</option>"+
												"</select>";
	{rdelim}
{rdelim}

function addConditionRow(groupIndex) {ldelim}

	var groupColumns = column_index_array[groupIndex];
	if(typeof(groupColumns) != 'undefined') {ldelim}
		for(var i=groupColumns.length - 1; i>=0; --i) {ldelim}
			var prevColumnIndex = groupColumns[i];
			if(document.getElementById('conditioncolumn_'+groupIndex+'_'+prevColumnIndex)) {ldelim}
				addColumnConditionGlue(prevColumnIndex);
				break;
			{rdelim}
		{rdelim}
	{rdelim}

	var columnIndex = advft_column_index_count+1;
	var nextNode = document.getElementById('groupfooter_'+groupIndex);

	var newNode = document.createElement('tr');
	newNodeId = 'conditioncolumn_'+groupIndex+'_'+columnIndex;
  	newNode.setAttribute('id',newNodeId);
  	newNode.setAttribute('name','conditionColumn');
	nextNode.parentNode.insertBefore(newNode, nextNode);

	node1 = document.createElement('td');
	node1.setAttribute('class', 'dvtCellLabel');
    node1.setAttribute('align', 'left');
	node1.setAttribute('width', '25%');
	newNode.appendChild(node1);
	{if $SOURCE eq 'reports' || $SOURCE eq 'usereports'}
		node1.innerHTML = '<select name="fcol'+columnIndex+'" id="fcol'+columnIndex+'" onchange="updatefOptions(this, \'fop'+columnIndex+'\');addRequiredElements('+columnIndex+');updateRelFieldOptions(this, \'fval_'+columnIndex+'\');" class="commonSelectPop">'+
							'<option value="">--{'NONE'|@getFixedLabel}--</option>'+
	        				'{$COLUMNS_BLOCK}'+
						'</select>';
	{else}
		node1.innerHTML = "<select name='fcol"+columnIndex+"' id='fcol"+columnIndex+"' onchange='updatefOptions(this, \"fop"+columnIndex+"\");addRequiredElements("+columnIndex+");' class='commonSelectPop'>"+
							"<option value=''>--{'NONE'|@getFixedLabel}--</option>"+
	        				"{$COLUMNS_BLOCK}"
						"</select>";
	{/if}
	node2 = document.createElement('td');
	node2.setAttribute('class', 'dvtCellLabel');
    node2.setAttribute('align', 'left');
	node2.setAttribute('width', '25%');
	newNode.appendChild(node2);
	node2.innerHTML = '<select name="fop'+columnIndex+'" id="fop'+columnIndex+'" class="ld-select-inner width100" onchange="addRequiredElements('+columnIndex+');">'+
							'<option value="">--{'NONE'|@getFixedLabel}--</option>'+
							'{$FOPTION}'+
						'</select>';

	node3 = document.createElement('td');
	node3.setAttribute('class', 'dvtCellLabel');
    node3.setAttribute('align', 'left');
	newNode.appendChild(node3);
  
	{if $SOURCE eq 'reports' }
		node3.innerHTML = '<input name="fval'+columnIndex+'" id="fval'+columnIndex+'" class="width150 commonTextBoxPop" type="text" value="">'+
						'<img height=20 width=20 align="absmiddle" style="cursor: pointer;" title="{'FIELDCOMPARE'|@getFixedLabel}" alt="{'FIELDCOMPARE'|@getFixedLabel}" src="themes/images/terms.png" onClick="hideAllElementsByName(\'relFieldsPopupDiv\'); fnvshobj(this,\'show_val'+columnIndex+'\');"/>'+
						'<input class="icon-homeimg icon-clear inpb-advSearchreset marL5" type="button" onclick="document.getElementById(\'fval'+columnIndex+'\').value=\'\';return false;" title="{'CLEAR'|@getFixedLabel}"/>'+
						'<div class="full-menu" id="show_val'+columnIndex+'" name="relFieldsPopupDiv" style="position: absolute; width:300px; z-index: 50; display: none;">'+
                        '<table width="300" cellspacing="0" cellpadding="0" border="0" class="full-menu-table-wrapper">'+
                        	'<tbody><tr><td>'+
                                '<table width="100%" align="center" cellspacing="0" cellpadding="0" border="0" class="full-menu-table">'+
                                    '<thead>'+
                                    '<tr>'+
                                        '<td colspan="5" class="divPeople-HeadBg">'+
                                        '<div>'+
                                            '<div style="float:left;">'+
                                                '<span class="divPeople-Imgico">'+
                                                    '<img src="themes/softed/tier/logo.png" >'+
                                                '</span>'+
                                                '<span class="divPeople-Head">'+
                                                    "{'Select_field'|@getFixedLabel}"+
                                                '</span>'+                                                    
                                            '</div>'+
                                            '<div class="divPeople-ImgClose">'+
                                                '<a onclick="hideAllElementsByName(\'relFieldsPopupDiv\');">'+
                                                    '<img src="themes/softed/tier/close.png">'+
                                                '</a>'+
                                            '</div>'+
                                        '</div>'+
                                        '</td>'+
                                    '</tr>'+
                                    '</thead>'+
                                '<tbody align="center">'+
										'<table width="100%" cellspacing="0" cellpadding="0" border="0" class="small">'+
											'<tr>'+
												'<td>'+
													'<table width="100%" cellspacing="0" cellpadding="5" border="0" bgcolor="white" class="small">'+
														'<tr>'+
															'<td width="30%" align="left" class="cellLabel small">{"RelatedFields"|@getFixedLabel}</td>'+
															'<td width="30%" align="left" class="cellText">'+
																'<select name="fval_'+columnIndex+'" id="fval_'+columnIndex+'" onChange="AddFieldToFilter('+columnIndex+',this);" class="commonSelectPop">'+
																	'<option value="">--{'NONE'|@getFixedLabel}--</option>'+
													        		'{$REL_FIELDS}'+
												        		'</select>'+
															'</td>'+
														'</tr>'+
													'</table>'+
												'</td>'+
											'</tr>'+
										'</table>'+
                                        '<tr>'+
                                            '<td class="divStorey-Bottom">'+
                                                '<a class="Save-button" onclick="hideAllElementsByName(\'relFieldsPopupDiv\');">{'Execution'|@getFixedLabel}</a>'+
                                            '</td>'+
                                        '</tr>'+
                                        '</tbody>'+
                                '</table>'+
                                '</td></tr></tbody></table>'+                                        
									'</td>'+
								'</tr>'+
							'</table>'+
						'</div>';
    {elseif $SOURCE eq 'usereports'}
    node3.innerHTML = '<input name="fval'+columnIndex+'" id="fval'+columnIndex+'" class="width150 commonTextBoxPop" type="text" value="">'+
						
						'<input class="icon-homeimg icon-clear inpb-advSearchreset marL5" type="button" onclick="document.getElementById(\'fval'+columnIndex+'\').value=\'\';return false;" title="{'CLEAR'|@getFixedLabel}"/>'+
						'<div class="layerPopup" id="show_val'+columnIndex+'" name="relFieldsPopupDiv" style="border:0; position: absolute; width:300px; z-index: 50; display: none;">'+
							'<table width="100%" cellspacing="0" cellpadding="0" border="0" align="center" class="mailClient mailClientBg">'+
								'<tr>'+
									'<td>'+
										'<table width="100%" cellspacing="0" cellpadding="0" border="0" class="layerHeadingULine">'+
											'<tr background="themes/images/qcBg.gif" class="mailSubHeader">'+
												'<td width=90% class="genHeaderSmall"><b>{'Select_field'|@getFixedLabel}</b></td>'+
												'<td align=right>'+
													'<img border="0" align="absmiddle" src="themes/images/Close.png" style="cursor: pointer;diplay:none" alt="{'CLOSE'|@getFixedLabel}" title="{'CLOSE'|@getFixedLabel}" onclick="hideAllElementsByName(\'relFieldsPopupDiv\');"/>'+
	          	'</td>'+
											'</tr>'+
										'</table>'+

										'<table width="100%" cellspacing="0" cellpadding="0" border="0" class="small">'+
											'<tr>'+
												'<td>'+
													'<table width="100%" cellspacing="0" cellpadding="5" border="0" bgcolor="white" class="small">'+
														'<tr>'+
															'<td width="30%" align="left" class="cellLabel small">{'RelatedFields'|@getFixedLabel}</td>'+
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
		node3.innerHTML = '<input name="fval'+columnIndex+'" id="fval'+columnIndex+'" class="width150 commonTextBoxPop" type="text" value="">'+
						'<input class="icon-homeimg icon-clear inpb-advSearchreset marL5" type="button" onclick="document.getElementById(\'fval'+columnIndex+'\').value=\'\';return false;" title="{'CLEAR'|@getFixedLabel}"/>';
	{/if}

	node4 = document.createElement('td');
	node4.setAttribute('class', 'dvtCellLabel');
    node4.setAttribute('align', 'left');
	node4.setAttribute('id', 'columnconditionglue_'+columnIndex);
	node4.setAttribute('width', '60px');
	newNode.appendChild(node4);

	node5 = document.createElement('td');
	node5.setAttribute('class', 'dvtCellLabel');
    node5.setAttribute('align', 'left');
	node5.setAttribute('width', '30px');
	newNode.appendChild(node5);
	node5.innerHTML = '<a class="icon-homeimg icon-sdel" title="{'DELETE'|@getFixedLabel}" onclick="deleteColumnRow('+groupIndex+','+columnIndex+');" href="javascript:;">'+
						'</a>';

//	if(document.getElementById('fcol'+columnIndex)) updatefOptions(document.getElementById('fcol'+columnIndex), 'fop'+columnIndex);
	if(typeof(column_index_array[groupIndex]) == 'undefined') column_index_array[groupIndex] = [];
	column_index_array[groupIndex].push(columnIndex);
	advft_column_index_count++;

{rdelim}
function deleteGroup(groupIndex)
{
    //36592: 公海参数设置-自动回收规则数据分类设置，删除条件之后，界面上无法再新增条件
}
function addGroupConditionGlue(groupIndex) {ldelim}

	var groupConditionGlueElement = document.getElementById('groupconditionglue_'+groupIndex);
	if(groupConditionGlueElement) {ldelim}
		groupConditionGlueElement.innerHTML = "<select name='gpcon"+groupIndex+"' id='gpcon"+groupIndex+"' class='small'>"+
												"<option value='and'>{'SEARCHAND'|@getFixedLabel}</option>"+
												"<option value='or'>{'OR'|@getFixedLabel}</option>"+
											"</select>";
	{rdelim}
{rdelim}
function addConditionGroup(parentNodeId) {ldelim}

	for(var i=group_index_array.length - 1; i>=0; --i) {ldelim}
		var prevGroupIndex = group_index_array[i];
		if(document.getElementById('conditiongroup_'+prevGroupIndex)) {ldelim}
			addGroupConditionGlue(prevGroupIndex);
			break;
		{rdelim}
	{rdelim}

	var groupIndex = advft_group_index_count+1;
	var parentNode = document.getElementById(parentNodeId);

	var newNode = document.createElement('div');
	newNodeId = 'conditiongroup_'+groupIndex;
  	newNode.setAttribute('id',newNodeId);
  	newNode.setAttribute('name','conditionGroup');

  	newNode.innerHTML = "<table class='crmTable nolinetable' border='0' cellpadding='5' cellspacing='1' width='100%' valign='top' id='conditiongrouptable_"+groupIndex+"'>"+
							"<tr id='groupheader_"+groupIndex+"'>"+
									"<input type='hidden' id='selectrow' name='selectrow' value='' ><a href='javascript:void(0);' onclick='deleteGroup(\""+groupIndex+"\");'></a>"+
							"</tr>"+
							"<tr id='groupfooter_"+groupIndex+"'>"+
								"<td colspan='5' align='left'>"+
									"<a href='javascript:;' onclick='addConditionRow(\""+groupIndex+"\")'>{'NEWCONDITIONS'|@getFixedLabel}</a>"+
								"</td>"+
							"</tr>"+
						"</table>"+
						"<table border='0' cellpadding='5' cellspacing='1' width='100%' valign='top'>"+
							"<tr><td align='center' id='groupconditionglue_"+groupIndex+"'>"+
							"</td></tr>"+
						"</table>";

	parentNode.appendChild(newNode);

	group_index_array.push(groupIndex);
	advft_group_index_count++;
{rdelim}
</script>

<div style="overflow:auto;" id='adv_filter_div' name='adv_filter_div'>
	<!--{*
	   循环上次高级搜索的条件时，多组合听况下，$COLUMN_INDEX 每次循环结束清零，
		新组合 （且、或）下拉框无法赋值。现在换为自增参数 $fori。
	   @project 序时簿查询记住搜索条件
	   @author tujt 2014-04-24
	*}-->
	{assign var='fori' value='0'}
	{foreach key=GROUP_ID item=GROUP_CRITERIA from=$CRITERIA_GROUPS}
		{assign var=GROUP_COLUMNS value=$GROUP_CRITERIA.columns}
		<script type="text/javascript">
            addConditionGroup('adv_filter_div');
		</script>
		{foreach key=COLUMN_INDEX item=COLUMN_CRITERIA from=$GROUP_COLUMNS}
		<script type="text/javascript">
			addConditionRow('{$GROUP_ID}');
           
			var conditionColumnRowElement = document.getElementById('fcol'+advft_column_index_count);
			conditionColumnRowElement.value = '{$COLUMN_CRITERIA.columnname}';
            
			updatefOptions(conditionColumnRowElement, 'fop'+advft_column_index_count);
			document.getElementById('fop'+advft_column_index_count).value = '{$COLUMN_CRITERIA.comparator}';
			addRequiredElements(advft_column_index_count);
			{if $SOURCE eq 'reports'|| $SOURCE eq 'usereports'}
				updateRelFieldOptions(conditionColumnRowElement, 'fval_'+advft_column_index_count);
			{/if}

			var columnvalue = "{$COLUMN_CRITERIA.value|@addslashes}";
			if('{$COLUMN_CRITERIA.comparator}' == 'bw' && columnvalue != '') {ldelim}
				var values = columnvalue.split(",");
				document.getElementById('fval'+advft_column_index_count).value = values[0];
				if(values.length == 2 && document.getElementById('fval_ext'+advft_column_index_count))
					document.getElementById('fval_ext'+advft_column_index_count).value = values[1];
			{rdelim} else {ldelim}
           
            if(columnvalue =='Accepted')
				document.getElementById('fval'+advft_column_index_count).value = alert_arr.Accepted;
                else if(columnvalue =='Rejected')
                document.getElementById('fval'+advft_column_index_count).value = alert_arr.Rejected;
                else{ldelim}
                var values = columnvalue.split(",");
				document.getElementById('fval'+advft_column_index_count).value = values[0];
                {rdelim}
			{rdelim}
		</script>
		{/foreach}
		{foreach key=COLUMN_INDEX item=COLUMN_CRITERIA from=$GROUP_COLUMNS}
		<script type="text/javascript">
			if(document.getElementById('fcon{$fori}')) document.getElementById('fcon{$fori}').value = '{$COLUMN_CRITERIA.column_condition}';
		</script>
		{assign var='fori' value=$fori+1}
		{/foreach}
	{foreachelse}
	<script type="text/javascript">
        addNewConditionGroup('adv_filter_div');
	</script>
	{/foreach}
	{foreach key=GROUP_ID item=GROUP_CRITERIA from=$CRITERIA_GROUPS}
	<script type="text/javascript">
		if(document.getElementById('gpcon{$GROUP_ID}')) document.getElementById('gpcon{$GROUP_ID}').value = '{$GROUP_CRITERIA.condition}';
	</script>
	{/foreach}
</div>