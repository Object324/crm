//朗捷 合同（报价单）->相关信息->出口空运特殊字段公式 计算运费
function autoTotalPrice(obj,id_rowIndex) {
    var popupobj=CrmPopup.getPopupObj("last"),
        weightSection=[], //重量区间
        weight = ld("#"+popupobj.divid+" [name=sf9995"+id_rowIndex+"]").val(); //货物重量
    if(weight == ''){
        return false
    }
    // 根据字段名获取重量区间
    ld.each(popupobj.detailfields,function(index,value){
        if(value.columnname == 'sf10131'  || value.columnname == 'sf10403'||value.columnname == 'sf10267' || value.columnname == 'sf10539' ||  value.columnname == 'sf10675' || value.columnname == 'sf10811' ){
            weightSection.push(parseInt(value.fieldlabel.slice(0,-2)));
        }
    })
    weightSection.sort(function (a,b) {
        return a - b
    });

    var totalPrice = ld("#"+popupobj.divid+" [name=span_sf10947"+id_rowIndex+"]").html(), //单行货物总价
    a= ld("#"+popupobj.divid+" [name=sf10131"+id_rowIndex+"]").val(),
    b= ld("#"+popupobj.divid+" [name=sf10267"+id_rowIndex+"]").val(),
    c= ld("#"+popupobj.divid+" [name=sf10403"+id_rowIndex+"]").val(),
    d= ld("#"+popupobj.divid+" [name=sf10539"+id_rowIndex+"]").val(),
    e= ld("#"+popupobj.divid+" [name=sf10675"+id_rowIndex+"]").val(),
    f= ld("#"+popupobj.divid+" [name=sf10811"+id_rowIndex+"]").val(),
    priceSection =[a,b,c,d,e,f];  //价格区间

    for (var i=0;i<weightSection.length;i++){
        if(weight>=weightSection[i] && weightSection[i+1] != undefined && weight <weightSection[i+1]){
            totalPrice= weight*priceSection[i];
            break;
        }
    }
    if(weight>= weightSection[weightSection.length-1]){
        totalPrice= weight*priceSection[weightSection.length-1];
    }
    if (totalPrice == 0){
        totalPrice ='0.00';
    }else{
        totalPrice = totalPrice.toFixed(2);
    }
    ld("#"+popupobj.divid+" [name=span_sf10947"+id_rowIndex+"]").html(totalPrice);
    ld("#"+popupobj.divid+" input[name=sf10947"+id_rowIndex+"]").val(totalPrice);
}