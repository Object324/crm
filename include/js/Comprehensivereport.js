//zxm 20221114 动态获取当前网页的模块名称
//var pageto_module = getSearchString('pageto_module',location.href);
var pageto_module = 'ReportAnalysis';
var viewName='';
function get_search_senior(ipt){
     viewName = encodeURIComponent(ipt.options[ipt.options.selectedIndex].value);
    if('smowner_search_senior' == viewName){//高级
		var selectuserid = '';
		var module ='';
		if(ld('#senioruserid').length == 0){
			selectuserid = ld('#selectuserid').val();
		}else{
			selectuserid = ld('#senioruserid').val();
		}
		if(document.getElementById('module') != undefined){
			module = document.getElementById('module').value;
		}
		var scopepopupobj;//自定义弹出层页面html，绑定事件
		var popup_caption_value = arrJsPopLabel['LBL_SELECTUSER'];//标题
        module = pageto_module;
		getJsScript('include/js/ScopePopup/ScopePopupObj.js',function(){
			scopepopupobj =  new ScopePopupObj(module);
			scopepopupobj.popup_caption_value = popup_caption_value;//标题title
			getJsScript('include/js/ScopePopup/ScopePopup.js',function(){
			   cls_ScopePopup.prop.popup_module = module;//模块
			   cls_ScopePopup.prop.popup_value = selectuserid;
			   cls_ScopePopup.prop.popup_url = 'module=Users&action=UsersAjax&file=viewuserinfo&popup_scopetype=private&popup_module='+module+'&popup_inputtype=checkbox&popup_selecttype=user'
			   var cls_ScopePopups = new cls_ScopePopup(scopepopupobj);
				//重写确认按钮事件
				scopepopupobj.setEventBtnOk=function(){
					ld('.E_pbtn .E_pbtnok').unbind('click').on('click',function(){
						if(empty(cls_ScopePopup.return_obj.return_id)){
                            var confirm_str = arrJsPopLabel['PLEASESELECTLESTONEUSER'];
                            ld('#layer').css('z-index','9999');
                            getJsScript('include/js/ldcrm.base.js',function(){
                                
                                //创建提示弹出层
                                create_divobj('clearcache_reminder',arrJsPopLabel['WARMPROMPT'],confirm_str,'no','','yes');

                            });
							return false;
						}else{
							ld('#'+cls_ScopePopup.popup_divid+' .E_pbtn .E_pbtncancel').click();
							if(document.getElementById('selectuserid') != undefined){
								document.getElementById('selectuserid').value=cls_ScopePopup.return_obj.return_id;
							}
							
						}
					});
				}
			});
		});
	}
}
function chose_year(year)
{
    //alert(year);
    document.getElementById("year_1").innerHTML = year;
    if(document.getElementById("year_2")){
        document.getElementById("year_2").innerHTML = year;
    }
    if(document.getElementById("year_3")){
        document.getElementById("year_3").innerHTML = year;
    }
    if(document.getElementById("year_4")){
        document.getElementById("year_4").innerHTML = year;
    }
    if(document.getElementById("year_5")){
        document.getElementById("year_5").innerHTML = year; 
    }
    //var annualtext=trim(ld("a[tag='annualtable']").html());
    ////32519:综合表报：年度表前面应该增加一个年份。
    ld("a[tag='annualtable']").html(year+annualtext);
    
        
}
function popup_all()
{
    var year = document.getElementById("year_1").innerHTML;
    var name = document.getElementById("year_situation").value;
    //zkt 20231011 XUQIU1001341 SQL注入
    var urlsting = "index.php?module="+pageto_module+"&action="+pageto_module+"Ajax&reportmodule=Comprehensivereport&file=ComprehensivereportDetail&year="+year+"&name="+name+"&parenttab=Reports";
    Comprehensive_windowsopen(urlsting,'','');
}
function popup(month)
{   
    var year = document.getElementById("year_1").innerHTML;
    var name = document.getElementById("account_cashbill").value;
    var month = month;
    //zkt 20231011 XUQIU1001341 SQL注入
    var urlsting = "index.php?module="+pageto_module+"&action="+pageto_module+"Ajax&reportmodule=Comprehensivereport&file=ComprehensivereportDetail&ReportHeader=DHeader&formodule=Accounts&year="+year+"&name="+name+"&month="+month+"&parenttab=Reports";
    Comprehensive_windowsopen(urlsting,'','');
}
function popup_user_cashbill(month)
{   
    var year = document.getElementById("year_1").innerHTML;
    var name = document.getElementById("user_cashbill").value;
    var month = month;
    //zkt 20231011 XUQIU1001341 SQL注入
    var urlsting = "index.php?module="+pageto_module+"&action="+pageto_module+"Ajax&reportmodule=Comprehensivereport&file=ComprehensivereportDetail&ReportHeader=DHeader&formodule=CashBill&year="+year+"&name="+name+"&month="+month+"&parenttab=Reports";
    Comprehensive_windowsopen(urlsting,'','');
}
function popup_user_salesorder(month)
{
    var year = document.getElementById("year_1").innerHTML;
    var name = document.getElementById("user_salesorder").value;
    var month = month;
    //zkt 20231011 XUQIU1001341 SQL注入
    var urlsting = "index.php?module="+pageto_module+"&action="+pageto_module+"Ajax&reportmodule=Comprehensivereport&file=ComprehensivereportDetail&ReportHeader=DHeader&formodule=SalesOrder&year="+year+"&name="+name+"&month="+month+"&parenttab=Reports";
    Comprehensive_windowsopen(urlsting,'','');
}
function popup_costprice_salesorder(month)
{
    var year = document.getElementById("year_1").innerHTML;
    var name = document.getElementById("costprice_salesorder").value;
    var month = month;
    //zkt 20231011 XUQIU1001341 SQL注入
    var urlsting = "index.php?module="+pageto_module+"&action="+pageto_module+"Ajax&reportmodule=Comprehensivereport&file=ComprehensivereportDetail&ReportHeader=DHeader&formodule=SalesOrder&year="+year+"&name="+name+"&month="+month+"&parenttab=Reports";
    Comprehensive_windowsopen(urlsting,'','');
}
function popup_grossprofitdetial(month)
{
    var year = document.getElementById("year_1").innerHTML;
    var name = document.getElementById("grossprofitdetial").value;
    var month = month;
    //zkt 20231011 XUQIU1001341 SQL注入
    var urlsting = "index.php?module="+pageto_module+"&action="+pageto_module+"Ajax&reportmodule=Comprehensivereport&file=ComprehensivereportDetail&ReportHeader=DHeader&formodule=SalesOrder&year="+year+"&name="+name+"&month="+month+"&parenttab=Reports";
    Comprehensive_windowsopen(urlsting,'','');
}
function popup_insourcingdetial(month)
{
    var year = document.getElementById("year_1").innerHTML;
    var name = document.getElementById("grossprofitdetial").value;
    var month = month;
    //zkt 20231011 XUQIU1001341 SQL注入
    var urlsting = "index.php?module="+pageto_module+"&action="+pageto_module+"Ajax&reportmodule=Comprehensivereport&file=InsourcingreportDetail&ReportHeader=DHeader&formodule=SalesOrder&year="+year+"&name="+name+"&month="+month+"&parenttab=Reports";
    Comprehensive_windowsopen(urlsting,'','');
}
function popup_productdetial(month)
{
    var year = document.getElementById("year_1").innerHTML;
    var name = document.getElementById("grossprofitdetial").value;
    var month = month;
    //zkt 20231011 XUQIU1001341 SQL注入
    var urlsting = "index.php?module="+pageto_module+"&action="+pageto_module+"Ajax&reportmodule=Comprehensivereport&file=ProductreportDetail&ReportHeader=DHeader&formodule=SalesOrder&year="+year+"&name="+name+"&month="+month+"&parenttab=Reports";
    Comprehensive_windowsopen(urlsting,'','');
}
function popup_assessdetial(month)
{
    var year = document.getElementById("year_1").innerHTML;
    var name = document.getElementById("grossprofitdetial").value;
    var month = month;
    //zkt 20231011 XUQIU1001341 SQL注入
    var urlsting = "index.php?module="+pageto_module+"&action="+pageto_module+"Ajax&reportmodule=Comprehensivereport&file=AssessreportDetail&ReportHeader=DHeader&formodule=SalesOrder&year="+year+"&name="+name+"&month="+month+"&parenttab=Reports";
    Comprehensive_windowsopen(urlsting,'','');
}
function popup_product_grossprofit(month)
{
    var year = document.getElementById("year_1").innerHTML;
    var name = document.getElementById("product_grossprofit").value;
    var month = month;
    //zkt 20231011 XUQIU1001341 SQL注入
    var urlsting = "index.php?module="+pageto_module+"&action="+pageto_module+"Ajax&reportmodule=Comprehensivereport&file=ComprehensivereportDetail&ReportHeader=DHeader&formodule=SalesOrder&year="+year+"&name="+name+"&month="+month+"&parenttab=Reports";
    Comprehensive_windowsopen(urlsting,'','');

}
function popup_account_grossprofit(month)
{
    var year = document.getElementById("year_1").innerHTML;
    var name = document.getElementById("account_grossprofit").value;
    var month = month;
    //zkt 20231011 XUQIU1001341 SQL注入
    var urlsting = "index.php?module="+pageto_module+"&action="+pageto_module+"Ajax&reportmodule=Comprehensivereport&file=ComprehensivereportDetail&ReportHeader=DHeader&formodule=Accounts&year="+year+"&name="+name+"&month="+month+"&parenttab=Reports";
    Comprehensive_windowsopen(urlsting,'','');
}

/*
*新增操作 ：检测任务完成情况统计表
*edit: andy
*date:29140114
*/
function popup_Testingdetial(month)
{
    var year = document.getElementById("year_1").innerHTML;
    var name = document.getElementById("SalesOrder_Testingdetial").value;
    var month = month;
    //zkt 20231011 XUQIU1001341 SQL注入
    Comprehensive_windowsopen("index.php?module="+pageto_module+"&action="+pageto_module+"Ajax&reportmodule=Comprehensivereport&file=ComprehensivereportDetail&ReportHeader=DHeader&formodule=SalesOrder&year="+year+"&name="+name+"&month="+month+"&parenttab=Reports",'','');
}

/**
*@爱安德明细表
*@andrew
*@20140623
*/
function popup_Drilldownreports(month)
{

    var year = document.getElementById("year_1").innerHTML;
    var name = document.getElementById("Drilldown_reports").value;
    var month = month;
    //zkt 20231011 XUQIU1001341 SQL注入
    Comprehensive_windowsopen("index.php?module="+pageto_module+"&action="+pageto_module+"Ajax&reportmodule=Comprehensivereport&file=Drilldownreports&ReportHeader=DHeader&year="+year+"&name="+name+"&month="+month+"&parenttab=Reports","","");
}

/**
*@爱安德明细表
*@andrew
*@20140623
*/
function popup_Summaryreports(month)
{

    var year = document.getElementById("year_1").innerHTML;
    var name = document.getElementById("Drilldown_reports").value;
    var month = month;
    //zkt 20231011 XUQIU1001341 SQL注入
    Comprehensive_windowsopen("index.php?module="+pageto_module+"&action="+pageto_module+"Ajax&reportmodule=Comprehensivereport&file=Summaryreports&ReportHeader=DHeader&year="+year+"&name="+name+"&month="+month+"&parenttab=Reports","","");
}


function popup_Salessummaryreport(month)
{

    var year = document.getElementById("year_1").innerHTML;
    //var name = document.getElementById("Salessummaryreport").value;
    var month = month;
    //zkt 20231011 XUQIU1001341 SQL注入
    Comprehensive_windowsopen("index.php?module="+pageto_module+"&action="+pageto_module+"Ajax&reportmodule=Comprehensivereport&file=youchuangReports&ReportHeader=DHeader&year="+year+"&month="+month+"&parenttab=Reports","","");
}

function popup_Productlinesaleperformancereport(month)
{

    var year = document.getElementById("year_1").innerHTML;
    //var name = document.getElementById("Salessummaryreport").value;
    var month = month;
    //zkt 20231011 XUQIU1001341 SQL注入
    Comprehensive_windowsopen("index.php?module="+pageto_module+"&action="+pageto_module+"Ajax&reportmodule=Comprehensivereport&file=youchuangReports2&ReportHeader=DHeader&year="+year+"&month="+month+"&parenttab=Reports","","");
}

function popup_LOTRECreport(month)
{

    var year = document.getElementById("year_1").innerHTML;
    //var name = document.getElementById("Salessummaryreport").value;
    var month = month;
    //zkt 20231011 XUQIU1001341 SQL注入
    Comprehensive_windowsopen("index.php?module="+pageto_module+"&action="+pageto_module+"Ajax&reportmodule=Comprehensivereport&file=lotrecreport&ReportHeader=DHeader&year="+year+"&month="+month+"&parenttab=Reports","","");
}
/**
*@红不让报表
*@andrew
*@20140702
*/
function popup_HBRreports(month)
{

    var year = document.getElementById("year_1").innerHTML;
    var name = document.getElementById("HBRreports").value;
    var month = month;
    //zkt 20231011 XUQIU1001341 SQL注入
    Comprehensive_windowsopen("index.php?module="+pageto_module+"&action="+pageto_module+"Ajax&reportmodule=Comprehensivereport&file=HBRreports&ReportHeader=DHeader&year="+year+"&name="+name+"&month="+month+"&parenttab=Reports","","");
}
/**
*@国通报表
*@andrew
*@20140721
*/
function popup_guotongreports(month)
{

    var year = document.getElementById("year_1").innerHTML;
    var name = document.getElementById("guotongreports").value;
    var month = month;
    //zkt 20231011 XUQIU1001341 SQL注入
    Comprehensive_windowsopen("index.php?module="+pageto_module+"&action="+pageto_module+"Ajax&reportmodule=Comprehensivereport&file=GuoTongReports&ReportHeader=DHeader&year="+year+"&name="+name+"&month="+month+"&parenttab=Reports","","");
}
/**
*@国通成本统计报表
*@andrew
*@20140721
*/
function popup_guotongreports2(month)
{

    var year = document.getElementById("year_1").innerHTML;
    var name = document.getElementById("guotongreports2").value;
    var month = month;
    //zkt 20231011 XUQIU1001341 SQL注入
    Comprehensive_windowsopen("index.php?module="+pageto_module+"&action="+pageto_module+"Ajax&reportmodule=Comprehensivereport&file=GuoTongReports&ReportHeader=DHeader&rtype=chengben&year="+year+"&name="+name+"&month="+month+"&parenttab=Reports","","");
}

function popup_dingjie(month)
{

    var year = document.getElementById("year_1").innerHTML;
    var month = month;
    //zkt 20231011 XUQIU1001341 SQL注入
    Comprehensive_windowsopen("index.php?module="+pageto_module+"&action="+pageto_module+"Ajax&reportmodule=Comprehensivereport&file=dingjiereports&ReportHeader=DHeader&year="+year+"&month="+month+"&parenttab=Reports","","");
}

function popup_lideng(month)
{

    var year = document.getElementById("year_1").innerHTML;
    var month = month;
    //zkt 20231011 XUQIU1001341 SQL注入
    Comprehensive_windowsopen("index.php?module="+pageto_module+"&action="+pageto_module+"Ajax&reportmodule=Comprehensivereport&file=lidengreports&ReportHeader=DHeader&year="+year+"&month="+month+"&parenttab=Reports","","");
}

function popup_StockAssetSummary()
{

    var year = document.getElementById("year_1").innerHTML;
    //zkt 20231011 XUQIU1001341 SQL注入
    Comprehensive_windowsopen("index.php?module="+pageto_module+"&action=StockAssetSummaryReports&ReportHeader=DHeader&year="+year+"&parenttab=Reports","","");
}
function popup_FuDiSalesReport(){
    var year = document.getElementById("year_1").innerHTML;
    //zkt 20231011 XUQIU1001341 SQL注入
    Comprehensive_windowsopen("index.php?module="+pageto_module+"&action="+pageto_module+"Ajax&reportmodule=Comprehensivereport&file=FuDiSalesReport&ReportHeader=DHeader&year="+year+"&parenttab=Reports","","");
}
function popup_RentCollectionReport(){
    var year = document.getElementById("year_1").innerHTML;
    //zkt 20231011 XUQIU1001341 SQL注入
    Comprehensive_windowsopen("index.php?module="+pageto_module+"&action="+pageto_module+"Ajax&reportmodule=Comprehensivereport&file=RentCollectionReport&ReportHeader=DHeader&year="+year+"&parenttab=Reports","","");
}
function popup_LeasingReports(){
    var year = document.getElementById("year_1").innerHTML;
    //zkt 20231011 XUQIU1001341 SQL注入
    Comprehensive_windowsopen("index.php?module="+pageto_module+"&action="+pageto_module+"Ajax&reportmodule=Comprehensivereport&file=LeasingReports&ReportHeader=DHeader&year="+year+"&parenttab=Reports","","");
}

function popup_SummaryNationalAssetsAreaReports(){
    var year = document.getElementById("year_1").innerHTML;
    //zkt 20231011 XUQIU1001341 SQL注入
    Comprehensive_windowsopen("index.php?module="+pageto_module+"&action="+pageto_module+"Ajax&reportmodule=Comprehensivereport&file=SummaryNationalAssetsAreaReports&ReportHeader=DHeader&year="+year+"&parenttab=Reports","","");
}

function popup_Projectprofitreport(){
    var year = document.getElementById("year_1").innerHTML;
    //zkt 20231011 XUQIU1001341 SQL注入
    Comprehensive_windowsopen("index.php?module="+pageto_module+"&action="+pageto_module+"Ajax&reportmodule=Comprehensivereport&file=Projectprofitreport&ReportHeader=DHeader&year="+year+"&parenttab=Reports","","");
}
function popup_ProjectSchedulereport(){
    var year = document.getElementById("year_1").innerHTML;
    Comprehensive_windowsopen("index.php?module="+pageto_module+"&action="+pageto_module+"Ajax&reportmodule=Comprehensivereport&file=ProjectSchedule&ReportHeader=DHeader&year="+year+"&parenttab=Reports","","");
}
function popup_Operationsreport(){
    var year = document.getElementById("year_1").innerHTML;
    Comprehensive_windowsopen("index.php?module="+pageto_module+"&action="+pageto_module+"Ajax&reportmodule=Comprehensivereport&file=OperationsReport&ReportHeader=DHeader&year="+year+"&parenttab=Reports","","");
}

function popup_FinancialReport(){
    var year = document.getElementById("year_1").innerHTML;
    Comprehensive_windowsopen("index.php?module="+pageto_module+"&action="+pageto_module+"Ajax&reportmodule=Comprehensivereport&file=FinancialReport&ReportHeader=DHeader&year="+year+"&parenttab=Reports","","");
}

function popup_hetonggangReport(){
    var year = document.getElementById("year_1").innerHTML;
    Comprehensive_windowsopen("index.php?module="+pageto_module+"&action="+pageto_module+"Ajax&reportmodule=Comprehensivereport&file=hetonggangReport&ReportHeader=DHeader&year="+year+"&parenttab=Reports","","");
}

function popup_amountpaymentreport(){
    var year = document.getElementById("year_1").innerHTML;
    Comprehensive_windowsopen("index.php?module="+pageto_module+"&action="+pageto_module+"Ajax&reportmodule=Comprehensivereport&file=amountpaymentsummary&ReportHeader=DHeader&year="+year+"&parenttab=Reports","","");
}
/**
*@销售记录明细表
*@andrew
*@20140731
*/
function popup_guotongreports3(month)
{

    var year = document.getElementById("year_1").innerHTML;
    var name = document.getElementById("guotongreports2").value;
    var month = month;
    Comprehensive_windowsopen("index.php?module="+pageto_module+"&action="+pageto_module+"Ajax&reportmodule=Comprehensivereport&file=GuoTongReportsSalesrecordslist&ReportHeader=DHeader&rtype=chengben&year="+year+"&name="+name+"&month="+month+"&parenttab=Reports","","");
}
/*
更新操作
edit:can
date:20131106
reason:浩星明细表
*/
function popup_HxCrmdetail(month)
{
    var year = document.getElementById("year_1").innerHTML;
    var name = document.getElementById("SalesOrder_HxDetail").value;
    var month = month;
    Comprehensive_windowsopen("index.php?module="+pageto_module+"&action="+pageto_module+"Ajax&reportmodule=Comprehensivereport&file=HxCrmDetail&ReportHeader=DHeader&formodule=SalesOrder&year="+year+"&name="+name+"&month="+month+"&parenttab=Reports","","");
}
/**
*@小白熊报表
*@andrew
*@20141222
*/
function popup_snowbearrpisp()
{
    var year = document.getElementById("year_1").innerHTML;
    var name='SNOWBEARRPISP';
    Comprehensive_windowsopen("index.php?module="+pageto_module+"&action="+pageto_module+"Ajax&reportmodule=Comprehensivereport&file=snowbearreports&opentype=yes&name="+name+"&ReportHeader=DHeader&year="+year,"","");
}

function popup_snowbearrpisppeijianminxi()
{
    var year = document.getElementById("year_1").innerHTML;
    var name='SNOWBEARRPSL';
    Comprehensive_windowsopen("index.php?module="+pageto_module+"&action="+pageto_module+"Ajax&reportmodule=Comprehensivereport&file=snowbearreports&opentype=yes&name="+name+"&ReportHeader=DHeader&year="+year,"","");
}

function popup_snowbearSNOWBEARHNSRSR()
{
    var year = document.getElementById("year_1").innerHTML;
    var name='SNOWBEARHNSRSR';
    Comprehensive_windowsopen("index.php?module="+pageto_module+"&action="+pageto_module+"Ajax&reportmodule=Comprehensivereport&file=snowbearreports&opentype=yes&name="+name+"&ReportHeader=DHeader&year="+year,"","");
}

function popup_snowbearCCAR()
{
    var year = document.getElementById("year_1").innerHTML;
    var name='Customercomplaintanalysisreport';
    Comprehensive_windowsopen("index.php?module="+pageto_module+"&action="+pageto_module+"Ajax&reportmodule=Comprehensivereport&file=snowbearreports&opentype=yes&name="+name+"&ReportHeader=DHeader&year="+year,"","");
}

function popup_snowbearCCARflash()
{
    var year = document.getElementById("year_1").innerHTML;
    var name='Customercomplaintanalysisreport2';
    Comprehensive_windowsopen("index.php?module="+pageto_module+"&action="+pageto_module+"Ajax&reportmodule=Comprehensivereport&file=snowbearreportsflash&opentype=yes&name="+name+"&ReportHeader=DHeader&year="+year,"","");
}
function popup_snowbearCCARflash2()
{
    var year = document.getElementById("year_1").innerHTML;
    var name='Productcustomerservicenumberfailurestatistics2';
    Comprehensive_windowsopen("index.php?module="+pageto_module+"&action="+pageto_module+"Ajax&reportmodule=Comprehensivereport&file=snowbearreportsflash2&opentype=yes&name="+name+"&ReportHeader=DHeader&year="+year,"","");
}
function popup_snowbearCCARflash3()
{
    var year = document.getElementById("year_1").innerHTML;
    var name='Productcustomerservicenumberfailurestatistics3';
    Comprehensive_windowsopen("index.php?module="+pageto_module+"&action="+pageto_module+"Ajax&reportmodule=Comprehensivereport&file=snowbearreportsflash3&opentype=yes&name="+name+"&ReportHeader=DHeader&year="+year,"","");
}
function popup_snowbearCCARflash400()
{
    var year = document.getElementById("year_1").innerHTML;
    var name='Productcustomerservicenumberfailurestatistics2';
    Comprehensive_windowsopen("index.php?module="+pageto_module+"&action="+pageto_module+"Ajax&reportmodule=Comprehensivereport&file=snowbearreportsflash400&opentype=yes&name="+name+"&ReportHeader=DHeader&year="+year,"","");
}
function popup_snowbearraordsr()
{
    var year = document.getElementById("year_1").innerHTML;
    var name='Returnamountregionaldatasummaryreport';
    Comprehensive_windowsopen("index.php?module="+pageto_module+"&action="+pageto_module+"Ajax&reportmodule=Comprehensivereport&file=snowbearreports&opentype=yes&name="+name+"&ReportHeader=DHeader&year="+year,"","");
}

function popup_snowbearrnordsr()
{
    var year = document.getElementById("year_1").innerHTML;
    var name='Returnnumberregionaldatasummaryreport';
    Comprehensive_windowsopen("index.php?module="+pageto_module+"&action="+pageto_module+"Ajax&reportmodule=Comprehensivereport&file=snowbearreports&opentype=yes&name="+name+"&ReportHeader=DHeader&year="+year,"","");
}

function popup_snowbearPcsnofs()
{
    var year = document.getElementById("year_1").innerHTML;
    var name='Productcustomerservicenumberfailurestatistics';
    Comprehensive_windowsopen("index.php?module="+pageto_module+"&action="+pageto_module+"Ajax&reportmodule=Comprehensivereport&file=snowbearreports&opentype=yes&name="+name+"&ReportHeader=DHeader&year="+year,"","");
}

function popup_snowbearCsnostofa()
{
    var year = document.getElementById("year_1").innerHTML;
    var name='Customerservicenumberofsummarytableoffaultarea';
    Comprehensive_windowsopen("index.php?module="+pageto_module+"&action="+pageto_module+"Ajax&reportmodule=Comprehensivereport&file=snowbearreports&opentype=yes&name="+name+"&ReportHeader=DHeader&year="+year,"","");
}

function popup_snowbearAtcsf()
{
    var year = document.getElementById("year_1").innerHTML;
    var name='Analysisofthetablecustomerservicefailure';
    Comprehensive_windowsopen("index.php?module="+pageto_module+"&action="+pageto_module+"Ajax&reportmodule=Comprehensivereport&file=snowbearreports&opentype=yes&name="+name+"&ReportHeader=DHeader&year="+year,"","");
}
/**
*@导出小白熊报表
*@andrew
*@20141222
*/
function exportsnowbear(name,year,ApplicableModel,ProductName,approvalSales){
    //document.getElementById("ajaxExport").value='yes';
    //alert("index.php?module="+pageto_module+"&action=snowbearreports&ajaxExport=yes&approvalSales="+approvalSales+"&ProductName="+ProductName+"&ApplicableModel="+ApplicableModel+"&name="+name+"&ReportHeader=DHeader&year="+year);
    window.href="index.php?module="+pageto_module+"&action="+pageto_module+"Ajax&reportmodule=Comprehensivereport&file=snowbearreports&ajaxExport=yes&approvalSales="+approvalSales+"&ProductName="+ProductName+"&ApplicableModel="+ApplicableModel+"&name="+name+"&ReportHeader=DHeader&year="+year;
}

function exportsnowbearSNOWBEARRPSL(name,year,SRPN,CONTRACTNO,EXPLAIN,ApplicableModel,ProductName,approvalSales){
   // document.getElementById("ajaxExport").value='yes';
    window.location="index.php?module="+pageto_module+"&action="+pageto_module+"Ajax&reportmodule=Comprehensivereport&file=snowbearreports&ajaxExport=yes&SRPN="+SRPN+"&CONTRACTNO="+CONTRACTNO+"&EXPLAIN="+EXPLAIN+"&approvalSales="+approvalSales+"&ProductName="+ProductName+"&ApplicableModel="+ApplicableModel+"&name="+name+"&ReportHeader=DHeader&begin_end_date_arr="+year;
}
/*
更新操作
edit:can
date:20131106
reason:皓星利润分析表（已收)
*/
function popup_HxCrmrent(month)
{
    var year = document.getElementById("year_1").innerHTML;
    var name = document.getElementById("SaleOrder_HxRent").value;
    var month = month;
    Comprehensive_windowsopen("index.php?module="+pageto_module+"&action="+pageto_module+"Ajax&reportmodule=Comprehensivereport&file=HxCrmRent&ReportHeader=DHeader&formodule=SalesOrder&year="+year+"&name="+name+"&month="+month+"&parenttab=Reports","","");
}
/*
更新操作
edit:can
date:20131204
reason:皓星利润分析表（未收)
*/
function popup_HxCrmPaymentplan(month)
{
    var year = document.getElementById("year_1").innerHTML;
    var name = document.getElementById("SaleOrder_HxRent").value;
    var month = month;
    Comprehensive_windowsopen("index.php?module="+pageto_module+"&action="+pageto_module+"Ajax&reportmodule=Comprehensivereport&file=HxCrmPaymentplan&ReportHeader=DHeader&formodule=SalesOrder&year="+year+"&name="+name+"&month="+month+"&parenttab=Reports","","");
}
/*
集家网报表
*/
function popup_jjwang()
{
    var year = document.getElementById("year_1").innerHTML;
    Comprehensive_windowsopen("index.php?module="+pageto_module+"&action="+pageto_module+"Ajax&reportmodule=Comprehensivereport&file=jjwangreports&ReportHeader=DHeader&year="+year+"&parenttab=Reports","","");
}
/*
更新操作
edit:can
date:20140430
reason:租金欠款明细表
*/
function popup_HxCrmNoPaymentplan(month)
{
    var year = document.getElementById("year_1").innerHTML;
    var name = document.getElementById("SaleOrder_HxRent").value;
    var month = month;
    Comprehensive_windowsopen("index.php?module="+pageto_module+"&action="+pageto_module+"Ajax&reportmodule=Comprehensivereport&file=HxCrmNoPaymentplan&ReportHeader=DHeader&formodule=SalesOrder&year="+year+"&name="+name+"&month="+month+"&parenttab=Reports","","");
}
/*
更新操作
edit:andy
date:20140122
reason:龙威总表按网点
*/
function popup_latticepointdetial(month)
{
    var year = document.getElementById("year_1").innerHTML;
    var name = document.getElementById("latticepointdetial").value;
    var month = month;
    //zkt 20231010 XUQIU1001341 SQL注入
    var urlsting ="index.php?module="+pageto_module+"&action="+pageto_module+"Ajax&reportmodule=Comprehensivereport&file=latticepointdetial&ReportHeader=DHeader&formodule=SalesOrder&year="+year+"&name="+name+"&month="+month+"&parenttab=Reports";
    urlstring= cls_encryptyurl.Puyoung_Encryptyurl(urlstring,'');
    Comprehensive_windowsopen(urlsting,"","");
}
/*
更新操作
edit:andy
date:20140126
reason:龙威总表按机型
*/
function popup_HelpDeskdetial(month)
{
    var year = document.getElementById("year_1").innerHTML;
    var name = document.getElementById("latticepointdetial").value;
    var month = month;
    //zkt 20231010 XUQIU1001341 SQL注入
    var urlsting = "index.php?module="+pageto_module+"&action="+pageto_module+"Ajax&reportmodule=Comprehensivereport&file=HelpDeskreportDetail&ReportHeader=DHeader&formodule=SalesOrder&year="+year+"&name="+name+"&month="+month+"&parenttab=Reports";
    urlstring= cls_encryptyurl.Puyoung_Encryptyurl(urlstring,'');
    Comprehensive_windowsopen(urlsting,"","");
}
function change_color(year,now)
{
    var year = year;
    var now = now;
    var urlstring = "module="+pageto_module+"&action="+pageto_module+"Ajax&reportmodule=Comprehensivereport&file=ComprehensivereportAll&year="+year+"&now="+now;
    ldAjaxHtml('index.php?',urlstring,function(response) {
        DelProgressObjs();
        //alert(response.responseText[1]);
        if(response.indexOf('#SUCCESS#')>-1){
            var result=response.split('#SUCCESS#');
            ld('#div_year_table').get(0).innerHTML=result[1];
        }
    });
}
/*
更新操作
edit:andrew
date:20140110
reason:销售总表：年度统计表（龙威）
*/
function popup_marketAll()
{
    var year = document.getElementById("year_1").innerHTML;
    var name = document.getElementById("RWmarketAll").value;
    //zkt 20231010 XUQIU1001341 SQL注入
    var urlsting = "index.php?module="+pageto_module+"&action="+pageto_module+"Ajax&reportmodule=Comprehensivereport&file=RwCrmDetail&ReportHeader=DHeader&formodule=marketAll&year="+year+"&name="+name+"&parenttab=Reports";
    urlstring= cls_encryptyurl.Puyoung_Encryptyurl(urlstring,'');
    Comprehensive_windowsopen(urlstring,"","");
}

function DoOnchange(){
    var proid = document.changeForm.proid.value;
    var month = document.getElementById('month').value;
    var year = document.getElementById('year').value;
    window.location.href="index.php?module="+pageto_module+"&action="+pageto_module+"Ajax&reportmodule=Comprehensivereport&file=HelpDeskreportDetail&ReportHeader=DHeader&formodule=SalesOrder&year="+year+"&name=latticepointdetial&month="+month+"&proid="+proid+"&parenttab=Reports";
}


function change_table(typename){
    document.getElementById('change_table_'+typename).className='On B';
    document.getElementById('change_table_div_'+typename).style.display="block";
    var typename_array = eval('('+ report_typename +')')?eval('('+ report_typename +')'):JSON.parse(report_typename);

    for(i=0;i<=typename_array.length;i++)
    {
        if(typename!=typename_array[i])
        {
            if(document.getElementById('change_table_'+typename_array[i])!=undefined)
            {
                document.getElementById('change_table_'+typename_array[i]).className='';
            }
            if(document.getElementById('change_table_div_'+typename_array[i])!=undefined)
            {
                document.getElementById('change_table_div_'+typename_array[i]).style.display="none";
            }
        }
    }
}

function display_table(event){
    var event=event||window.event;
    var fromobj=event.srcElement||event.target;
    
    if(fromobj!=undefined&&fromobj.id=='img1'&& document.getElementById('a1').style.display!="block")
    {
        document.getElementById('a1').style.display="block";
        document.getElementById('a2').style.display="block";
        return ;
    }
    else
    {
         document.getElementById('a1').style.display="none";
         document.getElementById('a2').style.display="none";
    }
    var toobj=event.relatedTarget ||event.toElement;
    /*if(toobj!=undefined&&toobj.id!='a1'&&toobj.id!='a2'&&toobj.id!='a3'&&toobj.id!='img1'&&toobj.id!='a5')
    {
    document.getElementById('a1').style.display="none";
    document.getElementById('a2').style.display="none";
    return ;
    }*/
    if(toobj!=undefined)
    {
        var parentobj=toobj;
        while(parentobj!=undefined)
        {
            if(parentobj.id=='a5')
            {
                break;
            }
        
            if(parentobj.tagName!=undefined && parentobj.tagName.toLowerCase()=='body')
            {
                 document.getElementById('a1').style.display="none";
                 document.getElementById('a2').style.display="none";
                 break;
            }
            parentobj=parentobj.parentNode||parentobj.parentElement;
        }
    }
}

function changeshow(hiddendivid,showdivid){
    document.getElementById(hiddendivid).style.display="none";
    document.getElementById(hiddendivid+'s').style.display="none";
    //document.getElementById(showdivid).setAttribute("style", "");
    document.getElementById(showdivid).style.display="";
    document.getElementById(showdivid+'s').style.display="";
}
/**
 *@andy
 *@date 20140526
 *@reason 综合报表增加查询时间和查询范围功能
 *@verson 5.3
 */
function Report_form_queryValidate(){
    pageto_module = getSearchString('module',location.href);
    /*
    var begin_date=document.forms['Report_form_query'].begin_date.value;
    var end_date=document.forms['Report_form_query'].end_date.value;
    //alert(begin_date)
    if(begin_date.replace(/^\s+/g, '').replace(/\s+$/g, '').length==0)
    {
        //alert('查询初期不能为空!')
        alert(arrJsPopLabel['THEINITIALQUERYCANNOTBEEMPTY']);
        document.forms['Report_form_query'].begin_date.focus();
        return false;
    }
    if(end_date.replace(/^\s+/g, '').replace(/\s+$/g, '').length==0)
    {
        //alert('查询期末不能为空!');
        alert(arrJsPopLabel['THEINITTERMIALQUERYCANNOTBEEMPTY']);
        document.forms['Report_form_query'].end_date.focus();
        return false;
    }
    if(end_date < begin_date)
    {
        //alert('查询期末不能小于查询初期!');
        alert(arrJsPopLabel['THEFINALCANNOTBELESSTHANTHEINITIALQUERY']);
        return false;
    }
    if(!isDate(begin_date)){
        //alert('请输入正确格式的查询初期时间!');
        alert(arrJsPopLabel['PLEASEINPUTTHECORRECTFORMATEARLY']);
        return false;
    }
    if(!isDate(end_date)){
        //alert('请输入正确格式的查询期末时间!');
        alert(arrJsPopLabel['PLEASEINPUTTHECORRECTFORMATFINALTIME']);
        return false;
    }
    */
    //return false;
	if(ld('#return_mypage') != undefined && ld('#return_mypage').val() == 'home'){
		var return_mypage = ld('#return_mypage').val();
		var module = document.forms['Report_form_query'].module.value;
		var actionname = document.forms['Report_form_query'].action.value;
		var Report_form_query = document.forms['Report_form_query'].Report_form_query.value;
		var ReportHeader = document.forms['Report_form_query'].ReportHeader.value;
		var year = document.forms['Report_form_query'].year.value;
		var begin_date = document.forms['Report_form_query'].begin_date.value;
		var url_str = 'module='+pageto_module+'&action='+pageto_module+'Ajax&reportmodule=Comprehensivereport&file='+actionname+'&Report_form_query='+Report_form_query+'&ReportHeader='+ReportHeader+'&year='+year+'&begin_date='+begin_date+'&b_begin_date=&ajax=true&return_mypage='+return_mypage;

        //zkt 20231010 XUQIU1001341 SQL注入
        ldAjaxHtml('index.php?',url_str,function(response) {
            DelProgressObjs();
            ld('#comprehensivereportdiv').html(response);
        });
		return false;
	}
    document.forms['Report_form_query'].submit();
}
function submit_productcategory(){
	if(ld('#return_mypage') != undefined && ld('#return_mypage').val() == 'home'){
		var return_mypage = ld('#return_mypage').val();
		var module = document.forms['Report_form_query'].module.value;
		var actionname = document.forms['Report_form_query'].action.value;
		var Report_form_query = document.forms['Report_form_query'].Report_form_query.value;
		var ReportHeader = document.forms['Report_form_query'].ReportHeader.value;
		var year = document.forms['Report_form_query'].year.value;
        var begin_date = document.forms['Report_form_query'].begin_date.value;
		var productcategoryvalue =  ld('#productcategoryvalue').val();
		var url_str = 'module='+pageto_module+'&action='+pageto_module+'Ajax&reportmodule=Comprehensivereport&file='+actionname+'&Report_form_query='+Report_form_query+'&ReportHeader='+ReportHeader+'&year='+year+'&begin_date='+begin_date+'&productcategoryvalue='+productcategoryvalue+'&b_begin_date=&ajax=true&return_mypage='+return_mypage;

        //zkt 20231010 XUQIU1001341 SQL注入
        ldAjaxHtml('index.php?',url_str,function(response) {
            DelProgressObjs();
            ld('#comprehensivereportdiv').html(response);
        });
		return false;
	}
    document.forms['Report_form_query'].submit();
}
//验证日期格式
function isDate(date){
 var v = date.match(/^(\d{4})-(\d{1,2})-(\d{1,2})$/i);
 if(!v) {
  return false;
 }else{
    return true;
 }
} 
function CfnDropDownUserslongwei(obj,Lay,topY){

	var tagName = document.getElementById(Lay);
	var leftSide = findPopX(obj);
	var topSide = findPopY(obj);

    topSide=obj.offsetHeight+0;
	var maxW = tagName.style.width;
	var widthM = maxW.substring(0,maxW.length-2);
	var getVal = eval(leftSide) + eval(widthM);
	if(getVal  > document.body.clientWidth ){
		leftSide = eval(leftSide) - eval(widthM);
		tagName.style.left = leftSide + 0 + 'px';
	}
	else
		tagName.style.left= leftSide + 'px';
        if(topY!=undefined){
        tagName.style.top= topSide+ 0 + topY+'px';
        tagName.style.width=obj.clientWidth+'px';
        }
        else
		tagName.style.top= topSide + 0 +'px';
		tagName.style.display = 'block';
}
function CfnDropDownUsers(obj,Lay,topY){

	var tagName = document.getElementById(Lay);
	var leftSide = findPopX(obj);
	var topSide = findPopY(obj);

    topSide=obj.offsetHeight+20;
	var maxW = tagName.style.width;
	var widthM = maxW.substring(0,maxW.length-2);
	var getVal = eval(leftSide) + eval(widthM);
	if(getVal  > document.body.clientWidth ){
		leftSide = eval(leftSide) - eval(widthM);
		tagName.style.left = leftSide + 34 + 'px';
	}
	else
		tagName.style.left= leftSide + 'px';
        if(topY!=undefined){
        tagName.style.top= topSide+ 11 + topY+'px';
        tagName.style.width=obj.clientWidth+'px';
        }
        else
		tagName.style.top= topSide + 28 +'px';
		tagName.style.display = 'block';
}
function getSelected(txtid){
    cbobj=document.getElementsByName('cb_select_user');
    txtidobj=document.getElementById(txtid);
    txtobj=document.getElementById('search_text');
    if(cbobj!=undefined&&txtobj!=undefined&&txtidobj!=undefined){
        txtobj_str='';
        txtidobj_str='';
        for(i=0;i<cbobj.length;i++){
            if(cbobj[i].checked){
                sp_obj=document.getElementById('sp_user_'+i);
                txt_obj=document.getElementById('search_text_'+i);
                txtobj_str=txtobj_str+sp_obj.innerHTML+',';
                txtidobj_str=txtidobj_str+txt_obj.value+',';
            }
        }
        txtobj_str=txtobj_str.substr(0,txtobj_str.lastIndexOf(','));
        txtidobj_str=txtidobj_str.substr(0,txtidobj_str.lastIndexOf(','));
        txtobj.value=txtobj_str;
        txtidobj.value=txtidobj_str;
    }
}
function ngetSelected(txtid,divs){
  
    cbobj=document.getElementsByName(divs);
    //alert(divs);
    txtidobj=document.getElementById(txtid);
    if(divs=='cb_select_account'){
        txtobj=document.getElementById('search_text2');
    }else if(divs=='cb_select_user'){
        txtobj=document.getElementById('search_text');
    }else if(divs=='cb_select_Sector'){
        txtobj=document.getElementById('search_text3');
    }else if(divs=='cb_select_Salesman'){
        txtobj=document.getElementById('search_text4');
    }else if(divs=='cb_select_Salesmans'){
        txtobj=document.getElementById('search_text5');
    }
    
    
    if(cbobj!==undefined&&txtobj!==undefined&&txtidobj!==undefined){
        txtobj_str='';
        txtidobj_str='';
        for(i=0;i<cbobj.length;i++){
            if(cbobj[i].checked){
                if(divs=='cb_select_account'){
                    sp_obj=document.getElementById('sp_account_'+i);
                    txt_obj=document.getElementById('search_text2_'+i);
                }else if(divs=='cb_select_user'){
                    sp_obj=document.getElementById('sp_user_'+i);
                    txt_obj=document.getElementById('search_text_'+i);
                }else if(divs=='cb_select_Sector'){
                    sp_obj=document.getElementById('sp_Sector_'+i);
                    txt_obj=document.getElementById('search_text3_'+i);
                }else if(divs=='cb_select_Salesman'){
                    sp_obj=document.getElementById('sp_Salesman_'+i);
                    txt_obj=document.getElementById('search_text4_'+i);
                }else if(divs=='cb_select_Salesmans'){
                    sp_obj=document.getElementById('sp_Salesmans_'+i);
                    txt_obj=document.getElementById('search_text5_'+i);
                }

                txtobj_str=txtobj_str+sp_obj.innerHTML+',';
                txtidobj_str=txtidobj_str+txt_obj.value+',';
            }
        }
        txtobj_str=txtobj_str.substr(0,txtobj_str.lastIndexOf(','));
        txtidobj_str=txtidobj_str.substr(0,txtidobj_str.lastIndexOf(','));
        txtobj.value=txtobj_str;
        if(txtidobj){
           txtidobj.value=txtidobj_str; 
        }
        
        
    }
}

calendarParentid="searchAcc";
document.onclick=function(event)
{
     var e=event||window.event;
      var obj=e.srcElement||e.target;
      while(obj!=undefined)
     {
        if(document.getElementById('a1')!=null){
            if(obj.tagName=='BODY'||obj.tagName=='HTML')
            {
                 document.getElementById('a1').style.display="none";
                 document.getElementById('a2').style.display="none";
                  
                break;
            }
      }
        if(obj.id=="a2"|| obj.id=="a1"||obj.id=="img1")
        {
           
            break;
        }
        obj=obj.parentNode||obj.parentElement ;
     }
}
function BodyClick2(obj,lay){
    addListener2(document, "click",
    function(evt) {
        var evt = window.event ? window.event: evt,
        target = evt.srcElement || evt.target;
        
        if (target == obj||target.id == lay||target.parentNode==undefined) {
            document.getElementById(lay).style.display = "";
            document.getElementById(lay).style.zIndex=1; 
            return;
        } else {
            while (target.nodeName.toLowerCase()) {
                target = target.parentNode;
                if(target==undefined)
                {
                    //document.getElementById(lay).style.display="";
                    return ;
                }
                if (target== obj||target.id == lay) {
                    document.getElementById(lay).style.display = "";
                    return;
                }
                if (target.nodeName.toLowerCase() == "body") {
                    document.getElementById(lay).style.display = "none";
                    return;
                }
            }
        }
    });
}
function addListener2(element, e, fn) {
    if (element.addEventListener) {
        element.addEventListener(e, fn, false);
    } else {
        element.attachEvent("on" + e, fn);
    }
}

function changedaytime(obj,type,day1,day2){
    //document.getElementById('startmonth').value=day1;  
    //document.getElementById('endmonth').value=day2;
    document.getElementById('begin_date').value=day1+' '+'-'+' '+day2;
	setReportTime(document.getElementById('begin_date').value);
    ld('#begin_date').daterangepicker(null, function(start, end, label) {
        
      });
      
    /**
    *@author:andy
    *@data:
    *@reason:优化
    *@version:|
    */
    var p=obj.parentNode.children;
    //alert(p.length)
    for(var i=0;i<p.length;i++)
    {
        
        var changeid=p[i].id;
        changeid = changeid.charAt(changeid.length - 1);
        if(p[i] != obj){
            if(p[i].nodeName == 'A'&&changeid=='1')
                p[i].className='changeday';
        }
    }
    obj.className='onselected_A changeday';
}
function changedaytime2(obj,type,day1,day2){
    //document.getElementById('startmonth').value=day1;  
    //document.getElementById('endmonth').value=day2;
    document.getElementById('begin_date2').value=day1+' '+'-'+' '+day2;
	setReportTime(document.getElementById('begin_date2').value);
    ld('#begin_date2').daterangepicker(null, function(start, end, label) {
        
      });
      
    /**
    *@author:andy
    *@data:
    *@reason:优化
    *@version:|
    */
    var p=obj.parentNode.children;

    //alert(p.length)
    for(var i=0;i<p.length;i++)
    {
        var changeid=p[i].id;
        changeid = changeid.charAt(changeid.length - 1);
        if(p[i] != obj){
            if(p[i].nodeName == 'A'&&changeid=='2')
                p[i].className='changeday';
        }
    }
    obj.className='onselected_A changeday';
}
function changedaytime3(obj,type,day1,day2){
    //document.getElementById('startmonth').value=day1;  
    //document.getElementById('endmonth').value=day2;
    document.getElementById('begin_date3').value=day1+' '+'-'+' '+day2;
	setReportTime(document.getElementById('begin_date2').value);
    ld('#begin_date3').daterangepicker(null, function(start, end, label) {
        
      });
      
    /**
    *@author:andy
    *@data:
    *@reason:优化
    *@version:|
    */
    
    var p=obj.parentNode.children;

    //alert(p.length)
    for(var i=0;i<p.length;i++)
    {
        var changeid=p[i].id;
        changeid = changeid.charAt(changeid.length - 1);
        if(p[i] != obj){
            if(p[i].nodeName == 'A'&&changeid=='3')
                p[i].className='changeday';
        }
    }
    obj.className='onselected_A changeday';
}
function changedaytime4(obj,type,day1,day2){
    document.getElementById('begin_date4').value=day1+' '+'-'+' '+day2;
	setReportTime(document.getElementById('begin_date4').value);
    ld('#begin_date4').daterangepicker(null, function(start, end, label) {
        
      });
      
    var p=obj.parentNode.children;

    //alert(p.length)
    for(var i=0;i<p.length;i++)
    {
        var changeid=p[i].id;
        changeid = changeid.charAt(changeid.length - 1);
        if(p[i] != obj){
            if(p[i].nodeName == 'A'&&changeid=='4')
                p[i].className='changeday';
        }
    }
    obj.className='onselected_A changeday';
}
function search_jinxinggongzi(type){
   var smownerid = ld('#smownerid').val();
   var salesorderno = ld('#salesorderno').val();
   var accountname =ld('#accountname').val();
   var cf_1494 = ld('#cf_1494').val();
   var cf_1469 = ld('#cf_1469').val();
   var begin_date = ld('#begin_date').val();

   var url='module='+pageto_module+'&action='+pageto_module+'Ajax&reportmodule=Comprehensivereport&file=jinxinggongzi&Report_form_query=true&ajax=true&smownerid='+smownerid+"&begin_date="+begin_date+'&type='+type;
    if(type=='export'){
        //zkt 20231010 XUQIU1001341 SQL注入
        url= cls_encryptyurl.Puyoung_Encryptyurl(url,'');
        Comprehensive_windowsopen('index.php?'+url,"","");
        return ;
    }
    //zkt 20231010 XUQIU1001341 SQL注入
    ldAjaxHtml('index.php?',url,function(response) {
        DelProgressObjs();
        document.getElementById('checksms').innerHTML=response;
    });
}

function search_amountpaymentsummary(){
   var SmOwnerSearchScope = ld('#SmOwnerSearchScope').val();
   var year = ld('#year').val();
   var cf_1486 =ld('#cf_1486').val();

   var url='module='+pageto_module+'&action='+pageto_module+'Ajax&reportmodule=Comprehensivereport&file=amountpaymentsummary&Report_form_query=true&ajax=true&smownerid='+SmOwnerSearchScope+'&year='+year+'&cf_1486='+cf_1486;
    //zkt 20231010 XUQIU1001341 SQL注入
    ldAjaxHtml('index.php?',url,function(response) {
        DelProgressObjs();
        document.getElementById('checksms').innerHTML=response;
    });
}
function search_rentcollection(type){
   var smownerid = ld('#smownerid').val();
   var cf_1471value = ld('#cf_1471value').val();
   var cf_1472value = ld('#cf_1472value').val();
   var productcategoryvalue = ld('#productcategoryvalue').val();
   var contract_no = ld('#contract_no').val();
   var cf_1545 = ld('#cf_1545').val();
   var begin_date =ld('#begin_date').val();
   var SmOwnerSearchScope = ld('#SmOwnerSearchScope').val();
   var selectuserid = ld('#selectuserid').val();
   var url='module='+pageto_module+'&action='+pageto_module+'Ajax&reportmodule=Comprehensivereport&file=RentCollectionReport&Report_form_query=true&ajax=true&smownerid='
   +smownerid+"&begin_date="+begin_date+'&type='+type+'&cf_1471value='+cf_1471value+'&cf_1472value='+cf_1472value+'&productcategoryvalue='+productcategoryvalue+
   '&contract_no='+contract_no+'&cf_1545='+cf_1545+'&SmOwnerSearchScope='+SmOwnerSearchScope+'&selectuserid='+selectuserid;
    if(type=='export'){
        //zkt 20231011 XUQIU1001341 SQL注入
        url= cls_encryptyurl.Puyoung_Encryptyurl(url,'');
        window.open('index.php?'+url,"",""); 
        return ;
    }
    //zkt 20231011 XUQIU1001341 SQL注入
    ldAjaxHtml('index.php?',url,function(response) {
        DelProgressObjs();
        document.getElementById('checksms').innerHTML=response;
    });
}

function search_LeasingReports(type){
   var smownerid = ld('#smownerid').val();
   var cf_1471value = ld('#cf_1471value').val();
   var cf_1472value = ld('#cf_1472value').val();
   var productcategoryvalue = ld('#productcategoryvalue').val();
   var contract_no = ld('#contract_no').val();
   var cf_1545 = ld('#cf_1545').val();
   var begin_date =ld('#begin_date').val();
   var SmOwnerSearchScope = ld('#SmOwnerSearchScope').val();
   var selectuserid = ld('#selectuserid').val();
   var url='module='+pageto_module+'&action='+pageto_module+'Ajax&reportmodule=Comprehensivereport&file=LeasingReports&Report_form_query=true&ajax=true&smownerid='
   +smownerid+"&begin_date="+begin_date+'&type='+type+'&cf_1471value='+cf_1471value+'&cf_1472value='+cf_1472value+'&productcategoryvalue='+productcategoryvalue+
   '&contract_no='+contract_no+'&cf_1545='+cf_1545+'&SmOwnerSearchScope='+SmOwnerSearchScope+'&selectuserid='+selectuserid;
    if(type=='export'){
        //zkt 20231011 XUQIU1001341 SQL注入
        url= cls_encryptyurl.Puyoung_Encryptyurl(url,'');
        window.open('index.php?'+url,"",""); 
        return ;
    }
    //zkt 20231011 XUQIU1001341 SQL注入
    ldAjaxHtml('index.php?',url,function(response) {
        DelProgressObjs();
        document.getElementById('checksms').innerHTML=response;
    });
}
function search_Financial(type){
   var cf_1484 = ld('#cf_1484').val();
   var accountname =ld('#accountname').val();
   var cf_1486 = ld('#cf_1486').val();
   var cf_1504 = ld('#cf_1504').val();
   var cf_1506 = ld('#cf_1506').val();
   var begin_date = ld('#begin_date').val();
   var begin_date2 = ld('#begin_date2').val();
   var begin_date3 = ld('#begin_date3').val();
   var listprice = ld('#listprice').val();
   var desc_id='';
    var obj = document.getElementsByName("approvestatus");
    for(i=0;i<obj.length;i++){
   if(obj[i].checked!=false&&obj[i].value!=undefined){ 
     desc_id+='"'+obj[i].value+'",';
   }}
   var url='module='+pageto_module+'&action='+pageto_module+'Ajax&reportmodule=Comprehensivereport&file=FinancialReport'
   +'&Report_form_query=true&ajax=true&cf_1484='+cf_1484+'&accountname='+accountname+"&cf_1486="+cf_1486+"&cf_1504="+cf_1504
   +"&begin_date3="+begin_date3+"&cf_1506="+cf_1506+"&listprice="+listprice
   +"&begin_date2="+begin_date2+"&begin_date="+begin_date+'&type='+type;
   if(desc_id!=''){
        url+='&approvestatus='+desc_id;
    }
   if(type=='export'){
       //zkt 20231011 XUQIU1001341 SQL注入
       url= cls_encryptyurl.Puyoung_Encryptyurl(url,'');
        window.open(encodeURI('index.php?'+url),"",""); 
        return ;
    }
    //zkt 20231011 XUQIU1001341 SQL注入
    ldAjaxHtml('index.php?',url,function(response) {
        DelProgressObjs();
        document.getElementById('checksms').innerHTML=response;
    });
}

function search_hetonggang(type){
   //var smownerid = ld('#smownerid').val();
   var begin_date = ld('#begin_date').val();
   var begin_date2 = ld('#begin_date2').val();
   var begin_date3 = ld('#begin_date3').val();
   var smownerid = ld('#SmOwnerSearchScope').val();
   var desc_id='';
    var obj = document.getElementsByName("approvestatus");
    for(i=0;i<obj.length;i++){
   if(obj[i].checked!=false&&obj[i].value!=undefined){ 
      desc_id+='"'+obj[i].value+'",';
   }}
   var url='module='+pageto_module+'&action='+pageto_module+'Ajax&reportmodule=Comprehensivereport&file=hetonggangReport'
   +'&Report_form_query=true&ajax=true&smownerid='+smownerid
   +"&begin_date3="+begin_date3
   +"&begin_date2="+begin_date2+"&begin_date="+begin_date+'&type='+type;
   if(desc_id!=''){
        url+='&approvestatus='+desc_id;
    }
    if(type=='export'){
        //zkt 20231011 XUQIU1001341 SQL注入
        url= cls_encryptyurl.Puyoung_Encryptyurl(url,'');
        window.open(encodeURI('index.php?'+url),"","");
        return ;
    }
    //zkt 20231011 XUQIU1001341 SQL注入
    ldAjaxHtml('index.php?',url,function(response) {
        DelProgressObjs();
        document.getElementById('checksms').innerHTML=response;
    });

}

function search_Operations(type){
   //var smownerid = ld('#smownerid').val();
   var smownerid = ld('#SmOwnerSearchScope').val();
   var cf_1484 = ld('#cf_1484').val();
   var accountname =ld('#accountname').val();
   var productname = ld('#productname').val();
   var cf_1498 = ld('#cf_1498').val();
   var cf_1494 = ld('#cf_1494').val();
   var begin_date = ld('#begin_date').val();
   var begin_date2 = ld('#begin_date2').val();
   
   
   var desc_id='';
    var obj = document.getElementsByName("approvestatus");
    for(i=0;i<obj.length;i++){
   if(obj[i].checked!=false&&obj[i].value!=undefined){ 
     desc_id+='"'+obj[i].value+'",';
   }}


   var selectuserid='';
   if(ld('#selectuserid')!='undefined'&&ld('#selectuserid')!=undefined){
       selectuserid = ld('#selectuserid').val();
   }

   var url='module='+pageto_module+'&action='+pageto_module+'Ajax&reportmodule=Comprehensivereport&file=OperationsReport'
   +'&Report_form_query=true&ajax=true&smownerid='+smownerid+'&cf_1484='
   +cf_1484+'&accountname='+accountname+'&productname='+productname+"&cf_1498="+cf_1498+"&cf_1494="+cf_1494
   +"&selectuserid="+selectuserid+'&SmOwnerSearchScope='+viewName
   +"&begin_date2="+begin_date2+"&begin_date="+begin_date+'&type='+type;
   if(desc_id!=''){
        url+='&approvestatus='+desc_id;
    }
   viewName='';
    if(type=='export'){
        //zkt 20231011 XUQIU1001341 SQL注入
        url= cls_encryptyurl.Puyoung_Encryptyurl(url,'');
        window.open(encodeURI('index.php?'+url),"","");
        return ;
    }
    //zkt 20231011 XUQIU1001341 SQL注入
    ldAjaxHtml('index.php?',url,function(response) {
        DelProgressObjs();
        document.getElementById('checksms').innerHTML=response;
    });
}
function search_dividend(type){
   var smownerid = ld('#smownerid').val();
   var salesorderno = ld('#salesorderno').val();
   var accountname =ld('#accountname').val();
   var cf_1494 = ld('#cf_1494').val();
   var cf_1469 = ld('#cf_1469').val();
   var begin_date = ld('#begin_date').val();
   var begin_date2 = ld('#begin_date2').val();
   
   var url='module='+pageto_module+'&action='+pageto_module+'Ajax&reportmodule=Comprehensivereport&file=Dividend&Report_form_query=true&ajax=true&smownerid='+smownerid+'&salesorderno='+salesorderno+'&accountname='+accountname+'&cf_1494='+cf_1494+"&cf_1469="+cf_1469+"&begin_date2="+begin_date2+"&begin_date="+begin_date+'&type='+type;
    if(type=='export'){
        //zkt 20231011 XUQIU1001341 SQL注入
        url= cls_encryptyurl.Puyoung_Encryptyurl(url,'');
        window.open(encodeURI('index.php?'+url),"","");
        return ;
    }
    //zkt 20231011 XUQIU1001341 SQL注入
    ldAjaxHtml('index.php?',url,function(response) {
        DelProgressObjs();
        document.getElementById('checksms').innerHTML=response;
    });
}
function search_paixi(){
   var accountname =ld('#accountname').val();
   var phone = ld('#phone').val();
   var cf_1483 = ld('#cf_1483').val();
   var begin_date = ld('#begin_date').val();
   var begin_date2 = ld('#begin_date2').val();
   
   var url='module='+pageto_module+'&action='+pageto_module+'Ajax&reportmodule=Comprehensivereport&file=shuowei&Report_form_query=true&ajax=true&accountname='
   +accountname+'&phone='+phone+'&cf_1483='+cf_1483+"&begin_date2="+begin_date2+"&begin_date="+begin_date;
    //zkt 20231011 XUQIU1001341 SQL注入
    ldAjaxHtml('index.php?',url,function(response) {
        DelProgressObjs();
        document.getElementById('checksms').innerHTML=response;
    });
}
function search_licaodai(type){
   var accountname =ld('#accountname').val();
   var phone = ld('#phone').val();
   var cf_1483 = ld('#cf_1483').val();
   var begin_date = ld('#begin_date').val();
   var begin_date2 = ld('#begin_date2').val();
   var fuxitype=ld("#fuxitype option:selected").val();
      
   var url='module='+pageto_module+'&action='+pageto_module+'Ajax&reportmodule=Comprehensivereport&file=licaodai&Report_form_query=true&ajax=true&accountname='
   +accountname+'&phone='+phone+'&cf_1483='+cf_1483+"&begin_date2="+begin_date2+"&begin_date="+begin_date+'&type='+type+'&fuxitype='+fuxitype;
    if(type=='export'){
        //zkt 20231011 XUQIU1001341 SQL注入
        url= cls_encryptyurl.Puyoung_Encryptyurl(url,'');
        window.open(encodeURI('index.php?'+url),"","");
        return ;
    }
    //zkt 20231011 XUQIU1001341 SQL注入
    ldAjaxHtml('index.php?',url,function(response) {
        DelProgressObjs();
        document.getElementById('checksms').innerHTML=response;
    });
}
function search_Projectprofitreport(type){
   var subject =ld('#subject').val();
   var begin_date = ld('#begin_date').val();
    var SmOwnerSearchScope = ld('#SmOwnerSearchScope').val();
   var selectuserid='';
   if(ld('#selectuserid')!='undefined'&&ld('#selectuserid')!=undefined){
       selectuserid = ld('#selectuserid').val();
   }
   var url='module='+pageto_module+'&action='+pageto_module+'Ajax&reportmodule=Comprehensivereport&file=Projectprofitreport&Report_form_query=true&ajax=true&type='
   +type+'&subject='+subject+'&begin_date='+begin_date+'&SmOwnerSearchScope='+SmOwnerSearchScope+'&selectuserid='+selectuserid;
    if(type=='export'){
        //zkt 20231011 XUQIU1001341 SQL注入
        url= cls_encryptyurl.Puyoung_Encryptyurl(url,'');
        window.open(encodeURI('index.php?'+url),"","");
        return ;
    }
    //zkt 20231011 XUQIU1001341 SQL注入
    ldAjaxHtml('index.php?',url,function(response) {
        DelProgressObjs();
        document.getElementById('checksms').innerHTML=response;
    });
}

function search_ProjectSchedule(type){

      var subject =ld('#subject').val();
   var begin_date = ld('#begin_date').val();
       var SmOwnerSearchScope = ld('#SmOwnerSearchScope').val();
   var selectuserid='';
   if(ld('#selectuserid')!='undefined'&&ld('#selectuserid')!=undefined){
       selectuserid = ld('#selectuserid').val();
   }
   var url='module='+pageto_module+'&action='+pageto_module+'Ajax&reportmodule=Comprehensivereport&file=ProjectSchedule&Report_form_query=true&ajax=true&type='
   +type+'&subject='+subject+'&begin_date='+begin_date+'&SmOwnerSearchScope='+SmOwnerSearchScope+'&selectuserid='+selectuserid;
    if(type=='export'){
        //zkt 20231011 XUQIU1001341 SQL注入
        url= cls_encryptyurl.Puyoung_Encryptyurl(url,'');
        window.open(encodeURI('index.php?'+url),"","");
        return ;
    }
    //zkt 20231011 XUQIU1001341 SQL注入
    ldAjaxHtml('index.php?',url,function(response) {
        DelProgressObjs();
        document.getElementById('checksms').innerHTML=response;
    });
}
function search_receivabls(type){
   var accountname =ld('#accountname').val();
   var productname = ld('#productname').val();
   var cf_1461 = ld('#cf_1461').val();
   var fsalesorder_name = ld('#fsalesorder_name').val();
   var productsheet = ld('#productsheet').val();
   var cf_1476=ld("#cf_1476 option:selected").val();
   var cf_1469=ld("#cf_1469 option:selected").val();
   var begin_date = ld('#begin_date').val();
   var ordertype = ld('#ordertype option:selected').val();
   var url='module='+pageto_module+'&action='+pageto_module+'Ajax&reportmodule=Comprehensivereport&file=ReceivablesReport&Report_form_query=true&ajax=true&accountname='
   +accountname+'&productname='+productname+'&cf_1461='+cf_1461+"&productsheet="+productsheet+"&begin_date="
   +begin_date+'&cf_1476='+cf_1476+'&cf_1469='+cf_1469+'&type='+type+'&fsalesorder_name='+fsalesorder_name+'&ordertype='+ordertype;
    if(type=='export'){
        //zkt 20231011 XUQIU1001341 SQL注入
        url= cls_encryptyurl.Puyoung_Encryptyurl(url,'');
        window.open(encodeURI('index.php?'+url),"","");
        return ;
    }
    //zkt 20231011 XUQIU1001341 SQL注入
    ldAjaxHtml('index.php?',url,function(response) {
        DelProgressObjs();
        document.getElementById('checksms').innerHTML=response;
    });
}
function search_costreceivabls(type){
   var accountname =ld('#accountname').val();
   var productname = ld('#productname').val();
   var cf_1461 = ld('#cf_1461').val();
   var productsheet = ld('#productsheet').val();
   var cf_1476=ld("#cf_1476 option:selected").val();
   var cf_1469=ld("#cf_1469 option:selected").val();
   var begin_date = ld('#begin_date').val();
   var carrier = ld('#carrier').val();
   var ordertype = ld('#ordertype option:selected').val();
   var fsalesorder_name = ld('#fsalesorder_name').val();
      
   var url='module='+pageto_module+'&action='+pageto_module+'Ajax&reportmodule=Comprehensivereport&file=CostRevenuesReport&Report_form_query=true&ajax=true&accountname='
   +accountname+'&productname='+productname+'&cf_1461='+cf_1461+"&productsheet="+productsheet+"&begin_date="
   +begin_date+'&cf_1476='+cf_1476+'&cf_1469='+cf_1469+'&carrier='+carrier+'&type='+type+'&fsalesorder_name='+fsalesorder_name+'&ordertype='+ordertype;;
    if(type=='export'){
        //zkt 20231011 XUQIU1001341 SQL注入
        url= cls_encryptyurl.Puyoung_Encryptyurl(url,'');
        window.open(encodeURI('index.php?'+url),"","");
        return ;
    }
    //zkt 20231011 XUQIU1001341 SQL注入
    ldAjaxHtml('index.php?',url,function(response) {
        DelProgressObjs();
        document.getElementById('checksms').innerHTML=response;
    });
}
function paixi_dividend(sid,seq,DAY,val,id,phone){

    if (confirm("是否派息"))  {
        //ld('#'+sid+'_'+seq).hidden();
        var url='module='+pageto_module+'&action='+pageto_module+'Ajax&reportmodule=Comprehensivereport&file=shuowei&type=paixi&ajax=true&sid='+sid+'&seq='+seq+'&DAY='+DAY+'&accountname='+accountname+'&value='+val;
        //zkt 20231011 XUQIU1001341 SQL注入
        ldAjaxHtml('index.php?',url,function(response) {
            DelProgressObjs();
            document.getElementById(id).style.display = "none";
            ld("#divSendInform_div").get(0).innerHTML=response;
            fnvshobj(this,'divSendInform');
        });
    }
}

function licaodai_dividend(sid,seq,DAY,val,id,phone){

    if (confirm("是否派息"))  {
        //ld('#'+sid+'_'+seq).hidden();
        var url='module='+pageto_module+'&action='+pageto_module+'Ajax&reportmodule=Comprehensivereport&file=licaodai&type=paixi&ajax=true&sid='+sid+'&seq='+seq+'&DAY='+DAY+'&accountname='+accountname+'&value='+val;
        //zkt 20231011 XUQIU1001341 SQL注入
        ldAjaxHtml('index.php?',url,function(response) {
            DelProgressObjs();
            document.getElementById(id).style.display = "none";
            ld("#divSendInform_div").get(0).innerHTML=response;
            fnvshobj(this,'divSendInform');
        });
    }
}
function SaveComSendInfo(obj)
{
    var textRecipient=document.getElementById("textRecipient").value;
    if(textRecipient==''){
        //接收人信息为空！
        alert(arrJsPopLabel['RECIPIENTINFOEMPTY']);
        return false;
    }
    var textContext=document.getElementById("textContext").value;
    if(textContext==''){
        //接收内容为空！
        alert(arrJsPopLabel['RECEIVECONTENTEMPTY']);
        return false;
    }
    var sendaccount=document.getElementById("sendaccount").value;
    if(sendaccount==''){
        //没有设置通讯账户，请使用管理员用户到控制面板中设置！
        alert(arrJsPopLabel['COMMUNICATIONSACCOUNTNOTSET']);
        return false;
    }
    
    //window.location.href="index.php?action=DetailView&module=OutboundOrder&parenttab=Stock&record="+stockid;
    var url='module=MassSMS&action=SaveComSendInfo&ajax=true&textRecipient='+textRecipient+'&textContext='+textContext;
    //zkt 20231011 XUQIU1001341 SQL注入
    ldAjaxHtml('index.php?',url,function(response) {
        DelProgressObjs();
        fninvshnew('divSendInform');
    });
}
var intcount=1;
function showSelectUsers(ipt){
		var obj = {'field':'senioruserid','view':'private','type':'searchscope','empty':1};
		ViewUserPopup(obj,function(userobj){
		  if(userobj.userid!='undefined'&&userobj.userid!=undefined){
 			    document.getElementById('smownerid').value=userobj.userid.value;
                document.getElementById('smownername').value=userobj.username.value; 
		  }else{
                document.getElementById('smownerid').value='';
                document.getElementById('smownername').value=''; 
		  }      
		},function(){
		  if(intcount==1){
		      		 ld('#viewuserpopup').css('top','20%');intcount=2;
		  }
		});  
}
function edit_paymentSchedule(id,type){
    
    if(type==1){
		//预计付款日
        document.getElementById('time_'+id).value=document.getElementById(id+'_time_show').innerHTML;
        document.getElementById(id+'_time_show').style.display='none';
        document.getElementById(id+'_time_edit').style.display='block';
        //付息状态
        document.getElementById('paixi_'+id).value=document.getElementById(id+'_paixi_show').innerHTML;
        document.getElementById(id+'_paixi_show').style.display='none';
        document.getElementById(id+'_paixi_edit').style.display='block';
        //本金状态
        document.getElementById('benjin_'+id).value=document.getElementById(id+'_benjin_show').innerHTML;
        document.getElementById(id+'_benjin_show').style.display='none';
        document.getElementById(id+'_benjin_edit').style.display='block';
		//实付利息
		document.getElementById('sflx_'+id).value=document.getElementById(id+'_sflx_show').innerHTML;
        document.getElementById(id+'_sflx_show').style.display='none';
        document.getElementById(id+'_sflx_edit').style.display='block';
    }else if(type==2){
		//预计付款日
        document.getElementById(id+'_time_show').style.display='block';
        document.getElementById(id+'_time_edit').style.display='none';  
        //付息状态
        document.getElementById(id+'_paixi_show').style.display='block';
        document.getElementById(id+'_paixi_edit').style.display='none';  
        //本金状态
        document.getElementById(id+'_benjin_show').style.display='block';
        document.getElementById(id+'_benjin_edit').style.display='none'; 
		//实付利息
		document.getElementById(id+'_sflx_show').style.display='block';
        document.getElementById(id+'_sflx_edit').style.display='none'; 
    }  
    
}
function Save_paymentSchedule(id,sid,seq,total){


    var time=document.getElementById('time_'+id).value;
    var paixi=document.getElementById('paixi_'+id).value;
    var benjin=document.getElementById('benjin_'+id).value;
	var sflx = document.getElementById('sflx_'+id).value;
    
    var accountname =ld('#accountname').val();
    var cf_1522 = ld('#cf_1522').val();
    var salesorder_no = ld('#salesorder_no').val();
    var cf_1523 = ld('#cf_1523value').val();
    var begin_date=ld("#begin_date").val();
    var begin_date2=ld("#begin_date2").val();
    var begin_date3 = ld('#begin_date3').val();
    var url='module='+pageto_module+'&action='+pageto_module+'Ajax&reportmodule=Comprehensivereport&file=PaymentScheduleReport&Report_form_query=true&type=save&time='
    +time+'&paixi='+paixi+'&benjin='+benjin+'&id='+sid+'&qici='+seq+'&accountname='
   +accountname+'&cf_1522='+cf_1522+'&salesorder_no='+salesorder_no+'&begin_date='
   +begin_date+'&begin_date2='+begin_date2+'&begin_date3='+begin_date3+'&cf_1523='+cf_1523+'&total='+total+'&sflx='+sflx;
    //zkt 20231011 XUQIU1001341 SQL注入
    ldAjaxHtml('index.php?',url,function(response) {
        DelProgressObjs();
        document.getElementById(id+'_time_show').innerHTML=document.getElementById('time_'+id).value;
        document.getElementById(id+'_time_show').style.display='block';
        document.getElementById(id+'_time_edit').style.display='none';

        document.getElementById(id+'_paixi_show').innerHTML=document.getElementById('paixi_'+id).value;
        document.getElementById(id+'_paixi_show').style.display='block';
        document.getElementById(id+'_paixi_edit').style.display='none';

        document.getElementById(id+'_benjin_show').innerHTML=document.getElementById('benjin_'+id).value;
        document.getElementById(id+'_benjin_show').style.display='block';
        document.getElementById(id+'_benjin_edit').style.display='none';
        //实付利息
        document.getElementById(id+'_sflx_show').innerHTML=document.getElementById('sflx_'+id).value;
        document.getElementById(id+'_sflx_show').style.display='block';
        document.getElementById(id+'_sflx_edit').style.display='none';
        document.getElementById('checksms').innerHTML=response;
    });
}
function Save_SendpaymentSchedule(id,sid,seq,total){

    var time=document.getElementById('time_'+id).value;
    var paixi=document.getElementById('paixi_'+id).value;
    var benjin=document.getElementById('benjin_'+id).value;
    
    var vendorname =ld('#vendorname').val();
    var cf_1527 = ld('#cf_1527').val();
    var purchaseorder_no = ld('#purchaseorder_no').val();
    var cf_1528 = ld('#cf_1528value').val();
    var begin_date=ld("#begin_date").val();
    var begin_date2=ld("#begin_date2").val();
    var begin_date3 = ld('#begin_date3').val();
    var url='module='+pageto_module+'&action='+pageto_module+'Ajax&reportmodule=Comprehensivereport&file=SendPaymentScheduleReport&Report_form_query=true&type=save&ajax=true&time='
    +time+'&paixi='+paixi+'&benjin='+benjin+'&id='+sid+'&qici='+seq+'&vendorname='
   +vendorname+'&cf_1528='+cf_1528+'&purchaseorder_no='+purchaseorder_no+'&begin_date='
   +begin_date+'&begin_date2='+begin_date2+'&begin_date3='+begin_date3+'&cf_1527='+cf_1527+'&total='+total;
    //zkt 20231011 XUQIU1001341 SQL注入
    ldAjaxHtml('index.php?',url,function(response) {
        DelProgressObjs();
        document.getElementById(id+'_time_show').innerHTML=document.getElementById('time_'+id).value;
        document.getElementById(id+'_time_show').style.display='block';
        document.getElementById(id+'_time_edit').style.display='none';

        document.getElementById(id+'_paixi_show').innerHTML=document.getElementById('paixi_'+id).value;
        document.getElementById(id+'_paixi_show').style.display='block';
        document.getElementById(id+'_paixi_edit').style.display='none';

        document.getElementById(id+'_benjin_show').innerHTML=document.getElementById('benjin_'+id).value;
        document.getElementById(id+'_benjin_show').style.display='block';
        document.getElementById(id+'_benjin_edit').style.display='none';
        document.getElementById('checksms').innerHTML=response;
    });
}
function tiqian_paymentSchedule(id,sid,seq){
   var accountname =ld('#accountname').val();
   var cf_1522 = ld('#cf_1522').val();
   var salesorder_no = ld('#salesorder_no').val();
   var cf_1523 = ld('#cf_1523value').val();
   var begin_date=ld("#begin_date").val();
   var begin_date2=ld("#begin_date2").val();
   var begin_date3 = ld('#begin_date3').val();
    var time=document.getElementById(id+'_time_show').innerHTML;
    var paixi=document.getElementById(id+'_paixi_show').innerHTML;
    var benjin=document.getElementById(id+'_benjin_show').innerHTML;
    var url='module='+pageto_module+'&action='+pageto_module+'Ajax&reportmodule=Comprehensivereport&file=PaymentScheduleReport&Report_form_query=true&ajax=true&type=tiqian&time='
    +time+'&paixi='+paixi+'&benjin='+benjin+'&id='+sid+'&qici='+seq+'&accountname='
   +accountname+'&cf_1522='+cf_1522+'&salesorder_no='+salesorder_no+'&begin_date='
   +begin_date+'&begin_date2='+begin_date2+'&begin_date3='+begin_date3+'&cf_1523='+cf_1523;
    //zkt 20231011 XUQIU1001341 SQL注入
    ldAjaxHtml('index.php?',url,function(response) {
        DelProgressObjs();
        document.getElementById('checksms').innerHTML=response;
    });
}
function search_paymentschedule(action){
	var accountname =ld('#accountname').val();
	var cf_1522 = ld('#cf_1522').val();
	var salesorder_no = ld('#salesorder_no').val();
	var cf_1523 = ld('#cf_1523value').val();
	var begin_date=ld("#begin_date").val();//进款日期
	var begin_date2=ld("#begin_date2").val();//项目启动日期
	var begin_date3 = ld('#begin_date3').val();//本金到期日期
	var begin_date4 = '';
	//在付款明细表中，添加“预计付款日”过滤条件，请参考举例表单。							
	if(ld('#begin_date4') != undefined){
		begin_date4 = ld('#begin_date4').val();//预计付款日
	}
   var url='module='+pageto_module+'&action='+pageto_module+'Ajax&reportmodule=Comprehensivereport&file='+action+'&Report_form_query=true&ajax=true&accountname='
   +accountname+'&cf_1522='+cf_1522+'&salesorder_no='+salesorder_no+'&begin_date='
   +begin_date+'&begin_date2='+begin_date2+'&begin_date3='+begin_date3+'&cf_1523='+cf_1523+'&begin_date4='+begin_date4;
	var cf_1539='';var cf_1541='';var cf_1540='';var cf_1542='';
	if(ld('#cf_1539') != undefined){
		cf_1539 = ld('#cf_1539value').val();//归属团队
		url += '&cf_1539='+cf_1539;
	}
	if(ld('#cf_1541') != undefined){
		cf_1541 = ld('#cf_1541value').val();//理财产品
		url += '&cf_1541='+cf_1541;
	}
	if(ld('#cf_1540') != undefined){
		cf_1540 = ld('#cf_1540value').val();//隶属
		url += '&cf_1540='+cf_1540;
	}
	if(ld('#cf_1542') != undefined){
		cf_1542 = ld('#cf_1542value').val();//代持人
		url += '&cf_1542='+cf_1542;
	}
    //zkt 20231011 XUQIU1001341 SQL注入
    ldAjaxHtml('index.php?',url,function(response) {
        DelProgressObjs();
        document.getElementById('checksms').innerHTML=response;
    });
}

function tiqian_SendpaymentSchedule(id,sid,seq){
    var vendorname =ld('#vendorname').val();
    var cf_1527 = ld('#cf_1527').val();
    var purchaseorder_no = ld('#purchaseorder_no').val();
    var cf_1528 = ld('#cf_1528value').val();
   var begin_date=ld("#begin_date").val();
   var begin_date2=ld("#begin_date2").val();
   var begin_date3 = ld('#begin_date3').val();
    var time=document.getElementById(id+'_time_show').innerHTML;
    var paixi=document.getElementById(id+'_paixi_show').innerHTML;
    var benjin=document.getElementById(id+'_benjin_show').innerHTML;
    var url='module='+pageto_module+'&action='+pageto_module+'Ajax&reportmodule=Comprehensivereport&file=SendPaymentScheduleReport&Report_form_query=true&ajax=true&type=tiqian&time='
    +time+'&paixi='+paixi+'&benjin='+benjin+'&id='+sid+'&qici='+seq+'&vendorname='
   +vendorname+'&cf_1528='+cf_1528+'&purchaseorder_no='+purchaseorder_no+'&begin_date='
   +begin_date+'&begin_date2='+begin_date2+'&begin_date3='+begin_date3+'&cf_1527='+cf_1527;
    //zkt 20231011 XUQIU1001341 SQL注入
    ldAjaxHtml('index.php?',url,function(response) {
        DelProgressObjs();
        document.getElementById('checksms').innerHTML=response;
    });
}
function search_Sendpaymentschedule(action){
   var vendorname =ld('#vendorname').val();
   var cf_1527 = ld('#cf_1527').val();
   var purchaseorder_no = ld('#purchaseorder_no').val();
   var cf_1528 = ld('#cf_1528value').val();
   var begin_date=ld("#begin_date").val();
   var begin_date2=ld("#begin_date2").val();
   var begin_date3 = ld('#begin_date3').val();

   var url='module='+pageto_module+'&action='+pageto_module+'Ajax&reportmodule=Comprehensivereport&file='+action+'&Report_form_query=true&ajax=true&vendorname='
   +vendorname+'&cf_1528='+cf_1528+'&purchaseorder_no='+purchaseorder_no+'&begin_date='
   +begin_date+'&begin_date2='+begin_date2+'&begin_date3='+begin_date3+'&cf_1527='+cf_1527;
    //zkt 20231011 XUQIU1001341 SQL注入
    ldAjaxHtml('index.php?',url,function(response) {
        DelProgressObjs();
        document.getElementById('checksms').innerHTML=response;
    });
}
function set_export(){
    document.getElementById('export').value='yes';

}

function set_noexport(){
    document.getElementById('export').value='';

}

function yijiapopup1(id,type)
{
    var url='module='+pageto_module+'&action='+pageto_module+'Ajax&reportmodule=Comprehensivereport&file=yijiapopup1&Report_form_query=true&ajax=true&salesorderid='+id+'&type='+type;
    //zkt 20231011 XUQIU1001341 SQL注入
    ldAjaxHtml('index.php?',url,function(response) {
        DelProgressObjs();
        ld("#divSendInform_div").innerHTML=response.responseText;
        fnvshobj(this,'divSendInform');
    });
}

function Comprehensive_windowsopen(url,target,feature){
    if(url == undefined || url == ''){
        return false;
    }
    if(target == undefined ){
        target == ''
    }
    if(feature == undefined ){
        feature == ''
    }
    //zkt 20231011 XUQIU1001341 SQL注入
    url= cls_encryptyurl.Puyoung_Encryptyurl(url,'');
    window.open(url,target,feature);
}