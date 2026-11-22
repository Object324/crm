
<script type='text/javascript'>
{literal}

function isRelatedListBlockLoadeds(id,urldata){
	var elem = document.getElementById(id);
	if(elem == null || typeof elem == 'undefined' || urldata.indexOf('order_by') != -1 ||
		urldata.indexOf('start') != -1 || urldata.indexOf('withCount') != -1){
		return false;
	}
	var tables = elem.getElementsByTagName('table');
	return tables.length > 0;
}

function loadRelatedListBlocks(urldata,target,imagesuffix) {

	var showdata = 'show_'+imagesuffix;
	var showdata_element = $(showdata);

	var hidedata = 'hide_'+imagesuffix;
	var hidedata_element = $(hidedata);
	if(isRelatedListBlockLoadeds(target,urldata) == true){
		$(target).show();
		showdata_element.hide();
      	hidedata_element.show();
		$('delete_'+imagesuffix).show();
		return;
	}
	var indicator = 'indicator_'+imagesuffix;
	var indicator_element = $(indicator);
	indicator_element.show();
	$('delete_'+imagesuffix).show();
	
	var target_element = $(target);
	new Ajax.Request(
		'index.php',
        {queue: {position: 'end', scope: 'command'},
                method: 'post',
                postBody: urldata,
                onComplete: function(response) {
					var responseData = trim(response.responseText);
      				target_element.update(responseData);
					target_element.show();
      				showdata_element.hide();
      				hidedata_element.show();
      				indicator_element.hide();
					if($('return_module').value == 'Campaigns'){
						var obj = document.getElementsByName(imagesuffix+'_selected_id');
						var relatedModule = imagesuffix.replace('Campaigns_',"");
						$(relatedModule+'_count').innerHTML = numofRows;
						if(selectallActivation == 'true'){
							$(imagesuffix+'_selectallActivate').value='true';
							$(imagesuffix+'_linkForSelectAll').show();
							$(imagesuffix+'_selectAllRec').style.display='none';
							$(imagesuffix+'_deSelectAllRec').style.display='inline';
							var exculdedArray=excludedRecords.split(';');
							if (obj) {
								var viewForSelectLink = showSelectAllLink(obj,exculdedArray);
								$(imagesuffix+'_selectCurrentPageRec').checked = viewForSelectLink;
								$(imagesuffix+'_excludedRecords').value = $(imagesuffix+'_excludedRecords').value+excludedRecords;
							}
						}else{
							$(imagesuffix+'_linkForSelectAll').hide();
							rel_toggleSelect(false,imagesuffix+'_selected_id',relatedModule);
						}
						updateParentCheckbox(obj,imagesuffix);
					}
				}
        }
	);
}

function hideRelatedListBlocks(target, imagesuffix) {
	
	var showdata = 'show_'+imagesuffix;
	var showdata_element = $(showdata);
	
	var hidedata = 'hide_'+imagesuffix;
	var hidedata_element = $(hidedata);
	
	var target_element = $(target);
	if(target_element){
		target_element.hide();
	}
	hidedata_element.hide();
	showdata_element.show();
	$('delete_'+imagesuffix).hide();
}

function disableRelatedListBlocks(urldata,target,imagesuffix){
	var showdata = 'show_'+imagesuffix;
	var showdata_element = $(showdata);

	var hidedata = 'hide_'+imagesuffix;
	var hidedata_element = $(hidedata);

	var indicator = 'indicator_'+imagesuffix;
	var indicator_element = $(indicator);
	indicator_element.show();
	
	var target_element = $(target);
	new Ajax.Request(
		'index.php',
        {queue: {position: 'end', scope: 'command'},
                method: 'post',
                postBody: urldata,
                onComplete: function(response) {
					var responseData = trim(response.responseText);
					target_element.hide();
					$('delete_'+imagesuffix).hide();
      				hidedata_element.hide();
					showdata_element.show();
      				indicator_element.hide();
				}
        }
	);
}

{/literal}
</script>
<table class="bgwhite" border=0 cellspacing=0 cellpadding=0 width=100%>
	<tr valign=top>
       <td style="padding:5px" >
			<!-- Command Buttons -->
			<table border=0 cellspacing=0 cellpadding=0 width=100%>
                <!-- NOTE: We should avoid form-inside-form condition, which could happen when
                Singlepane view is enabled. -->
            {if $PUBLICACCOUNT >0 }
            {assign var=count value=1}
            <div style="position:absolute;z-index:1000;right:40%;"><img src='themes/softed/images/publicaccount.png' /></div>
            {/if}
      
            {if $APPROVESTATUS neq ''}
				{assign var=count value=1}
				<div style="position:absolute;right:30%;"><img src="{$APPROVESTATUS}"/> </div>
            {/if}
			<form action="index.php" method="post" name="DetailView" id="form">	
            															
            	{include file='DetailViewHidden.tpl'}
                    <input type="hidden" name="SearchScope" id="SearchScopeDetail" value="{$SEARCHSCOPE}"/>
    	        {include file='MainDetailFields.tpl'}
                <!--添加评论 by LD Can 20130205 -->
				{* vtlib Customization: Embed DetailViewWidget block:// type if any *}
				{if $CUSTOM_LINKS && !empty($CUSTOM_LINKS.DETAILVIEWWIDGET)}
					{foreach item=CUSTOM_LINK_DETAILVIEWWIDGET from=$CUSTOM_LINKS.DETAILVIEWWIDGET}
						{if preg_match("/^block:\/\/.*/", $CUSTOM_LINK_DETAILVIEWWIDGET->linkurl)}
							<tr>
								<td style="padding:5px;" >
									{php}
                                       echo vtlib_process_widget($this->_tpl_vars['CUSTOM_LINK_DETAILVIEWWIDGET'], $this->_tpl_vars);
									{/php}
								</td>
							</tr>
						{/if}
					{/foreach}
				{/if}
				{* END *}
				<!-- Inventory - Product Details informations -->
				<tr>
					{$ASSOCIATED_PRODUCTS}
				</tr>
               
            {if $MODULE eq 'Calendar'}
            {include file= 'ActivityDetailView.tpl'}
            {/if}
			</form>
            {if $MODULE eq "Expense"}
            <tr>
                
                    {include file="modules/Expense/DetailList.tpl"}
               
            </tr>
            {/if}
            
            {if $MODULE eq "CashBill"}
            <tr>
                <td style="padding:5px;width:100%;">
			    {include file="modules/CashBill/DetailPaymentList.tpl"}
                </td>
            </tr>
		    {/if}
            {if $MODULE eq "SendCashBill"}
            <tr>
                <td style="padding:5px;width:100%;">
			    {include file="modules/SendCashBill/DetailPaymentList.tpl"}
                </td>
            </tr>
		    {/if}
			<!-- End the form related to detail view -->
            {if $APPROVE|@count neq 0}
              <tr>
				<td style="padding:5px;" width="80%">
		          <!--table border=0 cellspacing=0 cellpadding=0 width=100%>
                    <tr>
                     <td>
                        <table class="small" width="100%" cellspacing="0" cellpadding="0" border="0">
                            <tbody>
                                <tr>
                                    <td class="dvInnerHeader" colspan="4">
                                    <div style="float:left;font-weight:bold;float:left;">
                                     <b>审批历史</b>
                                    </div>
                                    </td>
                                </tr>
                            </tbody>
                        </table-->
                        <table border=0 cellspacing=0 cellpadding=0 width=100%>
                                    <tr>
                                     <td class="dvInnerHeader">
{*
                                    edit:andrew
                                    20140103
                                    添加审批历史现实隐藏
                                    *}
						<div style="font-weight: bold;height: 1.75em;">
                <div style="float: right;width: 2em;">
					<a href="javascript:disableRelatedListBlocks('','appStaus','SalesOrder_App');">
						<img id="delete_SalesOrder_App" style="display:none;" src="themes/images/windowMinMax.gif" border="0" align="absmiddle" />
					</a>
				</div>
				<span>
					<a class="icon-homeimg icon-inactivate" id="show_SalesOrder_App" href="javascript:loadRelatedListBlocks('','appStaus','SalesOrder_App');" title="{'DISPLAY'|@getFixedLabel}" style="display:none;"></a>
					<a class="icon-homeimg icon-activate" id="hide_SalesOrder_App"  href="javascript:hideRelatedListBlocks('appStaus','SalesOrder_App');" title="{'HIDDEN'|@getFixedLabel}"></a>
				</span>{'APPROVALHISTORY'|@getFixedLabel}
                <img id="indicator_SalesOrder_App" style="display:none;" src="themes/images/vtbusy.gif" border="0" align="absmiddle" />
							</div>
		              </td></tr>
                                    <tr>          
                                    <td id="appStaus">                                   
                                    {include file= 'Approve/ApproveLogEntries.tpl'}
                                    </td>
                                    </tr>
                 </table>
            </td>
           </tr>
          {/if}
		  </table>
		</td>
      </tr>
  </table>