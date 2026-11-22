/**
 * Created by gyq_10 on 2016/4/15.
 */

var TabDetailFields = (function(){

    //参数：传递给单例的一个参数集合
    function DetailFields() {

        this.name = 'TabDetailFields';

    }


    DetailFields.prototype.selectFieldType = function(obj){

        var selVal = ld(obj).val();


        ld.get("index.php",{selectFieldType_ajax : selVal ,module:"Settings",file:"ProductToolEditField",'action':"SettingsAjax"},function(response){

            ld(obj).parent().parent().nextAll().remove();
            ld(obj).parent().parent().after(response);

        });
    }

    DetailFields.prototype.saveFieldInfo = function(selectFieldType){

        var DetailFieldsHtmlExist = ld('#selectmodule').prev().val();

        if(DetailFieldsHtmlExist == 'cls_TabDetailFields') {

            var urlstring = '';
            if (selectFieldType == 'Date') {//日期
                var dateStyle = $('selectDateStyle').value;

                urlstring += '&selectFieldType=' + dateStyle;
                if ($('dateOption') != undefined) {
                    urlstring += '&dataOption=' + $('dateOption').value;
                }
            } else {
                //文本
                if (selectFieldType == 'Text') {
                    //字段长度
                    if ($('textlength') != undefined) {
                        if ($('textlength').value == '') {
                            alert($('textlength').alt + arrJsPopLabel['CANOTEMPTY'] + '!');
                            $('textlength').focus();
                            return 'exit';
                        } else {
                            urlstring += '&textlength=' + $('textlength').value;
                        }
                    }
                } else if (selectFieldType == 'Num') {//数字
                    //精度
                    if ($('precisionvalue') != undefined) {
                        var precisionvalue = $('precisionvalue').value;
                        if (precisionvalue == '' || precisionvalue < 0) {
                            urlstring += '&precision=0';
                        } else {
                            urlstring += '&precision=' + precisionvalue;
                        }
                    }
                } else if (selectFieldType == 'Number') {	//数量
                    urlstring += '&precision=8';//数量默认精度为8
                } else if (selectFieldType == 'Amount') {	//金额
                    urlstring += '&precision=6';//金额默认精度为6
                } else if (selectFieldType == 'CheckBox') {
                    if ($('checkcolumn').checked == true) {
                        urlstring += '&checkcolumn=1';
                    } else {
                        urlstring += '&checkcolumn=0';
                    }
                }
                //默认值
                if ($('defaultvalue') != undefined) {
                    urlstring += '&defaultvalue=' + encodeURIComponent($('defaultvalue').value);
                }
                urlstring += '&selectFieldType=' + selectFieldType;
                //数字、数量、金额、整数
                var reg = /^\d*$/;
                var f = /^\d*\.\d{1,}$/;
                if (selectFieldType == 'Int' || selectFieldType == 'Num' || selectFieldType == 'Number' || selectFieldType == 'Amount') {
                    var defaultvalue = $('defaultvalue').value;
                    if (defaultvalue != '') {
                        if (!defaultvalue.match(reg) && !defaultvalue.match(f)) {
                            alert(arrJsPopLabel['LBL_DEFAULTVALUE'] + arrJsPopLabel['FORMATERROR']);
                            return 'exit';
                        }
                    }
                }
                //数字精度
                if (selectFieldType == 'Num') {
                    var precisionvalue = $('precisionvalue').value;
                    if (precisionvalue != '') {
                        var reg = /^\d+$/;
                        if (!precisionvalue.match(reg) && !defaultvalue.match(f)) {
                            alert(arrJsPopLabel['PRECISIONVALUE'] + arrJsPopLabel['FORMATERROR']);
                            return 'exit';
                        }
                    }
                }
            }
            return urlstring;
        }else{
            return false;
        }

    }



    //实例容器
    var instance;

    var _static = {
        name: 'TabDetailFields',

        //获取实例的方法
        getInstance: function () {
            if (instance === undefined) {
                instance = new DetailFields();
            }
            return instance;

        }
    };
    return _static;

})();
