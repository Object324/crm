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
<!--修改编码格式:统一编码：UTF-8-->
-->*}

{*<!-- module header -->*}

<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/ListView.js"></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/search.js"></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/Merge.js"></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/dtlviewajax.js"></script>

<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/vtlib.js"></script>

<script language="javascript" type="text/javascript">
var typeofdata = new Array();
typeofdata['E'] = ['e','n','s','ew','c','k','isnull','isnotnull'];
typeofdata['V'] = ['e','n','s','ew','c','k','isnull','isnotnull'];
typeofdata['N'] = ['e','n','l','g','m','h','isnull','isnotnull'];
typeofdata['NN'] = ['e','n','l','g','m','h','isnull','isnotnull'];
typeofdata['T'] = ['e','n','l','g','m','h','isnull','isnotnull'];
typeofdata['I'] = ['e','n','l','g','m','h','isnull','isnotnull'];
typeofdata['C'] = ['e','n'];
typeofdata['DT'] = ['e','n','l','g','m','h','isnull','isnotnull'];
typeofdata['D'] = ['e','n','l','g','m','h','isnull','isnotnull'];
var fLabels = new Array();
/*
fLabels['e'] = "{$APP.is}";
fLabels['n'] = "{$APP.is_not}";
fLabels['s'] = "{$APP.begins_with}";
fLabels['ew'] = "{$APP.ends_with}";
fLabels['c'] = "{$APP.contains}";
fLabels['k'] = "{$APP.does_not_contains}";
fLabels['l'] = "{$APP.less_than}";
fLabels['g'] = "{$APP.greater_than}";
fLabels['m'] = "{$APP.less_or_equal}";
fLabels['h'] = "{$APP.greater_or_equal}";*/
fLabels['e'] = '{'EQ'|@getFixedLabel}';
fLabels['n'] = '{'NEQ'|@getFixedLabel}';
fLabels['c'] = '{'IN'|@getFixedLabel}';
fLabels['k'] = '{'NOT_IN'|@getFixedLabel}';
fLabels['l'] = '{'LT'|@getFixedLabel}';
fLabels['g'] = '{'GT'|@getFixedLabel}';
fLabels['m'] = '{'LE'|@getFixedLabel}';;
fLabels['h'] = '{'GE'|@getFixedLabel}';
fLabels['bw'] = '{'Interval'|@getFixedLabel}';
fLabels['b'] = '{'Before'|@getFixedLabel}';
fLabels['a'] = '{'After'|@getFixedLabel}';
fLabels['isnull'] = '{'ISNULL'|@getFixedLabel}';
fLabels['isnotnull'] = '{'ISNOTNULL'|@getFixedLabel}';
var noneLabel;
{literal}

{/literal}
</script>
<script language="JavaScript" type="text/javascript" src="modules/{$MODULE}/{$MODULE}.js"></script>
<script language="javascript">
function callSearch(searchtype)
{ldelim}
	for(i=1;i<=26;i++)
    	{ldelim}
        	var data_td_id = 'alpha_'+ eval(i);
        	getObj(data_td_id).className = 'searchAlph';
    	{rdelim}
    	gPopupAlphaSearchUrl = '';
	search_fld_val= $('bas_searchfield').options[$('bas_searchfield').selectedIndex].value;
    var search_text_value = trim(document.basicSearch.search_text.value);
	search_txt_val= encodeURIComponent(search_txt_val);
    var searchScope= encodeURIComponent(document.getElementById("SmOwnerSearchScope").options[document.getElementById("SmOwnerSearchScope").options.selectedIndex].value);
        var urlstring = '';
        if(searchtype == 'Basic')
        {ldelim}
            if(search_txt_val=='')
            {ldelim}
				var fldarr = search_fld_val.split(':');
				if('D' != fldarr[fldarr.length-1]){ldelim}
                    document.basicSearch.search_text.blur();
                    var confirm_str = arrJsPopLabel['PLEASEENTERKEYWORDTOSEARCH'];
                    RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
				    return false;
				{rdelim}
            {rdelim}
        
        		var p_tab = document.getElementsByName("parenttab");
                urlstring = 'search_field='+search_fld_val+'&searchtype=BasicSearch&search_text='+search_txt_val+'&';
                urlstring=urlstring+'SearchScope='+searchScope+'&';
                urlstring = urlstring + 'parenttab='+p_tab[0].value+ '&';
        {rdelim}
        else if(searchtype == 'Advanced')
        {ldelim}
        		checkAdvancedFilter();
				var advft_criteria = $('advft_criteria').value;
				var advft_criteria_groups = $('advft_criteria_groups').value;
				urlstring += '&advft_criteria='+advft_criteria+'&advft_criteria_groups='+advft_criteria_groups+'&';
				urlstring=urlstring+'SearchScope='+searchScope+'&';
                urlstring += 'searchtype=advance&'
        {rdelim}
	$("status").style.display="inline";
	new Ajax.Request(
		'index.php',
		{ldelim}queue: {ldelim}position: 'end', scope: 'command'{rdelim},
			method: 'post',
			postBody:urlstring +'query=true&file=index&module={$MODULE}&action={$MODULE}Ajax&ajax=true&search=true',
			onComplete: function(response) {ldelim}
								$("status").style.display="none";
                                result = response.responseText.split('&#&#&#');
                                $("ListViewContents").innerHTML= result[2];
                                if(result[1] != '')
                                RemindsMsg("","LdPopWidth400px","","yes","",result[1]);
								$('basicsearchcolumns').innerHTML = '';
			{rdelim}
	       {rdelim}
        );
	return false
{rdelim}
function alphabetic(module,url,dataid)
{ldelim}
        for(i=1;i<=26;i++)
        {ldelim}
                var data_td_id = 'alpha_'+ eval(i);
                getObj(data_td_id).className = 'searchAlph';

        {rdelim}
        getObj(dataid).className = 'searchAlphselected';
	$("status").style.display="inline";
	new Ajax.Request(
		'index.php',
		{ldelim}queue: {ldelim}position: 'end', scope: 'command'{rdelim},
			method: 'post',
			postBody: 'module='+module+'&action='+module+'Ajax&file=index&ajax=true&search=true&'+url,
			onComplete: function(response) {ldelim}
				$("status").style.display="none";
				result = response.responseText.split('&#&#&#');
				$("ListViewContents").innerHTML= result[2];
				if(result[1] != '')
			                RemindsMsg("","LdPopWidth400px","","yes","",result[1]);
				$('basicsearchcolumns').innerHTML = '';
			{rdelim}
		{rdelim}
	);
{rdelim}

</script>

<div id="searchingUI" style="display:none;">
        <table border=0 cellspacing=0 cellpadding=0 width=100%>
        <tr>
                <td align=center>
                <img src="{'searching.gif'|@lingdang_imageurl:$THEME}" alt="{$APP.LBL_SEARCHING}"  title="{$APP.LBL_SEARCHING}">
                </td>
        </tr>
        </table>

</div>


{*<!-- Contents -->*}
<table border=0 cellspacing=0 cellpadding=0 width=100% align=center>
    <tr>
	<td valign="top" width=100%>
	 <!-- SIMPLE SEARCH -->
{if $SEATCH_INPUT.searchtype == 'BasicSearch'}
<div id="searchAcc" style="display: inline;/*position:relative;*/">
{else}
<div id="searchAcc" style="display: none;/*position:relative;*/">
{/if}
<form name="basicSearch" method="post" action="index.php" onSubmit="return callSearch('Basic');">
<table width="100%" cellpadding="5" cellspacing="0"  class="searchUIBasicTable" align="center" border=0>
	<tr class="basicserachtr">
        <td class="searchUIName" align="left">
		<span class="searctype">{'Basic_queries'|@getFixedLabel}</span>
        <span class="searctypechangge"><a href="javascript:void(0);" onClick="fnhide('searchAcc');show('advSearch');document.basicSearch.searchtype.value='advance';">{'Advanced_Search2'|@getFixedLabel}&gt;&gt;</a></span>
		</td>
        <td valign="top" style="font-size: 15px;" onMouseOver="this.style.cursor='pointer';" onclick="moveMe('searchAcc');searchshowhide('searchAcc','advSearch')">[x]</td>
    </tr>
    <tr class="basicsearchfield">
		<td colspan="2">
            <table cellpadding="0">
                <tbody>
                <tr>
                <td class="basicserachtrtd">{'Find_field'|@getFixedLabel}</td>
                <td class="basicserachtrtd">
                    <div id="basicsearchcolumns_real">
        			<select name="search_field" id="bas_searchfield" style="width:150px">
        			 {html_options  options=$SEARCHLISTHEADER selected=$SEATCH_INPUT.search_field}
        			</select>
        			</div>
                    <input type="hidden" name="searchtype" value="BasicSearch">
                    <input type="hidden" name="module" value="{$MODULE}" id="curmodule">
        			<input name="maxrecords" type="hidden" value="{$MAX_RECORDS}" id='maxrecords'>
                    <input type="hidden" name="parenttab" value="{$CATEGORY}">
        			<input type="hidden" name="action" value="index">
                    <input type="hidden" name="query" value="true">
        			<input type="hidden" name="search_cnt">
					<input type="hidden" value="{$BATCHNUM}" id='batchnum' />
                </td>
                <td class="basicserachtrtd">{'Find_Keyword'|@getFixedLabel}</td>
                <td class="basicserachtrtd"><input type="text"  class="txtBox" style="width:120px" name="search_text" value="{$SEATCH_INPUT.search_text}" onkeyup="searchSubmit(event,'Basic')"/></td>
                <td><input name="submit" type="button" class="createauto" onClick="callSearch('Basic');" value="{'FINDNOW'|@getFixedLabel}"/></td>
                </tr>
                </tbody>
            </table>
        </td>
	</tr>
	<tr>
		<td colspan="2" align="center" style="padding: 0px;">
			<table border=0 cellspacing=0 cellpadding=0 width=100% style="border-bottom: 1px solid #ededed;">
				<tr>
                     {$ALPHABETICAL}
                </tr>
            </table>
		</td>
	</tr>
</table>
</form>
</div>

<!-- ADVANCED SEARCH -->
{if $SEATCH_INPUT.searchtype == 'advance'}
<div id="advSearch" style="display:inline;">
{else}
<div id="advSearch" style="display:none;">
{/if}
<form name="advSearch" method="post" action="index.php" onSubmit="return callSearch('Advanced');">
	<table width="100%" cellspacing="0" cellpadding="5" border="0">
		<tr class="basicserachtr">
			<td class="searchUIName" nowrap align="left" width="90%">
                <span class="searctype">{'Advanced_Search'|@getFixedLabel}</span>
                <span class="searctypechangge"><a href="javascript:void(0);" onClick="show('searchAcc');fnhide('advSearch')">{'Go'|@getFixedLabel} {'LOWER_BASIC_QUERY'|@getFixedLabel}</a></span>
            </td>
			<td align="right" style="font-size: 15px;" valign="top" onMouseOver="this.style.cursor='pointer';" onclick="moveMe('searchAcc');searchshowhide('searchAcc','advSearch')">[x]</td>
		</tr>
	</table>
	<table cellpadding="2" cellspacing="0" width="100%" align="center" border="0" style="background:#F4F4F4;">
		<tr>
			<td align="center" width="90%" style="vertial-align:bottom">
				{include file='AdvanceFilter.tpl' SOURCE='customview' PAGEMODE='list' COLUMNS_BLOCK=$FIELDNAMES}
			</td>
		</tr>
	</table>

	<table border=0 cellspacing=0 cellpadding=5 width=100% align="center" style="background:#FBFBFB;">
		<tr>
			<td align="center">
            <input type="button" class="createauto" value="{'FINDNOW'|@getFixedLabel}" onClick="callSearch('Advanced');">
            <input type="button" class="createauto" value="{'NEWCOMBINATION'|@getFixedLabel}" onclick="addNewConditionGroup('adv_filter_div')" />
			</td>
		</tr>
	</table>
</form><br>
</div>
{*<!-- Searching UI -->*}
 
 <div id="mergeDup" style="z-index:0;display:none;position:relative;">
	{include file="MergeColumns.tpl"}
</div>
 
	   <!-- PUBLIC CONTENTS STARTS-->
	  <div id="ListViewContents" style="width:100%;">
	 		{include file="DocumentsListViewEntries.tpl"}
      </div>

     </td>
   </tr>
</table>

<!-- Add new Folder UI for Documents module starts -->

<script language="JavaScript" type="text/javascript" src="modules/Documents/Documents.js"></script>
<div id="orgLay" class="D_pop_box LdPopWidth400px" style="display:none;">
    <div class="D_pop_tit">
    	<strong class="D_ptita">{'ADDFOLDER'|@getFixedLabel}</strong>
        <a href="javascript:closeFolderCreate();" class="D_ptitc">
            <img class="D_ptitcimg" src="themes/icon/pop_close.png" alt="{'CLOSE'|@getFixedLabel}" title="{'CLOSE'|@getFixedLabel}"/>
        </a>
    </div>
    	<table class="D_pop_bod" cellspacing="1" cellpadding="1" border="0">
          <tr>
            <td align="right"><font color="red">*</font>{'Folder_name'|@getFixedLabel}:</td>
            <td>
				<input id="folder_id" name="folderId" type="hidden" value=''/>
				<input id="fldrsave_mode" name="folderId" type="hidden" value='save'/>                    
				<input id="folder_name" name="folderName"  type="text" style="border:1px solid #eee"/>
                &nbsp;&nbsp;{'20word_limit'|@getFixedLabel}
            </td>
          </tr>
          <tr>
            <td align="right">{'DESCRIPTION'|@getFixedLabel}:</span></td>
            <td>
                <input id="folder_desc" name="folderDesc" type="text" style="border:1px solid #eee"/>
                &nbsp;&nbsp;{'50word_limit'|@getFixedLabel}
            </td>
          </tr>
        </table>
    <div class="D_pbtn">
    	<input type="button" class="D_pbtnok" value="{'SAVE'|@getFixedLabel}" onclick="AddFolder();"/><span>&nbsp;</span>
        <input type="button" class="D_pbtncancel" value="{'CANCEL'|@getFixedLabel}" onclick="closeFolderCreate();"/> 
    </div>
</div>

<div id="sortview" class="D_pop_box LdPopWidth240px" style="display:none;">
<div id="sortview_form_div"></div>
</div>

<!--修改负责人-->
<div id="smowneredit" class="D_pop_box LdPopWidth400px" style="display:none;">
<div id="smowneredit_form_div"></div>
</div>

<div id="SubmitApprove" class="D_pop_box LdPopWidth400px" style="display:none;"></div>
<!-- Add new folder UI for Documents module ends -->