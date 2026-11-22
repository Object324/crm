<table class="D_pop_bod" cellspacing="1" cellpadding="1" border="0" style="width: 100%;padding: 0 !important;margin: 0;">
    <tr>
        <td width="30%" align="right">接收服务器类型：</td>
        <td>
            <select name="mailreceivetype">
            <option value="pop3">pop3</option>
            </select>
        </td>
    </tr>
    <tr>
        <td  align="right">邮箱账号：</td>
        <td>
        <input class="detailedViewTextBox" type="text" name="mail_username" value="{$mailaccountname}"/>
        </td>
    </tr>
    <tr>
        <td  align="right">密码：</td>
        <td>
        <input class="detailedViewTextBox" name="mail_pwd" type="password" value="{$mailpwd}"/>
        </td>
    </tr>
    <tr>
        <td  align="right">POP服务器：</td>
        <td>
        <input class="detailedViewTextBox" type="text" name="mailaccountname" value="{$mailservername}" style="width: 45%;"/>
        <input class="detailedViewTextBox" type="checkbox" name="chk_pop3_ssl" onclick="sslPort()"  {if $ssltype neq 'none' &&$ssltype neq ''}  checked=""{/if}  style="width:auto;margin: 0 3px 0 10px;"/>SSL<span style="margin-left: 6px;">端口：</span>
        <input class="detailedViewTextBox" name="pop3_ssl_port"  type="text" readonly="" value="{$PORT}" style="width: 15%;"/>
        </td>
    </tr>
    <tr>
        <td  align="right">SMTP服务器：</td>
        <td>
        <input class="detailedViewTextBox" type="text" style="width: 45%;" name="smtp_mailaccountname" value="{$smtp_servername}"/>
        <input class="detailedViewTextBox" type="checkbox" name="chk_smtp_ssl" onclick="smtp_sslPort()"  {if $smtp_ssltype neq 'none' &&$smtp_ssltype neq ''}  checked=""{/if} style="width:auto;margin: 0 3px 0 10px;"/>SSL
        <span style="margin-left: 6px;">端口：</span>
        <input class="detailedViewTextBox" type="text" value="{$SMTPPORT}" name="smtp_ssl_port" style="width: 15%;"/>
        </td>
    </tr>
<table>