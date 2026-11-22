function moreCurrencySet(){
    var that=this;
    that.popupobj = '';
    that.more_currency_info = [];
    that.fieldname = '';
    that.prevPopobj = '';
    that.linedata = [];

    this.moreCurrencySetConfirm = function (){
        var tmpmore_currency_info = that.more_currency_info;
        that.linedata[that.fieldname] = tmpmore_currency_info[0]['curvalue'];
        var popupobj = CrmPopup.getPopupObj('last');
        popupobj.CancelEvent();
    }
    this.getMoreCurrentInfoHtml = function (tmp_value){
        var more_currency_info = that.more_currency_info;
        var fieldname = that.fieldname;

        var html = '';
        html += '<table class="D_pop_bod listEntries" width="100%" cellspacing="0" cellpadding="0" border="0">' +
            '<thead><tr>' +
            '<th>币种</th>            ' +
            '<th>价格</th>' +
            '<th>换算率</th>' +
            '<th>重算其他币种价格</th>' +
            '<th style="display:none">...</th>' +
            '</tr></thead>';
        html += '<tbody>';
        ld.each(more_currency_info,function (index,price){
            html += '<tr rowindex="'+index+'">';
            var check_value = '';
            var disable_value = '';
            var check_disabled = '';

            if(price.check_value==1 || price.is_basecurrency==1){
                check_value='checked'
                disable_value = '';
            }else{
                check_value=''
                disable_value = 'disabled';
            }
            if(price.curid==1){
                check_disabled = 'disabled';//人民币默认选中不可取消
                price.curvalue = tmp_value;
            }
            var base_cur_check = "";
            if(price.is_basecurrency == 1){
                base_cur_check = "checked";
            }

            html += '<td class="select-input"><input id="currencystring_'+price.curid+'" type="checkbox"  name="'+fieldname+'_cur_'+price.curid+'_check" onclick="fnenableDisable(this,\''+price.curid+'\',\''+fieldname+'\'); updateCurrencyValue(this,\''+price.curname+'\',\''+fieldname+'\',\''+price.conversionrate+'\');" '+check_value+' '+check_disabled+'/>' +
                '<label for="currencystring_'+price.curid+'">'+price.currencylabelShow+' ('+price.currencysymbol+')</label></td>';

            html += '<td><input '+disable_value+' type="text" size="10" class="ld-input-inner" name="'+price.curname+'" id="'+price.curname+'" value="'+price.curvalue+'" onkeyup="value=value.replace(/[^0-9.]/g, \'\').replace(/(\\..*)\\./g, \'$1\');"/></td>';

            html += '<td><input disabled=true type="text" size="10" class="ld-input-inner" name="'+fieldname+'_cur_conv_rate'+price.curid+'" value="'+price.conversionrate+'"/></td>';

            html += '<td><div class="ld-button ld-button-primary" name="cur_reset'+price.curid+'" onclick="resetCurrencyValue(this,\''+price.curname+'\',\''+fieldname+'\',\''+price.conversionrate+'\');">重算价格</div></td>';

            html += '<td style="display:none"><input '+disable_value+' type="radio" name="base_currency_input" value="'+price.curname+'" '+base_cur_check+' onchange="updateBaseCurrencyValue()" />' +
                '<input type="text" style="display:none" value="'+price.curid+'" name="base_currency_curid"/></td>'

            html += '</tr>';
        })
        html += '</tbody></table>';
        return html;
    }
}
moreCurrencySet.showCurrencySet = function (more_currency_info,fieldname,linedata,prevPopobj){
    var moreCurrencySetObj = new moreCurrencySet();
    moreCurrencySetObj.more_currency_info = more_currency_info;
    moreCurrencySetObj.fieldname = fieldname;
    moreCurrencySetObj.prevPopobj = prevPopobj;
    moreCurrencySetObj.linedata = linedata;
    var tmp_value = linedata[fieldname];//本位币的值

    //弹框显示多币种
    var currencyhtml = moreCurrencySetObj.getMoreCurrentInfoHtml(tmp_value);
    var currencyPopupobj = CrmPopup.load("产品价格",  moreCurrencySetObj.moreCurrencySetConfirm,"", "LdPopWidth800px", 'Products', [], arrJsPopLabel['CONFIRMED'], "", arrJsPopLabel['CANCEL']);
    currencyPopupobj.prevshow();
    currencyPopupobj.createScrollDiv();//创建滚动条
    CrmPopup.setPopupobjHtmlContent_scroll(currencyPopupobj,currencyhtml);
    currencyPopupobj.center();
    //双向绑定
    ld.each(more_currency_info,function (index,price){
        var trobj = ld('#'+currencyPopupobj.divid).find('tr[rowindex='+index+']');
        //复选框
        var checkboxobj = trobj.find('#currencystring_'+price.curid);
        var DataHtmlBindobj1 = new DataHtmlBind();
        DataHtmlBindobj1.setJqueryObj(checkboxobj);
        DataHtmlBindobj1.setDataBindByJqueryObj(price, 'check_value');
        //价格
        var priceInputObj = trobj.find('#'+price.curname);
        var DataHtmlBindobj2 = new DataHtmlBind();
        DataHtmlBindobj2.setJqueryObj(priceInputObj);
        DataHtmlBindobj2.setDataBindByJqueryObj(price, 'curvalue');

    });

    moreCurrencySetObj.popupobj = currencyPopupobj;

}