<div class="List3Box">
{if $AJAX neq 'yes'}
<div name="relatelisttab">
    <div class="detail-relation-box">
    <ul id="nav-relation-btn" class="detail-relation-btn">
        <li>
            <a class="current" href="javascript:;" onclick="channelcode_relateds(this)" type="DetailViewTab" relatetag="detailview" relatedid="{$RECORD}">
                <span>{'details1'|@getFixedLabel}</span>
            </a>
        </li>
		<li>
			<a href="javascript:;" onclick="channelcode_relateds(this)" type="DetailViewTab" relatetag="code_history" relatedid="{$RECORD}">
				<span>{'scanningcustomers'|@getFixedLabel}</span>
				{if $HISTORYCOUNT neq 0}
					<b tag="code_history_count" relateidtag="0" style="">[{$HISTORYCOUNT}]</b>
				{/if}
			</a>
		</li>
    </ul>
</div>

</div>
{/if}
<div class="DivCTable" name="channelcode_detail_div" style="height:800px;">
	{*<table width="100%" cellspacing="0" cellpadding="0" border="0">
    <tbody>
	<tr>
        <td align="left">
            <div class="">
                <ul class="D_btn_box a">
					<li class="D_anu_a D_menu_hova detail_menu" onclick="detail_channelcode_edit(event,{$RECORD});return false;">
						<a title="{'EDIT'|@getFixedLabel}" tag="" href="javascript:;">
														<b class="icon-homeimg icon-pen"></b>
							<span>{'EDIT'|@getFixedLabel}</span>
						</a>
					</li>
                    <li class="D_anu_a D_menu_hova detail_menu" onclick="detail_channelcode_delete(event,{$RECORD})">
						<a title="{'DELETE'|@getFixedLabel}" tag="" href="javascript:;">
														<b class="icon-homeimg icon-check"></b>
							<span>{'DELETE'|@getFixedLabel}</span>
						</a>
					</li>                                                                 
                </ul>
			</div>
        </td>
        <td align="right"></td>
    </tr>
</tbody></table>*}
<div name="advance_stage_div" class="advance_stage_div"><link rel="stylesheet" href="themes/softed/multistep/MultiStep.min.css" type="text/css">
<link rel="stylesheet" href="themes/softed/multistep/MultiStep-theme.min.css" type="text/css"> 
<div id="tbltgm">
<table width="100%" cellspacing="0" cellpadding="0" border="0">
    <tbody><tr valign="top">
        <td style="padding:0px">
            <!-- Command Buttons -->
            <table class="linefeed" width="100%" cellspacing="0" cellpadding="0" border="0">
				<tbody>
				<tr>
					<td>
						<div name="displayfields">
							<table width="100%" cellspacing="0" cellpadding="0" border="0">
							<tbody>
								<tr><td style="width:100%;">
									<table width="100%" cellspacing="0" cellpadding="0" border="0">
																	
									</table>
									 <div class="DivCName DivCNamehover" onclick="showHideStatus('tbl{'BASICINFO'|@getFixedLabel}','aid{'BASICINFO'|@getFixedLabel}');">
                						<span class="" id="aid{'BASICINFO'|@getFixedLabel}" name="aid{'BASICINFO'|@getFixedLabel}"></span>{'BASICINFO'|@getFixedLabel}
									</div>
                                    <div class="DivCNotice" style="width:auto;display:block;" id="tbl{'BASICINFO'|@getFixedLabel}" name="tbl{'BASICINFO'|@getFixedLabel}">
    				                        
										<table class="DetailContentTable" width="100%" cellspacing="1" cellpadding="0" border="0">                     
											<tbody>
											<tr>                               
												<td class="DetailedTd1Label" width="20%" align="right"><input type="hidden" id="hdtxt_IsAdmin" value="1"><span>{'Scancodetocontactstaff'|@getFixedLabel}：</span></td>
												<td class="DetailedTd2Info" width="30%" align="left">
													<font color="">{$DATA.channel_username}</font>&nbsp;
												</td>
												<td class="DetailedTd1Label" width="20%" align="right"><input type="hidden" id="hdtxt_IsAdmin" value="1"><span>{'channelname'|@getFixedLabel}：</span></td>
												
												<td class="DetailedTd2Info" width="30%" align="left">
													<font color="">{$DATA.channel_name}</font>&nbsp;
												</td>			    													    												    											                                                									
											</tr>
											<tr>                               
												<td class="DetailedTd1Label" width="20%" align="right"><input type="hidden" id="hdtxt_IsAdmin" value="1"><span>{'Scanthecodeandlabelthecorrespondingcustomers'|@getFixedLabel}：</span></td>
												<td class="DetailedTd2Info" width="30%" align="left">
													<font color="">{$DATA.channel_label}</font>&nbsp;
												</td>
												<td class="DetailedTd1Label" width="20%" align="right"><input type="hidden" id="hdtxt_IsAdmin" value="1"><span>{'Welcomemessageform'|@getFixedLabel}：</span></td>
												
												<td class="DetailedTd2Info" width="30%" align="left">
													<font color="">{$DATA.channeltype}</font>&nbsp;
												</td>			    													    												    											                                                									
											</tr>
											<tr>                               
												<td class="DetailedTd1Label" width="20%" align="right"><input type="hidden" id="hdtxt_IsAdmin" value="1"><span>{'Person_in_charge'|@getFixedLabel}：</span></td>
												<td class="DetailedTd2Info" width="30%" align="left">
													<font color="">{$DATA.creator_name}</font>&nbsp;
												</td>
												<td class="DetailedTd1Label" width="20%" align="right"><input type="hidden" id="hdtxt_IsAdmin" value="1"><span>{'Createtime1'|@getFixedLabel}：</span></td>
												
												<td class="DetailedTd2Info" width="30%" align="left">
													<font color="">{$DATA.createdtime}</font>&nbsp;
												</td>			    													    												    											                                                									
											</tr>
											{if $VERSION_ACCOUNT eq 'dongmao'}
												<tr>                               
													<td class="DetailedTd1Label" width="20%" align="right"><input type="hidden" id="hdtxt_IsAdmin" value="1"><span>客户档案：</span></td>
													<td class="DetailedTd2Info" width="30%" align="left">
														<a title="{$SERVICECHAR_NAME}" fieldname="servicecharge_id" module="Contacts" referencemodule="ServiceCharge" referencerecord="{$SERVICECHAR_ID}" record="{$SERVICECHAR_ID}" lasturl="" href="index.php?pageto_module=ServiceCharge&pageto_action=index&pageto_record={$SERVICECHAR_ID}" onclick="ListReferenceLinkClick(ld(this),event)">{$SERVICECHAR_NAME}</a>
													</td>								                                                							<td class="DetailedTd1Label" width="20%" align="right"><input type="hidden" id="hdtxt_IsAdmin" value="1"><span>车辆信息：</span></td>
													<td class="DetailedTd2Info" width="30%" align="left">
														<a title="{$CUSTOMFORM100_NAME}" fieldname="customform100_id" module="Contacts" referencemodule="CustomForm100" referencerecord="{$CUSTOMFORM100_ID}" record="{$CUSTOMFORM100_ID}" lasturl="" href="index.php?pageto_module=CustomForm100&pageto_action=index&pageto_record={$CUSTOMFORM100_ID}" onclick="ListReferenceLinkClick(ld(this),event)">{$CUSTOMFORM100_NAME}</a>
													</td>
												</tr>
											{/if}
											</tbody>
										</table>
									</div>
								 </td>
								</tr>                                   
						</tbody></table>
					</div>
                  </td>
                  </tr>
					<tr>
					<td>
						<div>
							<table width="100%" cellspacing="0" cellpadding="0" border="0">
							<tbody>
								<tr><td style="width:100%;">
									<table width="100%" cellspacing="0" cellpadding="0" border="0">
																	
									</table>
									 <div class="DivCName DivCNamehover" onclick="showHideStatus('tbl{'channelcode'|@getFixedLabel}','aid{'channelcode'|@getFixedLabel}');">
                						<span class="" id="aid{'channelcode'|@getFixedLabel}" name="aid{'channelcode'|@getFixedLabel}"></span>{'channelcode'|@getFixedLabel}
									</div>
                                    <div class="DivCNotice" style="width:auto;display:block;" id="tbl{'channelcode'|@getFixedLabel}" name="tbl{'channelcode'|@getFixedLabel}">
    				                        
										<table class="DetailContentTable" width="100%" cellspacing="1" cellpadding="0" border="0">                     
											<tbody><tr>                               
												<td class="DetailedTd1Label" width="20%" align="right"><input type="hidden" id="hdtxt_IsAdmin" value="1"><span>{'Scancodetocontactstaff'|@getFixedLabel}：</span></td>
												<td class="DetailedTd2Info" width="30%" style="height:200px;" align="left">
													<div class="detail-img" module="Products" record="" fieldname="imagename">
														<div id="Carouselsingle" style="text-align: left">
															<img src="{$DATA.qr_code}" width="166" border="0">
														</div>
													</div>
												</td>
												<td class="DetailedTd1Label" width="20%" align="right">
													{if $DATA.qr_code neq '' }
														<input type="hidden" id="hdtxt_IsAdmin" value="1">
														<img name="qrcode2" onclick="" data-original="{$DATA.qr_code}" src="{$DATA.qr_code}" alt="" width="0" height="0">
														<a href="javascript:void(0);" onclick="ld('img[name=qrcode2]').click();" title="{'DOWNLOAD'|@getFixedLabel}{'channelcode'|@getFixedLabel}">{'DOWNLOAD'|@getFixedLabel}{'channelcode'|@getFixedLabel}</a></td>
													{/if}
												</td>
												
												<td class="DetailedTd2Info" width="30%" align="left">
													
												</td>			    													    												    											                                                									
											</tr>
											</tbody>
										</table>
									</div>
								 </td>
								</tr>                                   
						</tbody></table>
					</div>
                  </td>
                  </tr>
                  {if $VERSION_ACCOUNT eq 'dongmao' && $SERVICECHAR_ID gt 0}
					<tr>
						<td>
							<div>
								<table width="100%" cellspacing="0" cellpadding="0" border="0">
								<tbody>
									<tr><td style="width:100%;">
										<table width="100%" cellspacing="0" cellpadding="0" border="0">
																		
										</table>
										 <div class="DivCName DivCNamehover" onclick="showHideStatus('tbl签到码','aid签到码');">
											<span class="" id="aid签到码" name="aid签到码"></span>签到码
										</div>
										<div class="DivCNotice" style="width:auto;display:block;" id="tbl签到码" name="tbl签到码">
												
											<table class="DetailContentTable" width="100%" cellspacing="1" cellpadding="0" border="0">                     
												<tbody><tr>                               
													<td class="DetailedTd1Label" width="20%" align="right"><input type="hidden" id="hdtxt_IsAdmin" value="1"><span>扫码签到：</span></td>
													<td class="DetailedTd2Info" width="30%" style="height:200px;" align="left">
														<div class="detail-img" module="Products" record="" fieldname="imagename">
															<div id="Carouselsingle" style="text-align: left">
																<img src="{$sign_url}">
															</div>
														</div>
													</td>
													<td class="DetailedTd1Label" width="20%" align="right">
														<img name="qrcode0" onclick="" data-original="{$sign_url}" src="{$sign_url}" alt="" width="0" height="0">
														<a href="javascript:void(0);" onclick="ld('img[name=qrcode0]').click();" title="{'DOWNLOAD'|@getFixedLabel}签到码">{'DOWNLOAD'|@getFixedLabel}签到码</a></td>
													<td class="DetailedTd2Info" width="30%" align="left">
														
													</td>			    													    												    											                                                									
												</tr>
												</tbody>
											</table>
										</div>
									 </td>
									</tr>                                   
							</tbody></table>
						</div>
					  </td>
					</tr>
				 {/if}
      			</tbody></table>
      		</div>      
            <!--	related	-->
      		
      	</td>
  </tr> 
</tbody></table>
</div>
</div>

<script>


    // 使用listview.js中的previewImage函数 展示图片
    ld(function(){
       
        var images= ld('#tbltgm img');
        if(images.length>0){
            ld.each(images,function (i,val) {
                // 使用previewImage函数 需要提前加载加载事件。要不会出现第一次点击不能弹出
                previewImage(val);
            })
        }
    })
</script>