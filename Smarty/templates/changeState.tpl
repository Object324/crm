<form action="index.php" method="post" name="changestatus">
    <div id='subappcontent'>
        <table class="ld-public-content-small" border="0" cellpadding="0" cellspacing="0" width="100%">
            <tr>
                <td class="ld-form-item-label">{$FIXEDLABEL}</td>
                <td class="ld-form-item-content">
                    <div class=""ld-flex-start">
                        <select name="statusname" class="ld-select-inner">
                            {foreach item=statusname from=$STATUSNAMES}
                                <option value="{$statusname.statusname}">{$statusname.statusname}</option>
                            {/foreach}
                        </select>
                    </div>
                </td>
            </tr>
        </table>
    </div>
</form>
