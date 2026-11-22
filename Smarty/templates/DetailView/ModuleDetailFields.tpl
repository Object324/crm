{foreach key=header item=detail from=$BLOCKS name=blocknames}
	{if $header eq 'show_origin_information'}
	<table border=0 cellspacing=0 cellpadding=0 width=100% >
		<tr>
			<td class="" colspan="4" style="padding:0px;width:100%;">
				<div class="">{$RELATEDORDERINFORMATION}</div>
			</td>
		</tr>
	</table>
	{else}
		<table border=0 cellspacing=0 cellpadding=0 width=100% >
		   	<tr width='100%'>
			{strip}
				<td colspan=4 >
					{if $BLOCKINITIALSTATUS[$header] eq 1}
						{assign var='arrawcls' value=''}
					{else}
						{assign var='arrawcls' value='On'}
					{/if}
					{if !empty($BLOCKS_LABELTOID[$header])}
						<div class="DivCName DivCNamehover {if $arrawcls=='On'}ld-shadow-first{/if} tip-items-list" data-direction="left" data-type="position" data-tip="{'COLLAPSE'|@getFixedLabel}" onclick="showHideStatus('tbl{$BLOCKS_LABELTOID[$header]|@replace:' ':''}','aid{$BLOCKS_LABELTOID[$header]|@replace:' ':''}');">
							<span class="{$arrawcls}" id="aid{$BLOCKS_LABELTOID[$header]|@replace:' ':''}" name="aid{$BLOCKS_LABELTOID[$header]|@replace:' ':''}"></span>{$header}
					{else}
						<div class="DivCName DivCNamehover tip-items-list" data-direction="left" data-type="position" data-tip="{'COLLAPSE'|@getFixedLabel}" onclick="showHideStatus('tbl{$header|replace:' ':''}','aid{$header|replace:' ':''}');">
							<span class="{$arrawcls}" id="aid{$header|replace:' ':''}" name="aid{$header|replace:' ':''}"></span>{$header}
					{/if}
							{$header|@getBlockInfoForLinks:'detailview'}
						</div>
				</td>
			{/strip}
		   	</tr>
	 	</table>
	{if $BLOCKINITIALSTATUS[$header] eq 1}
		{if !empty($BLOCKS_LABELTOID[$header])}
			<div class="DivCNotice ld-shadow-first" style="width:auto;display:block;" id="tbl{$BLOCKS_LABELTOID[$header]|replace:' ':''}" name="tbl{$BLOCKS_LABELTOID[$header]|replace:' ':''}" >
		{else}
			<div class="DivCNotice ld-shadow-first" style="width:auto;display:block;" id="tbl{$header|replace:' ':''}" name="tbl{$header|replace:' ':''}" >
		{/if}
	{else}
		{if !empty($BLOCKS_LABELTOID[$header])}
			<div class="DivCNotice ld-shadow-first" style="width:auto;display:none;" id="tbl{$BLOCKS_LABELTOID[$header]|replace:' ':''}" name="tbl{$BLOCKS_LABELTOID[$header]|replace:' ':''}" >
		{else}
			<div class="DivCNotice ld-shadow-first" style="width:auto;display:none;" id="tbl{$header|replace:' ':''}" name="tbl{$header|replace:' ':''}" >
		{/if}
	{/if}
	<table border=0 cellspacing=0 cellpadding=0 width="100%" class="DetailContentTable ld-detail-tablecontent" style="table-layout: fixed;word-break: break-all; word-wrap: break-word;">
		<tr><td style="width: 200px;height: 0;"></td><td style="width: calc(100% - 200px);height: 0;"></td><td style="width: 200px;height: 0;"></td><td style="width: calc(100% - 200px);height: 0;"></td></tr>
		{foreach item=details from=$detail}
	   	<tr width='100%'>
		{foreach key=label item=data from=$details}
			{assign var=keyid value=$data.ui}
			{assign var=keyval value=$data.value}
			{assign var=keytblname value=$data.tablename}
			{assign var=keyfldname value=$data.fldname}
			{assign var=pick_color value=$data.pick_color}
			{assign var=keyfldid value=$data.fldid}
			{assign var=keyoptions value=$data.options}
			{assign var=keysecid value=$data.secid}
			{assign var=keyseclink value=$data.link}
			{assign var=keycursymb value=$data.cursymb}
			{assign var=keysalut value=$data.salut}
			{assign var=keycntimage value=$data.cntimage}
			{assign var=keyadmin value=$data.isadmin}
			{assign var=display_type value=$data.displaytype}
			{assign var=_readonly value=$data.readonly}
			{assign var=fieldonly value=$data.fieldonly}
			{assign var=rawvalue value=$data.rawvalue}
			{assign var=allowedit value=$data.allowedit}
			{assign var=value_name value=$data.value_name}
			{*zxm 20211230字段颜色 字段说明样式*}
			{assign var=fieldvaluecolor value=$data.fieldvaluecolor}
			{assign var=fieldplaceholder value=$data.fieldplaceholder}
			{assign var=ShowHyperlinks value=$data.ShowHyperlinks}
			{assign var = BUSINESSQUERY value = $data.businessquery}{* 是否为工商查询字段 *}
			{assign var = ENABLEBUSINESS value = $data.isenablebusiness}{* 是否启用工商查询 *}
			{assign var = BUSINESSFUZZYQUERY value = $data.isenablebusinessfuzzyquery}{* 是否启用工商模糊查询 *}
			{assign var=helptips value=$data.helptips}

				{if $label neq ''}
					{*editor:gyq_20200312 reason:中英文全角冒号是一样的
					0039657: （51mis.com/kfbtest）合同订单模块>明细界面：红框中全部要加上全角的冒号(参照“客户”模块） 只修改单据的详细界面，新增和编辑界面不修改 手机端也不修改。*}
					{assign var=oldlabel value=$label}
					{* 2024-06-05 xxy 详情页去掉冒号 XUQIU20240603-02 页面设置/单据分录定制，字段类型增加“帮助信息”字段属性（朱俊） *}
					{* {assign var=label value=$label|cat:"："} *}
					{if $keyid neq '83' && $keyid neq '301'}
						<td class="ld-form-item-label">
					{/if}
					
					{if $keycntimage ne ''}
						{* <td class="ld-form-item-label"> *}
							<input type="hidden" id="hdtxt_IsAdmin" value={$keyadmin}></input>{$keycntimage}
						{* </td> *}
					{elseif $keyid neq '83'}<!-- Avoid to display the label Tax Class -->
						{if $keyid eq '71' || $keyid eq '72'}  <!--CurrencySymbol-->
							{* <td class="ld-form-item-label"> *}
								<input type="hidden" id="hdtxt_IsAdmin" value={$keyadmin}></input>{$label}
							{* </td> *}
						{elseif $keyid eq '9'}
							{*ls 20220713 BUG0053858 销售发票（发票编号：INV1）单据查看详情界面，“百分比”字段标签没有显示百分号*}
							{* <td class="ld-form-item-label"> *}
								<input type="hidden" id="hdtxt_IsAdmin" value={$keyadmin}></input>{$oldlabel} (%)：
							{* </td> *}
						{elseif $keyid eq '202'}
							{* <td class="ld-form-item-label"> *}
								<span>{$label}{if $ISSOURCEMODULE}  {/if}{$ISSOURCEMODULE|@getTranstab}</span>
							{* </td> *}
						{elseif $keyid eq '301'}
                            <td class="ld-form-item-content" colspan="4">
                                {assign var = tag_keyval value = htmlentities($keyval)}
                                <input type="hidden" name="detail_tagger_search" value="{$tag_keyval}" tag_id="" tag_type="{$keysecid}" id="detail_tagger_search" />
                                <script type="text/javascript">
                                    {literal}
                                    ld(document).ready(function(){
                                        ListTagDetailShow('detail_tagger_search');
                                    });
                                    {/literal}
                                </script>
                                <input name="add_moduledata_tag" module="{$MODULE}" onclick="detailbutton_click(this,'{$MODULE}','add_moduledata_tag','{$ID}');return false;" class="createautonew" value="{'Tagging'|@getFixedLabel}" type="button">
                            </td>
                        {else}
							{* <td class="ld-form-item-label"> *}
							<input type="hidden" id="hdtxt_IsAdmin" value={$keyadmin}></input>{$label}
							{* </td> *}
						{/if}
					{/if}
					{if $keyid neq '83' && $keyid neq '301'}
						{include file="Helptips.tpl"}
						</td>
					{/if}
                    {if $keyid neq '301'}
    					{if ($DETAILBUTTON.Edit.permit eq 'yes' ||$DETAILBUTTON.moduledetailEdit.permit eq 'yes' ) && $display_type neq '2' && $_readonly eq '0' || $allowedit eq 'no'}
    						{* Performance Optimization Control *}
    						{if $allowedit eq 'no' || $alloweditpage eq 'no'}
    							{include file="DetailNoEdit.tpl"}
    						{else}
								{if !empty($DETAILVIEW_AJAX_EDIT) }
									{if $EDITSTATUS eq 'no' || $alloweditpage eq 'no'}
										{include file="DetailNoEdit.tpl"}
									{else}
                                        
										{include file="DetailViewUI.tpl"}
									{/if}
								{else}
									{include file="DetailViewFields.tpl"}
								{/if}
							{/if}
    					{else}
    						{include file="DetailViewFields.tpl"}
    					{/if}
                    {/if}        
				{else}
				{/if}
			{assign var=keyids value=$keyid}
		{/foreach}
	   	</tr>
	   	{/foreach}
	</table>
	</div> <!-- Line added by SAKTI on 10th Apr, 2008 -->
{/if}
{/foreach}