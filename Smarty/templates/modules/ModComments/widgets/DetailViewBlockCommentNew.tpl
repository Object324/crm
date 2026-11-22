{*+**********************************************************************************
 * The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 ***********************************************************************************
 *}
<!--修改编码格式:统一编码：UTF-8-->
{if $MODULE neq 'ModComments'}
    {if empty($smarty.request.ajax) && 'ModComments'|@vtlib_isModuleActive == true}
    <div class="DivCName" id="modcomment_srollto" name="modcomment_srollto">
        <div style="margin: 0 10px;">{'ModComments'|@getTranstab}
            {if $MODCOMMENTDISPLAYRIGHT neq 'yes'}
            <a class="tip-items-list" data-commentmode="advanced" onclick="changeMode(this)" id = "commentMode" data-tip="{'CONCISEMODE'|@getFixedLabel}" data-direction ="top" data-type="position"><img src="themes/softed/images/commentmode1.png" style="margin-bottom: 2px; margin-left: 10px;"></a>
            {/if}
        </div>

    </div>
    <div class="DivCNotice DivCNoticeBor" style="display: block;" id="detail_coment_div_{$UIKEY}" name="detail_coment_div_{$UIKEY}">
    	<div class="Pldiv">
            <div id="comment_create_div" class="ld-detail-ModComments-create" data-commentid="{$UIKEY}" style="margin-top: 8px;">
                <fieldset>
                    <textarea id="create_comment_{$UIKEY}"></textarea>
                </fieldset>
                <div class="ld-detail-ModComments-images-warp" style="display:none;">
                    <div>
                        <div class="ld-detail-ModComments-images">
                            <canvas width="98" height="98"></canvas>
                            <div class="insert-imagess"></div>
                            <div class="delete-images">X</div>
                        </div>
                        <div class="ld-detail-ModComments-addimages">
                            <input class="ld-detail-ModComments-addimages-input"/>
                        </div>
                    </div>
                    <div class="ld-detail-ModComments-images-info">
                        <div class="alldelete-images">全部删除</div>
                        <div class="images-info">共添加了1个文件，总大小763KB</div>
                    </div>
                </div>
                <div class="ld-detail-ModComments-Cc" id="comment_ccrange" tag="CCrange">
                    <ul class="reader-bar-list">
                        {if $copyuser neq false && is_array($copyuser)}
                            {foreach key = SMOWERID item = SMOWERLastName from = $copyuser}
                            <li userid="{$SMOWERID}">
                                <span class="item-name">{$SMOWERLastName}</span><span class="remove-h">×</span>
                            </li>
                            {/foreach}
                        {/if}
                    </ul>
                    <span class="input-tip" onclick="ModCommentsCommon.selectCcrange(this);"><i>+</i>{'SELECTCCRANGE'|@getFixedLabel}</span>
                </div>
                <div class="comment-uploader-list" name="upload_image" style="display:none;">
                    <span>{'Image'|@getFixedLabel}:</span>
                </div>
                <div class="comment-uploader-list" name="upload_filename" style="display:none;">
                    <span>{'Attachment'|@getFixedLabel}:</span>
                </div>
                <div class="ld-detail-ModComments-toolbar">
                    <input name="isPreviewEnable" type="hidden" value="{$isPreviewEnable}">
                    <a class="addtouch addtouch_reply" data-tag="addtouch_at_btn" data-type="comment" data-modcommentid="{$UIKEY}" href="javascript:void(0);" title=""></a>
                    {*<a><img src="https://a9.fspage.com/FSR/frontend/html/fx/assets/images/clear-3254726015.gif" style="width: 18px;height: 18px;background: url(./themes/icon/send_function_icon.png) -87px 1px no-repeat;background-size: auto;background-size: 254px 35px;"></a>*}
                    {if $isImgEnable eq 'yes'}
                        <a class="addimg" data-tag="addimg_at_btn" data-type="comment" data-modcommentid="{$UIKEY}" href="javascript:void(0);" title="">
                            <div name="comment_image" id="comment_image" class="homeAddfu"></div>
                        </a>
                    {/if}
                    {if $isAttEnable eq 'yes'}
                        <a class="addfu" data-tag="addfu_at_btn" data-type="comment" data-modcommentid="{$UIKEY}" href="javascript:void(0);" title="">
                            <div name="comment_filename" id="comment_filename" class="wu-example homeAddfu"></div>
                        </a>
                    {/if}
                    <div class="ld-detail-ModComments-btn">
                        <div name="addcomment" class="ld-button ld-button-primary"  onclick="ModCommentsCommon.addComment('{$UIKEY}', '{$ID}');">{'PUBLISH'|@getFixedLabel}</div>
                        {*<div class="ld-button ld-button-canceld"  style="display:none;">取消</div>*}
                    </div>
                </div>
            </div>
        </div>
    </div>
    <!--遮罩层-->
    <div class="ui-mask" style=""></div>
    <!-- 负责人 -->
    <div id="ModCommentUsersDiv" class="ui-popup ui-popup-small" style="width:255px;display:none;">
    	<div id="modcommentuser">
    		<div class="ui-popup-head">
    	        <div class="ui-popup-cursor" style="float:left;">&nbsp;</div>
    			{*<ul class='usercontrol'>
    				<li tag='Recently'>最近</li>
    				<li tag='Colleague'>同事</li><!-- class='On' -->
    				<li tag='Department'>部门</li>
    			</ul>*}
    			<input class="searchText" type='text' name='searchColleagueText' id='searchColleagueText' value='' placeholder='' tag='' data-replyid='' onkeyup="CommentclickSelectControl(this,event)" />
    			<div class='ui-popup-close' style="float: right;">
    				<b>×</b>
    			</div>
    		</div>
    		<div class="ui-popup-centent">
    			<div class='usercontent' id="RecentlyDiv" style='display:none;'></div>
    			<div class='usercontent' id="ColleagueDiv" style='display:none;'></div>
    			<div class='usercontent' id="DepartmentDiv" style='display:none;'></div>
    		</div>
    	</div>
    </div>
    <!--共有几个同事弹出-->
    {*<div class="fs-tip" id="modcommentcc-tip"  style="display: none; position: absolute; top: 1062px;">
    	<span class="close">×</span>
    	<div class="share-group-tpl">
    		<div class="share-group-warp">
    		</div>
    		<div class="share-group-countman">
    			共<span class="num">12</span>人
    		</div>
    	</div>
    	<div class="arrows-wrapper arrows-t">
    		<div class="arrows-inner"></div>
    	</div>
    </div>*}
    <div class="DivCName DivCNamehover" onclick="showHideStatus('contentwrap_{$UIKEY}','aid{$UIKEY}');">
        <label class="cursorPointer" style='display:inline-block; width:50%'>
            <span class="" id="aid{$UIKEY}" name="aid{$UIKEY}"></span>{'ModComments'|@getTranstab}
        </label>
        <label name="modcomment_highselect" id="modcomment_highselect"  style="float: right;padding-right: 10px">
        	{'DISPLAY'|@getFixedLabel} <select style="width:auto;padding-left: 5px;" class="commonDetailedTextBox small" onchange="ModCommentsCommon.reloadContentWithFiltering('{$WIDGET_NAME}', '{$ID}', this.value, 'contentwrap_{$UIKEY}', 'indicator{$UIKEY}');">
        		<option value="All" {if $CRITERIA eq 'All'}selected{/if}>{'ALL'|@getFixedLabel}</option>
        		<option value="Last5" {if $CRITERIA eq 'Last5'}selected{/if}>{'TOP5'|@getFixedLabel}</option>
        		<option value="Mine" {if $CRITERIA eq 'Mine'}selected{/if}>{'MINEADD'|@getFixedLabel}</option>
        	</select>
        </label>
    </div>
    {/if}
    <div id="contentwrap_{$UIKEY}" name="contentwrap_{$UIKEY}" style="width: 100%;background: #fff;">
        {$MODCOMMENTOBJ}
    </div>

{/if}
	