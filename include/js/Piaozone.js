// ls 240827  XUQIU20240815-01 对接发票云的API接口
function Piaozone(){
    var that = this;
    this.timer = '';
    this.isconnect = false;

    this.module = '';
    this.record = '';

    this.isauthorize = 'no';//是否授权且配置
    this.service_url = '';
    this.eventCode = '';//打开发票采集页面
    this.access_token = '';
    this.identifytype = '';//即linkKey
    this.billid = '';//单据id
    this.billno = '';//单据编号
    this.companyInfo = '';//设置的需要控制上传的公司抬头税号信息

    this.selectcompanyInfo = [];//选择的公司抬头信息
    // this.compony_name = '';//选择的公司名称
    // this.compony_taxno = '';//选择的税号
    this.invoicedata = {};//发票数据的集合，流水号为键
    this.invoicetype_arr = [];//发票类型的集合
    this.deleteserialno_arr = [];//删除的发票流水号的集合

    this.ImportInvoice = function(module){
        var popupobj = CrmPopup.getlastPopupObjByPageType(PageRecordPopup.pagetype);
        ld("#" + popupobj.divid + " #pz_block").css("display",'block');//显示发票明细区块
        // console.log(popupobj.record);
        var record = popupobj.record;

        if (empty(that.selectcompanyInfo)) { //多次“导入发票”，默认之前选项
            var urlstring = 'index.php?module='+module+'&action='+module+'Ajax&file=ImportInvoicePiaozone&operation=getCompanyInfo&record='+record+'&frommodule='+module;
            ldAjax(urlstring,'',function(data){
                if(data.code == 1){
                    that.companyInfo=data.result.companyInfo;

                    //多个公司则需要  弹出选择公司的抬头
                    if (that.companyInfo.length > 1) {
                        var crmPopupobj=CrmPopup.load("","","","LdPopWidth400px",module,"","","","");
                        crmPopupobj.prevshow();
                        crmPopupobj.setParams(data.result.title,that.saveCompanyInfo,"","LdPopWidth400px",module,[module,record],data.result.oktext,"",data.result.canceltext);
                        crmPopupobj.show(data.result.content);
                        crmPopupobj.center();
                    }else{
                        that.selectcompanyInfo = that.companyInfo;

                        that.startImportInvoice(module,record);
                    }


                }else{
                    MessagePopup.TipOne_warning(data.msg);
                    return false;
                }
                // popupobj.CancelEvent();
                DelProgressObjs();

            })
        }else{
            that.startImportInvoice(module,record);
        }
    }
    //多个公司抬头时先选择公司税号(暂定,不需要权限控制就去掉)
    this.saveCompanyInfo = function(module,record){
        var popupobj = CrmPopup.getPopupObj('last');

        that.selectcompanyInfo.push({
            "taxNo": ld("#"+popupobj.divid+" [name=selectcompany]").val(),
            "name": ld("#"+popupobj.divid+" [name=selectcompany] option:selected").text()
        });
        popupobj.CancelEvent();

        that.startImportInvoice(module,record);
    }
    //websocket需要使用record信息
    this.startImportInvoice = async function(module,record){
        if (that.isconnect === false) {
            //获取参数
            try {
                await that.initConfig(module,record);
                await that.startSocket(module,record);
            }
            catch (e) {
                return ;
            }

        }
        that.openPopup(module);

    }

    this.openPopup = function(module){
        var crmPopupobj= CrmPopup.load(arrJsPopLabel['InvoiceHelper'],"","","1230",module,"","","","");
        crmPopupobj.prevshow();
        // crmPopupobj.setParams(data.result.title,"","","LdPopWidth1100px",module,"","","","");
        crmPopupobj.createScrollDiv();//创建滚动条
        crmPopupobj.show('<iframe id="pz_iframe" style="width: 1230px; height: 600px;padding:2px; border:1px solid #ccc;"></iframe>');

        var reqUrl = encodeURIComponent(that.service_url + '/index.html?formId=rim_fpzs_main&&eventCode=' + that.eventCode);
        ld("#" + crmPopupobj.divid + " #pz_iframe").attr("src", that.service_url + "/accessTokenLogin.do?encode=true&access_token=" + that.access_token + '&redirect=' + reqUrl);
        // return false;
    }

    this.initConfig = async function(module,record){
        //获取发票采集页面参数信息
        var urlstring = 'index.php?module='+module+'&action='+module+'Ajax&file=ImportInvoicePiaozone&operation=getImportInvoiceConfig&record='+record+'&frommodule='+module;
        return new Promise((resolve, reject) => {
            ldAjaxsync(urlstring,{"selectcompanyInfo":JSON.stringify(that.selectcompanyInfo)},function(data){
                if(data.code == 1){
                    that.service_url = data.result.service_url;
                    that.access_token = data.result.access_token;
                    that.eventCode = data.result.eventCode;
                    that.identifytype = data.result.linkKey;
                    that.billid = data.result.billid;
                    that.billno = data.result.billno;

                    that.invoicetype_arr = data.result.invoicetype_arr;
                    if (empty(that.access_token) || empty(that.eventCode)) {
                        MessagePopup.TipOne_warning('接口参数配置错误，请检查！');
                        reject()
                        return false;
                    }
                    resolve()
                }else{
                    MessagePopup.TipOne_warning(data.msg);
                    reject()
                    return false;
                }
                DelProgressObjs();

            })
        })
    }

    this.startSocket = async function(module,record) {

        var socketUrl = that.service_url.replace("http://", "ws://").replace("https://", "wss://");
        //创建WebSocket对象，指定要连接的服务器地址与端口
        var socket = new WebSocket(socketUrl + "/msgwatch/?identifytype=" + that.identifytype + "&token=" + that.access_token);
        //打开事件
        socket.onopen = function () {
            //alert("连接成功");
            that.timer = setInterval(function () {
                socket.send("{\"handshake\":false}");
            }, 20000);

            /*that.timer = window.setTimeout(function () {
                socket.send("{\"handshake\":false}");
            }, 20);*/

            that.isconnect = true;
        };
        //获得消息事件
        socket.onmessage = function (msg) {
            console.log(msg.data);
            //alert("接收消息:" + msg.data);

            //导入发票后,关闭发票采集弹窗
            var lastpopupobj = CrmPopup.getPopupObj('last');
            lastpopupobj.CancelEvent();

            var msgdata = JSON.parse(msg.data);
            if (!empty(msgdata) && msgdata.hasOwnProperty('invoiceData')) {
                var tmpmsgdata = msgdata['invoiceData'];

                var popupobj = CrmPopup.getlastPopupObjByPageType(PageRecordPopup.pagetype);
                var tableobj=ld("#"+popupobj.divid+" [name="+popupobj.js_detailtablename+"]");//获取表格对象
                for (var i = 0; i < tmpmsgdata.length; i++) {
                    //console.log(tmpmsgdata[i]);
                    var tmpinvoiceData = tmpmsgdata[i];
                    var tmpserialNo = tmpinvoiceData["serialNo"];
                    if (that.invoicedata.hasOwnProperty(tmpserialNo)) {//重复导入
                        tmpmsgdata.splice(i, 1);
                        continue;
                    }

                    var tmprowindex = fnAddTabDetailRow(module);//增加分录行  并反写数据
                    if (module == 'Expense') {//费用报销单:反写“开票日期”到 开始日期、结束日期，“发票金额”到"报销金额"
                        var tmprowobj=ld(tableobj).find("tr[name=row"+tmprowindex+"]");
                        if(ld(tmprowobj).find("[name=startdate]").length>0){
                            ld(tmprowobj).find("[name=startdate]").val(tmpinvoiceData['invoiceDate']);
                            ld(tmprowobj).find("[name=startdate]").blur();
                        }
                        if(ld(tmprowobj).find("[name=enddate]").length>0){
                            ld(tmprowobj).find("[name=enddate]").val(tmpinvoiceData['invoiceDate']);
                            ld(tmprowobj).find("[name=enddate]").blur();
                        }
                        //有的账套有这个字段  但是以rmb_total为准(路总)
                        if(ld(tmprowobj).find("[name=money]").length>0){
                            ld(tmprowobj).find("[name=money]").val(JsNumbertoFixed(tmpinvoiceData['totalAmount'],2));
                            ld(tmprowobj).find("[name=money]").change();
                        }
                        if(ld(tmprowobj).find("[name=rmb_total]").length>0){
                            ld(tmprowobj).find("[name=rmb_total]").val(JsNumbertoFixed(tmpinvoiceData['totalAmount'],2));
                            ld(tmprowobj).find("[name=rmb_total]").change();
                        }
                        if(ld(tmprowobj).find("[name=span_rmb_total]").length>0){
                            ld(tmprowobj).find("[name=span_rmb_total]").html(JsNumbertoFixed(tmpinvoiceData['totalAmount'],2));
                        }

                    }


                    // that.invoicedata.push({tmpserialNo:tmpinvoiceData});
                    that.invoicedata[tmpserialNo] = tmpinvoiceData;
                    var del_index = that.deleteserialno_arr.indexOf(tmpserialNo);
                    if (del_index !== -1) {
                        that.deleteserialno_arr.splice(del_index, 1); //存在删除发票后再次选择的情况
                    }

                }

                that.invoiceDataToHtml(module,record,tmpmsgdata);
            }
        };
        //关闭事件
        socket.onclose = function () {
            clearInterval(that.timer);
            that.isconnect = false;
            // alert("连接关闭");
            console.log("连接关闭");
        };
        //发生了错误事件
        socket.onerror = function () {
            // alert("连接失败");
            console.log("连接失败");
            MessagePopup.TipOne_warning("连接失败");


        }

        return socket;
        //await socket;
    }

    //由于编辑页面导入发票时,已有的数据存在下载查看删除权限,故而不能直接循环that.invoicedata全部重新生成html.需要追加
    this.invoiceDataToHtml = function(module,record,tmpmsgdata){
        var trhtml='';
        var tmpinvoiceType='',tmpserialNo='',tmpinvoiceCode='',tmpinvoiceNo='',tmpinvoiceDate='',tmpdownloadUrl='';
        var rowid = 1;//行号
        ld.each(tmpmsgdata,function(tmpindex,tmpinfo){
            tmpinvoiceType = tmpinfo['invoiceType'];//发票类型(数字)
            tmpserialNo = tmpinfo['serialNo'];//发票流水号
            tmpinvoiceDate = tmpinfo['invoiceDate'];
            tmpdownloadUrl = tmpinfo['downloadUrl'];
            if (tmpinvoiceType == '9') {//火车票
                tmpinvoiceCode = tmpinfo['trainNum'];//发票代码(车次)
                tmpinvoiceNo = tmpinfo['printingSequenceNo'];//发票号码（印刷序号）
            }else if(tmpinvoiceType == '10'){//飞机票
                tmpinvoiceCode = tmpinfo['airNum'];//发票代码（机票编号）
                tmpinvoiceNo = tmpinfo['printNum'];//发票号码（印刷序列号）
            }else{
                tmpinvoiceCode = tmpinfo['invoiceCode'] || "";//发票代码
                tmpinvoiceNo = tmpinfo['invoiceNo'] || "";//发票号码
            }

            if(rowid%2 ==0) {
                trhtml += "<tr serialno='"+tmpserialNo+"' rowid='"+rowid+"' onmouseover=\"listOnMouseOver(ld(this))\" onmouseout=\"listOnMouseOut(ld(this),\'On\')\" class=\"lvtColDataBj\">";
            }
            else{
                trhtml += "<tr serialno='"+tmpserialNo+"' rowid='"+rowid+"' onmouseover=\"listOnMouseOver(ld(this))\" onmouseout=\"listOnMouseOut(ld(this),\'on\')\" class=\"lvtColData\">";
            }

            trhtml += '<td class="ld-form-item-content-entry" style="width:65px;text-align: center;">'+rowid+'</td>';
            trhtml += '<td class="ld-form-item-content-entry">'+that.invoicetype_arr[tmpinvoiceType]+'</td>';
            trhtml += '<td class="ld-form-item-content-entry">'+tmpinvoiceCode+'</td>';
            trhtml += '<td class="ld-form-item-content-entry">'+tmpinvoiceNo+'</td>';
            trhtml += '<td class="ld-form-item-content-entry">'+tmpinvoiceDate+'</td>';
            trhtml += '<td class="ld-form-item-content-entry">'+tmpinfo['totalAmount']+'</td>';
            trhtml += '<td class="ld-form-item-content-entry">'+(tmpinfo['buyerName'] || "")+'</td>';
            trhtml += '<td class="ld-form-item-content-entry"><a onclick="PiaozoneObj.downloadInvoice(ld(this),\''+module+'\',\''+record+'\',\''+tmpdownloadUrl+'\',\'download\');" href="javascript:void(0);">'+arrJsPopLabel['DOWNLOAD']+'&nbsp;</a>';
            trhtml += '<a onclick="PiaozoneObj.downloadInvoice(ld(this),\''+module+'\',\''+record+'\',\''+tmpdownloadUrl+'\',\'view\');" href="javascript:void(0);">'+arrJsPopLabel['VIEW']+'&nbsp;</a>';
            trhtml += '<a onclick="PiaozoneObj.deleteInvoice(ld(this),\''+module+'\',\''+record+'\');" href="javascript:void(0);">'+arrJsPopLabel['DELETE']+'</a>';
            trhtml += '</td>';
            trhtml += '</tr>';

            rowid++;
        });

        var popupobj = CrmPopup.getlastPopupObjByPageType(PageRecordPopup.pagetype);
        ld("#" + popupobj.divid + " #pz_table tbody").append(trhtml);

        that.updateRowNumbers();
        that.updateInvoiceTotal();

    }

    //下载发票 or 预览发票
    this.downloadInvoice = function(obj,module,record,downloadurl,type){
        //alert(type);
        //return;
        var urlstring = 'index.php?module='+module+'&action='+module+'Ajax&file=ImportInvoicePiaozone&operation=downloadInvoice&record='+record+'&frommodule='+module+'&downloadurl='+downloadurl+'&type='+type;
        ldAjax(urlstring,'',function(data){
            if(data.code == 1){
                OpenNewWebTab(data.result.downloadurl);
            }else{
                MessagePopup.TipOne_warning(data.msg);
                return false;
            }
            DelProgressObjs();

        })
    }

    //“删除发票“
    this.deleteInvoice = function(obj,module,record) {
        //删除当前行tr  并更新 that.invoicedata 的值
        var cur_trobj = ld(obj).closest('tr');
        var serialno = cur_trobj.attr("serialno");//流水号
        // console.log(serialno);

        if (!that.deleteserialno_arr.includes(serialno)) {
            that.deleteserialno_arr.push(serialno);//编辑单据已有发票数据行，分录点击“删除发票”后，再次“导入发票”是选不到该发票的，因此无需考虑再次导入发票的问题
        }
        delete that.invoicedata[serialno];

        ld(cur_trobj).remove();
        //更新行号
        that.updateRowNumbers();
        that.updateInvoiceTotal();
    }

    //更新编号,遍历tbody中的所有行
    this.updateRowNumbers = function() {
        var popupobj = CrmPopup.getlastPopupObjByPageType(PageRecordPopup.pagetype);
        ld("#" + popupobj.divid + " #pz_table tbody tr").each(function(index){
            ld(this).attr("rowid",(index + 1));
            ld(this).find('td:first').text(index + 1); // 更新第一列为编号
        });
    }

    //计算发票合计金额
    this.updateInvoiceTotal = function() {
        var invoicetotal = 0;//发票合计金额
        ld.each(that.invoicedata,function(tmpindex,tmpinfo){
            invoicetotal += parseFloat(tmpinfo['totalAmount']);
        });

        invoicetotal = JsNumbertoFixed(invoicetotal,2);

        var popupobj = CrmPopup.getlastPopupObjByPageType(PageRecordPopup.pagetype);
        ld("#" + popupobj.divid + " #pz_invoicetotal").val(invoicetotal);
        ld("#" + popupobj.divid + " #span_pz_invoicetotal").text(invoicetotal);
    }
}
var PiaozoneObj = new Piaozone();