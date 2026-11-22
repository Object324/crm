<div style="float:left;padding: 10px 10px 0 0;">{'Tag'|@getFixedLabel}</div>
<input type="hidden" name="fieldname" value="{$FIELDNAME}">
{if $MODULE_TAG neq ''}
	<div name="moduletag_list" style="padding-bottom: 10px;">
    {assign var = tag_keyval value = htmlentities($MODULE_TAG)}
		<input type="hidden" name="list_tagger_search" value="{$tag_keyval}" tag_id="{$MODULE_TAG_ID}" tag_type="{$MODULE_TAG_TYPE}" id="list_tagger_search" />
	</div>
	<div class="E_pbtn" style="border-top:none;display:none"><input name="button" onclick="ListTagSearch('{$MODULE}');" class="E_pbtnok" value="{'FINDNOW'|@getFixedLabel}" type="button"><span>&nbsp;</span>
	<input class="E_pbtncancel" value="{'CANCEL'|@getFixedLabel}" type="button" onclick="ListTagBlock();"></div>
{else}
	<div name="moduletag_list" style="padding-left: 80px;padding-bottom: 10px;margin-top: 8px;">
		<span style="color:#999;">{'listnotag'|@getFixedLabel}</span>
	</div>
{/if}

<script>
{literal}

var popupobj=CrmPopup.getPopupObj('last');

ld('div[name=moduletag_list]').find(" [tag_click=no]").unbind("click").bind("click",function(){
    //edit:can 2021-01-06 44137: （61mis.com/kfbcrm）标签；客户管理-客户；单据列表上方，点击标签查找，“立即查找”和“取消”按钮没有去掉
    ld(this).attr('tag_click','yes');
	ld(this).css('color','#3B7CFF');
	ld(this).css('border','1px solid #3B7CFF');
    ListTagSearch(popupobj.module);
    
})


ld('div[name=moduletag_list]').find(" [tag_click=yes]").unbind("click").bind("click",function(){
    //edit:can 2021-01-06 44137: （61mis.com/kfbcrm）标签；客户管理-客户；单据列表上方，点击标签查找，“立即查找”和“取消”按钮没有去掉
    ld(this).attr('tag_click','no');
	ld(this).css('color', '');
	ld(this).css('border','');
    ListTagSearch(popupobj.module);
    
})
{/literal}

</script>
