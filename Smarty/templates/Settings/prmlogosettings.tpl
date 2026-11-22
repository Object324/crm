<form action="index.php?module=Settings&amp;action=add2db" method="post" name="index" enctype="multipart/form-data" onsubmit="puyoungJS_DialogBox.block();" class="ajax_form">
    <table class="ld-public-content-small" width="100%" cellspacing="0" cellpadding="0" border="0">
        <tbody>
        <tr>
            <td class="ld-form-item-label">{'LOGO_name'|@getFixedLabel}</td>
            <td class="ld-form-item-content" style="display: flex;">
                <div class="imgContainer big bindtip" style="width: 145px;height:40px;display: flex;" data-tip="选择Logo" data-direction="top" data-type="position">
                    {if $PRMLOGONAME neq ''}
                        <img src="dataCache/test/logo/{$PRMLOGONAME}?a={$RANDNUM}" id="prm_logo_img" class="Logo" style="width: 121px;height: 40px;" >
                    {else}
                        <img src="include/images/noimage.gif" id="prm_logo_img" class="Logo" style="width: 121px;height: 40px;">
                    {/if}
                    <img src="include/images/addimage.png" class="overlay-Img" id="overlay_Img_big" style="margin-top: 10px;width: 24px;height:24px;" data-showbox="prm_logo_img" data-showname="prm_logo_name" data-prevname="{$PRMLOGONAME}" data-suggest="suggestedsize145x40px" data-width="145" data-height="40">
                </div>
                <div class="imgContainer" style="padding-left: 20px;line-height:40px;" id="prm_logo_name">
                    {$PRMLOGONAME}
                </div>
            </td>
        </tr>
        </tbody>
    </table>
</form>