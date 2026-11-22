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
 <!--修改编码格式:统一编码：UTF-8-->
-->*}
    <div class="allEmail">
        <span>
            邮箱设置
        </span>
    </div>
    <div class="clear"></div>
    <div class="emailBtnlist"> 
        <div class="emailBtn"">
            <ul class="ulbtn" style="margin-right: 15px;">
                <li>
                    <span class="ld-button ld-button-primary" onclick="createmailboxSetup()">新建</span>
                </li>
                <li>
                    <span class="ld-button ld-button-primary" onclick="delMailBox()">{'DELETE'|@getFixedLabel}</span>
                </li>
            </ul>
        </div>
    </div>
<div class="clear"></div>
<!--列表being-->
<div class="emialList">
    <div class="emailListDiv">
        <table cellspacing="0" border="0" cellpadding="0" width="100%" class="listEntries fir-center emailListcontent" style="border-collapse:separate !important;">
            <tr>
                <th class="ctextalign BgcolorF8" width="45px"><input type="checkbox" onclick="selectallmailbox(this.checked)"/></th>
                <th width="25%" class="BgcolorF8">
                    邮箱账户
                
                </th>
                <th width="45%" class="BgcolorF8">
                    收件服务器类型
                
                </th>            
                <th width="17%" class="BgcolorF8">创建时间</th>
                <th width="10%" class="BgcolorF8">操作</th>
            </tr>
                {foreach from=$MAILACCOUNTS item=mailaccountinfo}
                    <tr bgcolor="white" class="Hover {if $listInfo->seen neq 1} folder{/if}" >
                        <td class="ctextalign"><input type="checkbox" tag='{$mailaccountinfo.accountid}' name="emailbox"/></td>
                        <td width="30%">{$mailaccountinfo.mailaccountname}</td>
                        <td width="50%">POP3</td>
                        <td width="17%">{$mailaccountinfo.createdtime}</td>
                        <td>
                            <a class="Anu3_a" href="javascript:void(0);" style="white-space:nowrap;" onclick="EditmailboxSetup({$mailaccountinfo.accountid})">
                            编辑</a>
                        </td>
                    </tr>
                {foreachelse}
                    <tr bgcolor="#fff">
                        <td align="center" colspan="5" class="bgwhite" style="height:0px;padding: 0;">
                        
                            {* <div class="warningTableContent" style="z-index:600;">
                                <div class="wtc_img">
                                    <img src="themes/icon2023/ld-no-records.png"/>
                                </div><div class="wtc_content">{'NOTFOUNDANYRECORD'|@getFixedLabel}</div>
                                <div class="wtc_btn"></div>
                                <div></div>
                            </div> *}
                            {include file="NoRecords.tpl"}
                        </td>
                    </tr>
                {/foreach}
        </table>
    </div>
</div>
<!--列表end-->