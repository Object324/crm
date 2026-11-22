function RelateCreatePayPlan(curpopupobj)
{
    //edit:can 20230720  69402:出库单->相关信息->收款计划，新建收款计划应该调用合同创建收款计划那个批量创建的界面 
                
              var that=this;
              this.curpopupobj=curpopupobj;
            this.NewPaymentPlan= function (obj,divid,salesorderid,deployid,isImmediatelycreate,isshowPrintDiv)
            {
                var prompt;
                calendarParentid="CreatePaymentplan";//该变量在jscalendar/dynamiccalendar.js/
                if(deployid > 0)
                {
                    if(deployid == 1)
                    {
                        //回款计划总额已经等于未计划金额，是否继续？
                        prompt = arrJsPopLabel['REIMBURSEMENTEQUALUNPLANNED'];
                    }
                    else if(deployid == 2)
                    {
                        //回款计划总额已经大于未计划金额，是否继续？
                        prompt = arrJsPopLabel['REIMBURSEMENTGREATERUNPLANNED'];
                    }
                    var payment= window.confirm(prompt);
                    if(payment){
                    }
                    else
                    {
                        return false;
                    }
                }
                 
                //alert(that.curpopupobj.headermodule);
                var frommodule='';
                frommodule = that.getfrommodule();
                var lowermodulename=that.curpopupobj.module.toLowerCase()
            	var surl = "index.php?module=PaymentPlan&action=PaymentPlanAjax&file=RelateCreatePaymentPlan&frommoduleid=" +salesorderid+'&ReportHeader=DHeader&Immediatelycreate='+isImmediatelycreate+'&frommodule='+frommodule+'&isshowPrintDiv='+isshowPrintDiv;
            	var crmPopupobj=CrmPopup.load("","","","LdPopWidth800px",'PaymentPlan',"","","","");
            	crmPopupobj.prevshow();
                crmPopupobj.type='CreatePaymentplan';
            	ldAjaxNoProgress(surl,"",function(data){
            		if(data.code == 1){
            			crmPopupobj.setParams(data.result.title,that.saveNewPaymentPlan,"","LdPopWidth800px",'PaymentPlan',"",data.result.oktext,"",data.result.canceltext,"");
                        crmPopupobj.show(data.result.content);
                        // 需要去掉的给高度
                        crmPopupobj.reduceBodyHeight = 44;
                        // 设置内容最大高度
                        crmPopupobj.setPopBodyMaxHeight(".divPopOverflow");
                        ld("#"+crmPopupobj.divid+" [name=paymenttype]").unbind('change').on('change',function(){
                            that.changeListHeader(this);
                        });
                        //edit: xll 2023/05/16 BUG0060876 新建订单弹出“收款计划”后，点击“设置默认收款比例”设置窗口消失 
                        var popupobj = CrmPopup.getPopupObj('last');
                        popupobj.record = salesorderid;
                        that.createPopupobj=crmPopupobj;
                        var cls_resetComboxHtmlobj=new cls_resetComboxHtml('SmOwnerSearchScope');
                        //wym BUG0072163 销售订单关联创建收款计划界面，点击“设置默认收款比例”取消后，新建收款计划界面的“收款计划负责人”不显示了
                        cls_resetComboxHtmlobj.setPopupObj(crmPopupobj);
                        cls_resetComboxHtmlobj.searchhtmltype='div';
                        cls_resetComboxHtmlobj.picklistcontent=data.result.user_arr;
                        cls_resetComboxHtmlobj.setComboxObjHtml();
                        ld("#"+crmPopupobj.divid+" [name=cmb_span_optiontext_SmOwnerSearchScope]").html(data.result.selectedlastname);
                        if(typeof cls_wxOpenDataobj!=undefined&&typeof cls_wxOpenDataobj!="undefined")
                        {
                            cls_wxOpenDataobj.bindAllOpenDataByPopupObj(crmPopupobj);
                        }
                        if(frommodule!='SalesOrder')
                        {
                           
                            ld("#"+crmPopupobj.divid+" [btnname=CashSet]").css("display",'none');
                            
                        }
                        that.setEvent();
                        if(ld('#'+crmPopupobj.divid).width() == 450){
                            ld('#'+crmPopupobj.divid).width(850);
                            crmPopupobj.center();
                        }
                        var prevpopupobj = CrmPopup.getPopupObj("lastprev");
                        if(prevpopupobj.pagetype =='detailview_modulepage'){
                            popupobj.newcnacel = popupobj.CancelEvent;
                            popupobj.CancelEvent = function(){
                                popupobj.newcnacel();
                                DetailViewRelation.showpage_moduledetail(prevpopupobj);
                            }
                        }
            		}else{
            			crmPopupobj.CancelEvent();
            			 RemindsMsg("","LdPopWidth400px","","yes","yes",data.msg);
            		}
            	})
            		return false;
               
            }
            this.getfrommodule = function()
            {
                if(!empty(that.frommodule)){
                    frommodule = that.frommodule;
                }
                else if(that.curpopupobj.related_module=='detailview')
                {
                    frommodule=that.curpopupobj.module;
                }
                else{
                    frommodule= that.curpopupobj.headermodule;
                }
                return frommodule;
                  
            }
            this.setEvent=function()
            {
                if(that.createPopupobj != undefined){
                    var  popupobj=that.createPopupobj;
                } else{
                    var  popupobj=CrmPopup.getPopupObj('last');
                }
            	ld("#"+popupobj.divid+' [btnname=addtr]').unbind("click").bind("click",function(){
                   that.Addtr();
            	})
                
                ld("#"+popupobj.divid+' [btnname=deletetr]').unbind("click").bind("click",function(){
            	   
                   
                   that.deletetr(ld(this).get(0));
            	})
                
                ld("#"+popupobj.divid+" [btnname=LoadPeriodTime]").unbind("click").bind("click",function(){
            	   
                   
                   that.LoadPeriodTime(ld(this).get(0));
            	})
                ld("#"+popupobj.divid+" [btnname=CashSet]").unbind("click").bind("click",function(){


                    that.CashSet(ld(this).get(0),'SetPaymentplan',0);
                    return false;
                })
                
            }
            this.saveNewPaymentPlan=function(){
                var  popupobj=CrmPopup.getPopupObj('last');
                
            	var tabplan=ld("#"+popupobj.divid+" #tabpaymentplan").get(0);// document.getElementById("tabpaymentplan");
            
            	var rowcount=tabplan.rows.length;
            	var planamount=0.0;
            	if(rowcount<=1)
            	{
            		// puyoungJS_DialogBox.unblock();
            		//回款计划金额和未计划金额不一致！
            		var confirm = arrJsPopLabel['PLANNEDINCONSISTENTUNPLANNED'];
            		RemindsMsg("","LdPopWidth400px","","yes","yes",confirm);
            		return false;
            	}
            	for( var i=1;i<rowcount;i++)
                {
                    if(document.getElementById("periodtime"+i).value=="")
                    {
                        //puyoungJS_DialogBox.unblock();
                        //期次不能为空！
                        var confirm = arrJsPopLabel['OFTIMECANOTEMPTY'];
                        RemindsMsg("","LdPopWidth400px","","yes","yes",confirm);
                        document.getElementById("periodtime"+i).focus();
                        document.getElementById('save_payment_check').disabled=false;
                        return  false;
                    }
                    if(document.getElementById("amount"+i).value==0 ||trim(document.getElementById("amount"+i).value)=="")
                    {
                        //puyoungJS_DialogBox.unblock();
                        //金额不能为空或等于零！
                        var confirm = arrJsPopLabel['AMOUNTCANOTNULL'];
                        RemindsMsg("","LdPopWidth400px","","yes","yes",confirm);
                        document.getElementById("amount"+i).focus();
                     
                        return false;
                    }
                   if(isNaN(document.getElementById("amount"+i).value))
                   {
                        //  puyoungJS_DialogBox.unblock();
                        //金额非法！
                        var confirm = arrJsPopLabel['AMOUNTILLEGAL'];
                        RemindsMsg("","LdPopWidth400px","","yes","yes",confirm);
                        document.getElementById("amount"+i).focus();
                        
                        return  false;
                   }
                   var paymenttype = ld('#paymenttype').val();
                   if(paymenttype=='计划收款日期'){
            		   if(document.getElementById("plandate"+i).value=="")
            		   {
            			// puyoungJS_DialogBox.unblock();
            			 //计划日期不能为空！
            			 var confirm = arrJsPopLabel['PLANNEDATECANOTEMPTY'];
            			 RemindsMsg("","LdPopWidth400px","","yes","yes",confirm);
            			 document.getElementById("plandate"+i).focus();
            		 
            			 return false;
            		   }
                      
                   }
                   //37119: 如果在回款计划的页面设置中， 增加了“备注”栏目的属性为：必录项， 则在合同保存时弹出的回款计划页面，也应是必录项
                    var planremarklabel=ld("#planremarklabel").val();
                       if(document.getElementById('planremarktypeofdata').value=='m'&&ld.trim(ld("#description"+i).val())=='')
                       {
                        var confirm=arrJsPopLabel['LINE']+i+arrJsPopLabel['row']+planremarklabel+arrJsPopLabel['CANOTEMPTY'];
                        
                            RemindsMsg("","LdPopWidth400px","","yes","yes",confirm);
                              
                            return false;
                       }
                    planamount=parseFloat(parseFloat(planamount)+parseFloat(document.getElementById("amount"+i).value)).toFixed(2);
                    //wym BUG0072656 销售订单关联创建收款计划界面，收款计划类型选择”项目状态“，项目名称字段设置了必填，但在新建收款计划时必填没生效
                    //wym BUG0073170 收款计划设置“项目立项”必填时，销售订单关联创建收款计划根据“计划收款日期”收款时，提示“第一行项目立项不能为空”
                    var projectlabel=ld("#projectlabel").val();
                    if(document.getElementById('projecttypeofdata').value=='m'&&ld.trim(ld("input[name='projectid"+i+"']").val())==''&&paymenttype=='项目状态')
                    {
                        var confirm=arrJsPopLabel['LINE']+i+arrJsPopLabel['row']+projectlabel+arrJsPopLabel['CANOTEMPTY'];

                        RemindsMsg("","LdPopWidth400px","","yes","yes",confirm);

                        return false;
                    }

                }
            	var deploy = document.getElementById("DeployValue").value;
            	var nopaymentamount=parseFloat(document.forms['frmpaymentplan'].nopaymentamount.value).toFixed(2);
            	if(deploy == 1)
                {
                    if(planamount!=nopaymentamount)
                    {
                        //puyoungJS_DialogBox.unblock();
                        //回款计划金额和未计划金额不一致！
                        var confirm = arrJsPopLabel['PLANNEDINCONSISTENTUNPLANNED'];
                        RemindsMsg("","LdPopWidth400px","","yes","yes",confirm);
                         
                        return false;
                    }else{
            			that.submitNewPaymentPlan();
            		}
                }
                else if(deploy == 0)
                {
                    if(planamount == nopaymentamount)
                    {
                        that.submitNewPaymentPlan();
                    }
                    else
                    {
                        if(parseFloat(planamount) < parseFloat(nopaymentamount))
                        {
                            //prompt = "回款计划总额小于未计划金额，是否继续？";
                            //回款计划总额小于未计划金额，是否继续？
                            prompt = arrJsPopLabel['REIMBURSEMENTLESSUNPLANNED'];
                        }
                        else
                        {
                           // alert(planamount+'-'+nopaymentamount);
                            //prompt = "回款计划总额已经大于未计划金额，是否继续？";
                            //回款计划总额已经大于未计划金额，是否继续？
                            prompt = arrJsPopLabel['REIMBURSEMENTGREATERUNPLANNED'];
                        }
            
                        RemindsMsg("","LdPopWidth400px","","yes","yes",prompt);
                        //确定事件
                        ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
                            that.submitNewPaymentPlan();
                        });
                    }
                }
            	
            }
            //回款计划 - 保存
            this.submitNewPaymentPlan=function(){
            	var popupobj=CrmPopup.getPopupObj("last");
                var prevpopupobj = CrmPopup.getPopupObj("lastprev");
            	var data = new FormData(ld(".noMargin")[0]);
            	var surl = "";
            	ld('#rptContentLoading').show();
            	ld.ajax({
            		type: 'POST',
            		dataType: 'json',
            		processData: false, // 告诉jquery不要处理数据
            		contentType: false, // 告诉jquery不要设置contentType
            		data: data,
            		url: 'index.php?module=PaymentPlan&action=PaymentPlanAjax&file=MassAdd',
            		success: function(data) {
            		  
            			ld('#rptContentLoading').hide();
            			popupobj.CancelEvent();
                        //duan 详情页创建相关信息后刷新进度追踪图
                        if(prevpopupobj.pagetype =='detailview_modulepage'){
                            DetailViewRelation.showpage_moduledetail(prevpopupobj);
                        }
                        //41431: (61mis.com/kfbtest）合同订单模块>单据详情界面：工具栏点击“复制”按钮，然后保存单据，界面卡死，一直显示“加载中”
            		   var tmparra=new Array();
                        var tmpobj= new AfterUpdatePrevPopupObjContent("PaymentPlan",getEmptyValueInfo(),tmparra);
                        var refreshlistmodules=[];
                        refreshlistmodules.push("PaymentPlan");
                        tmpobj.eachrefreshlistbyModules(refreshlistmodules);
                        if(data.result.sysdeploy != undefined &&data.result.sysdeploy[that.curpopupobj.module]['deploytype']==57&&data.result.sysdeploy[that.curpopupobj.module]['deployvalue']=='0'){
                            var param = {'module':that.curpopupobj.module,'recordid':data.result.sysdeploy[that.curpopupobj.module]['record']};
                            
                            getJsScript('include/js/SystemPopup/PrintPopup.js',function(){
                                PrintPopup.showpopuphaveparam(param);
                            });
                        }
            		},
            		error: function(xhr, textStatus, errorThrown) {
            			//alert(2);
            		}
            	  })
            }
            //添加行
            this. Addtr=function()
            {
            
                var deploy = document.getElementById("DeployValue").value;
                var tabplan=document.getElementById("tabpaymentplan");
                var rowcount=tabplan.rows.length;
                var planamount=0.0;//计划总金额
                var planratio=0;//计划比例
                var curperiod=1;
                var curamount=0;
                var balanceratio=100;
                var prompt;
                var nopaymentamount=parseFloat(document.forms['frmpaymentplan'].nopaymentamount.value);//未计划金额
                var plandate=document.forms['frmpaymentplan'].NowDate.value;
                var balanceamount=parseFloat(document.forms['frmpaymentplan'].nopaymentamount.value);
            	var paymenttype = ld('#paymenttype').val();
                if(rowcount > 0)
                {
                    for( var i=1;i<rowcount;i++)
                    {
                        
                        if(trim(document.getElementById("amount"+i).value)=="")
                        {
                        }
                        else if(isNaN(document.getElementById("amount"+i).value))
                        {
                            //金额非法！
                            var confirm_str = arrJsPopLabel['AMOUNTILLEGAL'];
                            RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
                            document.getElementById("amount"+i).focus();
                            return  false;
                        }
                        else 
                        {
                            curamount=parseFloat(document.getElementById("amount"+i).value);
                            planamount=parseFloat(planamount)+curamount;
                            curratio=parseFloat(document.getElementById("ratio"+i).value);
                            planratio=parseFloat(planratio)+curratio;
                        
                        }
                       /*
                       edit:can
                       date:201300801
                       reason:4585: 建议：合同订单保存后创建回款计划界面，修改最后一期金额，然后单击添加时“期次”应该也有默认值
                       */
            
                            if(!isNaN(document.getElementById("periodtime"+i).value))
                            curperiod=parseFloat(document.getElementById("periodtime"+i).value)+1;
                    }
                }
                var currow=rowcount-1;
                if(rowcount>1)
                {
                    //计划回款日期
            		plandate=document.getElementById("plandate"+currow).value;
            		var dates=plandate.split("-");
            
            		dates[1]=parseInt(dates[1],10)+1;
            		if(dates[1]<10)
            		{
            			dates[1]="0"+dates[1];
            		}
            		if(dates[1]>=13)
            		{
            			dates[1]="01";
            			dates[0]=parseInt(dates[0],10)+1;
            		}
            		if((dates[0]%4==0 && dates[0]%100!=0)||(dates[0]%400==0)){
            			if(dates[1]==2&&dates[2]>29){
            			   dates[2]=29; 
            			}
            		}
            		if(dates[1]==2&&dates[2]>28){
            			dates[2]=28; 
            		}
            		plandate=dates[0]+"-"+dates[1]+"-"+dates[2];
                    //项目状态
            		var pliststr=document.getElementById("pliststr").value;
            		var dates=pliststr.split(",");
            		var is=0;
            		var selectHTML='';
            		while(dates.length-1>is){
            			selectHTML += "<option value='"+dates[is]+"'>"+dates[is]+"</option>"
            			is++;
            		}
            		selectHTML = selectHTML+"</select>";
            		balanceamount=parseFloat(nopaymentamount)-parseFloat(planamount);
            		balanceratio=100-parseFloat(planratio);
                    /*
                    Edit:chj
                    date:20130814
                    reason:控制汇款计划金额;追加还款期限  1 是  0 否
                    */
                    if(deploy == 0)
                    {
                        if(balanceamount < 0)
                        {
                            balanceamount = 0;
                        }  
                        if(balanceratio < 0)
                        {
                            balanceratio = 0;
                        }  
                    }
                    if(deploy == 1)
                    {
                        if(planamount>=nopaymentamount)
                        {
                            //回款计划总额已经等于未计划金额！
                            var confirm_str = arrJsPopLabel['PLANAMOUNTEQUALUNPLANAMOUNT'];
                            RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
                            return false;
                        }
                    }
                    else
                    {
                        if(planamount >= nopaymentamount)
                        {
                            if(planamount == nopaymentamount)
                            {
                                //回款计划总额已经等于未计划金额，是否继续？
                                prompt = arrJsPopLabel['REIMBURSEMENTEQUALUNPLANNED'];
                            }
                            else
                            {
                                //回款计划总额已经大于未计划金额，是否继续？
                                prompt = arrJsPopLabel['REIMBURSEMENTGREATERUNPLANNED'];
                                
                            }
                            RemindsMsg("","LdPopWidth400px","","yes","yes",prompt);
                            ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
                                //wym BUG0072161 调用了以前的方法
                                that.addrowstr(tabplan,rowcount,curperiod,balanceratio,balanceamount,nopaymentamount,paymenttype,plandate,selectHTML);
                            });
                            return ;
                        }   
                    }
                }else{
            		//项目状态
            		var pliststr=document.getElementById("pliststr").value;
            		var dates=pliststr.split(",");
            		var is=0;
            		var selectHTML='';
            		while(dates.length-1>is){
            			 selectHTML += "<option value='"+dates[is]+"'>"+dates[is]+"</option>"
            			is++;
            		}
            		selectHTML = selectHTML+"</select>";
                }
                that.addrowstr(tabplan,rowcount,curperiod,balanceratio,balanceamount,nopaymentamount,paymenttype,plandate,selectHTML);
                that.setEvent();
            }
            //添加行
            this.addrowstr=function (tabplan,rowcount,curperiod,balanceratio,balanceamount,nopaymentamount,paymenttype,plandate,selectHTML){

                var tabtr=tabplan.insertRow(rowcount);
                tabtr.id="row"+rowcount;
                var tddelete=tabtr.insertCell(0);
                tddelete.align='center';
                tddelete.innerHTML="<i class='ld-fonticon ld-fonticon-del' onclick='deletetr(this)'></i>";
                /*
                   edit:can
                   date:201300801
                   reason:4585: 建议：合同订单保存后创建回款计划界面，修改最后一期金额，然后单击添加时“期次”应该也有默认值
                   */
                var tdperiodtime=tabtr.insertCell(1);
                tdperiodtime.innerHTML="<input type='text' size='10' class='ld-input-inner gwidth100' name='periodtime"+rowcount+"' id='periodtime"+rowcount+"' value='"+curperiod+"'/>";
                var tdratio=tabtr.insertCell(2);
                tdratio.innerHTML="<input type='text' size='10' class='ld-input-inner gwidth100' name='ratio"+rowcount+"' id='ratio"+rowcount+"' value='"+parseFloat(balanceratio).toFixed(2)+"' onchange=changeamountn(this,'amount"+rowcount+"','ratio"+rowcount+"','"+nopaymentamount+"');>";
                var tdamount=tabtr.insertCell(3);
                tdamount.innerHTML="<input type='text' size='10' class='ld-input-inner gwidth100' name='amount"+rowcount+"' id='amount"+rowcount+"' value='"+parseFloat(balanceamount).toFixed(2)+"' onchange=changeratio(this,'ratio"+rowcount+"','amount"+rowcount+"','"+nopaymentamount+"');>";
                var tdplandate=tabtr.insertCell(4);
                tdplandate.innerHTML="<input type='text' size='15' onClick='WdatePicker()' class='Wdate ld-input-inner' readonly='true' name='plandate"+rowcount+"' value='"+plandate+"' id='plandate"+rowcount+"\'/>";
            	tdplandate.id='paymentpan_date_td_'+rowcount;
                tdplandate.setAttribute('class', 'ld-form-item-content');
                if (ld('input[name=paymenttypevalue]').val() == 'noproject') {//ls 2021-11-04 项目立项模块关闭时，新增期次不应该有项目状态
                    var tddescription=tabtr.insertCell(5);
                }else{
                    if(paymenttype == '项目状态'){
                        tdplandate.style.display='none';
                    }
                    var tdprjectstatus = tabtr.insertCell(5);
                    tdprjectstatus.innerHTML="<select class='ld-select-inner' name='projectstatus"+rowcount+"'>"+selectHTML;
                    tdprjectstatus.id='projectstatus_td_'+rowcount;
                    //wym XUQIU1001598 收款计划增加单选“项目立项”字段，项目立项字段启用下,新增行添加项目立项td
                    if(ld('#project_tr').length>0){
                        var tdproject=tabtr.insertCell(6);
                        tdproject.innerHTML="<input readonly name='projectid"+rowcount+"_name' type='text' fieldonly='0' value='' class='ld-input-inner gwidth70'>";
                        tdproject.innerHTML+="<input name='projectid"+rowcount+"' type='hidden' value=''>";
                        tdproject.innerHTML+="<a index='"+rowcount+"' class='icon-homeimg icon-select' href='javascript:;' title='"+arrJsPopLabel['SELECT']+"' onclick=showrelatedlist('PaymentPlan','Project','select','','projectid',this);></a>";
                        tdproject.innerHTML+="<input index='"+rowcount+"' class='icon-homeimg icon-clear inpb-reset' type='button' title='"+arrJsPopLabel['CLEAR']+"' onclick=\"clear_relatedfielddata('PaymentPlan','projectid','projectid_name','projectid','Project','popupselectfield',this);return false;\"/>";
                        tdproject.id='project_td_'+rowcount;
                        tdproject.style.overflow='visible';
                        if(paymenttype == '计划收款日期'){
                            tdprjectstatus.style.display='none';
                            tdproject.style.display='none';
                        }
                        var tddescription=tabtr.insertCell(7);
                    }else{
                        if(paymenttype == '计划收款日期'){
                            tdprjectstatus.style.display='none';
                        }
                        var tddescription=tabtr.insertCell(6);
                    }
                }
            
                tddescription.innerHTML="<textarea name='description"+rowcount+"' id='description"+rowcount+"' value='' cols='100%' class='ld-textarea-inner' style='height: 30px;'></textarea>";
            }
            //删除行
            this.deletetr=function(obj)
            {
                var rowindex=0;
                 var tabplan=document.getElementById("tabpaymentplan");
                 var paymentamount=document.getElementById("paymentamount").value;
                 while(obj.tagName!="TR")
                 {
                     obj=obj.parentNode;
                 }
                 rowindex=obj.id.substring(3);
            	obj.parentNode.removeChild(obj);
                 var rowcount=tabplan.rows.length;
                 if(rowindex>rowcount)
                 {
                    return ;
                 }
                 var j=parseInt(rowindex);
                 var i=parseInt(rowindex)+1;
                 var tdimage;
                 var tdhtml;
                 var obbj;
                 /*
                 更新操作
                 edit:can
                 date:20131031
                 reason:5420: 合同订单明细界面：创建回款计划窗口点击添加按钮时网页左下角报错
                 */
            
                for(j;j<rowcount;j++)
                {
            
                   document.getElementById("row"+i).id="row"+j;
                    obbj=document.getElementById("periodtime"+i);
                   obbj.name="periodtime"+j;
                    obbj.id="periodtime"+j;
                   document.getElementById("amount"+i).name="amount"+j;
                   document.getElementById("amount"+i).id="amount"+j;
                   document.getElementById("ratio"+i).name="ratio"+j;
                   document.getElementById("ratio"+i).id="ratio"+j;
            
                   //alert(document.getElementById("ratio"+j).onchange);
                   //document.getElementById("ratio"+j).onchange=changeamountn(document.getElementById("ratio"+j),'amount'+j,'ratio'+j,paymentamount);
                   document.getElementById("ratio"+j).onchange = function(){
                        var idstr = this.id;
                        var jj = idstr.substring(5,idstr.length);
                        changeamountn(this,'amount'+jj,'ratio'+jj,paymentamount);
                   }
                   document.getElementById("amount"+j).onchange = function(){
                        var idstr = this.id;
                        var jj = idstr.substring(6,idstr.length);
                        changeratio(this,'ratio'+jj,'amount'+jj,paymentamount);
                   }
            		document.getElementById("plandate"+i).name="plandate"+j;
            		document.getElementById("plandate"+i).id="plandate"+j;
            		document.getElementById("projectstatus"+i).name="projectstatus"+j;
            		document.getElementById("projectstatus"+i).id="projectstatus"+j;
                   /*
                    tdimage=tabplan.rows[j].cells[3];
                    
                    tdimage.innerHTML="<input type='text' size='10' value='"+ document.getElementById("plandate"+i).value+"' id='plandate"+j+"' name='plandate"+j+"'/>"+"<img class='popimg'  src='themes/softed/images/btnL3Calendar.gif' id='img"+j+"' onclick='showCalendar(\"plandate"+j+"\",\"%Y-%m-%d\",\"true\",\"12\",this)'/>";
                    */
                    i++;
                }
                 
            }
            this.changeListHeader=function(obj)
            {
                var paymenttype = obj.value;	//回款计划类型
                var tabplan=document.getElementById("tabpaymentplan");

                var rowcount=tabplan.rows.length;
                if(paymenttype == '项目状态'){
                    ld('#paymentpan_date_tr').hide();
                    ld('#projectstatus_tr').show();
                    ld('#project_tr').show();
                }else{
                    ld('#paymentpan_date_tr').show();
                    ld('#projectstatus_tr').hide();
                    ld('#project_tr').hide();
                }
                if(rowcount >= 1){
                    for(var i = 1; i<=rowcount; i++){
                        if(paymenttype == '项目状态'){
                            ld('#paymentpan_date_td_'+i).hide();
                            ld('#projectstatus_td_'+i).show();
                            ld('#paymentplan_times').hide();
                            ld('#project_td_'+i).show();
                        }else{
                            ld('#paymentpan_date_td_'+i).show();
                            ld('#projectstatus_td_'+i).hide();
                            ld('#project_td_'+i).hide();
                            ld('#paymentplan_times').show();
                        }
                    }
                }
            }
            //设置默认收款比例 从salesorder.js中移过来的
            this.CashSet=function(obj,divid,salesorderid)
            {
                //关闭回款计划弹出层

                var popupobj=CrmPopup.getPopupObj("last");
                popupobj.CancelEvent();
                var DetailPopupobj=CrmPopup.getlastPopupObjByPageType(DetailViewPage.pagetype);

                //edit: xll 2023/05/16 BUG0060876 新建订单弹出“收款计划”后，点击“设置默认收款比例”设置窗口消失
                if(salesorderid == 0 && DetailPopupobj != undefined && DetailPopupobj.record != undefined)
                {
                    salesorderid = DetailPopupobj.record;
                }else if(salesorderid == 0 && popupobj.record != undefined){
                    salesorderid = popupobj.record;
                }

                var surl = "index.php?module=PaymentPlan&action=PaymentPlanAjax&file=CashSet&salesorderid=" +salesorderid;
                var popupobj=CrmPopup.getPopupObj("last");
                var crmPopupobj=CrmPopup.load("","","","LdPopWidth600px",'PaymentPlan',"","","","");
                //wym 240517 BUG20240516-43 详情页相关创建有设置默认比例,此时可以获取详情页的record;新增订单自动带出创建收款计划也有设置默认比例,此时没有详情页可以获取record,所以需要存在这个弹窗上(有问题的话也可以放到对象上)
                crmPopupobj.salesorderid=salesorderid;
                crmPopupobj.prevshow();
                ldAjaxNoProgress(surl,"",function(data){
                    if(data.code == 1){
                        crmPopupobj.setParams(data.result.title,that.SaveCashBillSet,'',"LdPopWidth600px",'PaymentPlan',"",data.result.oktext,"",data.result.canceltext,"");
                        crmPopupobj.show(data.result.content);
                        // 需要去掉的给高度
                        crmPopupobj.reduceBodyHeight = 37;
                        // 设置内容最大高度
                        crmPopupobj.setPopBodyMaxHeight(".divPopOverflow");
                        //BUG20240625-64 ls 销售订单相关信息关联创建收款计划界面，点击新增期次->确定->设置默认收款比例->取消所有弹窗后，点击新建，界面一直显示加载中(弹窗没有被正常关闭)
                        ld('#'+crmPopupobj.divid+' .E_pbtn .E_pbtncancel').unbind('click').on('click',function(){
                            var popupobj=CrmPopup.getlastPopupObjByPageType(DetailViewPage.pagetype);
                            if(empty(popupobj)){
                                var crmPopupobj = CrmPopup.getPopupObj("last");
                                var record = crmPopupobj.salesorderid;
                                if(empty(record) && record != 0){
                                    record = salesorderid;
                                }
                            }else{
                                var record = popupobj.record;
                            }
                            that.NewPaymentPlan('','CreatePaymentplan',record,0,'no','no','SalesOrder');
                        });
                    }
                })
                if(ld('#'+crmPopupobj.divid).width() == 850){
                    ld('#'+crmPopupobj.divid).width(450);
                    crmPopupobj.center();
                }
            }
            this.SaveCashBillSet=function()
            {
                var tableset=document.getElementById("tableSet");
                var total=0;
                for(var i=1;i<tableset.rows.length;i++)
                {
                    if(isNaN(document.getElementById("percent"+i).value))
                    {
                        //回款比例非法！
                        var confirm_str = arrJsPopLabel['PROPORTIONILLEGALMONEYBACK'];
                        RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
                        document.getElementById("percent"+i).focus();
                        return false;
                    }
                    //if(!positiveInteger(document.getElementById("percent"+i).value))
                    if(document.getElementById("percent"+i).value<=0)
                    {
                        //回款比例必须是正整数！
                        var confirm_str = arrJsPopLabel['PROPORTIONBACKMUSTPOSITIVEINT'];
                        RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
                        document.getElementById("percent"+i).focus();
                        return false;
                    }
                    total=total+parseFloat(document.getElementById("percent"+i).value);

                }
                if(parseFloat(total) < 100)
                {
                    //回款比例合计必须等于100！
                    var confirm_str = arrJsPopLabel['PROPORTIONPAYMENTMUSTEQUAL'];
                    RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
                    return false;
                }
                if(parseFloat(total) > 100){
                    //回款比例合计已经超过100！
                    var confirm_str = arrJsPopLabel['Totalproportionhasbeenmorethan100'];
                    RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
                    return false;
                }
                var popupobj=CrmPopup.getPopupObj("last");
                var record = ld("#"+popupobj.divid+" [name=record]").val();
                var data = new FormData(ld(".setCashBillForm")[0]);
                var surl = "";
                ld('#rptContentLoading').show();
                ld.ajax({
                    type: 'POST',
                    dataType: 'json',
                    processData: false, // 告诉jquery不要处理数据
                    contentType: false, // 告诉jquery不要设置contentType
                    data: data,
                    url: 'index.php?module=PaymentPlan&action=PaymentPlanAjax&file=SaveCashBillSet',
                    success: function(json, textStatus, xhr) {
                        ld('#rptContentLoading').hide();

                        popupobj.CancelEvent();
                        that.NewPaymentPlan('','CreatePaymentplan',record,0,'no','no');
                    },
                    error: function(xhr, textStatus, errorThrown) {
                        //alert(2);
                    }
                })
            }
            this.CancelCashBillSet=function()
            {
                //edit:can 2020-12-03 43553: （本地php54，8.3.1.1版本）采购管理-采购订单-相关信息-付款计划（需要补丁）；在采购订单相关信息创建付款计划，付款计划新增界面点击左下角设置付款比例，付款比例弹出层中点取消，页面会一直转圈缓冲
                //  var popupobj=CrmPopup.getPopupObj('last');
                //edit:can 20210925 48033: （https://81mis.com/kfbcrm/ [^]）合同订单查看详情界面，相关信息中【新建】收款计划，点击【设置默认收款比例】-【取消】，再点击【设置默认比例】时点不动
                // popupobj.CancelEvent();
                //wym 240517 BUG20240516-43 新建销售订单后，自动弹出的收款计划设置，变更默认收款计划期数和比例界面，【取消】按钮点击没有效果
                var popupobj=CrmPopup.getlastPopupObjByPageType(DetailViewPage.pagetype);
                if(empty(popupobj)){
                    var crmPopupobj = CrmPopup.getPopupObj("last");
                    var record=crmPopupobj.salesorderid;
                }else{
                    var record = popupobj.record;
                }
                //@edit:liushuai,2021-04-06,reason:0045262: （61mis.com/kfbcrm）销售管理-合同订单-详情；相关创建收款计划，设置默认收款比例时，点击取消；单据详情会被关掉
                // popupobj.CancelEvent();
                that.NewPaymentPlan('','CreatePaymentplan',record,0,'no','no','SalesOrder');
            }
            this.LoadPeriodTime=function(obj)
            {
             var period=document.getElementById("OkPeriodTime");
             var loadcount=period.value;
             var r = /^\+?[1-9][0-9]*$/;　　//正整数 
             var nopaymentamount=document.forms['frmpaymentplan'].nopaymentamount.value;
            if( isNaN(loadcount))
            {
                //期数应该输入正整数！
                var confirm_str = arrJsPopLabel['PERIODSSHOULDPOSITIVEINTEGER'];
                RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
                document.getElementById("OkPeriodTime").focus();
                return false;
            }
            if(!r.test(loadcount))
            {
                //期数应该输入正整数！
                var confirm_str = arrJsPopLabel['PERIODSSHOULDPOSITIVEINTEGER'];
                RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
                document.getElementById("OkPeriodTime").focus();
                return false;
            }
            var percentamount=nopaymentamount/loadcount;
          
            percentamount=parseFloat(percentamount).toFixed(2);
            //alert(document.getElementById("tabpaymentplan").rows.length);
           while(document.getElementById("tabpaymentplan").rows.length>1)
           {
             document.getElementById("tabpaymentplan").deleteRow(1);
           }
               
               
            
            var startperiodtime=document.forms['frmpaymentplan'].startPeriodTime.value;
            var startplandate=document.forms['frmpaymentplan'].startplandate.value;
            var newRow;
            var newCell;
            var tddelete;
            var tdperiodtime;
            var tdamount;
            var tdprojectstatus;
            var tdproject;
            var tdplandate;
            var dates
            var mnth="";
            var count = 100/loadcount;
            var month_days="0";//月份的天数
    		var date30 = new Array('4','6','9','11');
            for(var i=1;i<=loadcount;i++)
            {
                newRow=document.getElementById("tabpaymentplan").insertRow(i);
                newRow.id="row"+i;
                tddelete=newRow.insertCell(0);
                tddelete.align="center";
                tddelete.innerHTML="<i class='ld-fonticon ld-fonticon-del' onclick='deletetr(this)'></i>";
    
                tdperiodtime=newRow.insertCell(1);
                var objperiodtime=document.createElement('input');
                objperiodtime.type='text';
                objperiodtime.size=10;
                objperiodtime.id="periodtime"+i;
                objperiodtime.name="periodtime"+i;
                objperiodtime.value=startperiodtime;
                objperiodtime.className='commonTextBoxPop gwidth100';
                tdperiodtime.appendChild(objperiodtime);
    			//0040881: （51mis.com/kfbtest）回款计划新增界面，回款计划金额按比例除不尽时，比例金额合计不等于总金额
                if(i == loadcount){
    				percentamount = nopaymentamount - percentamount*(loadcount - 1);
    				percentamount = parseFloat(percentamount).toFixed(2);
    				count = 100 - count.toFixed(2)*(loadcount - 1);
    			}
               
                //objratio.onblur=percentamount(objratio,'amount'+i,nopaymentamount);
                /*20101010
                andrew
                改进功能  合同关联创建回款计划
                在添加function 时出现问题，王灿说还是用html直接赋值
                */
               tdratio=newRow.insertCell(2);
               tdratio.innerHTML="<input type='text' class='ld-input-inner gwidth100' name='ratio"+i+"' value='"+count.toFixed(2)+"' id='ratio"+i+"' onchange=changeamountn(this,'amount"+i+"','ratio"+i+"','"+nopaymentamount+"'); size='10'>";
                /**
                *更新操作
                *edit:can
                *date:20131230
                *reason:06560: 合同订单->点击“创建回款计划”按钮，然后加载100期回款计划，再连续删除5~10期，程序就会弹出错误，如
                **/
                //tdperiodtime.innerHTML="<input type='text' size='10'  name='periodtime"+i+"' id='periodtime"+i+"' value='"+(startperiodtime)+"'/>";
                tdamount=newRow.insertCell(3);
               
                tdamount.innerHTML="<input type='text' size='10' class='ld-input-inner gwidth100' name='amount"+i+"' id='amount"+i+"' onchange=changeratio(this,'ratio"+i+"','amount"+i+"','"+nopaymentamount+"'); value='"+percentamount+"'/>";
                tdplandate=newRow.insertCell(4);
              //  
                var objplandate=document.createElement('input');
                objplandate.type='text';
                objplandate.size=10;
                objplandate.readOnly=true;
                objplandate.id='plandate'+i;
                objplandate.name='plandate'+i;
                var dates=startplandate.split("-");
            if((dates[0]%4==0 && dates[0]%100!=0)||(dates[0]%400==0)){
                    month_days=29;
                    if(dates[1]==2&&dates[2]>29){
                       dates[2]=29; 
                       
                    }
            }
           else  
           {
                month_days=28;
                if(dates[1]==2&&dates[2]>28){
                    dates[2]=28; 
                    
                }
           }
    	   if(ld.inArray(dates[1],date30) > 0 && dates[2] >= 30){
    			dates[2]=30;
    		}
            //20768: 合同订单>明细：关联创建回款计划，当回款计划日期为31号时，4、6、9、11月份日期显示错误。
            var tempdate=startplandate;
            switch(parseInt(dates[1]))
            {
                case 1:
                case 3:
                case 5:
                case 7:
                case 8:
                case 10:
                case 12:
                    month_days=31;
                    break;
                case 4:
                case 6:
                case 9:
                case 11:
                 month_days=30;   
                 break;
                        
            }
          
            if(dates[2]>month_days)
            {
                dates[2]=month_days;
            }
            startplandate=dates[0]+"-"+dates[1]+"-"+dates[2];
            
            objplandate.value=dates[0]+"-"+dates[1]+"-"+dates[2];
            tdplandate.innerHTML="<input type='text' onClick='WdatePicker()' class='Wdate ld-input-inner' size='15' readonly='true' name='plandate"+i+"' value='"+startplandate+"' id='plandate"+i+"\'/>";
                //ls 2021-11-03 48559: (81mis.com/kfbcrm/index.php)合同订单》收款计划新建，新建收款计划时，重算收款期次，然后切换收款计划类型会失败；会出现项目状态和收款日期一起出现问题
                tdplandate.id='paymentpan_date_td_'+i;
                tdplandate.setAttribute('class', 'ld-form-item-content');
                if (ld('input[name=paymenttypevalue]').val() == 'noproject'){ //当Projects模块未启用时收款计划类型只有计划回款日期
                    tddescription=newRow.insertCell(5);
                }else{
                    var paymenttype = ld('#paymenttype').val();
                    if(paymenttype == '项目状态'){
                        tdplandate.style.display='none';
                    }
                    tdprojectstatus=newRow.insertCell(5);
    
                    //项目状态
                    var pliststr=document.getElementById("pliststr").value;
                    var tmp_plist=pliststr.split(",");
                    var is=0;
                    var selectHTML='';
                    while(tmp_plist.length-1>is){
                        selectHTML += "<option value='"+tmp_plist[is]+"'>"+tmp_plist[is]+"</option>"
                        is++;
                    }
    
                    tdprojectstatus.innerHTML="<select class='ld-select-inner' name='projectstatus"+i+"' id='projectstatus"+i+"'/>" +selectHTML
                    "</select>";
    
                    tdprojectstatus.id='projectstatus_td_'+i;
                    //wym BUG0073465
                    if(ld('#project_tr').length>0){
                        var tdproject=newRow.insertCell(6);
                        tdproject.innerHTML="<input readonly name='projectid"+i+"_name' type='text' fieldonly='0' value='' class='ld-input-inner gwidth70'>";
                        tdproject.innerHTML+="<input  name='projectid"+i+"' type='hidden' value=''>";
                        tdproject.innerHTML+="<a index='"+i+"' class='icon-homeimg icon-select' href='javascript:;' title='"+arrJsPopLabel['SELECT']+"' onclick=showrelatedlist('PaymentPlan','Project','select','','projectid',this);></a>";
                        tdproject.innerHTML+="<input index='"+i+"' class='icon-homeimg icon-clear inpb-reset' type='button' title='"+arrJsPopLabel['CLEAR']+"' onclick=\"clear_relatedfielddata('PaymentPlan','projectid','projectid_name','projectid','Project','popupselectfield',this);return false;\"/>";
                        tdproject.id='project_td_'+i;
                        tdproject.style.overflow='visible';
                        if(paymenttype == '计划收款日期'){
                            tdprojectstatus.style.display='none';
                            tdproject.style.display='none';
                        }
                        tddescription=newRow.insertCell(7);
                    }else{
						if(paymenttype == '计划收款日期'){
							tdprojectstatus.style.display='none';
						}
                        tddescription=newRow.insertCell(6);
                    }
                }
    
    
            // tddescription=newRow.insertCell(5);
            tddescription.innerHTML="<textarea name='description"+i+"' id='description"+i+"' value='' cols='100%' class='ld-textarea-inner' style='height: 30px;'></textarea>";
    
               
            startplandate=tempdate;
            dates=startplandate.split("-");
            dates[1]=parseInt(dates[1],10)+1;
           
            
           
                if(dates[1]<10)
                {
                    dates[1]="0"+dates[1];
                }
                if(dates[1]>=13)
                {
                    dates[1]="01";
                    dates[0]=parseInt(dates[0],10)+1;
                   
                }
                
                startplandate=dates[0]+"-"+dates[1]+"-"+dates[2];
                startperiodtime++;
                 
            }
        }
        
         
        
        //document.getElementById('createPaymentid'),'SetPaymentplan',0
    
}
RelateCreatePayPlan.changeamountn = function (ratioval,amountnid,ratioid,salesorderamount){
    //0024226: 采购订单明细：更多-创建付款计划，弹出层中比例字段清空，点击下金额，结果清空的字段显示为NaN
    if(isNaN(ratioval.value) || ratioval.value==''){
        ratioval.value=0;
    }
    //chj:因为金额会根据币种的改变而对于改变  回款预测
    if(document.frmsendpayment != undefined)
    {
        salesorderamount = ld('#nopaymentamount1').html();
        salesorderamount = salesorderamount.replace(/,/gi,'');
    }
    //回款计划
    if(document.frmpaymentplan != undefined)
    {
        salesorderamount = ld('#nopaymentamount1').html();
        salesorderamount = salesorderamount.replace(/,/gi,'');
    }

    var popupobj = CrmPopup.getPopupObj("last");
    var tr_length = ld('#'+popupobj.divid+' #tabpaymentplan tr[id^=row]').length;
    var amountnval = 0;
    if(parseInt(amountnid.replace('amount','')) == tr_length){
        var sum_setPaymen = 0;
        var sum_hascountamount = 0;
        ld.each(ld('#'+popupobj.divid+' #tabpaymentplan tr[id^=row]'),function (index,trobj){
            if(ld(this).find('#ratio'+(index+1)).val() != ''){
                sum_setPaymen += parseFloat(ld(this).find('#ratio'+(index+1)).val());
            }
            if(ld(this).find('#amount'+(index+1)).val() != '' && tr_length != index+1){
                sum_hascountamount += parseFloat(ld(this).find('#amount'+(index+1)).val());
            }
        })
        amountnval = sum_setPaymen*salesorderamount*0.01 - sum_hascountamount;
    }else{
        amountnval = parseFloat(ratioval.value).toFixed(2)*0.01*salesorderamount
    }
    document.getElementById(ratioid).value=parseFloat(ratioval.value).toFixed(2);
    document.getElementById(amountnid).value=amountnval.toFixed(2);
}
