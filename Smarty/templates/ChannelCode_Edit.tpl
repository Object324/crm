{*zxm 2020-1104 示例悬浮 增加style样式以及for-example的三个div*}
<style>
	.for-example{
		float:left;
	}
	.for-example:hover + #pic_miniprogram,.for-example:hover + #pic_text,.for-example:hover + #pic_card{
		color:red;
		display:block;
	}
	#pic_text{
		display:none;
		position:relative;
		top:-200px;
		left:-10px;
		float:left;
		z-index:20;
		height:0;
	}
	#pic_card{
		display:none;
		position:relative;
		top:-200px;
		left:-10px;
		float:left;
		z-index:20;
		height:0;
	}
	#pic_miniprogram{
		display:none;
		position:relative;
		top:-300px;
		left:-10px;
		float:left;
		z-index:20;
		height:0;
	}
	#pic_miniprogram img{
		height:300px;
	}
	#pic_card img{
		height:200px;
	}
	#pic_text img{
		height:200px;
	}
</style>
<div class="edit-left" >
</div>
<div id="DetailContent" class="edit-right" style="">
	<form enctype="multipart/form-data" method="POST" id="my_form" action="index.php" class="ajax_form">
	<input type="hidden" value="ChannelCode" name="module">
	<input type="hidden" value="ChannelCodeAjax" name="action">
	<input type="hidden" value="Save" name="file" >
	<input type="hidden" value="{$RECORD}" name="channelcode_id">
	<input type="hidden" value="yes" name="savaajax">
	<input type="hidden" value="{$RELATED}" name="related">
	<div name="displayfields">
		<table class="DetailContentTable linefeed" width="100%" cellspacing="0" cellpadding="0" border="0">
			<tbody>
			<tr>
				<td colspan="4" class="ld-from-headblock e">
					<div class="ld-from-headblock-title" tag="headblock-title">{'Scancodetocontactstaff'|@getFixedLabel}</div>
				</td>
			</tr>
			<tr>
				<td class="ld-form-item-label" width="20%">
					<font color="red">*</font>{'Selectwechatemployees'|@getFixedLabel}
				</td>
				<td class="ld-form-item-content" width="80%">
					<input id="userid_name" name="userid_name" class="ld-input-inner ld-input-inner-add" readonly="" style="height:25px;line-height:25px;padding-left:8px;display:-webkit-inline-box;text-overflow:ellipsis;overflow:hidden;" value="{$DATA.channel_username}">
					<input type="hidden" name="userid" id="userid" value="{$DATA.channel_userid}" input_label="{'Selectwechatemployees'|@getFixedLabel}"/>
					<a class="ld-text-select" href="javascript:;" title="{'SELECT'|@getFixedLabel}" onclick="channelcode_selectuser();">+</a>
					{* <a class="ld-text-clear" href="javascript:;" title="{'CLEAR'|@getFixedLabel}" onclick="clear_relatedfielddata('ServiceCharge','servicecharge_id','servicecharge_id_name','','Contacts','popupselectfield');return false;">+</a> *}
				</td>
				<td><span style="line-height: 23px;">{'Noonefoundtoaddsee'|@getFixedLabel}<a href="javascript:;" title="{'SELECT'|@getFixedLabel}" onclick="getLinksUrl('','Settings','channelcode_externalcontact');">{'Howtoaddthem'|@getFixedLabel}</a></span></td>
			</tr>
			</tbody>
		</table>
		<table class="DetailContentTable linefeed" width="100%" cellspacing="0" cellpadding="0" border="0">
			<tbody>
			<tr>
				<td colspan="4" class="ld-from-headblock e">
					{* <b>{'Channelinformationsetting'|@getFixedLabel}</b> *}
					<div class="ld-from-headblock-title" tag="headblock-title">{'Channelinformationsetting'|@getFixedLabel}</div>
				</td>
			</tr>
			{if $VERSION_ACCOUNT eq 'dongmao'}
				<tr>
					<td class="ld-form-item-label" width="20%">
						客户档案
					</td>
					<td class="ld-form-item-content" width="80%">
						<input readonly="" name="servicecharge_id_name" type="text" fieldonly="0" value="{$SERVICECHAR_NAME}" class="ld-input-inner ld-input-inner-add">
						<input name="servicecharge_id" type="hidden" value="{$SERVICECHAR_ID}">
						{* <a class="icon-homeimg icon-select" href="javascript:;" title="{'SELECT'|@getFixedLabel}" onclick="showrelatedlist('ChannelCode','ServiceCharge','select','','servicecharge_id');"></a>
						<input class="icon-homeimg icon-clear inpb-reset" type="button" title="{'CLEAR'|@getFixedLabel}" onclick="clear_relatedfielddata('ServiceCharge','servicecharge_id','servicecharge_id_name','','Contacts','popupselectfield');return false;"> *}
						<a class="ld-text-select" href="javascript:;" title="{'SELECT'|@getFixedLabel}" onclick="showrelatedlist('ChannelCode','ServiceCharge','select','','servicecharge_id');">+</a>
						<a class="ld-text-clear" href="javascript:;" title="{'CLEAR'|@getFixedLabel}" onclick="clear_relatedfielddata('ServiceCharge','servicecharge_id','servicecharge_id_name','','Contacts','popupselectfield');return false;">+</a>
					</td>
				</tr>
				<tr>
					<td class="ld-form-item-label" width="20%">
						车辆信息
					</td>
					<td width="30%" class="ld-form-item-content">
						<input readonly="" name="customform100_id_name" type="text" fieldonly="0" value="{$CUSTOMFORM100_NAME}" class="ld-input-inner ld-input-inner-add">
						<input name="customform100_id" type="hidden" value="{$CUSTOMFORM100_ID}">
						{* <a class="icon-homeimg icon-select" href="javascript:;" title="{'SELECT'|@getFixedLabel}" onclick="showrelatedlist('ChannelCode','CustomForm100','select','','customform100_id');"></a>
						<input class="icon-homeimg icon-clear inpb-reset" type="button" title="{'CLEAR'|@getFixedLabel}" onclick="clear_relatedfielddata('CustomForm100','customform100_id','customform100_id_name','','Contacts','popupselectfield');return false;"> *}
						<a class="ld-text-select" href="javascript:;" title="{'SELECT'|@getFixedLabel}" onclick="showrelatedlist('ChannelCode','CustomForm100','select','','customform100_id');">+</a>
						<a class="ld-text-clear" href="javascript:;" title="{'CLEAR'|@getFixedLabel}" onclick="clear_relatedfielddata('CustomForm100','customform100_id','customform100_id_name','','Contacts','popupselectfield');return false;">+</a>
					</td>
				</tr>
			{/if}
			<tr>
				<td class="ld-form-item-label" width="20%">
					<font color="red">*</font>{'channelname'|@getFixedLabel}
				</td>
				<td class="ld-form-item-content" width="80%">
					<input fieldonly="0" type="text" tabindex="c" name="channelname" id="channelname" input_label="{'channelname'|@getFixedLabel}" value="{$DATA.channel_name}" class="ld-input-inner">
				</td>
			</tr>
			<tr>
				<td class="ld-form-item-label" width="20%" align="right">
					<input type="checkbox" class="second_switch" name="channelverify" value="yes" {if $DATA.channelverify neq 'no' } checked {/if}/>
				</td>
				<td class="ld-form-item-content" width="80%">
					{'Customersautomaticallybecomefriendswithoutconfirmation'|@getFixedLabel}
				</td>
			</tr>
		</table>
		<table class="DetailContentTable linefeed" width="100%" cellspacing="0" cellpadding="0" border="0">
			<tbody><tr>
				<td colspan="4" class="ld-from-headblock e">
					<div class="ld-from-headblock-title" tag="headblock-title">{'Labelthecorrespondingcustomerafterscanningthecode'|@getFixedLabel}</div>
				</td>
			</tr>
			<tr>
				<td class="ld-form-item-label" width="20%">
					<font color="red"></font>{'EnterpriseWeChatCustomerTags'|@getFixedLabel}
				</td>
				<td class="ld-form-item-content" width="80%">
					<input type="hidden" name="channellabel_id" id="channellabel_id" value="{$DATA.channel_label_string}"/>	
					<input id="channellabel" name="channellabel" class="ld-input-inner ld-input-inner-add" style="height:25px;line-height:25px;padding-left:8px;display:-webkit-inline-box;text-overflow:ellipsis;overflow:hidden;" value="{$DATA.channel_label}" readonly=""/>
					<a class="ld-text-select" href="javascript:;" title="{'SELECT'|@getFixedLabel}" onclick="channelcode_label();">+</a>
					{* <a class="ld-text-clear" href="javascript:;" title="{'CLEAR'|@getFixedLabel}" onclick="clear_relatedfielddata('','{$fldname}','{$fldname}_name','','{$MODULE}','popupselectfield');return false;">+</a> *}
				</td>
			</tr>
		</table>
		<table class="DetailContentTable linefeed" width="100%" cellspacing="0" cellpadding="0" border="0">
			<tbody><tr>
				<td colspan="4" class="ld-from-headblock e">
					<div class="ld-from-headblock-title" tag="headblock-title">{'Autogreetingsettings'|@getFixedLabel}</div>
				</td>
			</tr>
			<tr>
				<td class="ld-form-item-label" width="80%">
					{'Turnonautogreeting'|@getFixedLabel}
				</td>
				<td class="ld-form-item-content" width="20%">
					<input type="checkbox" class="second_switch" name="contact_way" onclick="contact_way_chk(event,'open')" {if $DATA.words neq '' or $DATA.card_title neq '' or $DATA.app_title neq '' or $DATA.file_name neq ''}checked{/if} />
				</td>
			</tr>
			<tr name="contact_way_tr" {if $DATA.words neq '' or $DATA.card_title neq '' or $DATA.app_title neq '' or $DATA.file_name neq ''}style="height: 50px;display:;"{else}style="display:none;"{/if}>
				<td class="ld-form-item-label" width="20%">
					<font color="red">*</font>{'REMINDS'|@getFixedLabel}{'SERVICECONTRACTSTYPE'|@getFixedLabel}：
				</td>
				<td class="ld-form-item-content select-input" width="80%">
					<input type="checkbox" name="contact_way_wenzi" onclick="contact_way_chk(event,'words')" {if $DATA.words neq ''}checked{/if} />
					<label style="margin-right: 15px !important;">{'Text1'|@getFixedLabel}</label>
					<input type="checkbox" name="contact_way_others" onclick="contact_way_chk(event,'others')" {if $DATA.contact_way_type neq ''}checked{/if}/>
					<label>{'JIUWEIPHONEOTHER'|@getFixedLabel}</label>
					<input type="radio" name="contact_way_other" value="card" onclick="contact_way_chk(event,'card')" {if $DATA.contact_way_type eq 'card'}checked{elseif $DATA.contact_way_type eq ''}disabled{/if}/><label>{'Card'|@getFixedLabel}</label>
					<input type="radio" name="contact_way_other" value="img" onclick="contact_way_chk(event,'img')"   {if $DATA.contact_way_type  eq 'img'}checked{elseif $DATA.contact_way_type eq ''}disabled{/if} /><label>{'PICTURE'|@getFixedLabel}</label>
					<input type="radio" name="contact_way_other" value="app" onclick="contact_way_chk(event,'app')"  {if $DATA.contact_way_type eq 'app'}checked{elseif $DATA.contact_way_type eq ''}disabled{/if} /><label>{'App'|@getFixedLabel}</label>
					<p class="colorC0" style="padding-top: 5px;">{'Twotypesofmessagetypescanbeselected'|@getFixedLabel}</p>
				</td>
			</tr>
			{* 文字 *}
			<tr name="contact_way_words_tr" {if $DATA.words neq ''}style="height: 65px;display:;"{else}style="height: 65px;display:none;"{/if}>
				<td class="ld-form-item-label" width="20%" align="right">
					<font color="red">*</font>{'Text1'|@getFixedLabel}：
				</td>
				<td class="ld-form-item-content" width="80%" align="left">
					<textarea class="ld-textarea-inner b" tabindex="d" input_label="{'Text1'|@getFixedLabel}" placeholder="{'pleaseenter'|@getFixedLabel}{'Text1'|@getFixedLabel}" fieldonly="0" name="words_content" id="words_content" cols="90" style="height: 36px;overflow: hidden; overflow-wrap: break-word; resize: horizontal;">{$DATA.words}</textarea><br/>
					<a href="javascript:;" class="for-example" title="">{'Text1'|@getFixedLabel}{'Welcomeexamples'|@getFixedLabel}</a><div class="for-example-img" id="pic_text"><img src="{{$imgExampleArr['text']}}"></div>
				</td>
			</tr>
			{* 链接卡片标题 *}
			<tr name="contact_way_card_tr1" {if $DATA.contact_way_type eq 'card'}style="height: 60px;display:;"{else}style="height: 60px;display:none;"{/if}>
				<td class="ld-form-item-label" width="20%" align="right">
					<font color="red">*</font>{'Card'|@getFixedLabel}{'MAILTITLE'|@getFixedLabel}
				</td>
				<td class="ld-form-item-content" width="80%" align="left">
					<input fieldonly="0" type="text" placeholder="{'pleaseenter'|@getFixedLabel}{'Card'|@getFixedLabel}{'MAILTITLE'|@getFixedLabel}" input_label="{'Card'|@getFixedLabel}{'MAILTITLE'|@getFixedLabel}" tabindex="c" name="card_title" id="card_title" value="{$DATA.card_title}" class="ld-input-inner">
				</td>
			</tr>
			{* 链接卡片描述 *}
			<tr name="contact_way_card_tr2" {if $DATA.contact_way_type eq 'card'}style="height: 60px;display:;"{else}style="height: 60px;display:none;"{/if}>
				<td class="ld-form-item-label" width="20%" align="right">
					<font color="red"></font>{'Card'|@getFixedLabel}{'CAMCARDCAPTION'|@getFixedLabel}
				</td>
				<td class="ld-form-item-content" width="80%" align="left">
					<textarea class="ld-textarea-inner b" tabindex="d" placeholder="{'pleaseenter'|@getFixedLabel}{'Card'|@getFixedLabel}{'CAMCARDCAPTION'|@getFixedLabel}" input_label="{'Card'|@getFixedLabel}{'CAMCARDCAPTION'|@getFixedLabel}" fieldonly="0" name="card_description" id="card_description" onblur="this.className='detailedViewTextBox'" cols="90" style="height: 36px; overflow: hidden; overflow-wrap: break-word; resize: horizontal;margin-top: 3px;">{$DATA.card_description}</textarea>
				</td>
			</tr>
			{* 链接卡片图片 *}
			<tr name="contact_way_card_tr3" {if $DATA.contact_way_type eq 'card'}style="height: 60px;display:;"{else}style="height: 60px;display:none;"{/if}>
				<td class="ld-form-item-label" width="20%" align="right">
					<font color="red">*</font>{'Card'|@getFixedLabel}{'Image'|@getFixedLabel}
				</td>
				<td class="ld-form-item-content" width="80%" align="left">
					<a href="javascript:;" class="uploadfile">{'Uploadpictures'|@getFixedLabel}
						<input type="file" name="cardFile" id="cardFile" onchange="channel_validateFile(this,'card');" accept="image/*" title="{'Uploadpictures'|@getFixedLabel}">
					</a><input type="hidden" value="{if $DATA.contact_way_type eq 'card'}{$DATA.file_name}{/if}" input_label="{'Uploadpictures'|@getFixedLabel}" name="card_hidden"><span name="span_card">{if $DATA.contact_way_type eq 'card'}{$DATA.file_name}{/if}</span><p class="colorC0">{'Therecommendedscaleoflinkcardimageis'|@getFixedLabel}</p>
				</td>
			</tr>
			{* 输入卡片链接 *}
			<tr name="contact_way_card_tr4" {if $DATA.contact_way_type eq 'card'}style="height: 50px;display:;"{else}style="height: 50px;display:none;"{/if}>
				<td class="ld-form-item-label" width="20%" align="right">
					<font color="red">*</font>{'Inputcardlink'|@getFixedLabel}
				</td>
				<td class="ld-form-item-content" width="80%" align="left">
					<input fieldonly="0" type="text" placeholder="{'Inputcardlink'|@getFixedLabel}" tabindex="c" input_label="{'Inputcardlink'|@getFixedLabel}" name="card_href" id="card_href" value="{$DATA.card_href}" class="ld-input-inner">
					<br /><a href="javascript:;" class="for-example" title="">{'Card'|@getFixedLabel}{'Welcomeexamples'|@getFixedLabel}</a>
					<div class="for-example-img" id="pic_card"><img src="{{$imgExampleArr['card']}}"></div>
				</td>
			</tr>
			{* 消息图片 *}
			<tr name="contact_way_img_tr1" {if $DATA.contact_way_type eq 'img'}style="height: 60px;"{else}style="height: 60px;display:none;"{/if}>
				<td class="ld-form-item-label" width="20%" align="right">
					<font color="red">*</font>{'REMINDS'|@getFixedLabel}{'PICTURE'|@getFixedLabel}
				</td>
				<td class="ld-form-item-content" width="80%" align="left">
					<a href="javascript:;" class="uploadfile">{'Uploadpictures'|@getFixedLabel}
						<input type="file" name="imgFile" id="imgFile" onchange="channel_validateFile(this,'img');" accept="image/*" title="{'Uploadpictures'|@getFixedLabel}">
					</a><input type="hidden" value="{if $DATA.contact_way_type eq 'img'}{$DATA.file_name}{/if}" name="img_hidden" input_label="{'REMINDS'|@getFixedLabel}{'PICTURE'|@getFixedLabel}" /><span name="span_img">{if $DATA.contact_way_type eq 'img'}{$DATA.file_name}{/if}</span><p class="colorC0">{'PleaseuploadpicturesinPNGandJPGformat'|@getFixedLabel}</p>
				</td>
			</tr>
			{* 小程序标题 *}
			<tr name="contact_way_app_tr1" {if $DATA.contact_way_type eq 'app'}style="height: 60px;display:;"{else}style="height: 60px;display:none;"{/if}>
				<td class="ld-form-item-label" width="20%" align="right">
					<font color="red">*</font>{'App'|@getFixedLabel}{'MAILTITLE'|@getFixedLabel}
				</td>
				<td class="ld-form-item-content" width="80%" align="left">
					<input fieldonly="0" type="text" placeholder="{'pleaseenter'|@getFixedLabel}{'App'|@getFixedLabel}{'MAILTITLE'|@getFixedLabel}" input_label="{'App'|@getFixedLabel}{'MAILTITLE'|@getFixedLabel}" tabindex="c" name="app_title" id="app_title" value="{$DATA.app_title}" class="ld-input-inner">
				</td>
			</tr>
			{* 小程序封面图 *}
			<tr name="contact_way_app_tr2" {if $DATA.contact_way_type eq 'app'}style="height: 60px;display:;"{else}style="height: 60px;display:none;"{/if}>
				<td class="ld-form-item-label" width="20%" align="right">
					<font color="red">*</font>{'App'|@getFixedLabel}{'Cover'|@getFixedLabel}
				</td>
				<td class="ld-form-item-content" width="80%" align="left">
					<a href="javascript:;" class="uploadfile">{'Uploadpictures'|@getFixedLabel}
						<input type="file" name="appFile" id="appFile" onchange="channel_validateFile(this,'app');" accept="image/*" title="{'Uploadpictures'|@getFixedLabel}">
					</a><input type="hidden" value="{if $DATA.contact_way_type eq 'app'}{$DATA.file_name}{/if}" name="app_hidden" input_label="{'App'|@getFixedLabel}{'Cover'|@getFixedLabel}"><span name="span_app">{if $DATA.contact_way_type eq 'app'}{$DATA.file_name}{/if}</span><p class="colorC0">{'PleaseuploadpicturesinPNGandJPGformat'|@getFixedLabel}</p>
				</td>
			</tr>
			{* 小程序AppID *}
			<tr name="contact_way_app_tr3" {if $DATA.contact_way_type eq 'app'}style="height: 60px;display:;"{else}style="height: 60px;display:none;"{/if}>
				<td class="ld-form-item-label" width="20%" align="right">
					<font color="red">*</font>{'App'|@getFixedLabel}AppID
				</td>
				<td class="ld-form-item-content" width="80%" align="left">
					<input fieldonly="0" type="text" placeholder="{'pleaseenter'|@getFixedLabel}{'App'|@getFixedLabel}AppID" tabindex="c" input_label="{'App'|@getFixedLabel}AppID" name="app_id" id="app_id" value="{$DATA.app_id}" class="ld-input-inner">
					<br>{'thisappletmusthavebeenassociated'|@getFixedLabel}<a href="https://work.weixin.qq.com/help?doc_id=13104" target="_blank">{'Seehowtorelate'|@getFixedLabel}</a>
				</td>
			</tr>
			{* 小程序 Page 路径 *}
			<tr name="contact_way_app_tr4" {if $DATA.contact_way_type eq 'app'}style="height: 60px;display:;"{else}style="height: 60px;display:none;"{/if}>
				<td class="ld-form-item-label" width="20%" align="right">
					<font color="red">*</font>{'App'|@getFixedLabel} Page {'route'|@getFixedLabel}
				</td>
				<td class="ld-form-item-content" width="80%" align="left">
					<input fieldonly="0" type="text" placeholder="{'pleaseenter'|@getFixedLabel}{'App'|@getFixedLabel} Page {'route'|@getFixedLabel}" input_label="{'App'|@getFixedLabel} Page {'route'|@getFixedLabel}" tabindex="c" name="app_src" id="app_src" value="{$DATA.app_src}" class="ld-input-inner">
					<br><p style="float:left;">{'thisappletmusthavebeenassociated'|@getFixedLabel}</p><a class="for-example" href="javascript:;">{'Appexample'|@getFixedLabel}</a>
					<div class="for-example-img" id="pic_miniprogram"><img src="{{$imgExampleArr['miniprogram']}}"></div>
				</td>
			</tr>
		</table>
	</div>
	</form>
</div>

