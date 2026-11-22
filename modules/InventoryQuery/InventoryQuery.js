document.write("<script type='text/javascript' src='include/js/Inventory.js'></"+"script>");
function getWarehouse(warehouseid,obj){
    if(document.getElementById("selectwareid") != undefined)
    {
        var select_id = document.getElementById("selectwareid").value;
        if(select_id > 0)
        {
            $('morewarehouseid').className='';
            document.getElementById("selectwareid").value = '';
        } 
    }
    if(obj!=null){
    var classmethods = $$('.on');
    for(var i=0;i<classmethods.length;i++){
    classmethods[i].className = 'on';
    }
    obj.className='on On';
    
    }
    
    $('wareid').value=warehouseid;
    getListViewEntries_js('InventoryQuery','set=1');  
	 if(document.getElementById('morewarehouseid')!=undefined)
    {
        ld('morewarehouseid').className='';   
    }
	if(ld('#ware_select_more') != undefined){
		ld('#ware_select_more').removeClass('On');
		ld('#cmb_span_optiontext_selectwareid').html('');
	}
}
function getMoreWarehouse(obj,id){
    var classmethods = $$('.on');
    var warehouseid=obj.value;
    if(warehouseid==''){
        //您没有这个仓库的权限！
       // window.location.href='index.php?module=InventoryQuery&action=index&parenttab=Stock';
        //alert(arrJsPopLabel['NOHAVEPERMISSIONWAREHOUSE']);
        return false;
    }
    for(var i=0;i<classmethods.length;i++){
        classmethods[i].className = 'on';
        }
        $(id).className='On';
        $('wareid').value=warehouseid;
        getListViewEntries_js('InventoryQuery','start=1');
		ld('#ware_select_more').addClass('On');
}