<div class="ld-pop-container ld-table-container ld-table-container-lines">
    <div class="divPopOverflow">
        <table id="CamCardDetail" border="0" cellpadding="0" cellspacing="0" width="100%">
            <thead>
                <tr>
                    <th width="20%" style="width: 20% !important;" align="left">{'ORIGINALLABELNAME'|@getFixedLabel}</th>
                    <th width="20%" align="left">{'WHETHERTODISPLAY'|@getFixedLabel}</th>
                    <th width="20%" align="left">{'MODIFIEDLABEL'|@getFixedLabel}</th>
                    <th width="40%" align="left">{'CORRESPONDINGCONTENT'|@getFixedLabel}</th>
                </tr>
            </thead>
            <tbody>
                <tr>
                    <td>{'WebsiteTitle'|@getFixedLabel}</td>
                    {if $VERSIONINFO.titleisshow eq 'yes'}
                        <td><input type="checkbox" class="second_switch" checked="" name="chk_browse_title_show" /></td>
                    {else}
                        <td><input type="checkbox" class="second_switch" name="chk_browse_title_show" /></td>
                    {/if}
                    {if $LANGUAGETYPE eq 'zh'}
                        <td>{$VERSIONINFO.LBL_BROWSER_TITLE}</td>
                    {else}
                        <td>{$VERSIONINFO.EN_LBL_BROWSER_TITLE}</td>
                    {/if}
                    {if $LANGUAGETYPE eq 'zh'}
                        <td><input class="ld-input-inner" type="text" name="txt_browse_title" value="{$VERSIONINFO.after_zh_title}"/></td>
                    {else}
                        <td><input class="ld-input-inner" type="text" name="txt_browse_title" value="{$VERSIONINFO.after_en_title}"/></td>
                    {/if}
                </tr>
                <tr>
                    <td>{'WelcomeToLogin'|@getFixedLabel}</td>
                    <td><input  type="checkbox" class="second_switch" checked="" disabled="" name="chk_login_welcome" /></td>
                    {if $LANGUAGETYPE eq 'zh'}
                        <td>{$GLOBAL_WELCOME.zh}</td>
                    {else}
                        <td>{$GLOBAL_WELCOME.en}</td>
                    {/if}
                    {if $LANGUAGETYPE eq 'zh'}
                        <td><input class="ld-input-inner" type="text" name="txt_login_welcome" value="{$GLOBAL_WELCOME.after_zh_content}"/></td>
                    {else}
                        <td><input class="ld-input-inner" type="text" name="txt_login_welcome" value="{$GLOBAL_WELCOME.after_en_content}"/></td>
                    {/if}
                </tr>
                <tr>
                    <td>{'LBL_ENTERPRISEWECHAT'|@getFixedLabel}</td>
                    {if $WXLOGINBTN.isshow eq 'yes'}
                        <td><input type="checkbox" class="second_switch" checked="" name="chk_login_wxbtn_show" /></td>
                    {else}
                        <td><input type="checkbox" class="second_switch" name="chk_login_wxbtn_show" /></td>
                    {/if}
                     {if $LANGUAGETYPE eq 'zh'}
                        <td>{$WXLOGINBTN.zh}</td>
                    {else}
                        <td>{$WXLOGINBTN.en}</td>
                    {/if}
                    {if $LANGUAGETYPE eq 'zh'}
                        <td><input class="ld-input-inner" type="text" name="txt_login_wxbtn" value="{$WXLOGINBTN.after_zh_content}"/></td>
                    {else}
                        <td><input class="ld-input-inner" type="text" name="txt_login_wxbtn" value="{$WXLOGINBTN.after_en_content}"/></td>
                    {/if}
                </tr>
                {foreach item=row key=key from=$LOGINIFO}
                <tr mark="content_rows">
                    {if $LANGUAGETYPE eq 'zh'}
                        <td>{$row.zh}</td>
                    {else}
                        <td>{$row.en}</td>
                    {/if}
                    {if 'isshow'|@array_key_exists:$row}
                        {if $row.isshow eq 'yes' }
                            <td><input type="checkbox" class="second_switch" checked="" name="chk_{$key}"/></td>
                        {else}
                            <td><input type="checkbox" class="second_switch" name="chk_{$key}"/></td>
                        {/if}
                    {else}
                        <td><input  type="checkbox" class="second_switch" checked="" disabled=""/></td>
                    {/if}
                    {if $LANGUAGETYPE eq 'zh'}
                        <td>{$row.zh}</td>
                    {else}
                        <td>{$row.en}</td>
                    {/if}
                    {if $key eq 'backgroundbg'}
                        <td>
                            <div style="width: 145px;height:40px;padding-top: 5px;display: inherit;">
                                <img src="{$row.content}" name="backgroundbg_img"class="Logo" style="width: 130px;height: 36px;">
                            </div>
                            <div style="display: inherit;">默认背景：[{$BACKGROUNDFILENAME}]</div>
                            <input name="MAX_FILE_SIZE" value="800000" type="HIDDEN">
                            <input name="PREV_FILE" value="{$BACKGROUNDFILENAME}" type="HIDDEN">
                            <input name="backgroundbg_hidden" value="{$BACKGROUNDFILENAME}" type="hidden">
                            <div style="height: 20px;line-height: 20px;">选择新背景：<span style="color: red;">建议尺寸：1920*1200(像素)，图片名称禁用汉字及中文特殊字符</span></div>
                            <input name="backgroundbg" value="{$BACKGROUNDFILENAME}" onchange="validateFilename(this);OrganizationConfig.showLOGO(this,'backgroundbg_img')" type="file" style="padding-bottom: 5px;">
                        </td>
                    {elseif $key eq 'logoname'}
                     <td>
                            <div style="width: 145px;height:40px;padding-top: 5px;display: inherit;">
                                <img src="{$row.content}" name="logoname_img" class="Logo" style="width: 130px;height: 36px;">
                            </div>
                            <div style="display: inherit;"></div>
                            <input name="MAX_FILE_SIZE" value="800000" type="HIDDEN">
                            <input name="PREV_FILE" value="{$LOGONAME}" type="HIDDEN">
                            <input name="logoname_hidden" value="{$LOGONAME}" type="hidden">
                            <div style="height: 40px;line-height: 20px;">{'SELECTLOGO'|@getFixedLabel}<span style="color: red;">{'SUGGESTEDSIZE14540PIXELS'|@getFixedLabel}</span></div>
                            <div style="height: 20px;line-height: 20px;">{'IMAGESMAYBYDISPLAYED'|@getFixedLabel}</div>
                            <input name="logoname" value="{$LOGONAME}" onchange="validateFilename(this);OrganizationConfig.showLOGO(this,'logoname_img')" type="file" style="padding-bottom: 5px;">
                        </td>
                     {elseif $key eq 'minilogoname'}
                     <td>
                            <div style="width: 145px;height:40px;padding-top: 5px;display: inherit;">
                                <img src="{$row.content}" name="minilogoname_img"class="Logo" style="width: 130px;height: 36px;">
                            </div>
                            <div style="display: inherit;"></div>
                            <input name="MAX_FILE_SIZE" value="800000" type="HIDDEN">
                            <input name="PREV_FILE" value="{$MINILOGONAME}" type="HIDDEN">
                            <input name="minilogoname_hidden" value="{$MINILOGONAME}" type="hidden">
                            <div style="height: 40px;line-height: 20px;">{'SELECTMINILOGO'|@getFixedLabel}<span style="color: red;">{'SUGGESTEDSIZE3636PIXELS'|@getFixedLabel}</span></div>
                            <div style="height: 20px;line-height: 20px;">{'IMAGESMAYBYDISPLAYED'|@getFixedLabel}</div>
                            <input name="minilogoname" value="{$MINILOGONAME}" onchange="validateFilename(this);OrganizationConfig.showLOGO(this,'minilogoname_img');" type="file" style="padding-bottom: 5px;">
                        </td>
                    {elseif $key eq 'loginlocation'}
                        <td>
                            <select name="txt_loginlocation" class="ld-select-inner width100">
                                {if $row.content eq '左'}
                                    <option value="左" selected="">左</option>
                                {else}
                                    <option value="左">左</option>
                                {/if}
                                {if $row.content eq '中'}
                                    <option value="中" selected="">中</option>
                                {else}
                                    <option value="中">中</option>
                                {/if}
                                {if $row.content eq '右'}
                                    <option value="右" selected="">右</option>
                                {else}
                                    <option value="右">右</option>
                                {/if}
                            </select>
                        </td>
                    {elseif $key eq 'autheninfo'}
                        <td>{$SERVERURL}{$row.content}</td>
                    {else}
                        {if 'isedit'|@array_key_exists:$row&& $row.isedit eq 'yes'}
                            <td><input class="ld-input-inner" type="text" name="txt_{$key}" value="{$row.content}"/></td>
                        {else}
                            <td>{$row.content}</td>
                        {/if}
                    {/if}
                </tr>
                {/foreach}
                {foreach from=$GLOBALLOGINPAGEURL item=row key=key}
                <tr mark="content_rows">
                    {if $LANGUAGETYPE eq 'zh'}
                        <td>{$row.zh}</td>
                    {else}
                        <td>{$row.en}</td>
                    {/if}
                    <td><input type="checkbox" class="second_switch" {if $row.isshow eq 'yes'}checked=""{/if} name="pageurl_chk_isshow_{$key}"/></td>
                    <td>
                        <input class="ld-input-inner" type="text" name="pageurl_txt_content_{$key}" value="{$row.content}"/>
                    </td>
                    <td>
                        <input class="ld-input-inner" type="text" name="pageurl_txt_url_{$key}" value="{$row.url}"/>
                    </td>
                </tr>
                {/foreach}
            </tbody>
        </table>
    </div>
</div>