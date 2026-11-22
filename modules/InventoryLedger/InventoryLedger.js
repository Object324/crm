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
        var classmethods = $$('#tabWareHouse li a');
        for(var i=0;i<classmethods.length;i++){
        classmethods[i].className = '';
        }
        obj.className='On';
    }
    getListViewEntries_js('InventoryLedger','warehouseid='+warehouseid);
    $('warehouseid').value=warehouseid; 
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
    var classmethods = $$('#tabWareHouse li a');
    var warehouseid=obj.value;
    if(warehouseid==''){
        //您没有这个仓库的权限！
        //19330: 库存>出库单列表界面：全部仓库切换到更多选择“仓库数量”，然后在选择空白的，界面会闪下undefind
       // window.location.href='index.php?module=InventoryLedger&action=index&parenttab=Stock';
        //alert(arrJsPopLabel['NOHAVEPERMISSIONWAREHOUSE']);
        return false;
    }
    for(var i=0;i<classmethods.length;i++){
        classmethods[i].className = '';
    }
    $(id).className='On';
    getListViewEntries_js('InventoryLedger','start=1&warehouseid='+warehouseid);        
    $('warehouseid').value=warehouseid; 
	ld('#ware_select_more').addClass('On');
}
function getInitalNum(obj,pricetype,startdate,enddate,productid,warehouseid,ledger,type)
{
    //alert("module=InventoryLedger&action=InventoryDiv&pricetype="+pricetype+"&startdate="+startdate+"&enddate="+enddate+"&productid="+productid+"&warehouseid="+warehouseid+"&ledger="+ledger+"&type="+type);
    $("status").style.display="inline";
    new Ajax.Request("index.php",
		{
			queue:{
				position:"end",
				scope:"command"
			},
			method:"post",
			postBody:"module=InventoryLedger&action=InventoryDiv&pricetype="+pricetype+"&startdate="+startdate+"&enddate="+enddate+"&productid="+productid+"&warehouseid="+warehouseid+"&ledger="+ledger+"&type="+type,
			onComplete:function (response) {
			 var results=response.responseText.split('##SUCCESS##');  
             $('divInital').innerHTML=results[1];
             fnvshobj(obj,'divInital');
             $("status").style.display="none";
			}
		}); 
}

/**
 * 
 * @param
 * @returns
 * @author Tujt 2014-05-06
 */
function exportInventoryLedger(FIRSTDAY,LASTDAY,UNPRICE,PRODUCTINFO,PRODUCTDETAIL,LEDGER){
    var select_id = document.getElementById("warehouseid").value;

   document.location.href = 'index.php?module=InventoryLedger&action=InventoryLedgerAjax&file=ExportInventoryLedger&warehouseid='+select_id+'&createdate='+FIRSTDAY+'&enddate='+LASTDAY+'&unprice='+UNPRICE+'&productinfo='+PRODUCTINFO+'&productdetail='+PRODUCTDETAIL+'&hiddenledger='+LEDGER;
}