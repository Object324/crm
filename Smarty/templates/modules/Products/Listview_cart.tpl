<script language="JavaScript" type="text/javascript" src="include/js/modules/Products/shopcart.js"></script>
<script>
    //zxm @date:2024/10/24 @reason: 购物车创建订单 报错VERSION_ACCOUNT undefined
    var version_account = "{$VERSION_ACCOUNT}";
    //修改左上角名称
    ld("title").html("{'SHOPCART'|@getFixedLabel}");
    ld(".detail_path li").html("{'SHOPCART'|@getFixedLabel}");
    setTimeout(function() {
        //菜单有延时  这里为了计算准确需要定时300ms
        change_tablewidth();//调整上下table标签的宽度
    },300);
    load_previewimg();//为产品图片设置预览功能，默认图片不可预览
    var shopcartObj = new shopcart();
    shopcartObj.init();
</script>
<div id="ShopCartContent" class="ShopCartContent ld-bg-color">
    {include file='modules/Products/Listview_cart_content.tpl'}
</div>