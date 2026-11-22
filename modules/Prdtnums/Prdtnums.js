function updateQtyinstock(qtyinstock,fieldname,oSelect)
{
    if(oSelect.checked == true)
    {
        document.getElementById(fieldname).disabled = false;
    }else
    {
        document.getElementById(fieldname).disabled = true;
    }
}
function updateAllQtyinstock()
{
   
    var popupobj=CrmPopup.getPopupObj("last");
   
    for(var j=0; j<document.massdelete.elements.length; j++)
    {
        var fieldname = document.massdelete.elements[j].name;
        if(fieldname.indexOf("qtyinstock") > 0 && document.massdelete.elements[j].type == "text") {
            if(document.massdelete.selectall.checked) document.massdelete.elements[j].disabled = false;
            else document.massdelete.elements[j].disabled = true;
        }
    }
}
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
        for(var i=0;i<classmethods.length;i++)
        {
            classmethods[i].className = 'on';
        }
        obj.className='on On';
    }
    getListViewEntries_js('Prdtnums','start=1&warehouseid='+warehouseid);     
    $('warehouseid').value=warehouseid; 
    if(document.getElementById('selectwareid') != undefined)
    {
        document.getElementById('selectwareid').selectedIndex=0; 
    }
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
        //19330: 库存>出库单列表界面：全部仓库切换到更多选择“仓库数量”，然后在选择空白的，界面会闪下undefind
        //window.location.href='index.php?module=Prdtnums&action=index&parenttab=Stock';
        //alert(arrJsPopLabel['NOHAVEPERMISSIONWAREHOUSE']);
        return false;
    }
    for(var i=0;i<classmethods.length;i++){
        classmethods[i].className = 'on';
	}
	$(id).className='On';
	getListViewEntries_js('Prdtnums','start=1&warehouseid='+warehouseid);        
	$('warehouseid').value=warehouseid;
	ld('#ware_select_more').addClass('On');
}
prod_array = new Array();
function updateProductNum(type)
{
        x = document.massdelete.selected_id.length;
        prod_array = new Array(x);
        idstring = "";
        if ( x == undefined)
        {
            if (document.massdelete.selected_id.checked)
            {
                yy = document.massdelete.selected_id.value+"_qtyinstock";
                document.massdelete.idlist.value = document.massdelete.selected_id.value;
                var elem = document.massdelete.elements;
                var ele_len =elem.length;
                var i=0,j=0;
                for(i=0; i<ele_len; i++)
                {
                    if(elem[i].name == yy)
                    {
                        if (elem[i].value.replace(/^\s+/g, '').replace(/\s+$/g, '').length==0)
                        {
                            //初始化产品数量不能为空！
                            var confirm_str = arrJsPopLabel['QUANTITYINITIALIZATIONCANOTEMPTY'];
                            RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
                            elem[i].focus();
                            return false;
                        }
                        else if(isNaN(elem[i].value))
                        {
                            //无效的初始化产品数量！
                            var confirm_str = arrJsPopLabel['INVALIDINITIALIZATIONPRODUCTNUM'];
                            RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
                            elem[i].focus();
                            return false;
                        }
                    }
                }
            }
            else
            {
                //请至少选择一条记录！
                var confirm_str = arrJsPopLabel['PLEASESELECTLEASTONERECORD'];
                RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
                return false;
            }
        }
        else
        {
            xx = 0;
            for(i = 0; i < x ; i++)
            {
                if(document.massdelete.selected_id[i].checked)
                {
                    idstring = document.massdelete.selected_id[i].value +";"+idstring;
                    prod_array[xx] = document.massdelete.selected_id[i].value;
                    xx++;
                }
            }
            if (xx != 0)
            {
                document.massdelete.idlist.value=idstring;
                var elem = document.massdelete.elements;
                var ele_len =elem.length;
                var i=0,j=0;
                for(i=0; i<ele_len; i++)
                {
                    for(j=0; j < xx; j++)
                    {
                         var xy= prod_array[j]+"_qtyinstock";
                        if(elem[i].name == xy)
                        {
                            if (elem[i].value.replace(/^\s+/g, '').replace(/\s+$/g, '').length==0)
                            {
                                //初始化产品数量不能为空！
                                var confirm_str = arrJsPopLabel['QUANTITYINITIALIZATIONCANOTEMPTY'];
                                RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
                                elem[i].focus();
                                return false;
                            }
                            else if(isNaN(elem[i].value))
                            {
                                //无效的初始化产品数量！
                                var confirm_str = arrJsPopLabel['INVALIDINITIALIZATIONPRODUCTNUM'];
                                RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
                                elem[i].focus();
                                return false;
                            }
                        }
                    }
                }
            }
            else
            {
                //请至少选择一条记录！
                var confirm_str = arrJsPopLabel['PLEASESELECTLEASTONERECORD'];
                RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
                return false;
            }
        }
        if(type){//暂存
            document.massdelete.action="index.php?module=Prdtnums&action=Save&return_module=Prdtnums&return_action=ListView"
			document.massdelete.submit();
		}else{
            //确认后将不允许再更改产品初始数量，您确定要完成库存初始化吗？    
            var confirm_str = arrJsPopLabel['CONFIRMNOTALLOWEDCHANGEPRODUCT'];
            RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
            //确定按钮
            ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
                document.massdelete.action="index.php?module=Prdtnums&action=ProductStart&return_module=Prdtnums&return_action=ListView"
                document.massdelete.submit();
            });
            return false;
        }
}
function importproduct(){
    var form=document.forms['massdelete'];
    var warehouseid=form.warehouseid.value;
    document.location.href='index.php?module=Prdtnums&action=ImportProduct&warehouseid='+warehouseid;
}
function uploadAndParse(){
    var form=document.forms['importPrdtnums'];
    var files=form.import_file.value;
    if(files.length>0){
        return true;
    }else{
        //导入文件不能为空！
        var confirm_str = arrJsPopLabel['IMPORTFILECANOTEMPTY'];
        RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
        return false;
    }
}
function checkFileType(){
    var form=document.forms['importPrdtnums'];    
    var filepath=form.import_file.value;
    if(filepath!=''){
        var fileExtension = filepath.split('.').pop();
        if(fileExtension=='xls' || fileExtension=='xlsx');
        else
        //文件格式不正确，请导入xls或者xlsx文件！
        var confirm_str = arrJsPopLabel['FILEFORMATCORRECT'];
        RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
    }
}  