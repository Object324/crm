//# sourceURL= ProductsEdit.js
var ProductsEdit = function () {
    var that = this;

    //绑定编辑界面的事件
    that.editInit = function(){
        var that = this;
        if(!empty(that.restBlocks)) {
            that.showProductPropertyDetails();
            that.showProductDetailTable();
            if (that.popupJqObj.find('[name=sel_property_status]').length <= 0 || that.popupJqObj.find('[name=sel_property_status]').prop('checked') == false) {
                //字段隐藏 也不显示
                that.popupJqObj.find('[tag=productproperty_div]').hide();
            } else {

            }

            that.setInitEvent();
        }
    }
    that.setInitEvent = function(){
        //启用关闭产品属性的事件
        that.popupJqObj.find('[name=sel_property_status]').unbind('click',that.setproductproperty_divToggle)
        that.popupJqObj.find('[name=sel_property_status]').bind('click',that.setproductproperty_divToggle);


        //选择产品属性单据事件
        that.popupJqObj.find('[name=propertyids]').unbind('change',that.setpropertyidsChange);
        that.popupJqObj.find('[name=propertyids]').bind('change',that.setpropertyidsChange);


        //设为默认事件  分录行设为默认 只允许设置一行默认
        that.productpropertyDiv.find('#productproperty_list_body').find('[name=setdefault]').unbind('click',that.setDefaultEvent)
        that.productpropertyDiv.find('#productproperty_list_body').find('[name=setdefault]').bind('click',that.setDefaultEvent);
    }

    this.setDefaultEvent= function(event){
        var clickobj = event.target;
        var thisvalue = ld(clickobj).prop('checked');
        if(thisvalue==true){
            that.productpropertyDiv.find('#productproperty_list_body').find('[name=setdefault]').prop('checked',false);
            ld(clickobj).prop('checked',true);
        }
    }
    that.setpropertyidsChange = function(){

        that.popupJqObj.find('[tag=productproperty_div]').remove();
        that.getProductPropertyDetails();
    }
    that.setproductproperty_divToggle = function(){
        //选产品属性输入框隐藏 //启用关闭产品属性 需要将选产品属性的输入框隐藏  需要将选产品属性的区块隐藏
        that.popupJqObj.find('[tag=productproperty_div]').toggle();
    }
    //编辑的时候 直接显示产品属性数据
    that.showProductPropertyDetails = function(){
        var productproperty_arr = that.restBlocks['productproperty_arr'];
        var propertyHtml = that.getProductPropertyHtml(productproperty_arr);

        var html = '<div tag="productproperty_div"><table class="ld-createedit-tablecontent" style="width:100%;table-layout: fixed;" cellspacing="0" cellpadding="0" border="0">' +
            '  <tbody><tr><td style="width: 200px"></td><td style="width: calc(100% - 200px)"></td><td style="width: 200px"></td><td style="width: calc(100% - 200px)"></td></tr>';
        html += that.getBlockNameHtml();
        html += propertyHtml;
        html += that.getProductPropertyBtnHtml();
        //属性表格的表头
        html += that.gettableHeaderHtml();
        html += '</tbody></table></div>';
        that.EditTable.after(html);
        that.productpropertyDiv = that.popupJqObj.find('[tag=productproperty_div]');
        //双向绑定--属性明细勾选的双向绑定
        that.setPropertyDataBind(productproperty_arr);
        that.setCreateEvent();//创建按钮事件
    }
    //明细行的显示
    that.showProductDetailTable = function(){
        var propertyBodyHtml = that.createPropertyTbodyHtml();

        that.productpropertyDiv.find('#productproperty_list_body').html(propertyBodyHtml);

        that.getFileUpload();

        //双向绑定--明细行双向绑定
        that.setDetailFieldDataBind();
        //多币种价格按钮的事件 //enter赋值所有行
        that.setProductpropertyListBodyEvent();
    }
    that.setCreateEvent = function(){
        // 点击生成按钮的事件绑定
        that.popupJqObj.find('[tag=Create]').unbind('click').bind('click',function(){
            that.restBlocks['fieldValueList'] = [];
            //点击过选择生成之后 需要重新请求fieldValueList
            var productproperty_arr = that.restBlocks['productproperty_arr'];
            that.resetFieldValueList(productproperty_arr);
            that.showProductDetailTable();
        });
        //点击选择生成按钮的事件绑定
        that.popupJqObj.find('[tag=selectCreate]').unbind('click').bind('click',function(){
            that.selectCreatePopup();
        });
        //点击清空按钮清空表体
        that.popupJqObj.find('[tag=Clear]').unbind('click').bind('click',function(){
            RemindsMsg(arrJsPopLabel["WARMPROMPT"], "LdPopWidth400px", "", "yes", "yes",arrJsPopLabel["Areyousuretodeleteit"]);
            ld('input[tagclick="msgConfirm"]').unbind('click').on('click', function () {
                that.popupJqObj.find('#productproperty_list_body').empty();
            });
        });
    }
    that.setProductpropertyListBodyEvent = function(){
        //删除按钮
        that.popupJqObj.find('[tag=delete]').unbind('click').bind('click',function(){
            var trobj = Tools.getParentobjByChild(ld(this),'tr');
            var rowindex = trobj.attr('rowindex');
            var fieldname = ld(this).data('fieldname');
            var linedata = that.restBlocks['fieldValueList'][rowindex];
            linedata.selected = 0;
            trobj.remove();
            //重设行号
            var trobjs = that.productpropertyDiv.find('#productproperty_list_body tr');
            ld.each(trobjs,function(index,tmptrobj){
                ld(tmptrobj).find('[detailfieldname="no"]').text(parseInt(index)+1);
            });
        });
        //更多币种的点击事件
        that.popupJqObj.find('[tag=more_currency_info]').unbind('click').bind('click',function(){
            var trobj = Tools.getParentobjByChild(ld(this),'tr');
            var rowindex = trobj.attr('rowindex');
            var fieldname = ld(this).data('fieldname');
            var linedata = that.restBlocks['fieldValueList'][rowindex];
            //console.log('点击了第几行：'+rowindex);
            //console.log(linedata);
            //console.log('点击了哪个字段：'+fieldname);
            var more_currency_info = linedata[fieldname+'_morecurrency'];
            //console.log('点击了哪个字段的币种信息：');
            //console.log(more_currency_info);
            //点击的值

            AjaxJSPage("moreCurrencySet_js", 'include/js/modules/Products/moreCurrencySet.js');
            //三个参数 更多币种信息  字段名 本位币的值
            moreCurrencySet.showCurrencySet(more_currency_info,fieldname,linedata,that.popupJqObj);
        });
        ////Ctrl+Enter设置同列所有字段
        that.popupJqObj.find('[tag=money]').unbind('keydown').bind("keydown",function(event){
            var e = event || window.event;
            var keyCode = e.keyCode || e.which || e.charCode;
            var ctrlKey = e.ctrlKey || e.metaKey;
            if(ctrlKey && (keyCode == 13 || keyCode == 10)) {
                var value = ld(this).val();
                var id = ld(this).attr("id");
                var trobj = Tools.getParentobjByChild(ld(this),'tr');
                var rowindex = trobj.attr('rowindex');
                //that.popupJqObj.find('[tag=money]#'+id).val(value);
                var fieldValueList=that.restBlocks['fieldValueList'];
                var curlinedata = fieldValueList[rowindex];
                ld.each(fieldValueList,function(i,linedata){
                    if(i>=rowindex) {
                        linedata[id] = value;
                        if(linedata[id + '_morecurrency']){
                            //多币种
                            var tmpmorecurrency = linedata[id + '_morecurrency'];
                            ld.each(tmpmorecurrency, function (j, tmpcurrencyinfo) {
                                if (tmpcurrencyinfo.curid == 1) {
                                    tmpcurrencyinfo.curvalue = value;
                                    tmpcurrencyinfo.check_value = true;
                                } else {
                                    tmpcurrencyinfo.curvalue = value * tmpcurrencyinfo.conversionrate;
                                    tmpcurrencyinfo.check_value = true;
                                }
                            });
                        }
                    }
                });
            }
        });
        //提示显示
        that.popupJqObj.find('[tag=money]').on('focus', function (evt) {
            var tip_str = arrJsPopLabel['TIPOFBILL2'];
            var id = ld(this).attr("id");//fieldname
            var fieldname_txt = that.popupJqObj.find("th[head_detailfieldname = " + id + "]").text();
            var tip_str_fieldname = tip_str.replaceAll("$字段名称$", fieldname_txt);
            tip_str_fieldname = tip_str_fieldname.replaceAll("$field name$", fieldname_txt);
            that.popupJqObj.find('[name=kindlyremind]').text(tip_str_fieldname);
            that.popupJqObj.find('[name=kindlyremind]').show();
        });
        //失去焦点 隐藏提示
        that.popupJqObj.find('[tag=money]').on('blur',function (evt) {
            that.popupJqObj.find('[name=kindlyremind]').hide();
        });
    }

    //选择产品属性单据之后要去后台请求获取属性数据
    that.getProductPropertyDetails = function(){
        var propertyids_value = that.popupJqObj.find('[name=propertyids]').val();
        ldAjaxNoProgress("index.php?module=Products&action=ProductsAjax&file=ProductPropertyApi&funName=getProductPropertyInfo", {"productpropertyid": propertyids_value}, function (ajaxdata) {
            //属性和属性值名称的一个二维数组
            var productproperty_arr = ajaxdata.result.productproperty_arr;
            that.restBlocks['productproperty_arr'] = productproperty_arr;
            that.restBlocks['fieldValueList'] = ajaxdata.result.fieldValueList;
            that.restBlocks['productproperty_name_header_arr'] = ajaxdata.result.productproperty_name_header_arr;
            that.showProductPropertyDetails();
            that.setCreateEvent();//创建按钮事件
        });
    }
    //选择生成的弹框html内容
    that.selectCreatePopup = function(){
        var selectCreatePopupobj = CrmPopup.load(arrJsPopLabel["selectproperties"],  that.selectCreateConfirm,"", "LdPopWidth800px", 'Products', [that], arrJsPopLabel['CONFIRMED'], "", arrJsPopLabel['CANCEL']);
        selectCreatePopupobj.prevshow();

        var productproperty_arr = that.restBlocks['productproperty_arr'];
        that.resetFieldValueList(productproperty_arr);

        selectCreatePopupobj.createScrollDiv();//创建滚动条
        var propertCombinationHtml = '<div class="ld-description">' +
            '<b class="info-icon"></b>' +
            '<div class="ld-description-content">' +
            arrJsPopLabel['properties_explanation'] +
            '</div>' +
            '</div>' +
            '<div id="MergeTableDiv" class="ld-table-container ld-table-container-lines ld-table-container-bgcolor" style="overflow: auto; width: 100%; max-height: 492px; height: 492px;">' +
            '<table id="productproperty_select_list" class="MergeTable marT10" width="100%" cellspacing="0" cellpadding="0" border="0">' +
            '<thead><tr>';
        var header_arr = that.restBlocks['productproperty_name_header_arr'];
        ld.each(header_arr,function(i,thname){
            propertCombinationHtml+='<th>'+thname+'</th>';
        })
        propertCombinationHtml += '</tr></thead>';
        propertCombinationHtml += '<tbody>';

        var restBlocks = that.restBlocks;
        var tableHeader = restBlocks['tableHeader'];
        var fieldArr = restBlocks['fieldArr'];
        var fieldValueList = restBlocks['fieldValueList'];
        var html = '';
        ld.each(fieldValueList,function(i,line){
            var checked = '';
            if(line.selected===true){
                checked = 'checked';
            }
            var trclass="lvtColData";
            if(i%2==0){
                trclass = "lvtColDataBj";
            }

            html += '<tr class="'+trclass+'" rowindex="'+i+'">';
            html += '<td style="width:25px;" class="ld-form-item-content">';
            html += '<input type="checkbox" '+checked+' data-lineitem_id_combin="'+line.propertydetail_lineitem_id_combin+'">';
            html += '</td>';
            var property_value_name = line['property_value_name_combin'];
            html += '<td class="ld-form-item-content" >';
            html += property_value_name.replaceAll('|##|','/');
            html += '</td>';
            var property_value_name_arr = property_value_name.split('|##|');
            ld.each(property_value_name_arr,function(j,ppvaluename){
                html += '<td class="ld-form-item-content" >';
                html += ppvaluename;
                html += '</td>';
            });
            html += '</tr>';

        });
        propertCombinationHtml += html;
        propertCombinationHtml += '</tbody>';
        propertCombinationHtml += '</table>' +
            '</div>';

        CrmPopup.setPopupobjHtmlContent_scroll(selectCreatePopupobj,propertCombinationHtml);
        selectCreatePopupobj.center();
        //双向绑定
        ld.each(fieldValueList,function(i,line){
            var checkboxobj = ld('#'+selectCreatePopupobj.divid).find('[data-lineitem_id_combin="'+line.propertydetail_lineitem_id_combin+'"]');
            var DataHtmlBindobj = new DataHtmlBind();
            DataHtmlBindobj.setJqueryObj(checkboxobj);
            DataHtmlBindobj.setDataBindByJqueryObj(line, 'selected');
        });
    }
    that.resetFieldValueList = function(productproperty_arr){
        ldAjaxNoProgresssync("index.php?module=Products&action=ProductsAjax&file=ProductPropertyApi&funName=resetFieldValueListRequest",
            {"productproperty_arr": JSON.stringify(productproperty_arr),'productid':that.popupObj.record},
            function (res) {
                that.restBlocks['fieldValueList'] = res.result.fieldValueList;
                that.restBlocks['productproperty_name_header_arr'] = res.result.productproperty_name_header_arr;
            });
    }
    //选择生成确定事件
    that.selectCreateConfirm = function(that){
        var propertyBodyHtml = that.createPropertyTbodyHtml();
        that.productpropertyDiv.find('#productproperty_list_body').html(propertyBodyHtml);

        that.getFileUpload();

        //双向绑定--明细行双向绑定
        that.setDetailFieldDataBind();
        var popupobj = CrmPopup.getPopupObj('last');
        popupobj.CancelEvent();
    }

    //附件字段加载
    that.getFileUpload = function(){
        //明细附件字段js加载
        var restBlocks = that.restBlocks;
        var fieldValueList = restBlocks['fieldValueList'];
        var detailimage_arr = restBlocks['detailimage_arr'];
        var productproperty_list_bodyObj = that.productpropertyDiv.find('#productproperty_list_body');
        that.detailimage_arr = detailimage_arr;



        ld.each(fieldValueList,function(j,line){
            if(line.selected===true) {
                for (var i = 0; i < detailimage_arr.length; i++) {
                    var tmpfieldname = detailimage_arr[i].fieldname;
                    var trobj = productproperty_list_bodyObj.find('[rowindex='+j+']');
                    var fileuploader = ld(trobj).find(" div#" + tmpfieldname);
                    if (fileuploader.length > 0) {
                        var uploadFile = new WebUploadFile();
                        globalWebUploadType = uploadFile.getScript(globalWebUploadType);
                        uploadFile.setDetailEvent(globalWebUploadType, fileuploader, that.popupObj, i, j);
                    }
                }
            }
        })
    }
    that.setPropertyDataBind = function(productproperty_arr){
        ld.each(productproperty_arr,function(i,propertyInfo){
            ld.each(propertyInfo['details'],function(j,propertydetail){
                var checkboxobj = that.productpropertyDiv.find('#propertydetail_check_'+propertydetail.lineitem_id);
                var DataHtmlBindobj = new DataHtmlBind();
                DataHtmlBindobj.setJqueryObj(checkboxobj);
                DataHtmlBindobj.setDataBindByJqueryObj(propertydetail, 'selected');
            });
        });
    }
    //分录字段双向绑定
    that.setDetailFieldDataBind = function(){

        var restBlocks = that.restBlocks;
        var fieldValueList = restBlocks['fieldValueList'];
        var fieldArr = restBlocks.fieldArr;
        var tableobj = that.productpropertyDiv.find('#productproperty_list');

        ld.each(fieldValueList, function (j, linedata) {
            if(linedata.selected===true) {
                var rowobj = ld(tableobj).find("tr[rowindex=" + j + "]");
                ld.each(fieldArr, function (i, tmpfieldname) {
                    if (tmpfieldname == 'line_unit_price' || tmpfieldname == 'line_procostprice' || tmpfieldname == 'line_qtyearly' || tmpfieldname == 'line_status'|| tmpfieldname == 'setdefault' || tmpfieldname == 'line_productcode') {
                        if(tmpfieldname == 'line_status'||tmpfieldname == 'setdefault'){
                            //是否启用
                            if(linedata[tmpfieldname]==1){
                                rowobj.find('td[detailfieldname=' + tmpfieldname + '] #' + tmpfieldname).prop('checked',linedata[tmpfieldname]);
                            }
                        }else{
                            rowobj.find('td[detailfieldname=' + tmpfieldname + '] #' + tmpfieldname).val(linedata[tmpfieldname]);
                        }

                        var DataHtmlBindobj = new DataHtmlBind();
                        DataHtmlBindobj.setJqueryObj(rowobj.find('td[detailfieldname=' + tmpfieldname + '] #' + tmpfieldname));
                        DataHtmlBindobj.setDataBindByJqueryObj(linedata, tmpfieldname);
                    }
                });
            }
        });
    }
    //区块名称html
    that.getBlockNameHtml = function(){
        var html = '<tr tag="productproperty_block">' +
            '<td colspan="4" class="ld-from-headblock e">' +
            '<div class="ld-from-headblock-title" tag="headblock-title">'+arrJsPopLabel['Product_Property']+'</div>' +
            '</td>' +
            '</tr>';
        return html;
    }
    //根据获取的属性数组 生成属性行html
    that.getProductPropertyHtml = function(productproperty_arr){
        var html = '';
        ld.each(productproperty_arr,function(i,propertyInfo){
            html +='<tr tag="productproperty_block" class="ld-form-item">';
            html +='<td class="ld-form-item-label">' + propertyInfo.productproperty_name +
                '</td>' +
                '<td class="ld-form-item-content" colspan="3"><div class="ld-flex-start">';
            ld.each(propertyInfo['details'],function(j,propertydetail){
                var tmpselected = '';
                if(propertydetail.selected==true){
                    tmpselected = 'checked';
                }
                html +='<div class="padR20"><input type="checkbox" name="propertydetail_check_'+propertydetail.lineitem_id+'" id="propertydetail_check_'+propertydetail.lineitem_id+'" class="small" '+tmpselected+'><label class="padL6" for="propertydetail_check_'+propertydetail.lineitem_id+'" class="pad">'+propertydetail.property_value_name+'</label></div>';
            });
            html +='</div></div>';
            html += '</td></tr>';
        });

        return html;
    }

    //属性组后面的两个按钮
    that.getProductPropertyBtnHtml = function(){
        var html = '<tr tag="productproperty_block"><td colspan="4" class="ld-from-headblock e">' +
            '<div class="ld-button ld-button-primary" tag="Create">' +arrJsPopLabel['generate']+
            '</div>'
        html += '<div class="ld-button ld-button-primary" tag="selectCreate">'+arrJsPopLabel['Choosetogenerate']+
            '</div>' +
            '<div class="ld-button ld-button-cancel" tag="Clear">' +arrJsPopLabel['SETEMPTY']+
            '</div>' +
            '<span class="ld-entry-tip" style="display:none;" name="kindlyremind"></span>' +
            '</td>' +
            '</tr>';
        return html;
    }
    //属性组合表格的表体
    that.createPropertyTbodyHtml = function(){
        var restBlocks = that.restBlocks;
        var tableHeader = restBlocks['tableHeader'];
        var fieldArr = restBlocks['fieldArr'];
        var fieldValueList = restBlocks['fieldValueList'];
        var html = '';
        var seq_no = 1;
        ld.each(fieldValueList,function(i,line){
            if(line.selected===true) {
                html += '<tr rowindex="' + i + '">';
                ld.each(fieldArr, function (j, fieldname) {
                    html += '<td detailfieldname="' + fieldname + '" class="ld-form-item-content" >';
                    if (fieldname == 'attribute_combination') {
                        var attribute_combination_tmp = line[fieldname];
                        ld.each(attribute_combination_tmp, function (k, attr_info) {
                            html += attr_info['productproperty_name'] + ':' + attr_info['property_value_name'] + ' ';
                        });
                    } else if(fieldname=='no'){
                        html += seq_no;
                    }else {
                        html += that.getPropertyTbodyTdHtml(line, fieldname, tableHeader[j],i);
                    }

                    html += '</td>';
                });
                html += '</tr>';
                seq_no++;
            }
        });
        return html;
    }
    that.getPropertyTbodyTdHtml = function(line,fieldname,fieldinfo,line_number){
        var value = line[fieldname];
        var lineitem_id = line['lineitem_id'];
        var more_currency_info = line[fieldname+'_morecurrency'];
        var fieldtype = fieldinfo['fieldtype'];
        var tdhtmlArr = {
            'html':function(value){
                return value;
            },
            'action':function(value){
                return '<i tag="delete" class="ld-button-list-item ld-fonticon ld-fonticon-del textFloatDisplay bindtip" data-tip="'+arrJsPopLabel['DELETE']+'" data-direction="top" data-type="position" href="javascript:;"></i>';
            },
            'text':function(value){
                return '<input placeholder="" type="text" tabindex="p" value="" class="ld-input-inner" tag="money" id="'+fieldname+'">';
            },
            'Num':function(value){
                return '<input placeholder="" type="text" tabindex="p" value="" class="ld-input-inner" tag="money" id="'+fieldname+'">';
            },
            'Amount':function(value){
                var html = '<input class="ld-input-inner" tag="money" type="text" id="'+fieldname+'" style="color:" value="'+value+'">';
                if(more_currency_info.length>1){
                    html += '<i tag="more_currency_info" data-fieldname="'+fieldname+'" class="ld-fonticon ld-fonticon-price positionSecond bindtip" data-tip="'+arrJsPopLabel['More_Currency']+'" data-direction="top" data-type="position"></i>';
                }
                return html;
            },
            'CheckBox':function(value){
                return '<input class="second_switch" tabindex="r" type="checkbox" name="'+fieldname+'" id="'+fieldname+'">';
            },
            'Image':function(value){
                return '<input id="del_detailfile_list" name="del_detailfile_list" type="hidden" value=""><div id="'+fieldname+'" name="'+fieldname+'" class="wu-example"></div>';
            }
        }
        return tdhtmlArr[fieldtype](value);
    }
    //属性组合表格的表头
    that.gettableHeaderHtml = function(){
        var html = '<tr tag="productproperty_block"><td colspan="4" class="ld-pop-container ld-table-container ld-table-container-lines" style="padding: 0 10px 0 var(--ld-edit-padding);">';
        html += '<table id="productproperty_list" cellspacing="0" cellpadding="0" border="0"><thead><tr>';

        //表头的内容
        var tableHeaderArr = that.restBlocks.tableHeader;
        ld.each(tableHeaderArr,function(i,th){
            html += '<th head_detailfieldname="'+th.fieldname+'" width="'+th.width+'">'+th.label+'</th>';
        });

        html += '</tr></thead><tbody id="productproperty_list_body"></tbody></table>';
        html += '</td></tr>';
        return html;
    }



};
ProductsEdit.moduleEdit = function() {
    var ProductsEditObj = new ProductsEdit();
    var popupObj = CrmPopup.getPopupObj('last'),
        popupJqObj = ld(`#${popupObj.divid}`),
        EditTable = popupJqObj.find('[name=displayfields]').length>0?popupJqObj.find('[name=displayfields]'):popupJqObj.find('#DetailContent'),//快速创建放DetailContent后面
        restBlocks = popupObj.moduleData.restBlocks;
    if(!empty(restBlocks)) {
        ProductsEditObj.popupObj = popupObj;
        ProductsEditObj.popupJqObj = popupJqObj;
        ProductsEditObj.EditTable = EditTable;
        ProductsEditObj.restBlocks = restBlocks;
        ProductsEditObj.popupObj.detailimage_arr = restBlocks['detailimage_arr'];
        ProductsEditObj.editInit();

        popupObj.setObjEventArr.push(ProductsEditObj.setInitEvent);
    }

}