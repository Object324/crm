//zxm  2020-1209 库博特殊开发 增加的新行 将上一行的数据复制过来
function setNewRowValueCopy(type,lineNum){
    var tableobj = popupobj.getDetailTableObj();
    var prevrowobj = ld(tableobj).find("tr[rowindex="+(lineNum-1)+"]");
    var attr_arr = ["sf284","sf285","sf414","startdate","enddate","select_entitytypeid","entitytypeid_name","sf286","sf294","sf323","expensetype"];
    ld.each(attr_arr,function(index,item){
        var value = ld(prevrowobj).find("[detailcolumnname="+item+"]").val();
        var rowobj = ld(tableobj).find("tr[rowindex="+lineNum+"]");
        rowobj.find("[detailcolumnname="+item+"]").val(value);
        if(item=="sf414"||item=="sf286"||item=="sf294"||item=="expensetype"){
            rowobj.find("[name=cmb_span_optiontext_"+item+"]").val(value);
        }
    })
}