var popupobj=CrmPopup.getPopupObj("last");
popupobj.before_validate=function()
{
    
     var b=true;
	var popupobj=CrmPopup.getPopupObj("last");
	var divid=popupobj.divid;

	if(account_version=='langjie')
	{
	    var tableobj=ld("#"+popupobj.divid+" [name="+popupobj.js_detailtablename+"]");
      //  var 
        var trobjs=ld(tableobj).find("tr[detaildeleted=no]");
        var rowi=1;
        var arr=[];
        ld.each(ld(trobjs),function(){
            var rowindex=ld(this).attr("rowindex");
            var tmpobj={};
            var parent_lineitem_id=ld(this).find("[name=parent_lineitem_id"+rowindex+"]").val();
            var sf217count=ld(this).find("[name=sf217"+rowindex+"]").val();//商品数量
            if(eval(parent_lineitem_id)>0)
            {
                tmpobj={"parent_lineitem_id":parent_lineitem_id,'rowi':rowindex,'sf217count':sf217count};
                arr.push(tmpobj);
                
            }
        })
	   var max_url="module=Commission&action=CommissionAjax&quantityinfo="+JSON.stringify(arr)+"&commissionid="+popupobj.record+"&file=LangJieSaveQuantityCheck";
       
		ld.ajax({
			type : "post",
			url : "index.php",
			data : max_url,
			async:false,
            dataType:'json',
			success : function(response) {
			   
				if(response.code=='-1')
				{
					   RemindsMsg("","","","","",response.msg);
                       b= false;
								
				}
                
			}
		}); 
	}
    return b;       
     
	
}