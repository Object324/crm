<div class="qui_dialog_body ww_dialog_body" style="background-color: #fff;">
    <div class="msgDlg_right">
        <div class="msgDlg_right_text" style="font-size:13px;padding-left: 4px;">
            <div style="margin-left:80px;"></div>
            <table id="qrcode_content" class="settingPopTable lasttdbordernon pad10" border="0" cellpadding="0" cellspacing="0" width="350">
                <tbody>
                <tr>
                    <td class="ctextalign">
                        <p style="text-align: center;line-height: 40px;">
                            {'Expirationtime'|@getFixedLabel}:&nbsp;&nbsp;{$code_url_expiredtime}
                        </p>
                        <img src="{$pathfilename}" style="width: 180px;padding: 0 10px 10px 10px;">
                        <p style="text-align: center;line-height: 60px;">
                            {'SELFSERVICEQRCODEEXPLAIN1'|@getFixedLabel}
                        </p>
                    </td>
                </tr>
                <tr>
                    <td class="ctextalign">
                        <div class="ld-button" title="{'Regeneratepaymentcode'|@getFixedLabel}" data-type="reGeneratePaymentCode" onclick="detailbutton_click(this,'{$frommodule}','GeneratePaymentCode','{$record}');return false;">{'Regeneratepaymentcode'|@getFixedLabel}</div>
                    </td>
                </tr>
                </tbody>
            </table>
        </div>
    </div>
</div>