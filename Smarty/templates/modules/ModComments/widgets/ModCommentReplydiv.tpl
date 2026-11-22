<div class="ld-detail-ModComments-create" data-type="replycontent_div" id="replycontent_{$replyedid}_div" data-replyid="{$replyedid}" style="display:none;">
        <input name="isPreviewEnable" value="{$isPreviewEnable}" type="hidden">
        <fieldset>
            <textarea id="create_reply_{$replyedid}">{if $defaultcontent neq ''}{$defaultcontent}{/if}</textarea>
            <div class="comment-uploader-list" name="upload_image" style="display:none;">
                <span>{'Image'|@getFixedLabel}:</span>
            </div>
            <div class="comment-uploader-list" name="upload_filename" style="display:none;">
                <span>{'Attachment'|@getFixedLabel}:</span>
            </div>
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
            <div class="ld-detail-ModComments-images-info" >
                <div class="alldelete-images">全部删除</div>
                <div class="images-info">共添加了1个文件，总大小763KB</div>
            </div>
        </div>
        <div class="ld-detail-ModComments-Cc" style="display:none;">
            <span><i>+</i>选择抄送范围</span>
        </div>
        <div class="ld-detail-ModComments-toolbar">
            <a class="addtouch addtouch_reply" data-tag="addtouch_at_btn" data-type="reply" data-modcommentid="{$replyedid}"  href="javascript:void(0);" title=""></a>
            {*<a>
                        <img src="https://a9.fspage.com/FSR/frontend/html/fx/assets/images/clear-3254726015.gif" style="width: 18px;height: 18px;background: url(./themes/icon/send_function_icon.png) -87px 1px no-repeat;background-size: auto;background-size: 254px 35px;">
            </a>*}
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
                <div class="ld-button ld-button-primary" onclick="ModCommentsCommon.addReply('{$replyedid}', '{$parentid}');">{'Reply'|@getFixedLabel}</div>
                <div class="ld-button" onclick="ModCommentsCommon.hiddenReplydiv('{$replyedid}', '{$parentid}');">{'CANCEL'|@getFixedLabel}</div>
            </div>
        </div>
    </div>