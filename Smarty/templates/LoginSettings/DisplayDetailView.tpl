<div style="height: 100%">
    <div class="displayflex" style="height: 50px;align-items: center;justify-content: end;margin-right: 20px;">
        {*zkt 20230725 BUG0069969 kfbcrm-登录界面自定义设置-点击恢复默认logo，背景图片也应恢复默认，按钮修改为“恢复默认” *}
        {*wym 231226 BUG0077847 界面设置--登录界面自定义设置--按钮顺序调整为：“编辑”、“恢复默认”*}
        <a href="javascript:;" class="ld-button ld-button-primary"  name="LoginSettingEdit" title="{'EDIT'|@getFixedLabel}">{'EDIT'|@getFixedLabel}</a>
        <a href="javascript:;" class="ld-button" onclick="OrganizationConfig.restorethedefaultlogo_login()" title="{'RESTORETHEDEFAULTLOGO'|@getFixedLabel}">{'RESTORETHEDEFAULTLOGO'|@getFixedLabel}</a>
    </div>
    <div class="mar-1" style="height: calc(100% - 50px);overflow-y: auto;">
        <table id="CamCardDetail" class="settingTable fir-center" width="100%" cellspacing="0" cellpadding="0">
            {* BUG0068275 txy 2023.06.18 固定表头加滚动时表头加阴影*}
            <tr style="position: sticky; top:0px;z-index:1;">
                <th>#</th>
                <th>{'ORIGINALLABELNAME'|@getFixedLabel}</th>
                <th>{'WHETHERTODISPLAY'|@getFixedLabel}</th>
                <th>{'MODIFIEDLABEL'|@getFixedLabel}</th>
                <th>{'CORRESPONDINGCONTENT'|@getFixedLabel}</th>
            </tr>
            <tr id="setting_1" class="lvtColData" onmouseout="listOnMouseOut(ld(this),'on');" onmouseover="listOnMouseOver(ld(this));">
                <td>1</td>
                <td>{'WebsiteTitle'|@getFixedLabel}</td>
                <td><input type="checkbox" onclick="change_tablefield_presence(this,'browse_title','loginsettings')" class="second_switch"
                {if $VERSIONINFO.titleisshow eq 'yes'} checked=""{/if} /></td>
                {if $LANGUAGETYPE eq 'zh'}
                     <td>{$VERSIONINFO.LBL_BROWSER_TITLE}</td>
                {else}
                    <td>{$VERSIONINFO.EN_LBL_BROWSER_TITLE}</td>
                {/if}
                {if $LANGUAGETYPE eq 'zh'}
                    <td>{$VERSIONINFO.after_zh_title}</td>
                {else}
                    <td>{$VERSIONINFO.after_en_title}</td>
                {/if}
            </tr>
            <tr id="setting_2" class="lvtColDataBj" onmouseout="listOnMouseOut(ld(this),'On');" onmouseover="listOnMouseOver(ld(this));">
                <td>2</td>
                <td>{'WelcomeToLogin'|@getFixedLabel}</td>
                <td><input type="checkbox" onclick="change_tablefield_presence(this,'{$key}','loginsettings')" class="second_switch" checked="" disabled /></td>
                {if $LANGUAGETYPE eq 'zh'}
                    <td>{$GLOBAL_WELCOME.zh}</td>
                {else}
                    <td>{$GLOBAL_WELCOME.en}</td>
                {/if}
                {if $LANGUAGETYPE eq 'zh'}
                    <td>{$GLOBAL_WELCOME.after_zh_content}</td>
                {else}
                    <td>{$GLOBAL_WELCOME.after_en_content}</td>
                {/if}
            </tr>
            <tr id="setting_3" class="lvtColData" onmouseout="listOnMouseOut(ld(this),'on');" onmouseover="listOnMouseOver(ld(this));">
                <td>3</td>
                <td>{'LBL_ENTERPRISEWECHAT'|@getFixedLabel}</td>
                <td><input type="checkbox" onclick="change_tablefield_presence(this,'login_wxbtn','loginsettings')" class="second_switch"
                {if $WXLOGINBTN.isshow eq 'yes'} checked=""{/if} /></td>
                {if $LANGUAGETYPE eq 'zh'}
                    <td>{$WXLOGINBTN.zh}</td>
                {else}
                    <td>{$WXLOGINBTN.en}</td>
                {/if}
                {if $LANGUAGETYPE eq 'zh'}
                    <td>{$WXLOGINBTN.after_zh_content}</td>
                {else}
                    <td>{$WXLOGINBTN.after_en_content}</td>
                {/if}
            </tr>
            {assign var="i" value=3}
            {foreach item=row key=key from=$LOGINIFO}
            {assign var="i" value=$i+1}
            {if $i mod 2 eq '0'}
                <tr id="setting_{$i}" class="lvtColDataBj" onmouseout="listOnMouseOut(ld(this),'On');" onmouseover="listOnMouseOver(ld(this));">
            {else}
                <tr id="setting_{$i}" class="lvtColData" onmouseout="listOnMouseOut(ld(this),'on');" onmouseover="listOnMouseOver(ld(this));">
            {/if}
                <td>{$i}</td>
                {if $LANGUAGETYPE eq 'zh'}
                    <td>{$row.zh}</td>
                {else}
                    <td>{$row.en}</td>
                {/if}
                {if 'isshow'|@array_key_exists:$row}
                    <td><input type="checkbox" onclick="change_tablefield_presence(this,'{$key}','loginsettings')" class="second_switch" {if $row.isshow eq 'yes'} checked=""{/if} /></td>
                {else}
                    <td><input type="checkbox" onclick="change_tablefield_presence(this,'{$key}','loginsettings')" class="second_switch" checked="" disabled /></td>
                {/if}
                {if $LANGUAGETYPE eq 'zh'}
                    <td>{$row.zh}</td>
                {else}
                    <td>{$row.en}</td>
                {/if}
                {if $key eq 'backgroundbg' || $key eq 'logoname' || $key eq 'minilogoname'}
                    <td><image src='{$row.content}' style="width: 130px;height: 36px;"></image></td>
                {elseif $key eq 'autheninfo'}
                    <td>{$SERVERURL}{$row.content}</image></td>
                {else}
                    <td>{$row.content}</td>
                {/if}
            </tr>
            {/foreach}
            {foreach from=$GLOBALLOGINPAGEURL item=row key=key}
            {assign var="i" value=$i+1}
            {if $i mod 2 eq '0'}
                <tr id="setting_{$i}" class="lvtColDataBj" onmouseout="listOnMouseOut(ld(this),'On');" onmouseover="listOnMouseOver(ld(this));">
            {else}
                <tr id="setting_{$i}" class="lvtColData" onmouseout="listOnMouseOut(ld(this),'on');" onmouseover="listOnMouseOver(ld(this));">
            {/if}
                <td>{$i}</td>
                {if $LANGUAGETYPE eq 'zh'}
                    <td>{$row.zh}</td>
                {else}
                    <td>{$row.en}</td>
                {/if}
                {if 'isshow'|@array_key_exists:$row}
                    <td><input type="checkbox" onclick="change_tablefield_presence(this,'loginpageurl_{$key}','loginsettings')" class="second_switch"
                    {if $row.isshow eq 'yes'} checked=""{/if} /></td>
                {else}
                    <td><input type="checkbox" onclick="change_tablefield_presence(this,'loginpageurl_{$key}','loginsettings')" class="second_switch"
                    checked="" disabled /></td>
                {/if}
                <td>{$row.content}</td>
                <td>{$row.url}</td>
            </tr>
            {/foreach}
        </table>
    </div>
</div>
<script type="text/javascript">
    {literal}
    ld(function(){
        var that=this;
        ld("a[name=LoginSettingEdit]").unbind("click").bind("click",function(){
            ld.ajax({
                url:"index.php?module=Settings&action=SettingsAjax&file=LoginSettingEdit",
                type:"post",
                dataType:"json",
                timeout:20000,
                success:function(data){
                    var popupobj= CrmPopup.load(data.result.title,that.save,"","LdPopWidth800px","Settings","",data.result.oktext,"",data.result.canceltext);
                    popupobj.createScrollDiv();

                    popupobj.show(data.result.content);
                    popupobj.setScrollDivMaxHeight();
                    popupobj.center();

                    // 设置内容最大高度
                    popupobj.setPopBodyMaxHeight(".divPopOverflow");
                }
            })
        })

        that.save=function(loginui = 'old'){

            var popupobj=CrmPopup.getPopupObj('last');

            var formData = new FormData();
            var tmpuploadfilename = '';
            if(ld("#"+popupobj.divid+" [name=backgroundbg]").length > 0){
                if( ld("#"+popupobj.divid+" [name=backgroundbg]").get(0).files.length>0)
                {
                    var backgroundbgobj = ld("#"+popupobj.divid+" [name=backgroundbg]");
                    tmpuploadfilename += backgroundbgobj.get(0).files[0].name;
                    formData.append('backgroundbg', ld("#"+popupobj.divid+" [name=backgroundbg]").get(0).files[0]);
                    formData.append('name', backgroundbgobj.val());
                    formData.append("size",ld("#"+popupobj.divid+" [name=backgroundbg]").get(0).files[0].size);
                    formData.append("type",ld("#"+popupobj.divid+" [name=backgroundbg]").get(0).files[0].type);

                }
            }

            if( ld("#"+popupobj.divid+" [name=logoname]").get(0).files.length>0)
            {
                var logonameobj = ld("#"+popupobj.divid+" [name=logoname]");
                tmpuploadfilename += logonameobj.get(0).files[0].name;
                formData.append('logoname', ld("#"+popupobj.divid+" [name=logoname]").get(0).files[0]);
                formData.append('name_logo', logonameobj.val());
                formData.append("size_logo",ld("#"+popupobj.divid+" [name=logoname]").get(0).files[0].size);
                formData.append("type_logo",ld("#"+popupobj.divid+" [name=logoname]").get(0).files[0].type);
            }
            if( ld("#"+popupobj.divid+" [name=minilogoname]").get(0).files.length>0)
            {
                var minilogonameobj = ld("#"+popupobj.divid+" [name=minilogoname]");
                tmpuploadfilename += minilogonameobj.get(0).files[0].name;
                formData.append('minilogoname', ld("#"+popupobj.divid+" [name=minilogoname]").get(0).files[0]);
                formData.append('name_minilogo', ld("#"+popupobj.divid+" [name=minilogoname]").val());
                formData.append("size_minilogo",ld("#"+popupobj.divid+" [name=minilogoname]").get(0).files[0].size);
                formData.append("type_minilogo",ld("#"+popupobj.divid+" [name=minilogoname]").get(0).files[0].type);
            }
            var urlstring="";
            ld.each(ld("#"+popupobj.divid+" input[type=checkbox]"),function(){
                var checked=ld(this).prop("checked");
                var tmpname=ld(this).attr('name');
                if(checked){
                    urlstring+="&"+tmpname+"=1";
                }
            })

            ld.each(ld("#"+popupobj.divid+" input[type=text]"),function(){

                var tmpname=ld(this).attr('name');
                urlstring+="&"+tmpname+"="+encodeURIComponent(ld(this).val());

            })


            urlstring+="&txt_loginlocation="+ld("#"+popupobj.divid+" [name=txt_loginlocation]").val();

            var tmpurl = "index.php?module=Settings&action=SettingsAjax&file=LoginSettingSave"+urlstring+'&loginui='+loginui;
            tmpurl = cls_encryptyurl.Puyoung_EncryptyFileurl(tmpurl,'&filename='+tmpuploadfilename);
            ld.ajax({
                url:tmpurl,
                type: 'POST',
                cache: false,
                data:formData,
                processData: false,
                contentType: false,
                timeout:20000,
                dataType:'json',
                xhr:function(){
                    var xhr=new XMLHttpRequest();
                    xhr.upload.addEventListener('progress',function(e){

                    })
                    return xhr;
                }
            }).done(function(data) {

                if(data.code==1)
                {
                    ld.ajax({
                        url:"index.php?module=Settings&action=SettingsAjax&file=LoginSettings&ajax=yes",
                        timeout:20000,
                        dataType:"json",
                        success:function(data){
                            popupobj.CancelEvent();
                            ld("#CamCardViewDetail").html(data.result.content);
                            ld("[class='logo-pic logo-pic-normal'][tag=logo-pic]").attr("src",'dataCache/test/logo/'+data.result.logoname);
                            ld("[class='logo-pic logo-pic-mini'][tag=logo-pic]").attr("src",'dataCache/test/logo/'+data.result.minilogoname);
                        }
                    })
                }
                else if(data.code == 2){
                    var str = arrJsPopLabel['updateloginsavefirst'];
                    str += '<br><a style="color: var(--ld-font-link-color);cursor: pointer;" onclick="newloginuipreview()">'+arrJsPopLabel['shownewloginui']+'</a>';
                    RemindsMsg("","LdPopWidth400px","","yes","yes",str);
                    ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
                        var surl = 'index.php?module=Settings&action=SettingsAjax&file=LoginSettingsSwiper&loginui=new';
                        that.save('new');
                    })
                }


            })
        }
        that.save.funname="that.save";
    })
    {/literal}

</script>