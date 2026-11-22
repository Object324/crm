<!--修改编码格式:统一编码：UTF-8-->
<script type="text/javascript">
var TOGGLE_MODINFO_JSON = '{$TOGGLE_MODINFO_JSON}';
var TOGGLE_MODINFO = eval('(' + TOGGLE_MODINFO_JSON + ')') ? eval('(' + TOGGLE_MODINFO_JSON + ')') : JSON.parse(TOGGLE_MODINFO_JSON);
{literal}

function vtlib_modulemanager_toggleTab(shownode, hidenode, highlighttab, dehighlighttab) {
	if($(shownode)) $(shownode).show();
	if($(hidenode)) $(hidenode).hide();
	if($(highlighttab)) { $(highlighttab).addClassName('dvtSelectedCellCommon dvtSelectedCell'); $(highlighttab).removeClassName('dvtUnSelectedCell'); }
	if($(dehighlighttab)) { $(dehighlighttab).addClassName('dvtUnSelectedCell'); $(dehighlighttab).removeClassName('dvtSelectedCellCommon dvtSelectedCell'); }
}

function SearchModule(obj){
	var searchText = Tools.getParentobjByChild(obj,'div').find("input").val();//搜索框信息
	var value = ld("#searchmoudel_select").find("option:selected").attr("value");//下拉框取值
	var $searchTd;
	var pinyinlabel = '';
	var rightlabel = '';
	if (searchText != "" ) {
		ld(".lvtColData").css("display","none");
		ld(".lvtColDataBj").css("display","none");
		if(value=='REMARK'){
			$searchTd = ld("#vtlib_modulemanager_list").find('td[name='+ value +']:contains('+ searchText +')');
		} 
		else if(value=='WHETHERTOENABLE'){
			if(searchText==arrJsPopLabel['YES']) {
				$searchTd = ld("#vtlib_modulemanager_list").find('input[type=checkbox]:checked');
			}else if(searchText==arrJsPopLabel['NO']){;
				$searchTd = ld("#vtlib_modulemanager_list").find('input[type=checkbox]:not("input:checked")');
			}else {
				$searchTd = '';
			}
		} 
		else{
			if(searchText==arrJsPopLabel['YES']) {
				$searchTd = ld("#vtlib_modulemanager_list").find('input[type=checkbox]:checked');
			}else if(searchText==arrJsPopLabel['NO']){
				$searchTd = ld("#vtlib_modulemanager_list").find('input[type=checkbox]:not("input:checked")');
			}
			if(empty($searchTd)){
				$searchTd = ld("#vtlib_modulemanager_list").find('td[name!=operate]:contains('+ searchText +')');
			}else{
				$searchTd = $searchTd.add(ld("#vtlib_modulemanager_list").find('td[name!=operate]:contains('+ searchText +')'));
			}
			if(TOGGLE_MODINFO && !empty(TOGGLE_MODINFO)){// BUG20240621-52 xxy 模块管理中模块的搜索支持大小写，拼音检索
				ld.each(TOGGLE_MODINFO,function(tabid,infos){
					ld.each(infos.label,function(key,label){
						var pinyinlabel = makePy(label).join("").toLowerCase();
						if(value=='ZHPARENTMENUNMAE' && key == 'en'){
							return;
						}else if(value=='ENPARENTMENUNMAE' && (key == 'zh' || key == 'pinyin')){
							return;
						}
						if((label.toLowerCase()).indexOf(searchText.toLowerCase()) >= 0 || (pinyinlabel.toLowerCase()).indexOf(searchText.toLowerCase()) >= 0){
							rightlabel = label;
							if(key == 'pinyin'){
								rightlabel = infos.label['zh'];
							}
							if(value=='ALL'){
								if(empty($searchTd)){
									$searchTd = ld("#vtlib_modulemanager_list").find('td[name!=operate]:contains('+ rightlabel +')');
								}else{
									$searchTd = $searchTd.add(ld("#vtlib_modulemanager_list").find('td[name!=operate]:contains('+ rightlabel +')'));
								}
							}else{
								if(empty($searchTd)){
									$searchTd = ld("#vtlib_modulemanager_list").find('td[name='+ value +']:contains('+ rightlabel +')');
								}else{
									$searchTd = $searchTd.add(ld("#vtlib_modulemanager_list").find('td[name='+ value +']:contains('+ rightlabel +')'));
								}
							}
						}
					});
				});
			}
			//wym 240314 模块设置-搜索功能 该元素id修改的话这里要同步修改 BUG20240313-29 模块管理--搜索佣金单，出不来结果
			if($searchTd.length != 0){
				$searchTr = Tools.getParentobjByChild($searchTd, 'tr');
				ld($searchTr).css("display", "");
			}
		}
		if($searchTd.length != 0) {
			$searchTr = Tools.getParentobjByChild($searchTd, 'tr');
			ld($searchTr).css("display", "");
		}
		//对显示的tr进行重新排序
		xuhaoTd = ld("#vtlib_modulemanager_list").find("td[name=num]:visible");
		xuhaoTd.each(function(i) {
			xuhaoTd.eq(i).html(i+1);
		});
		//若页面内没有图标，则隐藏恢复全部默认图标
		var length=0;
		icon = ld("#vtlib_modulemanager_list").find("a[name=RestoreDefaultIcon]");
		icon.each(function(i) {
			iconTd = Tools.getParentobjByChild(icon.eq(i), 'td');
			if(iconTd.is(":visible")) length=length+1;
		});
		if(length>0){
			ld(".restore-default-icon-all").css("display","");
		}else{
			ld(".restore-default-icon-all").css("display","none");
		}
	}else{
		var num_tdobj = ld("#vtlib_modulemanager_list").find("td[name=num]");
		ld.each(num_tdobj,function (index,obj) {
			var num = ld(obj).attr('num');
			ld(obj).html(num);
		})
		ld(".lvtColData").css("display","");
		ld(".lvtColDataBj").css("display","");
		if(ld(".restore-default-icon-single").length==0){
			ld(".restore-default-icon-all").css("display","none");
		}else{
			ld(".restore-default-icon-all").css("display","");
		}
	}
}

function SearchModuleSubmit(event,obj){
	var e = event || window.event;
	if(e.keyCode == 13){
		SearchModuleBefore(obj);
	}
	var search_text = ld('#searchmoudel_input').val();
	ld('#searchmoudel_input').focus().val(search_text);
	if(!empty(search_text)){
		ld('.ld-icon-clearsearch').css('display','');
	}else{
		ld('.ld-icon-clearsearch').css('display','none');
	}
}

function SearchModuleBefore(obj){
	getJsScript('include/js/multipingyin.js', function () {
		SearchModule(obj);
	});
}

{/literal}
</script>

{if $DIR_NOTWRITABLE_LIST && !empty($DIR_NOTWRITABLE_LIST)}
<table class="small" width="100%" cellpadding=0 cellspacing=0 border=0>
	<tr>
		<td>
			<div style='background-color: #FFFABF; padding: 2px; margin: 0 0 2px 0; border: 1px solid yellow'>
			<b style='color: red'>{$MOD.VTLIB_LBL_WARNING}:</b> {$DIR_NOTWRITABLE_LIST|@implode:', '} <b>{$MOD.VTLIB_LBL_NOT_WRITEABLE}!</b>
		</td>
	</tr>
</table>
{/if}
<table class="fir-center" border="0" cellpadding="0" cellspacing="0" width="100%">
	<thead>
		<tr>
			<th width="65px">#</th>
			<th width="200px" class="locking-left" align="left" title="{'ZHPARENTMENUNMAE'|@getFixedLabel}">{'ZHPARENTMENUNMAE'|@getFixedLabel}</th>
			<th width="200px" align="left" title="{'ENPARENTMENUNMAE'|@getFixedLabel}">{'ENPARENTMENUNMAE'|@getFixedLabel}</th>
			<th width="145px" align="left" title="{'ICON'|@getFixedLabel}">{'ICON'|@getFixedLabel}<a class="restore-default-icon restore-default-icon-all" href="javascript:;"onclick="RestoreDefaultIcon('module','all')" title="{'RestoreAllDefaultIcon'|@getFixedLabel}" style="display: none;"></a></th>
			<th width="145px" title="{'WHETHERTOENABLE'|@getFixedLabel}">{'WHETHERTOENABLE'|@getFixedLabel}</th>
			<th width="145px" class="locking-rightleft"title="{'REMARK'|@getFixedLabel}" >{'REMARK'|@getFixedLabel}</th>
			<th width="230px" class="locking-right">{'OPERATING'|@getFixedLabel}</th>
		</tr>
	</thead>
	<tbody>
		{assign var="i" value=0}
		{assign var="modulenamenum" value='1'}
		{foreach key=moduleid item=modinfo name=modulenamenum from=$TOGGLE_MODINFO}
			{*230628 wym 隐藏了不能编辑也不能页面设置的模块*}
		    {if $modinfo.customized eq false && ($modinfo.noshowedit neq 'yes' || $modinfo.hassettings)}
		        {assign var="modulelabel" value=$modinfo.tablabel}
		        {assign var="j" value=$i++}
		        {if $j mod 2 eq '0'}
		            <tr id="setting_{$j}" class="lvtColData" onmouseout="listOnMouseOut(ld(this),'on');" onmouseover="listOnMouseOver(ld(this));">
		        {else}
		            <tr id="setting_{$j}" class="lvtColDataBj" onmouseout="listOnMouseOut(ld(this),'On');" onmouseover="listOnMouseOver(ld(this));">
		        {/if}
		            <td name="num" num="{$modulenamenum}">
		                {$modulenamenum}
		            </td >
		            <td class="locking-left" name="ZHPARENTMENUNMAE">
		                <span id="span_{$modinfo.label.zh}" class="modulecontrollspan" tag="zh" title="{$modinfo.label.zh}">{$modinfo.label.zh}</span>
		                <div id="editarea_{$modinfo.label.zh}" style="display:none;" class="modulecontrolldiv">
		                    <input id="txtbox_{$modinfo.label.modulename}_zh" class="ld-input-inner" type="text" value="{$modinfo.label.modulename}" maxlength="100" name="modulename">
		                </div>
		            </td>
		            <td name="ENPARENTMENUNMAE">
		                <span id="span_{$modinfo.label.modulename}" class="modulecontrollspan" tag="en" title="{$modinfo.label.en}">{$modinfo.label.en}</span>
		                <div id="editarea_{$modinfo.label.en}" style="display:none;" class="modulecontrolldiv">
		                    <input id="txtbox_{$modinfo.label.modulename}_en" class="ld-input-inner" type="text" value="{$modinfo.label.en}" maxlength="100" name="modulename">
		                </div>
		            </td>
		            <td name="ICON" tabid="{$moduleid}" >
		                <span id="editarea_{$modinfo.label.modulename}_showcontent">
		                    {*zxm 2021-1208 模块自定义图标*}
							<img style="width:30px;height:30px;{if $modinfo.active_icon == ''}display:none;{/if}" src="{if $modinfo.active_icon != ''}{$modinfo.active_icon}{/if}">
							<a  class="restore-default-icon restore-default-icon-single" style="display:none;" href="javascript:;" onclick="RestoreDefaultIcon('module','single',this)" title="{'RestoreDefaultIcon'|@getFixedLabel}" name="RestoreDefaultIcon"></a>

						</span>
						<div id="editarea_{$modinfo.label.modulename}_action" style="display:none;" class="modulecontrolldiv">
							<input name="active_icon_size" value="1024" type="hidden">
							<input name="active_icon_name" value="{$modinfo.active_icon}" type="hidden">
							<input name="active_icon" accept="image/*" value="{$modinfo.active_icon}" type="file">
							<input name="active_icon_name_hidden" value="{$modinfo.active_icon}" type="hidden">
							<span title="{'menuIconUploadSizeTips'|@getFixedLabel}" style="color: red;line-height: 20px;word-break: break-all">{'menuIconUploadSizeTips'|@getFixedLabel}</span>
						</div>
					</td>
			        <td name="WHETHERTOENABLE">
			            {if $modinfo.presence eq 0}
			            	<input type="checkbox" onclick="vtlib_toggleModule(this,'{$moduleid|@getTabname}', this.checked,'','{$BLOCKIDSETTING}','{$FIELDIDSETTING}');" {if $moduleid|@getTabname eq 'Users'}disabled{/if} class="second_switch" checked='' />
			            {else}
			            	<input type="checkbox" onclick="vtlib_toggleModule(this,'{$moduleid|@getTabname}', this.checked,'','{$BLOCKIDSETTING}','{$FIELDIDSETTING}');" class="second_switch"/>
			            {/if}
			        </td>
					<td class="locking-rightleft" name="REMARK">
						<span class="modulecontrollspan" tag="en" title="{$modinfo.description}">{$modinfo.description}</span>
					</td>
					<td class="locking-right" name="operate">
						<a ifhide="0"class="Anu3_a btns_upload_action" style="display: none" href="javascript:void(0);" onclick="vtlib_savemodulename(event,'txtbox_{$modinfo.label.modulename}_zh','txtbox_{$modinfo.label.modulename}_en','{$moduleid|@getTabname}','{$BLOCKIDSETTING}','{$FIELDIDSETTING}')">{'SAVE'|@getFixedLabel}</a>
						<a ifhide="0" class="Anu3_a redFont btns_upload_action" style="display: none" href="javascript:void(0);" onclick="vtlib_showeditinput(event,2,'','');" >{'CANCEL'|@getFixedLabel}</a>
						{if $modinfo.presence eq 0}
			                {if $modinfo.noshowedit neq 'yes'}
							<a ifhide="1" tag="123" class="Anu3_a btns_edit_action" href="javascript:void(0);" onclick="vtlib_showeditinput(event,1);" >{'EDIT'|@getFixedLabel}</a>
			                {/if}
							{if $modinfo.hassettings}
							<a ifhide="1" class="Anu3_a" tag="pagesettings" href="javascript:void(0);" modulesettingsmodulename='{$modinfo.label.modulename}'>
								{'LBL_PAGE_SET'|@getFixedLabel}
							</a>
							<a ifhide="1" class="Anu3_a" href="javascript:void(0);" onclick="SetRelatedlists(this,'{$modinfo.label.modulename}','{$BLOCKIDSETTING}','{$FIELDIDSETTING}')">{'PROJECTSETTINGS'|@getFixedLabel}</a>
							{/if}
						{else}
			                {if $modinfo.noshowedit neq 'yes'}
							<a ifhide="1" tag="123" class="Anu3_a btns_edit_action" href="javascript:void(0);" onclick="vtlib_showeditinput(event,1);" style="display: none">{'EDIT'|@getFixedLabel}</a>
			                {/if}
							{if $modinfo.hassettings}
							<a ifhide="1" class="Anu3_a" tag="pagesettings" href="javascript:void(0);" modulesettingsmodulename='{$modinfo.label.modulename}' style="display: none">
								{'LBL_PAGE_SET'|@getFixedLabel}
							</a>
							<a ifhide="1" class="Anu3_a" href="javascript:void(0);" onclick="SetRelatedlists(this,'{$modulename}','{$BLOCKIDSETTING}','{$FIELDIDSETTING}')" style="display: none">{'PROJECTSETTINGS'|@getFixedLabel}</a>
							{/if}
						{/if}
			        </td>
				</tr>
		    {assign var="modulenamenum" value=$modulenamenum+1}
			{/if}
		{/foreach}
	</tbody>
</table>
<script type="text/javascript">
	{literal}

	function setPageSettingClick(){
		//页面设置按钮事件
		ld("[tag=pagesettings]").unbind("click").bind("click",function(){
			ldAjax("index.php?module=Settings&action=SettingsAjax&file=LayoutBlockList&formodule="+ld(this).attr('modulesettingsmodulename'),'',function(ajaxdata){
				DelProgressObjs();
				ld(" [name=SettingRightContent]").html(ajaxdata.result.content);
			});
		})
	}

	ld(function(){
		setPageSettingClick();
		if(ld(".restore-default-icon-single").length==0){
			ld(".restore-default-icon-all").css("display","none");
		}else{
			ld(".restore-default-icon-all").css("display","");
		}
	})
	{/literal}
</script>