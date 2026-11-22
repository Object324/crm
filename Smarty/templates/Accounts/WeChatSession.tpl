<script src="include/js/WechatSession.js"></script>
<script type="text/javascript" src="include/js/BenzAMRRecorder.min.js"></script>
{*<script type="text/javascript" src="include/js/amrnb.js"></script>*}
{*<script type="text/javascript" src="include/js/amrplayer.js"></script>*}
<input type="hidden" name="prerecord" value="{$record}">

<input name="page" type="hidden" value="{$page}"/>
<input name="page_num" type="hidden" value="{$page_num}"/>

<div class="conversation-title" id="wechatsessionpagecontent">
	<input class="commonTextBoxPop" type="text" name="search" placeholder="{'SearchSessionContent'|@getFixedLabel}"/>
	<input class="E_pbtnok" onclick="WechatSession.prototype.search();" type="submit" name="submit" value="{'SEARCHNEW'|@getFixedLabel}">
	{if $page_num > 1}
		<a href="javascript:;" name="prevnextrecord" style="color: rgb(153, 153, 153);float: right;line-height: 100%;padding-right: 6%;text-decoration: none;" tag="nextrecord" onclick="WechatSession.prototype.searchPrevNext(ld(this),'paging')">{'NEXTPAGE'|@getFixedLabel}</a>
		<a href="javascript:;" name="prevnextrecord" style="color: rgb(52, 135, 226);float: right;line-height: 100%;padding-right: 10px;text-decoration: none;" tag="prevrecord" onclick="WechatSession.prototype.searchPrevNext(ld(this),'paging')">{'PREVPAGE'|@getFixedLabel}</a>
	{/if}
</div>
<div id="chatdata">
    {include file='Accounts/ChatData.tpl'}
</div>