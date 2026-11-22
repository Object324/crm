<div>
    <div style="padding: 12px 20px 6px 20px;overflow: hidden;">
        <div style="overflow:hidden;float:left;margin: 0px 6px 4px 0px;">     
            下游客户品类：<input type="checkbox" name="checkAll" id="checkAll" onclick="setAllChecked(this)" style="width: 20px;border: 0px;padding: 0px;margin: 0px;" checked="true"/>全选
        </div>
        {foreach key=index item=value from =$product_listvalue_arr}
        <div style="overflow:hidden;float: left;margin: 0px 6px 4px 0px;">            
            <input type="checkbox" name="chb[]"  listvalue="{$value}" onclick="setChecked(this)" style="width: 20px;border: 0px;padding: 0px;margin: 0px;" checked="true" />
            <span class="dongmaobgtype{$index}">{$value}</span>
        </div>
        {/foreach}    
    </div>
    <div style="padding: 12px 20px 6px 20px;overflow: hidden;">
        <div style="overflow:hidden;float:left;margin: 0px 6px 4px 0px;">     
            大巴车类型：<input type="checkbox" name="checkAll2" id="checkAll2" onclick="setAllChecked2(this)" style="width: 20px;border: 0px;padding: 0px;margin: 0px;" checked="true"/>全选
        </div>
        {foreach key=index item=value from =$bus_listvalue_arr}
        <div style="overflow:hidden;float: left;margin: 0px 6px 4px 0px;">            
            <input type="checkbox" name="chb2[]"  listvalue="{$value}" onclick="setChecked2(this)" style="width: 20px;border: 0px;padding: 0px;margin: 0px;" checked="true" />
            <span class="dongmaobg2type{$index}">{$value}</span>
        </div>
        {/foreach}    
    </div>
    <div style="padding: 4px 0px 12px 20px;">
        <span style="line-height: 28px;">中心点：</span><input type="text" id="centeraddress" name="addressinput" class="detailedViewTextBox" style="width:300px;margin-right: 20px;}"  value="{$address}"/>
        <span style="line-height: 28px;">距离(米)：</span><input type="text" name="distanceinput" class="detailedViewTextBox" style="margin-right: 20px;width:100px;"  value="{$distance}" onkeyup="this.value=this.value.replace(/\D/g,'')" />
        <input class="createauto" type="button" onclick="typesSearch()" value="查询"/>
        <span style="line-height: 28px;margin-left: 20px;"> <span style="line-height: 28px;margin-left: 20px;">下游客户共</span><span tag="quantity_product"> </span>条记录
        <span style="line-height: 28px;margin-left: 20px;"> <span style="line-height: 28px;margin-left: 20px;">大巴车共</span><span tag="quantity_bus"> </span>条记录
    </div>
</div>

<div id="map_div" name="map_div" style="height:100%"></div>
<script type="text/javascript" charset="utf-8" src="{$JSURL}include/js/modules/ServiceCharge/map_distribution.js"></script>
<script type="text/javascript" charset="utf-8">

    //接收主营品类型、大巴车类型给多选框
    var product_listvalue_arr = '{$product_listvalue_arr_forjs}';
    var bus_listvalue_arr = '{$bus_listvalue_arr_forjs}';
    var product_listvalue_arr_json = eval('('+ product_listvalue_arr +')')?eval('('+ product_listvalue_arr +')'):JSON.parse(product_listvalue_arr);
    var bus_listvalue_arr_json = eval('('+ bus_listvalue_arr +')')?eval('('+ bus_listvalue_arr +')'):JSON.parse(bus_listvalue_arr);
    //console.log(bus_listvalue_arr_json);
    
    
    //接收客户信息
    //var point_arr = '{$point_arr}';
    var point_arr = '{$all_accountinfo}';

    //接收中心点经纬度
    var first_map_lat = '{$first_map_lat}';
	var first_map_lng = '{$first_map_lng}';

    //接收拖拽后返回的中心点文字地址
    var address='{$address}';
    
    
    //接收距离值
    var distance='{$distance}';
    
    
    
    //接收拖拽后返回的客户数量，分别是主营品和大巴车数量
    var product_count='{$product_count}';
    var bus_count='{$bus_count}';
    ld('span[tag=quantity_product]').text(product_count);
    ld('span[tag=quantity_bus]').text(bus_count);
    
    
    //加载地图
    loadScript();    
</script>











