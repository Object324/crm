function fieldinfo(popupobj)
{
    var that = this;
    this.popupobj = popupobj;
    this.module = popupobj.module;
    //判断是否为数字类型或金额类型
    this.isFldNumOrMoney = function(fieldobj){
        if(this.istotalFldNumField(fieldobj) || this.istotalFldMoneyField(fieldobj) || this.isPriceField(fieldobj)){
            return true;
        }
        return  false;
    }
    //判断是否为数字类型
    this.istotalFldNumField = function(fieldobj){
        var module = this.module;
        if(empty(fieldobj)){
            return false;
        }
        if((module=='Accounts'||module=='Potentials'||module=='Leads')&&(fieldobj.columnname=='nolinkdays' || fieldobj.columnname=='approve_hours' ))
        {
            return false;
        }
        var uitype_arr = new Array('7','560');
        if(uitype_arr.includes(fieldobj.uitype)){
            return true;
        }else{
            return false;
        }
    }
    //判断是否为金额类型
    this.istotalFldMoneyField = function(fieldobj){
        var module = this.module;
        if(empty(fieldobj)){
            return false;
        }
        if(module=='Products'&&(fieldobj.columnname=='unit_price'||fieldobj.columnname=='costprice'))
        {
            return false;
        }
        var uitype_arr = new Array('71','72');
        if(uitype_arr.includes(fieldobj.uitype)){
            return true;
        }else{
            return false;
        }
    }
    //判断是否为价格字段
    this.isPriceField = function(fieldobj){
        var module = this.module;
        if(empty(fieldobj)){
            return false;
        }
        if(module=='Products'&&(fieldobj.columnname=='unit_price'||fieldobj.columnname=='costprice'))
        {
            return true;
        }
        return false;
    }
}
fieldinfo.prototype={
    fieldid:0,
    columnname:'',
    fieldlabel:'',
    defaultvalue:'',
    presence:0,
    uitype:1,
    typeofdata:'V~O',
    sequence:1,
    tabid:22,
    tablename:'',
    width:10,
    relate_search_parent_columnname:''
}


