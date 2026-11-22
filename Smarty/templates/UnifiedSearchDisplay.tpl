{*<!--
/*+*******************************************************************************
 * The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 *********************************************************************************/

-->*}
<!--修改编码格式:统一编码：UTF-8-->

<script language="JavaScript" type="text/javascript" src="include/js/search.js"></script>

{if $MODULE eq 'Contacts'}
{$IMAGELISTS}
<script language="JavaScript" type="text/javascript" src="include/js/thumbnail.js"></script>
<div id="dynloadarea" style="float:left;position:absolute;left:350px;top:150px;"></div>
{/if}
{if $BANKACCOUNTSET_JS == '1'}
	<script language="JavaScript" type="text/javascript" src="include/js/modules/BankAccountSet/BankAccountSet.js"></script>
{/if}
<div id="searchResultContainerId">
<input name="globalSearchText" id="globalSearchText" type="hidden" value="{$SEARCH_STRING}" />
<input name="tagSearchText" id="tagSearchText" type="hidden" value="{$TAG_SEARCH}" />
{include file='UnifiedSearchAjax.tpl'}
</div>
<script type="text/javascript">

{literal}

function quickSearch_ReportLog(module,url)
{
    getUnifiedSearchEntries_jss('',module,url);
}
 function quickSearchList_js(module,url)
 {
 
    getUnifiedSearchEntries_jss('',module,url);

 }
function getUnifiedSearchEntries_js(search,module,url)
{
    getUnifiedSearchEntries_jss(search,module,url);
    
}
    function getUnifiedSearchEntries_jss(search,module,url){
    	var qryStr = document.getElementsByName('search_criteria')[0].value;
    	var recordCount = document.getElementById(module+'RecordCount').value;
        var refmodule=module;
        //edit:can 2020-09-20 42673: （http://xiaoshou360.com/KH/chongwen [^]）（江苏崇文知识产权服务有限公司客户问题）使用电话小管家登录>输入“苏州”进行快速查找>查找后点击翻页：结果点击翻页的那个模块消失了。
		var surl = "index.php?module="+module+"&search_tag="+search+"&action="+module+"Ajax&file=UnifiedSearch&ajax=true&"+url+
    			'&query_string='+encodeURIComponent(qryStr)+'&search_onlyin='+encodeURIComponent('--USESELECTED--')+'&recordCount='+recordCount+'&refmodule='+refmodule;
		
        ldAjax(surl,"",function(data){
			if(data.code == 1){
				$('global_list_'+refmodule).innerHTML = data.result.content;
				DelProgressObjs();
                var popupobj = CrmPopup.getPopupObj('last');
                var resizetableobj = popupobj.modulelistresizeobj[module];
                resizetableobj.setReiszeTable_Init(module, '');
                setUnifiedSearchListViewHeight(module);
			}
		})
    	
    }
{/literal}

</script>