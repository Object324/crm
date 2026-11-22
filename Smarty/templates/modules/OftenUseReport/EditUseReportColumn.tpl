<div class="ld-pop-container ld-table-container ld-table-container-lines">
<form action="index.php" name="frmeditcolumn" method="post">
    <input  type="hidden" value="OftenUseReport" name="module"/>
    <input  type="hidden" value="ListView" name="action"/>
    <input  type="hidden" value="editColumnName" name="submode"/>
    <input  type="hidden" value="BasicSearch" name="searchtype"/>
    <input  type="hidden" value="" name="editsmownerids"/>
    <input  type="hidden" value="" name="editstartdate"/>
    <input  type="hidden" value="" name="editenddate"/>
    <input  type="hidden" value="" name="editdatefindcolumn"/>
    <input  type="hidden" value="" name="editotherfindcolumn"/>
    <input  type="hidden" value="" name="editbasicotherfind"/>
    <input  type="hidden" value="" name="editUseReportadv_group"/>
    <input  type="hidden" value="" name="editUseReportadv"/>
    <input  type="hidden" value="" name="editUseReportId"/>
    <input  type="hidden" value="{$COLUMNSID}" name="columnid"/>
    <div class="divPopOverflow">
        <table id="editColumnTable" class="" border="0" cellpadding="0" cellspacing="0" width="100%">
            <thead>
                <tr>
                    <th style="width: 45px;">#</th>
                    <th>{'CNTAG'|@getFixedLabel}</th>
                    <th>{'ENTAG'|@getFixedLabel}</th>
                </tr>
            </thead>
            <tbody>
                {foreach name=tabindex item=value from=$ALLCOLUMNS}
                <tr>
                    <td>{$smarty.foreach.tabindex.iteration}</td>
                    <td><input class="ld-input-inner" id="txt{$smarty.foreach.tabindex.iteration}" type="text" name="txt{$smarty.foreach.tabindex.iteration}" value="{$value.realname}"/></td>
                    <td><input class="ld-input-inner" id="txtc{$smarty.foreach.tabindex.iteration}" type="text" name="txtc{$smarty.foreach.tabindex.iteration}" value="{$value.realenname}"/></td>
                </tr>
                {/foreach}
            </tbody>
        </table>
    </div>
</form>
</div>