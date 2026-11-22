<div class="noticeBox">
	<div class="noticeBox_T">
		<span>{'News'|@getFixedLabel}<b>（{$REMINDSINFO.pagenum}/{$REMINDSCOUNT}）</b></span>
		{if $REMINDSINFO.nextpage eq 'yes'}
			<img id="remind_page_next" class="notice_on_right" tag="down" remindsid={$REMINDSINFO.remindsid} page={$REMINDSINFO.pagenum} onclick="return getRemindpages(this,event)" src="themes/icon2021/top/arrow_16.png">
		{else}
			<img id="remind_page_next" class="notice_on_right notice_off_right" tag="down" remindsid={$REMINDSINFO.remindsid} page={$REMINDSINFO.pagenum} src="themes/icon2021/top/arrow_16.png">
		{/if}
		{if $REMINDSINFO.prepage eq 'yes'}
			<img id="remind_page_prev" class="notice_on_left" tag="up" remindsid={$REMINDSINFO.remindsid} page={$REMINDSINFO.pagenum} onclick="return getRemindpages(this,event)" src="themes/icon2021/top/arrow_16.png">
		{else}
			<img id="remind_page_prev" class="notice_on_left notice_off_right" tag="up" remindsid={$REMINDSINFO.remindsid} page={$REMINDSINFO.pagenum} src="themes/icon2021/top/arrow_16.png">
		{/if}
	</div>
	<div class="noticeBox_C">
		{$REMINDSINFO.header_content}
	</div>
	<div class="noticeBox_B">
		<div class="noticeBox_B_Btn" onclick="return setRemindReadenHeader({$REMINDSINFO.remindsid}, {$REMINDSCOUNT});">{'LBL_READEN'|@getFixedLabel}</div>
		<div class="noticeBox_B_Line"></div>
		<div class="noticeBox_B_Btn" onclick="return RemindDelayDropDown(event,this,'selectviewremind_new');">{'POSTPONE'|@getFixedLabel}</div>
		<div class="noticeBox_B_Line"></div>
		<div class="noticeBox_B_Btn" onclick="window.location.href='index.php?pageto_action=index&pageto_module=Reminds&viewname=108'">{'MORE'|@getFixedLabel}</div>
	</div>
</div>
<div class="fixedLay1 WarmRemindDiv WarmRemindDiv_New" onmouseover="fnShowDrop('selectviewremind_new')" onmouseout="fnHideDrop('selectviewremind_new')" id="selectviewremind_new">
	<table cellspacing="1" cellpadding="0" border="0">
	    <tr><td><a onclick="return updateRemindtimeHeader('5', {$REMINDSINFO.remindsid}, {$REMINDSCOUNT});"  style="cursor:pointer;">5 {'MINUTE'|@getFixedLabel}</a></td></tr>
	    <tr><td><a onclick="return updateRemindtimeHeader('10', {$REMINDSINFO.remindsid}, {$REMINDSCOUNT});" style="cursor:pointer;">10 {'MINUTE'|@getFixedLabel}</a></td></tr>
	    <tr><td><a onclick="return updateRemindtimeHeader('15', {$REMINDSINFO.remindsid}, {$REMINDSCOUNT});" style="cursor:pointer;">15 {'MINUTE'|@getFixedLabel}</a></td></tr>
	    <tr><td><a onclick="return updateRemindtimeHeader('1H', {$REMINDSINFO.remindsid}, {$REMINDSCOUNT});" style="cursor:pointer;">1  {'HOUR'|@getFixedLabel}</a></td></tr>
	    <tr><td><a onclick="return updateRemindtimeHeader('2H', {$REMINDSINFO.remindsid}, {$REMINDSCOUNT});" style="cursor:pointer;">2  {'HOUR'|@getFixedLabel}</a></td></tr>
	    <tr><td><a onclick="return updateRemindtimeHeader('4H', {$REMINDSINFO.remindsid}, {$REMINDSCOUNT});" style="cursor:pointer;">4  {'HOUR'|@getFixedLabel}</a></td></tr>
	    <tr><td><a onclick="return updateRemindtimeHeader('8H', {$REMINDSINFO.remindsid}, {$REMINDSCOUNT});" style="cursor:pointer;">8  {'HOUR'|@getFixedLabel}</a></td></tr>
	    <tr><td><a onclick="return updateRemindtimeHeader('1D', {$REMINDSINFO.remindsid}, {$REMINDSCOUNT});" style="cursor:pointer;">1  {'Days'|@getFixedLabel}</a></td></tr>
	    <tr><td><a onclick="return updateRemindtimeHeader('2D', {$REMINDSINFO.remindsid}, {$REMINDSCOUNT});" style="cursor:pointer;">2  {'Days'|@getFixedLabel}</a></td></tr>
	    <tr><td><a onclick="return updateRemindtimeHeader('3D', {$REMINDSINFO.remindsid}, {$REMINDSCOUNT});" style="cursor:pointer;">3  {'Days'|@getFixedLabel}</a></td></tr>
	    <tr><td><a onclick="return updateRemindtimeHeader('5D', {$REMINDSINFO.remindsid}, {$REMINDSCOUNT});" style="cursor:pointer;">5  {'Days'|@getFixedLabel}</a></td></tr>
	</table>
</div>