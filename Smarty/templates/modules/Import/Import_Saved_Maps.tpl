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
-->*}
<!--修改编码格式:统一编码：UTF-8-->
<span class="small">{'Use_saved_mapping_table'|@getFixedLabel}</span>&nbsp;&nbsp;
<select name="saved_maps" id="saved_maps" class="small" onchange="ImportJs.loadSavedMap();">
	<option id="-1" value="" selected>--{'SELECT'|@getFixedLabel}--</option>
	{foreach key=_MAP_ID item=_MAP from=$SAVED_MAPS}
	<option id="{$_MAP_ID}" value="{$_MAP->getStringifiedContent()}">{$_MAP->getValue('name')}</option>
	{/foreach}
</select>
<span id="delete_map_container" style="display:none;">
	<a class="icon-homeimg icon-sdel" href="javascript:;" onclick="ImportJs.deleteMap('{$FOR_MODULE}');" title="{'DELETE'|@getFixedLabel}" ></a>
</span>