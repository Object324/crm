{*<!--
/*+********************************************************************************
  * The contents of this file are subject to the lingdang CRM Public License Version 1.0
  * ("License"); You may not use this file except in compliance with the License
  * The Original Code is:  lingdang CRM Open Source
  * The Initial Developer of the Original Code is lingdang.
  * Portions created by lingdang are Copyright (C) lingdang.
  * All Rights Reserved.
  *********************************************************************************/
-->*}
<script type="text/javascript">

DocmentWriteJs("include/js/modules/{$RELATED_MODULE}/{$RELATED_MODULE}.js","{$RELATED_MODULE}_js")
</script>
<script language="JavaScript" type="text/javascript" src="include/js/cls_RelatedAdvanceSet.js"></script>
<div class="DivC">
    <div class="DivCNameR" style="display:none;"><!--刘总要求隐藏-->
        <div>{$RELATEDLEFTMODHREFNAME} >> {'MOREINFORMATION'|@getFixedLabel} >> </div>
        <span class="On">
            {if $RELATED_MODULE eq 'SalesOrder' && $MODULE eq 'SalesOrder'}
                {if $VERSION eq 'jijin'}
                    {'SUPERADDTION'|@getFixedLabel}
                {else}
                    {'CHANGEORDER'|@getFixedLabel}
                {/if}
            {else}
                {$RELATED_MODULE|@getTranstab}
            {/if}
        </span>
    </div>
    <div class="clear"></div>
	<div class="Top">
        {*52161（https://81mis.com/kfbcrm）合同订单SO156，相关创建发票，发票金额1，保存后界面显示2个拖动条*}
		<table class="bgwhite" name="related_list_top_{$RELATED_MODULE}" width="100%" border="0" cellspacing="0" cellpadding="0" style="width:{if $RELATEDLISTDATA.total_width >0}{$RELATEDLISTDATA.total_width}px;{else}100%{/if}">
			<tr>
				<td class="DivCL a" style="width: 70%;">
	        		<ul class="D_btn_box d">
	          			<li class="D_anu_a">
	    					{$RELATEDLISTDATA.CUSTOM_BUTTON}
	          			</li>
	  					{if $HEADER eq 'Contacts' && $MODULE neq 'Campaigns' && $MODULE neq 'Accounts' && $MODULE neq 'Potentials' && $MODULE neq 'Products' && $MODULE neq 'Vendors'}
		  					{if $MODULE eq 'Calendar'}
				              	<li class="D_anu_a">
				    				<input alt="{$APP.LBL_SELECT_CONTACT_BUTTON_LABEL}" title="{$APP.LBL_SELECT_CONTACT_BUTTON_LABEL}" accessKey="" class="edit" value="{$APP.LBL_SELECT_BUTTON_LABEL} {$APP.Contacts}" LANGUAGE=javascript onclick='return window.open("index.php?module=Contacts&return_module={$MODULE}&action=Popup&popuptype=detailview&select=enable&form=EditView&form_submit=false&recordid={$ID}{$search_string}","test","width=640,height=602,resizable=0,scrollbars=0");' type="button"  name="button">
				              	</li>
		  					{elseif $MODULE neq 'Services' && $MOREPERMISSION eq 'yes'}
				              	<li class="D_anu_a">
				    				<input title="{$APP.LBL_ADD_NEW} {$APP.Contact}" accessyKey="F" class="createauto" onclick="this.form.action.value='EditView';this.form.module.value='Contacts'" type="submit" name="button" value="{$APP.LBL_ADD_NEW} {$APP.Contact}">
				              	</li>
		  					{/if}
	  					{elseif $HEADER eq 'Users' && $MODULE eq 'Calendar'}
				            <li class="D_anu_a">
				    			<input title="Change" accessKey="" tabindex="2" type="button" class="editauto" value="{$APP.LBL_SELECT_USER_BUTTON_LABEL}" name="button" LANGUAGE=javascript onclick='return window.open("index.php?module=Users&return_module=Calendar&return_action={$return_modname}&activity_mode=Events&action=Popup&popuptype=detailview&form=EditView&form_submit=true&select=enable&return_id={$ID}&recordid={$ID}","test","width=640,height=525,resizable=0,scrollbars=0")';>
				            </li>
				  		{/if}
			          	<li class="D_anu_a" style="display:none">
			  				<a href="javascript:void(0);" style="display:none" id='refresh-{$RELATED_MODULE}' onclick='resetRelated({$RELATIONID});return false;'><span>{'REFRESH'|@getFixedLabel}</span></a>
			          	</li>
			          	{if $CUSTOMVIEW_OPTION neq ''}
				            <li class="D_anu_a" style="width: 210px;">
								<div class="SelectCustomViewlabel"><span>{'DATACATEGORY'|@getFixedLabel}</span></div>
								<div class="xiangguan">{include file='SelectCustomView.tpl'}</div>
				            </li>
							<li class="D_anu_a" tag="firstnode" id="categoryAdvsearr">
								<div><a href="javascript:void(0);" relatedid={$RELATIONID} relatetag={$RELATED_MODULE} onclick="DetailViewRelation.HighersearchPopup(event,ld(this))"><b class="icon-categorybtn categoryAdvsear-search"></b>{'CUSTOMIZESEARCH'|@getFixedLabel}</a></div>
							</li>
							{*wym 240124 XUQIU1002043 单据相关信息显示数据的查询规则可定义*}
							{if $ISADMIN eq 1 && $SHOWADVANCESET eq 1}
								<li class="D_anu_a" tag="firstnode" id="categoryAdvset">
									<a href="javascript:void(0);" relatedid={$RELATIONID} relatetag={$RELATED_MODULE} onclick="cls_RelatedAdvanceSet.getInstance().create('{$MODULE}',ld(this))"><b class="icon-categorybtn categoryAdvsear-setting" ></b>{'Relatedquerycondition'|@getFixedLabel}</a>
								</li>
							{/if}
			          	{/if}
	        		</ul>			 
	     	 	</td>
				<td class="DivCR">
					<div class="PageDiv0" style="margin-top:4px;margin-bottom:4px;">
						<div class="ld-flex-start">
	  					<div class="ld-pagenum-div">{$RELATEDLISTDATA.navigation.0}</div>
	  					{$RELATEDLISTDATA.navigation.1}
						</div>
					</div>
				</td>
			</tr>
		</table>
	</div>
	<input type="hidden" id="viewname_{$RELATED_MODULE}" name="viewname_{$RELATED_MODULE}" value= "{$VIEWID}" />
	<input type="hidden" id="hidden_related_list" name="hidden_related_list" value="yes" />
	<input type="hidden" id="hidden_start" name="hidden_start" value="{$START}" />
	<input type="hidden" id="hidden_related_module_{$RELATED_MODULE}" name="hidden_related_module_{$RELATED_MODULE}" value="{$RELATED_MODULE}" />
	<input type="hidden" id="hidden_related_id_{$RELATED_MODULE}" name="hidden_related_id_{$RELATED_MODULE}" value="{$RELATIONID}" />
	<div id="hdScrolllistentries_yy_{$RELATED_MODULE}" name="hdScrolllistentries_yy_{$RELATED_MODULE}" style="position:relative;width:{if $RELATEDLISTDATA.total_width >0}{$RELATEDLISTDATA.total_width}px;{else}100%{/if}">
		<div style=" visibility: visible; top: 194px;overflow:hidden;width:{if $RELATEDLISTDATA.total_width >0}{$RELATEDLISTDATA.total_width}px;{else}100%{/if}" id="resize_header_table_divid_{$RELATED_MODULE}">
            <div  style="float:left; padding-right:20px">                    
				<table class="listEntries" id="resize_header_tableid_{$RELATED_MODULE}"  name="resize_header_tableid_{$RELATED_MODULE}" border="0" cellspacing="1" cellpadding="0" style="width:{if $RELATEDLISTDATA.total_width >0}{$RELATEDLISTDATA.total_width}px {else}100%{/if}">
					<tr>
						{foreach key=index item=_HEADER_FIELD from=$RELATEDLISTDATA.header name=relheadforeach}
							{if $_HEADER_FIELD eq 'OPERATING'|@getFixedLabel}
								<th width="{$RELATEDTABLEWIDTH}" tag="{$index+1}">{$_HEADER_FIELD}</th>
							{else}
								<th style="width:{$RELATEDLISTDATA.fieldwidth[$index]}px" tag="{$index+1}" headermodule="{$RELATEDLISTDATA.headername.module[$index]}" headername="{$RELATEDLISTDATA.headername.fieldname[$index]}" >{$_HEADER_FIELD}</th>
							{/if}
						{/foreach}
					</tr>
				</table>
			</div>
		</div>
		<div style="overflow:auto;" id="resize_content_table_divid_{$RELATED_MODULE}" name="resize_content_table_divid_{$RELATED_MODULE}">
			<div  style="float:left;{if $RELATEDLISTDATA.total_width <= 0}padding-right:20px{/if}">
				<table class="listEntries marT-53" id="resize_content_tableid_{$RELATED_MODULE}" name="resize_content_tableid_{$RELATED_MODULE}" border="0" cellspacing="1" cellpadding="0" style="width:{if $RELATEDLISTDATA.total_width >0}{$RELATEDLISTDATA.total_width}px {else}100%{/if}">
					<tr>
						{foreach key=index item=_HEADER_FIELD from=$RELATEDLISTDATA.header name=relheadforeach}
							{if $_HEADER_FIELD eq 'OPERATING'|@getFixedLabel}
									<th width="{$RELATEDTABLEWIDTH}" tag="{$index+1}">{$_HEADER_FIELD}</th>
								{else}
									<th style="width:{$RELATEDLISTDATA.fieldwidth[$index]}px" tag="{$index+1}" headermodule="{$RELATEDLISTDATA.headername.module[$index]}" headername="{$RELATEDLISTDATA.headername.fieldname[$index]}" >{$_HEADER_FIELD}</th>
								{/if}
						{/foreach}
					</tr>
					{if $MODULE eq 'Campaigns'}
					<tr>
						<td id="{$MODULE}_{$RELATED_MODULE}_linkForSelectAll" class="linkForSelectAll" style="display:none;" colspan="200">
							<span id="{$MODULE}_{$RELATED_MODULE}_selectAllRec" class="selectall" style="display:inline;" onClick="rel_toggleSelectAll_Records('{$MODULE}','{$RELATED_MODULE}',true,'{$MODULE}_{$RELATED_MODULE}_selected_id')">{'ALLSELECT'|@getFixedLabel} <span id={$RELATED_MODULE}_count class="folder"> </span> {'RECORDS'|@getFixedLabel}</span>
							<span id="{$MODULE}_{$RELATED_MODULE}_deSelectAllRec" class="selectall" style="display:none;" onClick="rel_toggleSelectAll_Records('{$MODULE}','{$RELATED_MODULE}',false,'{$MODULE}_{$RELATED_MODULE}_selected_id')">{'DESELECTALL'|@getFixedLabel}</span>
						</td>
					</tr>
					{/if}
					{$PROHTML}
					{if $RELATEDLISTDATA.totalfldhtml !=''}
						{$RELATEDLISTDATA.totalfldhtml}
					{/if}
				</table>
			</div>
		</div>
	</div>
{if $MODULE eq 'Campaigns' && ($RELATED_MODULE eq 'Contacts' || $RELATED_MODULE eq 'Leads' || $RELATED_MODULE eq 'Accounts')
			&& $RELATEDLISTDATA.entries|@count > 0 && $RESET_COOKIE eq 'true'}
			<script type='text/javascript'>set_cookie('{$RELATED_MODULE}_all', '');</script>
{/if}

{if $MODULE eq 'Campaigns'}
    <input id="{$MODULE}_{$RELATED_MODULE|replace:' ':''}_numOfRows" type="hidden" value="">
    <input id="{$MODULE}_{$RELATED_MODULE|replace:' ':''}_excludedRecords" type="hidden" value="">
    <input id="{$MODULE}_{$RELATED_MODULE|replace:' ':''}_selectallActivate" type="hidden" value="false">
{/if}

</form>
</div>


<div id="printview" class="E_pop_box LdPopWidth350px" style="display:none;">
    <div class="E_pop_tit">
    	<strong class="E_ptita">{'PRINT'|@getFixedLabel}</strong>
        <button class="E_ptitc" value="{'CLOSE'|@getFixedLabel}" title="{'CLOSE'|@getFixedLabel}" onclick="fninvshnew('printview');"></button>
    </div>
	<table class="D_pop_bod D_pop_bod_line" border="0" cellpadding="1" cellspacing="0">
        <tr>
            <td><div id="printview_form_div"></div></td>
        </tr>
    </table>
</div>



<script>
//RelateListPage.type
//41240: （http://192.168.1.6/crm/ [^]）客户单据详情界面，相关信息中关联创建“销售合同”保存后，相关信息“销售合同”界面显示异常
//立即创建回款计划
var popupobj=CrmPopup.getlastPopupObjByType(RelateListPage.type);
popupobj.relatelistsizeobj=new List_ResizeTable(popupobj);

popupobj.relatelistsizeobj.setRelatedResizeTable_Init('{$RELATED_MODULE}','');
popupobj.reSizePosition();//设置相关信息全屏
</script>