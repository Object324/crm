<!--*********************************************************************************
** The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
*
 ********************************************************************************/
-->
<!--修改编码格式:统一编码：UTF-8-->

{$DATE_JS}
<script type="text/javascript" src="include/js/modules/CustomView/CustomView.js"></script>
{*<script language="JavaScript" type="text/javascript" src="include/calculator/calc.js"></script>*}
{if $MORE_LISTVIEW eq 1}
    {literal}
    <form enctype="multipart/form-data" name="CustomView" method="POST" action="index.php" onsubmit="if(productmandatoryCheck()){puyoungJS_DialogBox.block();} else{ return false; }">
    {/literal}
    <input type="hidden" name="action" value="ProductSave">
{elseif $MORE_LISTVIEW eq 2}
{*        // @edit:liushuai @date:2020-07-09 @reason: 0041912/群发邮件模块*}
    {literal}
    <form enctype="multipart/form-data" name="CustomView" method="POST" action="index.php">
    {/literal}
    <input type="hidden" name="action" value="Save">
{else}
    {literal}
    <form enctype="multipart/form-data" name="CustomView" method="POST" action="index.php" onsubmit="if(mandatoryCheck()){puyoungJS_DialogBox.block();} else{ return false; }">
    {/literal}
    <input type="hidden" name="action" value="Save">
{/if}
<input type="hidden" name="ProductListView" id="ProductListView" value="">
<input type="hidden" name="SortOrderList" id="SortOrderList" value="" />
<input type="hidden" name="module" value="CustomView">
<input type="hidden" name="cvmodule" value="{$CVMODULE}">
{if $GROUPEMAIL == 'Emails' ||$GROUPEMAIL == 'MassSMS'}
{if $GROUPEMAIL eq 'Emails'}
<input type="hidden" name="return_module" value="Emails">
<input type="hidden" name="return_action" value="GroupEmail">
{elseif $GROUPEMAIL eq 'MassSMS'}
<input type="hidden" name="return_module" value="MassSMS">
<input type="hidden" name="return_action" value="index">
{/if}
{else}
<input type="hidden" name="parenttab" value="{$CATEGORY}">
<input type="hidden" name="return_module" value="{$RETURN_MODULE}">
<input type="hidden" name="return_action" value="{$RETURN_ACTION}">
{/if}
<input type="hidden" name="record" value="{$CUSTOMVIEWID}">
<input type="hidden" id="user_dateformat" name="user_dateformat" value="{$DATEFORMAT}">
<input type="hidden" name="group" value="{$GROUPEMAIL}">
<input type="hidden" name="SearchScope" value="{$SEARCHSCOPE}"/>
<input type="hidden" name="viewcopy" value="{$viewcopy}"/>
<input type="hidden" name="viewcopy_cvid" value="{$viewcopy_cvid}" />

<script language="javascript" type="text/javascript">
var fLabels = new Array();

fLabels['bw'] = '{'Interval'|@getFixedLabel}';
fLabels['e'] = '{'EQ'|@getFixedLabel}';
fLabels['n'] = '{'NEQ'|@getFixedLabel}';
fLabels['c'] = '{'IN'|@getFixedLabel}';
fLabels['k'] = '{'NOT_IN'|@getFixedLabel}';
fLabels['l'] = '{'LT'|@getFixedLabel}';
fLabels['g'] = '{'GT'|@getFixedLabel}';
fLabels['m'] = '{'LE'|@getFixedLabel}';;
fLabels['h'] = '{'GE'|@getFixedLabel}';
fLabels['b'] = '{'Before'|@getFixedLabel}';
fLabels['a'] = '{'After'|@getFixedLabel}';
fLabels['isnull'] = '{'ISNULL'|@getFixedLabel}';
fLabels['isnotnull'] = '{'ISNOTNULL'|@getFixedLabel}';
fLabels['curuser'] = '{'CURUSER'|@getFixedLabel}';
fLabels['includeuser'] = '{'INCULDECURUSER'|@getFixedLabel}';
function goto_CustomAction(module)
{ldelim}
        document.location.href = "index.php?module="+module+"&action=CustomAction&record={$CUSTOMVIEWID}";
{rdelim}
function productmandatoryCheck()
{ldelim}
    var tmpobj=new Object();
    tmpobj.divid="dv_datacustomview";
    CrmPopup.global_listPopupObj.push(tmpobj);

    var mandatorycheck = false;
    var i,j;
    var manCheck = new Array({$MANDATORYCHECK});
    var showvalues = "{$SHOWVALUES}";
    var module = "{$MODULE}";
    var sortArray = new Array();
    var sortOrder = new Array();
    var key = 0;
    if(manCheck)
    {ldelim}
        var isError = false;
        var errorMessage = "";
        var productinfo = "";

        var selObj=document.getElementById('selectedAssmablyColumns');
        var sortorderlist = "";
        if (trim(document.CustomView.viewName.value) == "")
        {ldelim}
                isError = true;
                errorMessage += "\n{$MOD.LBL_VIEW_NAME}";
        {rdelim}
        // Here we decide whether to submit the form.
        if (isError == true)
        {ldelim}
        /*
        edit:cdw
        date:20130801
        reason:
        */
            var confirm_str = arrJsPopLabel['CATEGORYNAMECANOTEMPTY'];
            RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
            return false;
        {rdelim}




		//判断显示列大于三列
		if(selObj.options.length < 3)
        {ldelim}
            var confirm_str = arrJsPopLabel['COLUMNSELECTLEASTTHREE'];
            RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
            return false;
        {rdelim};

        for (var i=0;i<selObj.options.length;i++)
        {ldelim}
            productinfo+=selObj.options[i].value+",";
        {rdelim}
        document.getElementById('ProductListView').value = productinfo;
		if(document.getElementById('more_listview') != undefined && document.getElementById('more_listview').value == 0)
        {ldelim}
		for(i=1;i<=9;i++)
            {ldelim}
                var columnvalue = document.getElementById("column"+i).value;
                if(columnvalue != null)
                {ldelim}
                    for(j=0;j<manCheck.length;j++)
                    {ldelim}
                            if(columnvalue == manCheck[j])
                            {ldelim}
                                    mandatorycheck = true;
                            {rdelim}
                    {rdelim}
                    if(mandatorycheck == true)
                    {ldelim}


        				if(($("jscal_field_date_start").value.replace(/^\s+/g, '').replace(/\s+$/g, '').length!=0) || ($("jscal_field_date_end").value.replace(/^\s+/g, '').replace(/\s+$/g, '').length!=0))
        					return stdfilterdateValidate();
        				else
        					return true;
                    {rdelim}
                    else
                    {ldelim}
                            mandatorycheck = false;
                    {rdelim}
                {rdelim}
            {rdelim}
        {rdelim}
        //获取已选择的分类名称
        for(var k=0; k<4; k++)
        {ldelim}
            if(document.getElementById('sortselect'+k) != undefined && document.getElementById('sortselect'+k).value != '')
            {ldelim}
                sortArray[key] = document.getElementById('sortselect'+k).value;
                var SortOrderRadio=document.getElementsByName('sortorder'+k);
                for(var n=0;n<SortOrderRadio.length;n++)
                {ldelim}
                    if(SortOrderRadio[n].checked)
                        sortOrder[key] = document.getElementById('sortselect'+k).value +"|"+SortOrderRadio[n].value;
                {rdelim}
                key++;
            {rdelim}
        {rdelim}

        if(module != 'InventoryQuery' && module != 'InventoryAccount')
        {ldelim}
            //排序方式设置需要至少选择一个字段
            if(sortArray.length == 0)
            {ldelim}
                var confirm_str = arrJsPopLabel['SETSORTORDER'];
                RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
                return false;
            {rdelim}
            //排序字段不能重复
            var sortinfo = sortArray.join(",")+",";
            document.getElementById('SortOrderList').value = sortOrder.join(",");
			var sortindexarr = [];var sortindex_i = 0;
            for(var k=0; k<4; k++)
            {ldelim}
                 if(sortinfo.replace(sortArray[k]+",","").indexOf(sortArray[k]+",")>-1)
                 {ldelim}
					//将重复字段设置为无
					var sort_v_i = '';var sort_v_j = '';
					for(var i=0;i<4;i++){ldelim}
						for(var j=3;j>i;j--){ldelim}
							sort_v_i = document.getElementById('sortselect'+i).value;
							sort_v_j = document.getElementById('sortselect'+j).value;
							if(sort_v_i == sort_v_j){ldelim}
								document.getElementById('sortselect'+j).value = '';
							{rdelim}
						{rdelim}
					{rdelim}
					return false;
                    break;
                 {rdelim}
            {rdelim}
        {rdelim}
  {rdelim}
    return true;
{rdelim}
function mandatoryCheck()
{ldelim}
    var mandatorycheck = false;
    var i,j;
    var manCheck = new Array({$MANDATORYCHECK});
    var showvalues = "{$SHOWVALUES}";
    if(manCheck)
    {ldelim}
        var isError = false;
        var errorMessage = "";
        if (trim(document.CustomView.viewName.value) == "")
        {ldelim}
                isError = true;
                errorMessage += "\n{$MOD.LBL_VIEW_NAME}";
        {rdelim}
        // Here we decide whether to submit the form.
        if (isError == true)
        {ldelim}
            if(ld('span[tag=view_title_label]').length > 0){ldelim}
                var view_title_label = ld('span[tag=view_title_label]').html();
                var confirm_str = view_title_label+' '+arrJsPopLabel['CANOTEMPTY'];
            {rdelim}else{ldelim}
                var confirm_str = arrJsPopLabel['CATEGORYNAMECANOTEMPTY'];
            {rdelim}
             RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
             return false;
        {rdelim}
		if(document.getElementById('more_listview') != undefined && document.getElementById('more_listview').value == 0)
        {ldelim}
		for(i=1;i<=9;i++)
            {ldelim}
                var columnvalue = document.getElementById("column"+i).value;
                if(columnvalue != null)
                {ldelim}
                    for(j=0;j<manCheck.length;j++)
                    {ldelim}
                            if(columnvalue == manCheck[j])
                            {ldelim}
                                    mandatorycheck = true;
                            {rdelim}
                    {rdelim}
                    if(mandatorycheck == true)
                    {ldelim}
        				if(($("jscal_field_date_start").value.replace(/^\s+/g, '').replace(/\s+$/g, '').length!=0) || ($("jscal_field_date_end").value.replace(/^\s+/g, '').replace(/\s+$/g, '').length!=0))
        					return stdfilterdateValidate();
        				else
        					return true;
                    {rdelim}
                    else
                    {ldelim}
                            mandatorycheck = false;
                    {rdelim}
                {rdelim}
            {rdelim}
        {rdelim}
        else
        {ldelim}
            return true;
        {rdelim}
  {rdelim}
        if(mandatorycheck == false)
        {ldelim}
                var confirm_str = arrJsPopLabel['ATLEASTCHOOSEREQUIREDFIELD']+'\n'+showvalues;
                RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
        {rdelim}

        return false;
{rdelim}
function setSortDiv(num)
{ldelim}
    var sortvalue = document.getElementById('sortselect'+num).value;
    if(sortvalue != '')
        document.getElementById('sortdiv'+num).style.display = 'block';
    else
        document.getElementById('sortdiv'+num).style.display = 'none';
{rdelim}
</script>

<div id="dv_datacustomview">
    <form name="EditView" method="post" enctype="multipart/form-data" action="index.php">
        <input type="hidden" name="SearchScope" value="{$SEARCHSCOPE}"/>
        <table class="settingPopTable lasttdbordernon a" border="0" cellpadding="0" cellspacing="0" width="100%">
    		<tr>
    		 	<th colspan="4" style="font-weight: bold;">{'Details'|@getFixedLabel}</th>
    		</tr>
    		<tr>
    			<td colspan=4 width="100%" style="padding:0px">
    			<table class="settingPopTable lasttdbordernon b" border="0" cellpadding="0" cellspacing="0" width="100%">
    				<tr>
                        {if $GROUPEMAIL == 'Emails' || $GROUPEMAIL == 'MassSMS'}
                            <td width="10%" align="right">
                                <span class="redFont">*</span>
                                <span tag='view_title_label'>{'Group_name'|@getFixedLabel}</span>
        					</td>
        					<td width="30%">
        						<input class="detailedViewTextBox" type="text" {if $NOVIEWNAME eq 'All'} readonly {/if} name='viewName' value="{$VIEWNAME}" onfocus="this.className='commonDetailedTextBox bgcolordh'" onblur="this.className='detailedViewTextBox'" size="40"/>
        		 			</td>
                            <td width="60%" colspan="3">
                        {else}
        					<td width="10%" align="right">
                                <span class="redFont">*</span>
                                <span tag='view_title_label'>{'Category_Name'|@getFixedLabel}</span>
        					</td>
        					<td width="30%">
        						<input class="detailedViewTextBox"{if $NOVIEWNAME eq 'All'} readonly {/if} type="text" name='viewName' value="{$VIEWNAME}" onfocus="this.className='commonDetailedTextBox gwidth70 bgcolordh'" onblur="this.className='detailedViewTextBox'" size="40"/>
        		 			</td>
        		 			<td width="20%">
            		  			{if $CHECKED eq 'checked'}
                                    <input type="checkbox" style="vertical-align:middle; margin-top:-2px; margin-bottom:1px;" name="setDefault" value="1" checked/>
            		  			{else}
                                    <input type="checkbox" style="vertical-align:middle; margin-top:-2px; margin-bottom:1px;" name="setDefault" value="0" />
            		  			{/if}
                                {'Set_Default'|@getFixedLabel}
        		 			</td>
                        {if $MCSHOW eq 'yes'}
        		 			<td width="20%">
            		  			{if $MCHECKED eq 'checked'}
                                    <input type="checkbox" style="vertical-align:middle; margin-top:-2px; margin-bottom:1px;" name="setMetrics" value="1" checked/>
            		  			{else}
                                    <input type="checkbox" style="vertical-align:middle; margin-top:-2px; margin-bottom:1px;" name="setMetrics" value="0" />
            		  			{/if}
                                {'DISPLAYINHOME'|@getFixedLabel}
        		 			</td>
                        {/if}
                            <td width="20%">
                        {/if}
        					{if $STATUS eq 1}
                                <input type="checkbox" style="vertical-align:middle; margin-top:-2px; margin-bottom:1px;" name="setStatus" value="1"/>
        					{elseif $STATUS eq 2 || $STATUS eq ''}
                               <input type="checkbox" style="vertical-align:middle; margin-top:-2px; margin-bottom:1px;" name="setStatus" value="2" checked/>
        					{elseif $STATUS eq 3 || $STATUS eq 0}
                                <input type="checkbox" style="vertical-align:middle; margin-top:-2px; margin-bottom:1px;" name="setStatus" value="3" checked {if $NOVIEWNAME eq 'All'}disabled{/if}/>
        					{/if}
                            {'Make_Public'|@getFixedLabel}
    					</td>
    				</tr>
    			</table>
    			</td>
    		</tr>
            <input type="hidden" id="more_listview" name="more_listview" value="{$MORE_LISTVIEW}" />
            {if $MORE_LISTVIEW eq 1}
                <tr>
                    <td colspan="4" class="f1">
                        <b>{'DISPLAYCOLUMNSETTINGS'|@getFixedLabel} </b>
                    </td>
        		</tr>
                <tr>
                    <td>{include file="ProductListView.tpl"}</td>
                </tr>
                {if $MODULE neq 'InventoryQuery' && $MODULE neq 'InventoryAccount'}
                    {*排序方式设置*}
                    <tr>
                        <td colspan="4" class="f1">
                            <b>{'SORTORDERSETTING'|@getFixedLabel}</b>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <table class="settingPopTable lasttdbordernon c" border="0" cellpadding="0" cellspacing="0" width="100%">
                            {foreach key = number item = defaultsort from =$SORTDEFAULT name=sort}
                            {if $defaultsort.columnname eq ''}
                                {assign var="divdisplay" value=none}
                            {else}
                                {assign var="divdisplay" value=block}
                            {/if}
                            <tr>
                                <td>
                                    <select class="detailedViewTextBox" name="sortselect{$number}" id="sortselect{$number}" style="width:100px;" onchange="setSortDiv({$number})">
                                        <option value="">--{'NONE'|@getFixedLabel}--</option>
                                    {foreach item=sortinfo from =$SORTARR}
                                        <option {if  $defaultsort.columnname eq $sortinfo.columnname} selected {/if} value="{$sortinfo.columnname}">{$sortinfo.fieldlabel}</option>
                                    {/foreach}
                                    </select>
                                </td>
                                <td>
                                    <div id="sortdiv{$number}" style="display:{$divdisplay};">
                                    <input type="radio" style="margin-top: -3px;" id="sortorderasc{$number}" name="sortorder{$number}" {if $defaultsort.sort eq 'asc'} checked {elseif $defaultsort.columnname eq ''} checked {/if} value="asc" />{'ASCENDINGORDER'|@getFixedLabel}
                                    <input type="radio" style="margin-top: -3px;" id="sortorderdesc{$number}" name="sortorder{$number}" {if $defaultsort.sort eq 'desc'} checked {/if} value="desc" />{'DESCENDINGORDER'|@getFixedLabel}
                                    </div>
                                </td>
                            </tr>
                            {/foreach}
                            </table>
                        </td>
                    </tr>
                {/if}
            {else}
                <input type="hidden" value="100" id="PageWidthPercent" name="PageWidthPercent"/>
            {/if}
            {if $GROUPEMAIL == 'Emails' || $GROUPEMAIL == 'MassSMS'}
            {else}
                {if $MORE_LISTVIEW == 0}
            		<tr>
            		 <td colspan="4" class="f1">
            		  <b>{'Select_field'|@getFixedLabel} </b>
            		 </td>
            		</tr>
            		<tr>
                		<td class="borderLBR padL10">
                            <select name="column1" id="column1" onChange="checkDuplicate();" {if $MODULE == 'InventoryQuery' || $MODULE == 'InventoryAccount'}disabled="disabled"{/if}>
                	            <option value="">--{'NONE'|@getFixedLabel}--</option>
                			    {foreach item=filteroption key=label from=$CHOOSECOLUMN1}
                				<optgroup label="{$label}" class=\"select\" style=\"border:none\">
                					{foreach item=text from=$filteroption}
                					 {assign var=option_values value=$text.text}
                		   		         <option {$text.selected} value={$text.value}>
                			                 {if $MOD.$option_values neq ''}
                                                {if $DATATYPE.0.$option_values eq 'M'}
                                                        {$option_values}   *
                                                {else}
                                                        {$option_values}
                                                {/if}
                                            {elseif $APP.$option_values neq ''}
                                                {if $DATATYPE.0.$option_values eq 'M'}
                                                        {$option_values}   *
                                                {else}
                                                        {$option_values}
                                                {/if}
                                            {else}
                                                {if $DATATYPE.0.$option_values eq 'M'}
                                                        {$option_values}    *
                                                {else}
                                                        {$option_values}
                                                {/if}
                                            {/if}
                					</option>
                				 {/foreach}
                			{/foreach}
                          	        {$CHOOSECOLUMN1}
                	       </select>
                        </td>
                		<td class="borderBR padL10">
                            <select name="column2" id="column2" onChange="checkDuplicate();" {if $MODULE == 'InventoryQuery' || $MODULE == 'InventoryAccount'}disabled="disabled"{/if}>
                                <option value="">--{'NONE'|@getFixedLabel}--</option>
                                {foreach item=filteroption key=label from=$CHOOSECOLUMN2}
                                    <optgroup label="{$label}" class=\"select\" style=\"border:none\">
                                    {foreach item=text from=$filteroption}
                                  	 {assign var=option_values value=$text.text}
                	   		         <option {$text.selected} value={$text.value}>
                		                 {if $option_values neq ''}
                                            {if $DATATYPE.0.$option_values eq 'M'}
                                                    {$option_values}   *
                                            {else}
                                                    {$option_values}
                                            {/if}
                                        {elseif $option_values neq ''}
                                            {if $DATATYPE.0.$option_values eq 'M'}
                                                    {$option_values}   *
                                            {else}
                                                    {$option_values}
                                            {/if}
                                        {else}
                                            {if $DATATYPE.0.$option_values eq 'M'}
                                                    {$option_values}   *
                                            {else}
                                                    {$option_values}
                                            {/if}
                                        {/if}
                				   </option>
                                   {/foreach}
                              {/foreach}
                                {$CHOOSECOLUMN2}
                           </select>
                        </td>
                	   <td class="borderBR padL10">
                            <select name="column3" id="column3" onChange="checkDuplicate();" {if $MODULE == 'InventoryQuery' || $MODULE == 'InventoryAccount'}disabled="disabled"{/if}>
                                <option value="">--{'NONE'|@getFixedLabel}--</option>
                                {foreach item=filteroption key=label from=$CHOOSECOLUMN3}
                                    <optgroup label="{$label}" class=\"select\" style=\"border:none\">
                                    {foreach item=text from=$filteroption}
                                    	 {assign var=option_values value=$text.text}
                   		                 <option {$text.selected} value={$text.value}>
                			             {if $option_values neq ''}
                                            {if $DATATYPE.0.$option_values eq 'M'}
                                                    {$option_values}   *
                                            {else}
                                                    {$option_values}
                                            {/if}
                                        {elseif $option_values neq ''}
                                            {if $DATATYPE.0.$option_values eq 'M'}
                                                    {$option_values}  *
                                            {else}
                                                    {$option_values}
                                            {/if}
                                        {else}
                                            {if $DATATYPE.0.$option_values eq 'M'}
                                                    {$option_values}    *
                                            {else}
                                                    {$option_values}
                                            {/if}
                                        {/if}
                					</option>
                                {/foreach}
                            {/foreach}
                                {$CHOOSECOLUMN3}
                            </select>
                       </td>
                        <td class="borderBR padL10">
                            <select name="column4" id="column4" onChange="checkDuplicate();" {if $MODULE == 'InventoryQuery' || $MODULE == 'InventoryAccount'}disabled="disabled"{/if}>
                                <option value="">--{'NONE'|@getFixedLabel}--</option>
                                {foreach item=filteroption key=label from=$CHOOSECOLUMN4}
                                    <optgroup label="{$label}" class=\"select\" style=\"border:none\">
                                    {foreach item=text from=$filteroption}
                                        {assign var=option_values value=$text.text}
                	   		             <option {$text.selected} value={$text.value}>
                		                {if $option_values neq ''}
                                            {if $DATATYPE.0.$option_values eq 'M'}
                                                    {$option_values}   *
                                            {else}
                                                    {$option_values}
                                            {/if}
                                        {elseif $option_values neq ''}
                                            {if $DATATYPE.0.$option_values eq 'M'}
                                                    {$option_values}   *
                                            {else}
                                                    {$option_values}
                                            {/if}
                                        {else}
                                            {if $DATATYPE.0.$option_values eq 'M'}
                                                    {$option_values}    *
                                            {else}
                                                    {$option_values}
                                            {/if}
                                        {/if}
                				       </option>
                                    {/foreach}
                                {/foreach}
                             {$CHOOSECOLUMN4}
                           </select>
                        </td>
            		</tr>
            		<tr class="dvtCellLabel">
            		   <td class="borderLBR padL10">
                            <select name="column5" id="column5" onChange="checkDuplicate();" {if $MODULE == 'InventoryQuery' || $MODULE == 'InventoryAccount'}disabled="disabled"{/if}>
                                <option value="">--{'NONE'|@getFixedLabel}--</option>
                                {foreach item=filteroption key=label from=$CHOOSECOLUMN5}
                                        <optgroup label="{$label}" class=\"select\" style=\"border:none\">
                                        {foreach item=text from=$filteroption}
                                          {assign var=option_values value=$text.text}
            		   		              <option {$text.selected} value={$text.value}>
            			                 {if $option_values neq ''}
                                            {if $DATATYPE.0.$option_values eq 'M'}
                                                    {$option_values}   *
                                            {else}
                                                    {$option_values}
                                            {/if}
                                        {elseif $option_values neq ''}
                                            {if $DATATYPE.0.$option_values eq 'M'}
                                                    {$option_values}   *
                                            {else}
                                                    {$option_values}
                                            {/if}
                                        {else}
                                            {if $DATATYPE.0.$option_values eq 'M'}
                                                    {$option_values}    *
                                            {else}
                                                    {$option_values}
                                            {/if}
                                        {/if}
            					       </option>
                                        {/foreach}
                             {/foreach}
                                    {$CHOOSECOLUMN5}
                           </select>
                         </td>
                         <td class="borderBR padL10">
                            <select name="column6" id="column6" onChange="checkDuplicate();" {if $MODULE == 'InventoryQuery' || $MODULE == 'InventoryAccount'}disabled="disabled"{/if}>
                                <option value="">--{'NONE'|@getFixedLabel}--</option>
                                {foreach item=filteroption key=label from=$CHOOSECOLUMN6}
                                    <optgroup label="{$label}" class=\"select\" style=\"border:none\">
                                    {foreach item=text from=$filteroption}
                                       	 {assign var=option_values value=$text.text}
            		   		             <option {$text.selected} value={$text.value}>
            			                 {if $option_values neq ''}
                                            {if $DATATYPE.0.$option_values eq 'M'}
                                                    {$option_values}   *
                                            {else}
                                                    {$option_values}
                                            {/if}
                                        {elseif $option_values neq ''}
                                            {if $DATATYPE.0.$option_values eq 'M'}
                                                    {$option_values}   *
                                            {else}
                                                    {$option_values}
                                            {/if}
                                        {else}
                                            {if $DATATYPE.0.$option_values eq 'M'}
                                                    {$option_values}    *
                                            {else}
                                                    {$option_values}
                                            {/if}
                                        {/if}
            					   </option>
                                   {/foreach}
                            {/foreach}
                                    {$CHOOSECOLUMN6}
                            </select>
                        </td>
                        <td class="borderBR padL10">
                            <select name="column7" id="column7" onChange="checkDuplicate();" {if $MODULE == 'InventoryQuery' || $MODULE == 'InventoryAccount'}disabled="disabled"{/if}>
                                <option value="">--{'NONE'|@getFixedLabel}--</option>
                                {foreach item=filteroption key=label from=$CHOOSECOLUMN7}
                                    <optgroup label="{$label}" class=\"select\" style=\"border:none\">
                                        {foreach item=text from=$filteroption}
                                      	 {assign var=option_values value=$text.text}
            		   		         <option {$text.selected} value={$text.value}>
            			        {if $option_values neq ''}
                                    {if $DATATYPE.0.$option_values eq 'M'}
                                            {$option_values}   *
                                    {else}
                                            {$option_values}
                                    {/if}
                                    {elseif $APP.$option_values neq ''}
                                        {if $DATATYPE.0.$option_values eq 'M'}
                                                {$option_values}   *
                                        {else}
                                                {$option_values}
                                        {/if}
                                    {else}
                                        {if $DATATYPE.0.$option_values eq 'M'}
                                                {$option_values}    *
                                        {else}
                                                {$option_values}
                                        {/if}
                                    {/if}
            					   </option>
                                        {/foreach}
                                {/foreach}
                                    {$CHOOSECOLUMN7}
                             </select>
                             </td>
                             <td class="borderBR padL10">
                                 <select name="column8" id="column8" onChange="checkDuplicate();" {if $MODULE == 'InventoryQuery' || $MODULE == 'InventoryAccount'}disabled="disabled"{/if}>
                                    <option value="">--{'NONE'|@getFixedLabel}--</option>
                                    {foreach item=filteroption key=label from=$CHOOSECOLUMN8}
                                        <optgroup label="{$label}" class=\"select\" style=\"border:none\">
                                        {foreach item=text from=$filteroption}
                                      	 {assign var=option_values value=$text.text}
                		   		         <option {$text.selected} value={$text.value}>
                			                 {if $option_values neq ''}
                                                {if $DATATYPE.0.$option_values eq 'M'}
                                                        {$option_values}   *
                                                {else}
                                                        {$option_values}
                                                {/if}
                                            {elseif $option_values neq ''}
                                                {if $DATATYPE.0.$option_values eq 'M'}
                                                        {$option_values}   *
                                                {else}
                                                        {$option_values}
                                                {/if}
                                            {else}
                                                {if $DATATYPE.0.$option_values eq 'M'}
                                                        {$option_values}    *
                                                {else}
                                                        {$option_values}
                                                {/if}
                                            {/if}
                					   </option>
                                       {/foreach}
                                   {/foreach}
                                        {$CHOOSECOLUMN8}
                			</select>
                        </td>
            		</tr>
            		<tr>
            		   <td class="borderLBR padL10">
                       <select name="column9" id="column9" onChange="checkDuplicate();" {if $MODULE == 'InventoryQuery' || $MODULE == 'InventoryAccount'}disabled="disabled"{/if}>
                            <option value="">--{'NONE'|@getFixedLabel}--</option>
                            {foreach item=filteroption key=label from=$CHOOSECOLUMN9}
                                    <optgroup label="{$label}" class=\"select\" style=\"border:none\">
                                    {foreach item=text from=$filteroption}
                                  	 {assign var=option_values value=$text.text}
            		   		         <option {$text.selected} value={$text.value}>
            			             {if $option_values neq ''}
                                        {if $DATATYPE.0.$option_values eq 'M'}
                                                {$option_values}   *
                                        {else}
                                                {$option_values}
                                        {/if}
                                    {elseif $option_values neq ''}
                                        {if $DATATYPE.0.$option_values eq 'M'}
                                                {$option_values}   *
                                        {else}
                                                {$option_values}
                                        {/if}
                                    {else}
                                        {if $DATATYPE.0.$option_values eq 'M'}
                                                {$option_values}    *
                                        {else}
                                                {$option_values}
                                        {/if}
                                    {/if}
            					 </option>
                                {/foreach}
                            {/foreach}
                                    {$CHOOSECOLUMN9}
                            </select>
                         </td>
            		     <td>&nbsp;</td>
            		     <td>&nbsp;</td>
            		     <td>&nbsp;</td>
            		</tr>
                {/if}
            {/if}
    		<tr><td colspan="4">&nbsp;</td></tr>
        </table>
        <table class="settingPopTable lasttdbordernon d" border="0" cellpadding="0" cellspacing="0" width="100%">
            <tbody>
                <tr>
                    {if $STDCOLUMNSCOUNT neq 0}
                        <td style="width: 100px;border-right: none;" nowrap class="dvtSelectedCellCommon dvtSelectedCell" id="pi" onclick="fnLoadCvValues('pi','mi','dv_customview_stdfiler','mnuTab2')">
                        <b>{'Basic_queries'|@getFixedLabel}</b>
                        </td>
                        <td class="dvtUnSelectedCell" style="width: 100px;" align="center" nowrap id="mi" onclick="fnLoadCvValues('mi','pi','mnuTab2','dv_customview_stdfiler')">
                        <b>{'Advanced_Search'|@getFixedLabel}</b>
                        </td>
                    {else}
                        <td class="dvtSelectedCellCommon dvtSelectedCell" style="width: 100px;" align="center" nowrap id="mi">
                        <b>{'Advanced_Search'|@getFixedLabel}</b>
                        </td>
                    {/if}
                    <td class="dvtTabCache" nowrap style="width:55%;">&nbsp;</td>
                </tr>
            </tbody>
        </table>
        <table class="settingPopTable lasttdbordernon e" border="0" cellpadding="0" cellspacing="0" width="100%">
            <tbody>
                <tr>
                    <td align="left" valign="top" style="padding: 0;">
                        {if $STDCOLUMNSCOUNT neq 0}
                            {assign var=stddiv value="style=display:none"}
                            {assign var=advdiv value="style=display:block"}
                        {else}
                            {assign var=stddiv value="style=display:block"}
                            {assign var=advdiv value="style=display:none"}
                        {/if}
                        <div id="dv_customview_stdfiler" {$stddiv}>
                            <table class="settingPopTable lasttdbordernon f" border="0" cellpadding="0" cellspacing="0" width="100%">
                                <tr>
                                    <td colspan="2" class="f1"><b>{'EASYTIMEFILTER'|@getFixedLabel}</b></td>
                                </tr>
{*                                {include file="standardFilterPick.tpl"}*}
                                <tr>
                                    <td align="right">{'Start_Date'|@getFixedLabel} </td>
                                    <td width="25%" align="left">
                                    {if $STDFILTERCRITERIA.0.selected eq "selected" || $CUSTOMVIEWID eq ""}
                                    {assign var=img_style value="visibility:visible"}
                                    {assign var=msg_style value=""}
                                     {else}
                                    {assign var=img_style value="visibility:hidden"}
                                    {assign var=msg_style value="readonly"}
                                     {/if}
                                     <input name="startdate" id="jscal_field_date_start" type="text" size="15" readonly="readonly" class="Wdate" value="{$STARTDATE}" {$msg_style} onClick="WdatePicker()">
                                     <font size=1><em old="(yyyy-mm-dd)">({$DATEFORMAT})</em></font>
                                     </td>
                                </tr>
                              <tr>
                                 <td align="right">{'End_Date'|@getFixedLabel} </td>
                                 <td width="25%" align="left">
                                 <input name="enddate" {$msg_style} id="jscal_field_date_end" type="text" size="15" readonly="readonly" class="Wdate" value="{$ENDDATE}" onClick="WdatePicker()">
                                 <font size=1><em old="(yyyy-mm-dd)">({$DATEFORMAT})</em></font>
                                 </td>
                              </tr>
                            </table>
                        </div>
                        <div id="mnuTab2" {$advdiv} >
                            <table class="settingPopTable lasttdbordernon g" border="0" cellpadding="0" cellspacing="0" width="100%">
                                <tr>
                                    <td style="padding:0;">
                                        {* @edit:liushuai @date:2020-07-09 @reason: 0041912/群发邮件模块高级查找*}
                                        {if $GROUPEMAIL eq 'Emails'}
                                            {include file='AdvanceFilterNew.tpl' SOURCE='customview'}
                                        {else}
                                            {include file='AdvanceFilterCustView.tpl' SOURCE='customview'}
                                        {/if}
                                    </td>
                                </tr>
                            </table>
                        </div>
                    </td>
                </tr>
            </tbody>
        </table>
    </form>
</div>
{$STDFILTER_JAVASCRIPT}
{$JAVASCRIPT}
<!-- to show the mandatory fields while creating new customview -->
<script language="javascript" type="text/javascript">
var k;
var colOpts;
var manCheck = new Array({$MANDATORYCHECK});

var viewCopy='{$viewCopy}';
var groupeamil_name='{$GROUPEMAIL}';  //原来判断是否是群发短信或者群发邮件模块 Liver 2016/06/01
var vienamenotemptyLabel='{'VIEWNAMECANNOTEMPTY'|@getFixedLabel}';
{literal}

if(document.CustomView.record.value == ''&& viewCopy=="NoCopy") {
	for(k=0;k<manCheck.length;k++) {
		selname = "column"+(k+1);
		selelement = document.getElementById(selname);
		if(selelement == null || typeof selelement == 'undefined') continue;
		colOpts = selelement.options;
		for (l=0;l<colOpts.length;l++) {
			if(colOpts[l].value == manCheck[k]) {
				colOpts[l].selected = true;
			}
		}
	}
}
/**
edit:can
reason:序时簿头列头不带明细判断列头至少有一个字段
**/
 function  columnHeaderCheck()
 {
    if(document.CustomView.more_listview != undefined && document.CustomView.more_listview.value == 2)
    {
        return true;
    }
     if (trim(document.CustomView.viewName.value) == "")
     {
        var confirm_str = vienamenotemptyLabel;
        RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
        return false;
     }
    var isEmpty=true;
    for(var i=1;i<=9;i++)
    {
        var obj=document.getElementById('column'+i);
        if(obj.options[obj.selectedIndex].value!='')
        {
            isEmpty=false;
            break;
        }
    }
    if(isEmpty)
    {
        var confirm_str = arrJsPopLabel['PLEASESELECTFIELD'];
        RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
        return false;
    }
    return true;
 }
function validateCV() {

    if(getObj('group').value!='')
    {

        if(checkAdvancedFilter()==false)
        {
            return false;
        }
    }
    else{

        if(checkDuplicate()) {
		  if( checkAdvancedFilter()==false)
          {
            return false;
          }
	   }
       else
       {
        return false;
       }
    }

	checkViewNameDup();
	return false;
}
//edit:can reason:判断视图名称是否重复,bug:10932: 客户中创建分类异常

function checkViewNameDup()
{
     var record=document.forms['CustomView'].record.value;
     var viewname=encodeURIComponent(document.forms['CustomView'].viewName.value);
     if(groupeamil_name=='MassSMS' || groupeamil_name=='Emails'){
       var module = groupeamil_name;
     }
     else{
        var module=document.forms['CustomView'].cvmodule.value;
     }
      new Ajax.Request
        (
        		'index.php',
        		{
        			queue: {
        				position: 'end',
        				scope: 'command'
        			},
        			method: 'post',
        			postBody:"module=CustomView&action=Save&record="+record+"&cvmodule="+module+"&viewName="+viewname+"&repeat=1&ReportHeader=dheader",
        			onComplete: function(response)
                    {
                        if(response.responseText.indexOf('###error####')>=0)
                        {
                            var confirm_str = viewnamelabel+arrJsPopLabel['CANOTREPEATED'];
                            RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);

                        }
                        else
                        {

						  document.forms['CustomView'].submit();

                        }
                    }
                }
          )
}
function checkDuplicate() {
    if($('jscal_field_date_start').value > $('jscal_field_date_end').value)
    {
        var confirm_str = arrJsPopLabel['STARTDATECANOTGREATERENDDATE'];
        RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
        return false;
    }
    if(document.getElementById('more_listview') != undefined && document.getElementById('more_listview').value == 1)
    {
        return true;
    }
	if(getObj('viewName').value.toLowerCase() == 'all') {
        var confirm_str = arrJsPopLabel['CANOTUSERNAMEOFALL'];
        RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
		return false;
	}

	var cvselect_array = new Array('column1','column2','column3','column4','column5','column6','column7','column8','column9')
	for(var loop=0;loop < cvselect_array.length-1;loop++) {
		selected_cv_columnvalue = $(cvselect_array[loop]).options[$(cvselect_array[loop]).selectedIndex].value;
		if(selected_cv_columnvalue != '') {
			for(var iloop=loop+1;iloop < cvselect_array.length;iloop++) {
				selected_cv_icolumnvalue = $(cvselect_array[iloop]).options[$(cvselect_array[iloop]).selectedIndex].value;
				if(selected_cv_columnvalue == selected_cv_icolumnvalue) {
					{/literal}
                        var confirm_str = '{'COLNOTDUPLICATE'|@getFixedLabel}';
                        RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
                        $(cvselect_array[iloop]).selectedIndex = 0;
                        return false;
					{literal}
				}

			}
		}
	}
	return true;
}

function stdfilterdateValidate()
{

	if(!dateValidate("startdate",arrJsPopLabel['STANDARDRULES']+" - "+arrJsPopLabel['STARTDATE'],"OTH"))
	{

		getObj("startdate").focus()
		return false;
	}
	else if(!dateValidate("enddate",arrJsPopLabel['STANDARDRULES']+" - "+arrJsPopLabel['ENDDATE'],"OTH"))
	{

		getObj("enddate").focus()
		return false;
	}
	else
	{

		if (!dateComparison("enddate",arrJsPopLabel['STANDARDRULES']+" - "+arrJsPopLabel['ENDDATE'],"startdate",arrJsPopLabel['STANDARDRULES']+" - "+arrJsPopLabel['STARTDATE'],"GE"))
         {

                        getObj("enddate").focus()
                        return false
         }
           else return true;
	}
}
standardFilterDisplay();
{/literal}
</script>