<style>
    .ld_uitype_list{
        width: 100%;
        display: flex;
        margin-top:16px;
    }
    .ld_uitype_list_item{
        padding-right: 32px;
    }
    .ld_uitype_list_item_img{
        width: 100%;
        border-radius: 8px;
        border: 1px solid #DCDEE0;
        overflow: hidden;
        position: relative;
        cursor: pointer;
    }
    .ld_uitype_list_item:hover .ld_uitype_list_item_img{
        box-shadow: 0px 2px 24px 0px rgba(200,201,204,0.5);
    }
    .uiselect.ld_uitype_list_item_img{
        border: 1px solid #3B7CFF;
    }
    .ld_leftmenu_ui_setting .ld_uitype_list_item_img img{
        width: 220px;
    }
    .ld_uitype_list_item_descdription{
        margin-top:8px;
    }
    .ld_uitype_list_item_descdription label{
        cursor: pointer;
        display: inline-flex;
        align-items: center;
    }
    .ld_uitype_list_item_descdription label span{
        font-weight: 400;
        font-size: 14px;
        color: #323233;
        line-height: 14px;
        text-align: left;
        font-style: normal;
        height:14px;
        white-space: normal;
        overflow-wrap: break-word;
    }
    .ld_uitype_list_item_descdription input{
        margin-right: 10px;
        vertical-align: initial;
    }
</style>
<div style="height: 100%">
    <div>
        <div style="margin-left: 20px; padding-top: 15px;">{'SETLOGINSWIPERRATIO'|@getFixedLabel}</div>
        <div class="ld_leftmenu_ui_setting" style="margin-left: 20px;">
            <div class="ld_uitype_list" id="loginswiperratio">
                <div class="ld_uitype_list_item" data-type="1:2">
                    <div class="ld_uitype_list_item_img {if $SWIPERRATIO == '1:2'}uiselect{/if}">
                        <img src="./themes/icon/loginswipertype1.png">
                        <span class="bingo" {if $SWIPERRATIO == '1:2'}style="display: block;"{/if}><i class="bingocheck"></i></span>
                    </div>
                    <div class="ld_uitype_list_item_descdription">
                        <label>
                            <input type="radio" name="ld_leftmenu_ui_setting" {if $SWIPERRATIO == '1:2'}checked=""{/if}>
                            <span>{'swipersmallproportion'|@getFixedLabel}</span>
                        </label>
                    </div>
                </div>
                <div class="ld_uitype_list_item" data-type="2:1">
                    <div class="ld_uitype_list_item_img {if $SWIPERRATIO == '2:1'}uiselect{/if}">
                        <img src="./themes/icon/loginswipertype2.png">
                        <span class="bingo" {if $SWIPERRATIO == '2:1'}style="display: block;"{/if}><i class="bingocheck"></i></span>
                    </div>
                    <div class="ld_uitype_list_item_descdription">
                        <label>
                            <input type="radio" name="ld_leftmenu_ui_setting" {if $SWIPERRATIO == '2:1'}checked=""{/if}>
                            <span>{'swiperbigproportion'|@getFixedLabel}</span>
                        </label>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <div class="displayflex" style="height: 50px;align-items: center;justify-content: end;margin-right: 20px;">
        <a href="javascript:;" class="ld-button ld-button-primary" onclick="swiptersettings.editswiper(0)" name="LoginSettingEdit" title="{'NEW'|@getFixedLabel}">{'NEW'|@getFixedLabel}</a>
        <a href="javascript:;" class="ld-button" onclick="swiptersettings.restdefaultswiper()" name="restswiperdefault" title="{'RESTORETHEDEFAULT'|@getFixedLabel}">{'RESTORETHEDEFAULT'|@getFixedLabel}</a>
    </div>
    <div class="mar-1" style="overflow-y: auto;">
        <table id="CamCardDetail" class="settingTable fir-center" width="100%" cellspacing="0" cellpadding="0">
            {* BUG0068275 txy 2023.06.18 固定表头加滚动时表头加阴影*}
            <tr style="position: sticky; top:0px;z-index:1;">
                <th>#</th>
                <th>{'Carousel'|@getFixedLabel}</th>
                <th>{'WHETHERTODISPLAY'|@getFixedLabel}</th>
{*                <th>{'LINK'|@getFixedLabel}</th>*}
                <th>{'OPERATING'|@getFixedLabel}</th>
            </tr>
            {assign var="i" value=0}
            {foreach from=$LOGINSWIPERARR item=swiperinfo key=key}
                {assign var="i" value=$i+1}
                {if $i mod 2 eq '0'}
                    <tr id="setting_{$i}" data-swiperid="{$swiperinfo['id']}" class="lvtColDataBj ld-category-draggable" onmouseout="listOnMouseOut(ld(this),'On');" onmouseover="listOnMouseOver(ld(this));">
                {else}
                    <tr id="setting_{$i}" data-swiperid="{$swiperinfo['id']}" class="lvtColData ld-category-draggable" onmouseout="listOnMouseOut(ld(this),'on');" onmouseover="listOnMouseOver(ld(this));">
                {/if}
                <td>{$i}</td>
                <td>
                    <img style="{if $SWIPERRATIO == '1:2'}height:160px;{else}width: 160px;{/if}" src="{$swiperinfo['content']}">
                </td>
                <td><input type="checkbox" class="second_switch" {if $swiperinfo['isshow'] == 'yes'}checked=""{/if} onchange="swiptersettings.isshowswiper(this,{$swiperinfo['id']})" /></td>

{*                <td>{$swiperinfo['url']}</td>*}
                <td style="width: 175px;">
                    <a class="Anu3_a" href="javascript:void(0)" onclick="swiptersettings.editswiper({$swiperinfo['id']})">{'EDIT'|@getFixedLabel}</a>
                    {if count($LOGINSWIPERARR) > 1}
                    <a class="Anu3_a redFont" href="javascript:void(0)" onclick="swiptersettings.deleteswiper({$swiperinfo['id']})">{'DELETE'|@getFixedLabel}</a>
                    {/if}
                    <a class="Anu3_a ld-dragicon drag-handle sort-tip-items" style="display: none;cursor: move;" data-tip="{'DRAGTOSORT'|@getFixedLabel}" data-direction="left" data-type="position" style="cursor: move; margin-top: 0px;"></a>
                </td>
                </tr>
            {/foreach}
        </table>
    </div>
</div>
<script>
    ld('#loginswiperratio .ld_uitype_list_item').off('click').on('click',function(){
        if(ld(this).find('.ld_uitype_list_item_img').hasClass('uiselect')){
            return false;
        }
        else{
            ld('.ld_uitype_list_item_img.uiselect').removeClass('uiselect');
            ld('span.bingo').hide();
            ld(this).find('.ld_uitype_list_item_img').addClass('uiselect');
            ld(this).find('span.bingo').show();
            ld(this).find('input[name=ld_leftmenu_ui_setting]').click();
            var type = ld(this).data('type');
            ldAjax('index.php?module=Settings&action=SettingsAjax&file=LoginSettingsSwiperRatio&type='+type,"",function(data){
                ld('#rptContentLoading').hide();
                if(data.code==1){
                    ld("#CamCardViewDetail").html(data.result.content);
                    MessagePopup.TipZero_success(arrJsPopLabel['SUCCESSFULLYSAVED']);
                    var surl = 'index.php?module=Settings&action=SettingsAjax&file=LoginSettingsSwiper&loginui=new';
                    ldAjax(surl, "", function (data) {
                        ld('#rptContentLoading').hide();
                        if (data.code == 1) {
                            ld("#CamCardViewDetail").html(data.result.content);
                        }
                    })
                }
            })
        }
    });
    ld('#CamCardDetail').find('tr').hover(
        function () {
            ld(this).find('.drag-handle').show();
        },
        function () {
            ld(this).find('.drag-handle').hide();
        }
    );
    Sortable.create(ld('#CamCardDetail tbody').get(0), {
        draggable:".ld-category-draggable",
        handle:".drag-handle",
        sort:true,
        onEnd: function (evt){
            var idarr = [];
            ld('#CamCardDetail tr').each(function (index,obj) {
                if(index == 0){
                    return true;
                }
                idarr.push(ld(obj).data('swiperid'));
            });
            var idstr = idarr.toString();
            var surl = 'index.php?module=Settings&action=SettingsAjax&file=LoginSettingsSwiperSequence&swiperidstr='+idstr;
            ldAjax(surl,"",function(data){
                if(data.code==1)
                {
                    var surl = 'index.php?module=Settings&action=SettingsAjax&file=LoginSettingsSwiper&loginui=new';
                    ldAjax(surl,"",function(data){
                        ld('#rptContentLoading').hide();
                        if(data.code==1){
                            ld("#CamCardViewDetail").html(data.result.content);
                        }
                    })
                }
            })
        }
    })

    function swiptersettings() {

    }
    swiptersettings.editswiper = function (swiperid) {
        var crmPopupobj=CrmPopup.load("","","","LdPopWidth600px",'Settings',"","","","");
        var surl = 'index.php?module=Settings&action=SettingsAjax&file=LoginSettingsSwiperEdit&swiperid='+swiperid;
        ldAjax(surl,"",function(data){
            if(data.code == 1){
                crmPopupobj.setParams(data.result.title,swiptersettings.saveswiper,"","LdPopWidth600px","Settings","",data.result.oktext,"",data.result.canceltext,"");
                crmPopupobj.show(data.result.content);
                crmPopupobj.center();
                var uploadFileobj = new WebUploadFile();
                var globalModWebUploadType=uploadFileobj.uploadType();
                var popupobj=CrmPopup.getPopupObj('last');
                if(globalModWebUploadType=='cos') {
                    getJsScript('include/js/webuploader/Speical_webUploaderCos.js', function () {

                        ld('#'+popupobj.divid).find("[name=loginswiperchooseimg").special_powerWebUploadCos({
                            fileTypeDuplicate:'yes',	//附件类型判断
                            fileNameDuplicate:'yes',	//同名附件判断
                            mode:'loginswiper',
                            replyid:0,
                            module:'Settings',	//当前模块
                            parentdivid:popupobj.divid,
                            jsonData:'',	//edit data,编辑界面显示已上传的附件
                            record:'',	//单据单据id
                            admin:'',//是否是管理员
                            uitype:'69',
                            supportformat:'',//支持格式
                            popupobj: crmPopupobj
                        });

                    });
                } else {
                    getJsScript('include/js/special_webuploader.js', function () {
                        ld('#'+popupobj.divid).find("[name=loginswiperchooseimg").special_powerWebUpload({
                            fileTypeDuplicate:'yes',	//附件类型判断
                            fileNameDuplicate:'yes',	//同名附件判断
                            mode:'loginswiper',
                            replyid:0,
                            module:'Settings',	//当前模块
                            parentdivid:popupobj.divid,
                            jsonData:'',	//edit data,编辑界面显示已上传的附件
                            record:'',	//单据单据id
                            admin:'',//是否是管理员
                            uitype:'69',
                            supportformat:'',//支持格式
                            popupobj: crmPopupobj
                        });

                    });
                }
            }
        });
    }
    swiptersettings.saveswiper = function () {
        var popupobj=CrmPopup.getPopupObj('last');
        var swiperid = ld("#"+popupobj.divid+" #swiperid").val();
        var tmpuploadfilename = '';
        if( ld("#"+popupobj.divid+" #loginswipercontent").val()!='')
        {
            /*var backgroundbgobj = ld("#"+popupobj.divid+" [name=loginswiper]");
            tmpuploadfilename = ld("#"+popupobj.divid+" [name=loginswiper]").get(0).files[0].name;
            formData.append('loginswiper', ld("#"+popupobj.divid+" [name=loginswiper]").get(0).files[0]);
            formData.append('name', backgroundbgobj.val());
            formData.append("size",ld("#"+popupobj.divid+" [name=loginswiper]").get(0).files[0].size);
            formData.append("type",ld("#"+popupobj.divid+" [name=loginswiper]").get(0).files[0].type);*/
        }
        else if(swiperid == 0){
            RemindsMsg("","LdPopWidth400px","","yes","yes",arrJsPopLabel['PICTURECANNOTEMPTY']);
            return false;
        }else{
            tmpuploadfilename = ld("#"+popupobj.divid+" [name=PREV_FILE]").val();
        }

        var tmpurl = 'index.php?module=Settings&action=SettingsAjax&file=LoginSettingsSwiperSave';
        var content = ld("#"+popupobj.divid+" #loginswipercontent").val();
        var url = ld("#"+popupobj.divid+" [name=swiperurl]").val();
        var isshow = 'yes';
        if(ld("#"+popupobj.divid+" [name=swiperisshow]").prop('checked')){
            isshow = 'yes';
        }
        else{
            isshow = 'no';
        }
        tmpurl += '&swiperid='+swiperid+'&url='+url+'&isshow='+isshow+'&imagename='+tmpuploadfilename+'&content='+content;
        ldAjax(tmpurl,'',function(data){
            if(data.code==1)
            {
                popupobj.CancelEvent();
                var surl = 'index.php?module=Settings&action=SettingsAjax&file=LoginSettingsSwiper&loginui=new';
                ldAjax(surl,"",function(data){
                    ld('#rptContentLoading').hide();
                    if(data.code==1){
                        ld("#CamCardViewDetail").html(data.result.content);
                    }
                })
            }
        });
    }
    swiptersettings.deleteswiper = function (swiperid) {
        var str = arrJsPopLabel['CANOTRESTOREDAFTERDELETIONDELETEOK'];
        RemindsMsg("","LdPopWidth400px","","yes","yes",str);
        ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
            var surl = 'index.php?module=Settings&action=SettingsAjax&file=LoginSettingsSwiperDelete&swiperid='+swiperid;
            ldAjax(surl,"",function(data){
                if(data.code==1)
                {
                    var surl = 'index.php?module=Settings&action=SettingsAjax&file=LoginSettingsSwiper&loginui=new';
                    ldAjax(surl,"",function(data){
                        ld('#rptContentLoading').hide();
                        if(data.code==1){
                            ld("#CamCardViewDetail").html(data.result.content);
                        }
                    })
                }
            })
        })
    }
    swiptersettings.isshowswiper = function (obj,swiperid) {
        var isshow = 'yes';
        if(ld(obj).prop('checked')){
            isshow = 'yes';
        }
        else{
            isshow = 'no';
        }
        var surl = 'index.php?module=Settings&action=SettingsAjax&file=LoginSettingsSwiperisshow&swiperid='+swiperid+'&isshow='+isshow;
        ldAjax(surl,"",function(data){
            if(data.code==1)
            {
                var surl = 'index.php?module=Settings&action=SettingsAjax&file=LoginSettingsSwiper&loginui=new';
                ldAjax(surl,"",function(data){
                    ld('#rptContentLoading').hide();
                    if(data.code==1){
                        ld("#CamCardViewDetail").html(data.result.content);
                    }
                })
            }
            else if(data.code==2){
                ld(obj).prop('checked',true);
                var str = arrJsPopLabel['LEASTONECOLUMN'];
                RemindsMsg("","LdPopWidth400px","","yes","yes",str);
            }
        })
    }
    swiptersettings.restdefaultswiper = function () {
        var str = arrJsPopLabel['restdefaultswiper'];
        RemindsMsg("","LdPopWidth400px","","yes","yes",str);
        ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function() {
            var surl = 'index.php?module=Settings&action=SettingsAjax&file=LoginSettingsSwiperDefault';
            ldAjax(surl, "", function (data) {
                if (data.code == 1) {
                    var surl = 'index.php?module=Settings&action=SettingsAjax&file=LoginSettingsSwiper&loginui=new';
                    ldAjax(surl, "", function (data) {
                        ld('#rptContentLoading').hide();
                        if (data.code == 1) {
                            ld("#CamCardViewDetail").html(data.result.content);
                        }
                    })
                }
            })
        });
    }
</script>