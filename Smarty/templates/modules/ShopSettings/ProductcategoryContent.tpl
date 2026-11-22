<div class="">	
    <table border=0 cellspacing=0 cellpadding=0 width=100% class="settingTable fir-center">
        <tr>
          	<th>#</th>
            <th title="{$product_fieldlabel}">{$product_fieldlabel}</th>
            <th title="{'WHETHERTODISPLAY'|@getFixedLabel}">{'WHETHERTODISPLAY'|@getFixedLabel}</th>
            <th width="230px">{'OPERATING'|@getFixedLabel}</th>
        </tr>
        {assign var="i" value=0}
		{foreach key=productcateid item=productcateinfo name=printlist from=$productcatelist}
            {assign var="j" value=$i++}
            {assign var="printlistNum" value=$smarty.foreach.printlist.iteration}
            {if $j mod 2 eq '0'}
                <tr id="setting_{$j}" class="lvtColData ld-category-draggable" data-productid="{$productcateid}" onmouseout="listOnMouseOut(ld(this),'on');" onmouseover="listOnMouseOver(ld(this));" >
            {else}
                <tr id="setting_{$j}" class="lvtColDataBj ld-category-draggable" data-productid="{$productcateid}" onmouseout="listOnMouseOut(ld(this),'On');" onmouseover="listOnMouseOver(ld(this));" >
            {/if}   
    		<td>{$printlistNum}</td>
            <td>
                {$productcateinfo.productname}
    		</td>
    		<td>
                {if $productcateinfo.display eq 'show'}
                <input type="checkbox" tag="{$productcateid}" name="inactivate" onclick="ProductcateSettingsOperate(this,'inactivate',{$productcateid})" class="second_switch" checked='' />
                {elseif $productcateinfo.display eq 'hide'}
                <input type="checkbox" tag="{$productcateid}" name="activate" onclick="ProductcateSettingsOperate(this,'activate',{$productcateid})" class="second_switch"/>
                {/if}
    		</td>
            <td>
                <b class="ld-category-icon ld-category-drag drag-handle sort-tip-items" data-tip="{'DRAGTOSORT'|@getFixedLabel}"  data-direction="top" data-type="position" style="cursor: move;" ></b>
            </td>
	    </tr>
	    {/foreach}
	</table>
</div>
<script>
    {literal}
    tooltip('.sort-tip-items', {transition: true, time: 200});
    ld.each(ld(" [name=SettingRightContent]").find('table tbody'),function(index,obj){
        Sortable.create(obj, {
            draggable:".ld-category-draggable",
            handle:".drag-handle",
            sort:true,
            onEnd: function (evt) {
                var sequence_arr = [];
                ld.each(ld('[name=SettingRightContent] table.settingTable.fir-center tr.ld-category-draggable'), function (index, tmpobj) {
                    var tmp_productid = ld(tmpobj).data("productid");
                    if (tmp_productid > 0) {
                        sequence_arr.push(tmp_productid);
                    }
                });
                if (sequence_arr.length > 0) {
                    sequence_arr = sequence_arr.toString();
                    var update_url = "index.php?module=ShopSettings&action=ShopSettingsAjax&file=ProductcategorySettings_save&ajax=yes&mode=drag&sequence_arr=" +sequence_arr;
                    ld.ajax({
                        type: "GET",
                        url: update_url,
                        success: function (data) {
                            var surl = "index.php?module=ShopSettings&action=ProductcategorySettings&ReportHeader=dheader&ajax=yes";
                            ldAjaxNoProgress(surl,"",function(data){
                                if(data.code==1){
                                    ld(' [name=listcontent]').html(data.result.content);
                                }
                            })
                            DelProgressObjs();
                        },
                        error: function (error) {
                        }
                    });
                }
            }
        })
    });
    {/literal}
</script>
