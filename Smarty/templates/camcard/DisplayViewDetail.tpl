<div class="ld-table-container ld-table-container-line ld-table-container-bgcolor">
    <table id="CamCardDetail" class="fir-center" width="100%" cellspacing="0" cellpadding="0">
        <thead>
            <tr>
                <th>#</th>
                <th align="left">{'CAMCARDFIELDS'|@getFixedLabel}</th>
                <th width="40%" align="left">{'CAMCARDCAPTION'|@getFixedLabel}</th>
                <th align="left">{'CAMCARDCRMFIELDS'|@getFixedLabel}</th>
            </tr>
        </thead>
        <tbody>
            {assign var="modulenamenum" value='1'}
            {assign var="i" value=0}
            {foreach item=row key=key from=$OPTIONLIST}
                {assign var="j" value=$i++}
                {if $j mod 2 eq '0'}
                    <tr mark="content_rows" id="setting_{$j}" class="lvtColData" onmouseout="listOnMouseOut(ld(this),'on');" onmouseover="listOnMouseOver(ld(this));">
                {else}
                    <tr mark="content_rows" id="setting_{$j}" class="lvtColDataBj" onmouseout="listOnMouseOut(ld(this),'On');" onmouseover="listOnMouseOver(ld(this));">
                {/if}
                    <td>{$modulenamenum}</td >
                    <td hidden>{$row.card_field}</td>
                    <td>{$row.card_field_sh}</td>
                    <td>{$row.describe}</td>
                    <td>{$row.select_html}</td>
                </tr>
                {assign var="modulenamenum" value=$modulenamenum+1}
            {/foreach}
        </tbody>
    </table>
</div>
