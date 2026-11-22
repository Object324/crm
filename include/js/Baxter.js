function Baxter(popupobj) {
    var that = this;
    if (empty(popupobj)) {
        popupobj = CrmPopup.getlastPopupObjByPageType(PageRecordPopup.pagetype);//新增或者编辑界面
    }
    that.popupobj = popupobj;
    that.module=popupobj.module;

    //CustomForm72(APD维修追踪记录):快递下单指令;  CustomForm74(APD二手机发现记录):二手机告知书发送指令
    this.setEvent=function()
    {
        ld.each(that.popupobj.fields, function (tmpindex, fieldinfo) {
            var tmpfieldname = fieldinfo.fieldname;
            var urlstring = 'index.php?module=' + that.module  + '&action=' + that.module  + 'Ajax&file=Baxter';

            //给指令字段定义事件。上门取故障机快递指令发送:cf_9275; 故障机寄回快递指令发送:cf_9279; 周转机取回快递下单指令:cf_9287
            if (that.module == 'CustomForm72') {
                // console.log(tmpfieldname);

                //cf_9357  记得改回  cf_9354 TODO。。。。
                if (tmpfieldname == 'cf_9275' || tmpfieldname == 'cf_9279' || tmpfieldname == 'cf_9287' || tmpfieldname == 'cf_9354' || tmpfieldname == 'cf_9337') {
                    ld('#' + that.popupobj.divid + " [name='sel_" + tmpfieldname + "']").unbind("change").bind('change', function () {
                        // console.log(ld('#' + that.popupobj.divid + " [name='sel_" + tmpfieldname + "']").prop("checked"));

                        if (ld('#' + that.popupobj.divid + " [name='sel_" + tmpfieldname + "']").prop("checked")) {
                            var customform24_id = ld('#' + that.popupobj.divid + " [name=customform24_id]").val();//customform24_id userID
                            //var serviceCode = ld('#' + that.popupobj.divid + " [name=customform72_no]").val();//维修追踪编号  TODO...... 可能会重复  用customform71_no-cf_9355替代
                            var customform71_id = ld('#'+that.popupobj.divid+" [name=customform71_id]").val();//故障机序列号 customform71_id,后台转换后取customform71_no
                            var cf_9355 = ld('#'+that.popupobj.divid+" [name=cf_9355]").val();//当前日期时间 cf_9355
                            var createName = ld('#' + that.popupobj.divid + " [name=cf_9264]").val().trim();//报修人姓名
                            var mobile = ld('#' + that.popupobj.divid + " [name=cf_9265]").val() || '';//电话
                            var province = ld('#' + that.popupobj.divid + " [name=bill_state]").val();//省
                            var city = ld('#' + that.popupobj.divid + " [name=bill_city]").val();//市
                            var county = ld('#' + that.popupobj.divid + " [name=bill_area]").val();//区县
                            var address = ld('#' + that.popupobj.divid + " [name=cf_9270]").val().trim();//地址
                            var params = {
                                'mode': 'expressorder',
                                'columnname': tmpfieldname,
                                'customform24_id': customform24_id,//userId
                                //'serviceCode': serviceCode,
                                'customform71_id': customform71_id,
                                'cf_9355': cf_9355,
                                'createName': createName,
                                'mobile': mobile,
                                'province': province,
                                'city': city,
                                'county': county,
                                'address': address,
                            };

                            if (tmpfieldname == 'cf_9275') {
                                var quguzhangji_no = ld('#' + that.popupobj.divid + " [name=cf_9277]").val().trim(); //cf_9277 取故障机快递单号
                                if (quguzhangji_no.length > 0) {
                                    MessagePopup.TipZero_error("请勿重复下单");
                                    return false;
                                }
                            } else if (tmpfieldname == 'cf_9279') {
                                var jihuiguzhangji_no = ld('#' + that.popupobj.divid + " [name=cf_9282]").val().trim(); //cf_9282 故障机寄回快递单号
                                if (jihuiguzhangji_no.length > 0) {
                                    MessagePopup.TipZero_error("请勿重复下单");
                                    return false;
                                }
                            } else if (tmpfieldname == 'cf_9287') {
                                var quzhouzhuanji_no = ld('#' + that.popupobj.divid + " [name=cf_9290]").val().trim(); //cf_9290 周转机取回快递单号
                                if (quzhouzhuanji_no.length > 0) {
                                    MessagePopup.TipZero_error("请勿重复下单");
                                    return false;
                                }
                            } else if (tmpfieldname == 'cf_9354') {// 指令开启时，周转机回仓 customform75_id 不为空且回仓快递单号为空时  触发
                                var customform75_id = ld('#' + that.popupobj.divid + " [name=customform75_id]").val();//周转机回仓

                                var huicang_no = ld('#' + that.popupobj.divid + " [name=cf_9340]").val().trim();//周转机回仓快递单号
                                if (customform75_id == '' || customform75_id <= 0) {
                                    MessagePopup.TipZero_error("请选择仓库");
                                    return false;
                                } else if (huicang_no.length > 0) {
                                    MessagePopup.TipZero_error("请勿重复下单");
                                    return false;
                                }
                                params["customform75_id"] = customform75_id;
                            } else if (tmpfieldname == 'cf_9337') {
                                var jizhouzhuanji_no = ld('#' + that.popupobj.divid + " [name=cf_9285]").val().trim(); //寄周转机
                                if (jizhouzhuanji_no.length > 0) {
                                    MessagePopup.TipZero_error("请勿重复下单");
                                    return false;
                                }

                                var customform75_id2 = ld('#' + that.popupobj.divid + " [name=customform75_id2]").val().trim();
                                if (customform75_id2 == '' || customform75_id2 <= 0) {
                                    MessagePopup.TipZero_error("请选择周转机寄出地址");
                                    return false;
                                }
                                params["customform75_id2"] = customform75_id2;
                            }

                            ldAjax(urlstring, params, function (data) {
                                // return;
                                if (data.code == 1) {
                                    //反写单号
                                    var expressNo = data.result.expressNo;
                                    if (tmpfieldname == "cf_9275") {
                                        ld('#' + that.popupobj.divid + " [name=cf_9277]").val(expressNo);
                                    } else if (tmpfieldname == "cf_9279") {
                                        ld('#' + that.popupobj.divid + " [name=cf_9282]").val(expressNo);
                                    } else if (tmpfieldname == "cf_9287") {
                                        ld('#' + that.popupobj.divid + " [name=cf_9290]").val(expressNo);
                                    } else if (tmpfieldname == "cf_9354") {
                                        ld('#' + that.popupobj.divid + " [name=cf_9340]").val(expressNo);
                                    }else if (tmpfieldname == "cf_9337") {
                                        ld('#' + that.popupobj.divid + " [name=cf_9285]").val(expressNo);
                                    }

                                    MessagePopup.TipZero_success(data.msg);

                                } else {
                                    //调用失败关闭指令
                                    ld('#' + that.popupobj.divid + " [name='sel_" + tmpfieldname + "']").prop("checked", false);
                                    MessagePopup.TipZero_error(data.msg);
                                }
                                DelProgressObjs();
                            });
                        }

                    });
                } /*else if(tmpfieldname == 'cf_9294') {//报价指令
                    ld('#' + that.popupobj.divid + " [name='sel_" + tmpfieldname + "']").unbind("change").bind('change', function () {
                        if (ld('#' + that.popupobj.divid + " [name='sel_" + tmpfieldname + "']").prop("checked")) {
                            var customform24_id = ld('#' + that.popupobj.divid + " [name=customform24_id]").val();//customform24_id
                            //var serviceCode = ld('#' + that.popupobj.divid + " [name=customform72_no]").val();//维修追踪编号  TODO...... 可能会重复 已废弃
                            var customform71_id = ld('#'+that.popupobj.divid+" [name=customform71_id]").val();//故障机序列号 customform71_id,后台转换后取customform71_no
                            var cf_9264 = ld('#' + that.popupobj.divid + " [name=cf_9264]").val().trim();//报修人姓名
                            var cf_9353 = ld('#' + that.popupobj.divid + " [name=cf_9353]").val();//用户联系电话
                            var cf_9355 = ld('#'+that.popupobj.divid+" [name=cf_9355]").val();//当前日期时间 cf_9355
                            var cf_9352 = ld('#' + that.popupobj.divid + " [name=cf_9352]").val();//收费消息途径
                            var serviceCost = ld('#' + that.popupobj.divid + " [name=cf_9296]").val() || 0;//报价金额，即维修费用,保留2位小数

                            if (serviceCost <= 0) {
                                MessagePopup.TipZero_error("报价金额需要大于0");
                                return false;
                            }

                            var params = {
                                'mode': 'quote',
                                'columnname': tmpfieldname,
                                'customform24_id': customform24_id,
                                'cf_9264': cf_9264,
                                'cf_9353': cf_9353,
                                //'serviceCode': serviceCode,
                                'customform71_id': customform71_id,
                                'cf_9355': cf_9355,
                                'cf_9352': cf_9352,
                                'serviceCost': serviceCost
                            };

                            ldAjax(urlstring, params, function (data) {
                                // return;
                                if (data.code == 1) {
                                    MessagePopup.TipZero_success(data.msg);
                                } else {
                                    //调用失败关闭指令
                                    ld('#' + that.popupobj.divid + " [name='sel_" + tmpfieldname + "']").prop("checked", false);
                                    MessagePopup.TipZero_error(data.msg);
                                }
                                DelProgressObjs();
                            });
                        }

                    });

                }*/


                /*
                * 快递取消下单指令
                * */
                if (tmpfieldname == 'cf_9376' || tmpfieldname == 'cf_9377' || tmpfieldname == 'cf_9378' || tmpfieldname == 'cf_9379' || tmpfieldname == 'cf_9380') {
                    ld('#' + that.popupobj.divid + " [name='sel_" + tmpfieldname + "']").unbind("change").bind('change', function () {

                        if (ld('#' + that.popupobj.divid + " [name='sel_" + tmpfieldname + "']").prop("checked")) {
                            var customform71_id = ld('#'+that.popupobj.divid+" [name=customform71_id]").val();//故障机序列号 customform71_id,后台转换后取customform71_no
                            var cf_9355 = ld('#'+that.popupobj.divid+" [name=cf_9355]").val();//当前日期时间 cf_9355
                            var params = {
                                'mode': 'cancel_expressorder',
                                'columnname': tmpfieldname,
                                //'serviceCode': serviceCode,
                                'customform71_id': customform71_id,
                                'cf_9355': cf_9355,
                            };

                            if (tmpfieldname == 'cf_9376') {
                                var express_no = ld('#' + that.popupobj.divid + " [name=cf_9285]").val().trim();
                            } else if (tmpfieldname == 'cf_9377') {
                                var express_no = ld('#' + that.popupobj.divid + " [name=cf_9277]").val().trim();
                            } else if (tmpfieldname == 'cf_9378') {
                                var express_no = ld('#' + that.popupobj.divid + " [name=cf_9282]").val().trim();
                            } else if (tmpfieldname == 'cf_9379') {
                                var express_no = ld('#' + that.popupobj.divid + " [name=cf_9290]").val().trim();
                            } else if (tmpfieldname == 'cf_9380') {
                                var express_no = ld('#' + that.popupobj.divid + " [name=cf_9340]").val().trim();
                            }
                            if (express_no.length < 1) {
                                ld('#' + that.popupobj.divid + " [name='sel_" + tmpfieldname + "']").prop("checked", false);
                                //ld('#' + that.popupobj.divid + " [name='" + tmpfieldname + "']").val(0);
                                MessagePopup.TipZero_error("无快递单号不能取消下单");
                                return false;
                            }
                            params["express_no"] = express_no;

                            ldAjax(urlstring, params, function (data) {
                                // return;
                                if (data.code == 1) {
                                    if (tmpfieldname == "cf_9376") {
                                        ld('#' + that.popupobj.divid + " [name=cf_9285]").val('');//清除快递单号
                                        ld('#' + that.popupobj.divid + " [name='sel_cf_9337']").prop("checked", false);//关闭下单指令
                                        ld('#' + that.popupobj.divid + " [name='cf_9337']").val(0);
                                    } else if (tmpfieldname == "cf_9377") {
                                        ld('#' + that.popupobj.divid + " [name=cf_9277]").val('');
                                        ld('#' + that.popupobj.divid + " [name='sel_cf_9275']").prop("checked", false);
                                        ld('#' + that.popupobj.divid + " [name='cf_9275']").val(0);
                                    } else if (tmpfieldname == "cf_9378") {
                                        ld('#' + that.popupobj.divid + " [name=cf_9282]").val('');
                                        ld('#' + that.popupobj.divid + " [name='sel_cf_9279']").prop("checked", false);
                                        ld('#' + that.popupobj.divid + " [name='cf_9279']").val(0);
                                    } else if (tmpfieldname == "cf_9379") {
                                        ld('#' + that.popupobj.divid + " [name=cf_9290]").val('');
                                        ld('#' + that.popupobj.divid + " [name='sel_cf_9287']").prop("checked", false);
                                        ld('#' + that.popupobj.divid + " [name='cf_9287']").val(0);
                                    }else if (tmpfieldname == "cf_9380") {
                                        ld('#' + that.popupobj.divid + " [name=cf_9340]").val('');
                                        ld('#' + that.popupobj.divid + " [name='sel_cf_9354']").prop("checked", false);
                                        ld('#' + that.popupobj.divid + " [name='cf_9354']").val(0);
                                    }

                                    MessagePopup.TipZero_success(data.msg);

                                } else {
                                    //调用失败关闭指令
                                    ld('#' + that.popupobj.divid + " [name='sel_" + tmpfieldname + "']").prop("checked", false);
                                    //ld('#' + that.popupobj.divid + " [name='sel_" + tmpfieldname + "']").val(0);
                                    MessagePopup.TipZero_error(data.msg);
                                }
                                DelProgressObjs();
                            });
                        }

                    });
                }

            }
            else if(that.module == 'CustomForm74'){
                if(tmpfieldname == 'cf_9307') {//二手机告知书发送指令
                    ld('#' + that.popupobj.divid + " [name='sel_" + tmpfieldname + "']").unbind("change").bind('change', function () {

                        if (ld('#' + that.popupobj.divid + " [name='sel_" + tmpfieldname + "']").prop("checked")) {
                            // var docketCode = ld('#' + that.popupobj.divid + " [name=customform74_no]").val();//二手机单据编号
                            var userName = ld('#' + that.popupobj.divid + " [name=cf_9304]").val().trim();
                            var userPhone = ld('#' + that.popupobj.divid + " [name=cf_9305]").val().trim();
                            var customform71_id = ld('#'+that.popupobj.divid+" [name=customform71_id]").val() || '';//故障机序列号 customform71_id,后台转换后取customform71_no
                            var cf_9356 = ld('#'+that.popupobj.divid+" [name=cf_9356]").val();//当前日期时间 cf_9356

                            var params = {
                                'mode': 'agreementSign',
                                'columnname': tmpfieldname,
                                // 'docketCode': docketCode,
                                'userName': userName,
                                'userPhone': userPhone,
                                'customform71_id': customform71_id,
                                'cf_9356': cf_9356
                            };

                            ldAjax(urlstring, params, function (data) {
                                // return;
                                if (data.code == 1) {
                                    ld('#' + that.popupobj.divid + " [name=cf_9387]").val(data.result.current_time);
                                    ld('#' + that.popupobj.divid + " [name=span_cf_9387]").html(data.result.current_time);
                                    ld('#' + that.popupobj.divid + " [name=cf_9386]").val('发送成功');
                                    ld('#' + that.popupobj.divid + " [name=span_cf_9386]").html('发送成功');
                                    if (ld('#' + that.popupobj.divid + " [name=cf_9309]").val() != '签署完成') {
                                        ld('#' + that.popupobj.divid + " [name=cf_9309]").val('未签署');
                                        ld('#' + that.popupobj.divid + " [name=span_cf_9309]").html('未签署');
                                    }

                                    MessagePopup.TipZero_success(data.msg);
                                } else {
                                    ld('#' + that.popupobj.divid + " [name=cf_9386]").val('发送失败');
                                    ld('#' + that.popupobj.divid + " [name=span_cf_9386]").html('发送失败');
                                    //调用失败关闭指令
                                    ld('#' + that.popupobj.divid + " [name='sel_" + tmpfieldname + "']").prop("checked", false);
                                    MessagePopup.TipZero_error(data.msg);
                                }
                                DelProgressObjs();
                            });
                        }

                    });

                }
            }
        });
    }


}

