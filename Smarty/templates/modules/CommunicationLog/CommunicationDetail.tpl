{*<!--
/*********************************************************************************
  *
  <!--修改编码格式:统一编码：UTF-8-->
  * The contents of this file are subject to the lingdang CRM Public License Version 1.0
   * ("License"); You may not use this file except in compliance with the License
   * The Original Code is:  lingdang CRM Open Source
   * The Initial Developer of the Original Code is lingdang.
   * Portions created by lingdang are Copyright (C) lingdang.
   * All Rights Reserved.
  *
 ********************************************************************************/
-->*}

{if $type eq 'smslist'}
<!--
edit:cdw
date:20130717
reason:0004453: 在通讯记录界面点击 查看 弹出来的界面建议：作业号、主题、内容等信息冒号右边对齐（如下面的信息显示）
-->
    <table border=0 cellspacing=0 cellpadding=5 width=80% >
        <tr>
            <td width="20%" align="right">作业号：</td>
            <td width="80%">{$batchno}</td>
        </tr>
        <tr>
            <td width="20%" align="right">接收名称：</td>
            <td width="80%">{$receivecontacts}</td>
        </tr>
        <tr>
            <td width="20%" align="right">接收号码：</td>
            <td width="80%">{$callednumber}</td>
        </tr>
        <tr>
            <td width="20%" align="right">主题：</td>
            <td width="80%">{$subject}</td>
        </tr>
        <tr>
            <td width="20%" align="right">内容：</td>
            <td width="80%">{$smscontent}</td>
        </tr>
    </table>
{/if}
{if $type eq 'smswork'}
    <table border=0 cellspacing=0 cellpadding=5 width=80% >
        <tr>
            <td width="20%" align="right">作业号：</td>
            <td width="80%">{$batchno}</td>
        </tr>
        <tr>
            <td width="20%" align="right">主题：</td>
            <td width="80%">{$subject}</td>
        </tr>
        <tr>
            <td width="20%" align="right">内容：</td>
            <td width="80%">{$smscontent}</td>
        </tr>
        <tr>
            <td width="20%" align="right">接收信息：</td>
            <td width="80%">
                {foreach key=results item=work from=$resultworklist}
                    {$work.Receive}
                
                {/foreach}
            </td>
        </tr>
    </table>
{/if}



