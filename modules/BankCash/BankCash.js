document.write("<script type='text/javascript' src='include/js/Inventory.js'></"+"script>");
function getBankCash(bankcashid,obj){
    if(document.getElementById("selectbankid") != undefined)
    {
        var select_id = document.getElementById("selectbankid").value;
        if(select_id > 0)
        {
            $('morebankcashid').className='';
            document.getElementById("selectbankid").value = '';
        } 
    }
    if(obj!=null){
        var classmethods = $$('.on');
        for(var i=0;i<classmethods.length;i++){
            classmethods[i].className = 'on';
        }
            obj.className='on On';
    }
    var leagerid = document.getElementById('hiddenledger').value;
	
	var startdate = document.getElementById('jscal_field_createdate').value;
    var enddate = document.getElementById('jscal_field_enddate').value;
	var urldata = 'start=1&startdate='+startdate+'&enddate='+enddate;
	urldata += '&bankcashid='+bankcashid+'&hiddenledger='+leagerid;
    getListViewEntries_js('BankCash',urldata);
    $('bankcashid').value=bankcashid; 
}
function exportback(url){
    var select_id = document.getElementById("bankcashid").value;
    document.location.href=url+select_id;
}
function getMoreBankCash(obj,id){
    var classmethods = $$('.on');
    var warehouseid=obj.value;
    if(warehouseid==''){
        return false;
    }
    for(var i=0;i<classmethods.length;i++){
        classmethods[i].className = 'on';
    }
    var startdate = document.getElementById('jscal_field_createdate').value;
    var enddate = document.getElementById('jscal_field_enddate').value;
    $(id).className='On';
    var leagerid = document.getElementById('hiddenledger').value;
    getListViewEntries_js('BankCash','start=1&startdate='+startdate+'&enddate='+enddate+'&bankcashid='+warehouseid+'&hiddenledger='+leagerid);       
    $('bankcashid').value=warehouseid; 
}