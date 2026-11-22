/**
 * 选择航班日期 获取空运订单 已使用的订单号+1 为未使用订单号
 * 其他行订单号均为第一行+行号（虚拟订单号） 不判断数据库。保存的时候再判断
 */
function getAirOrderNumber() {
    // type:change 日期发生改变 add 增加一行
    var popupobj = CrmPopup.getPopupObj('last'),
        rowcnt = ld('#'+popupobj.divid+' [name="rowcnt"]').get(0).value,
        time =ld("#"+popupobj.divid+" [name=flight_date]").val();
    ld.ajax({
        url: "index.php?module=CustomForm24&action=CustomForm24Ajax&file=getLangjieOrderNumber",
        type: 'POST',
        data:{time,rowcnt},
        dataType: 'json',
        timeout: 20000,
        success: function (data) {
            if(data.code ==1){
                for (var i=1;i<=rowcnt;i++){
                    var value = data.result.before+prefixInteger(3,(data.result.number+i-1))
                    // console.log(value)
                    ld("#"+popupobj.divid+" [name=sf169"+i+"]").val(value);
                    ld("#"+popupobj.divid+" [name=sf169"+i+"]").attr('readonly','true');
                    ld("#"+popupobj.divid+" [name=sf169"+i+"]").css('cursor','not-allowed');
                }


            }
        }
    })
}

// 格式化数字
function prefixInteger(length,num) {
    return ( "0000000000000000" + num ).substr( -length );
}
/**
 * 空运订单号增加一行
 */
function getAirOrderNumberadd(type,lineNum){
    var prevrowobj=ld(tableobj).find("tr[rowindex="+(lineNum-1)+"]");
    var value = ld(prevrowobj).find(" [detailcolumnname=sf169]").val();
    var tableobj=popupobj.getDetailTableObj();
    var rowobj=ld(tableobj).find("tr[rowindex="+lineNum+"]");
    
    var beforeValue = value.slice(0,9);
    var afterValue = parseInt(value.slice(9));
    var newAfterValue =prefixInteger(3,(afterValue+1));
    ld(rowobj).find(" [detailcolumnname=sf169]").val(beforeValue+newAfterValue);
    ld(rowobj).find(" [detailcolumnname=sf169]").attr('readonly','true');
    ld(rowobj).find(" [detailcolumnname=sf169]").css('cursor','not-allowed');
}
/***
 日期控件
 ***/
function datePickerChanged(objname)
{
    //alert(obj.cal.getNewDateStr());
    //布局规则
    var popupobj=CrmPopup.getPopupObj("last");
    //朗捷 根据时间返回订单号
    if(ld("#version_account").val() == 'langjie'&& popupobj.module =='CustomForm24' && objname =='flight_date' ){
        getAirOrderNumber();
    }

    popupobj.fieldruleobj.CheckReLoadPopup();
}

/*
编辑页面设置设置只读
 */
function setDetailReadOnly(){
    var popupobj=CrmPopup.getPopupObj("last"),
        rowcnt = ld('#'+popupobj.divid+' [name="rowcnt"]').get(0).value;
    var trobjs=popupobj.getTrObjsByDelType('no');
    ld.each(trobjs,function(){
        ld(this).find(" [name=sf169]").attr("readonly",true);
        
    })
    /*for(var i=1;i<=rowcnt;i++){
        ld("#"+popupobj.divid+" [name=sf169"+i+"]").attr('readonly','true');
    }*/

}