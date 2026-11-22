<table class="listEntries" border="0" cellspacing="1" cellpadding="0" width="80%">
<tr>
    <th class="firstChild"><input name="chk_allguiji" type="checkbox"/></th>
    <th style="width: 15%;">姓名</th>
    <th>部门</th>
    <th style="width: 15%;">时间</th>
    <th>位置</th>
</tr>

{foreach from=$USERINFO item=$usercontent}
        {assign var="i" value=$i+1}
        <tr id="report_{$i}" onmouseover="listOnMouseOver(ld(this))" {if $i % 2 eq '0'}class="lvtColDataBj" onmouseout="listOnMouseOut(ld(this),'On')"{else}class="lvtColData" onmouseout="listOnMouseOut(ld(this),'on')"{/if}>
            <td style="text-align:center;"><input name="chk_guiji" tag={$i}  type="checkbox"/></td>
            <td>{$usercontent.last_name}</td>
            <td>{$usercontent.groupnames}</td>
            <td>{$usercontent.time}</td>
            <td>{$usercontent.address}</td>
        </tr>       
{/foreach}
</table>