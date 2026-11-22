<div class="">	
    <table border=0 cellspacing=0 cellpadding=0 width=100% class="settingTable fir-center">
        <tr style="position: sticky; top:0px; z-index: 1">
          	<th>#</th>
            <th title="{'NavigationPicture'|@getFixedLabel}">{'NavigationPicture'|@getFixedLabel}</th>
            <th title="{'NavigationLinkType'|@getFixedLabel}">{'NavigationLinkType'|@getFixedLabel}</th>
            <th title="{'WHETHERTODISPLAY'|@getFixedLabel}">{'WHETHERTODISPLAY'|@getFixedLabel}</th>
            <th width="230px">{'OPERATING'|@getFixedLabel}</th>
        </tr>
        
        {assign var="i" value=0}
        {if is_array($List)}
            {assign var="maxcount" value = $List|@count}
        {else}
            {assign var="maxcount" value = 0}
        {/if}
		{foreach name=printlist item=listinfo from=$List}
            {assign var="printlistNum" value=$smarty.foreach.printlist.iteration }
            {assign var="j" value=$i++}
            {if $j mod 2 eq '0'}
                <tr id="setting_{$j}" class="lvtColData ld-category-draggable" data-carouselid="{$listinfo.carouselid}" onmouseout="listOnMouseOut(ld(this),'on');" onmouseover="listOnMouseOver(ld(this));" >
            {else}
                <tr id="setting_{$j}" class="lvtColDataBj ld-category-draggable" data-carouselid="{$listinfo.carouselid}" onmouseout="listOnMouseOut(ld(this),'On');" onmouseover="listOnMouseOver(ld(this));" >
            {/if}   
    		<td>{$printlistNum}</td>
            <td align="center" >
                <span id="carousel_{$listinfo.carouselid}" name="carousel_{$listinfo.carouselid}" record="{$listinfo.carouselid}" fieldname="imagename" style="display: inline;">
                    <a style=" border:0px solid #000;" href="{$listinfo.url_filepath}" target="_blank">
                        <img style="width:220px;height:100px;margin: 3px 0;" src="{$listinfo.url_filepath}" title="{$listinfo.uploadfile_name}" border="0">
                    </a>
                </span>
    		</td>
    	 	<td>
                {$listinfo.linktype|@getFixedLabel}
    		</td>
    		<td>      
                {if $listinfo.status eq 'yes'}
                <input type="checkbox" tag="{$listinfo.carouselid}" name="inactivate" onclick="CarouselSettingsOperate(this,'inactivate',{$listinfo.carouselid})" class="second_switch" checked='' />
                {elseif $listinfo.status eq 'no'}
                <input type="checkbox" tag="{$listinfo.carouselid}" name="activate" onclick="CarouselSettingsOperate(this,'activate',{$listinfo.carouselid})" class="second_switch"/>
                {/if}
    		</td>
            <td>
			  	<a class="Anu3_a" href="#" tag="{$listinfo.carouselid}" onclick="CarouselSettings_edit(this,'edit',{$listinfo.carouselid})" name="edit">{'EDIT'|@getFixedLabel}</a>
                <a class="Anu3_a redFont" tag="{$listinfo.carouselid}" name="delete" onclick="CarouselSettingsOperate(this,'delete',{$listinfo.carouselid})">{'DELETE'|@getFixedLabel}</a>
                <b class="ld-category-icon ld-category-drag drag-handle sort-tip-items" data-tip="{'DRAGTOSORT'|@getFixedLabel}"  data-direction="top" data-type="position" style="cursor: move;" ></b>
            </td>
	    </tr>
	    {/foreach}
	</table>
</div>
<script>
    {literal}
    tooltip('.sort-tip-items', {transition: true, time: 200});
    /*wym BUG0072603 kfbcrm-商城设置-点击第一行图片下移，直接跳到了第五行（邱：改成拖动）*/
    ld.each(ld(" [name=SettingRightContent]").find('table tbody'),function(index,obj){
        Sortable.create(obj, {
            draggable:".ld-category-draggable",
            handle:".drag-handle",
            sort:true,
            onEnd: function (evt) {
                var sequence_arr = [];
                ld.each(ld('[name=SettingRightContent] table.settingTable.fir-center tr.ld-category-draggable'), function (index, tmpobj) {
                    var tmp_carouselid = ld(tmpobj).data("carouselid");
                    if (tmp_carouselid > 0) {
                        sequence_arr.push(tmp_carouselid);
                    }
                });
                if (sequence_arr.length > 0) {
                    sequence_arr = sequence_arr.toString();
                    var update_url = "index.php?module=ShopSettings&action=ShopSettingsAjax&file=CarouselSettings_save&mode=drag&sequence_arr=" +sequence_arr;
                    ld.ajax({
                        type: "GET",
                        url: update_url,
                        success: function (data) {
                            var surl = "index.php?module=ShopSettings&action=CarouselSettings&ReportHeader=dheader&ajax=yes";
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
