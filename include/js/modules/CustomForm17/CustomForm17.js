//2022/1/13 chj 东莞贺桃：滤芯的数量计算开发：在产品类别为“饮水机”的服务周期内，能根据不同滤芯的保养周期自动计算出所需要的滤芯数量
function setProductDetailQuantityForHetao(){
	var popupobj=CrmPopup.getPopupObj('last');
	var trobjs=popupobj.getTrObjsByDelType("no");//获取没有删除的行 
	var num = 0;
	ld.each(trobjs,function(tmprowindex,rowobj){
		var rowindex=ld(rowobj).attr("rowindex");
        var quantity = ld(rowobj).find(" [detailcolumnname=quantity]").val();	//数量
		var sf4987 = ld(rowobj).find(" [detailcolumnname=sf4987]").val();	//服务周期（年）
		if(empty(sf4987))sf4987 = 0;
		if(empty(quantity))quantity = 1;
		var productcategory = ld(rowobj).find(" [detailcolumnname=productcategory]").val();
		if(productcategory == '饮水机'){
			num += eval(quantity) * eval(sf4987);
		}
	});
	ld.each(trobjs,function(tmprowindex,rowobj){
		var rowindex=ld(rowobj).attr("rowindex");
		var baoyang_zhouqi = ld(rowobj).find(" [detailcolumnname=baoyang_zhouqi]").val();	//保养周期（个月）
		var productcategory = ld(rowobj).find(" [detailcolumnname=productcategory]").val();
		if(productcategory == '滤芯'){
			var sf4351 = ld(rowobj).find(" [detailcolumnname=sf4351]").val();	//已领取数量
			if(baoyang_zhouqi == 1){
				ld(rowobj).find(" [detailcolumnname=quantity]").val(num*12);
				ld(rowobj).find(" [detailcolumnname=sf4563]").val(num*12 - sf4351);
			}else if(baoyang_zhouqi == 2){
				ld(rowobj).find(" [detailcolumnname=quantity]").val(num*6);
				ld(rowobj).find(" [detailcolumnname=sf4563]").val(num*6 - sf4351);
			}else if(baoyang_zhouqi == 3){
				ld(rowobj).find(" [detailcolumnname=quantity]").val(num*4);
				ld(rowobj).find(" [detailcolumnname=sf4563]").val(num*4 - sf4351);
			}else if(baoyang_zhouqi == 4){
				ld(rowobj).find(" [detailcolumnname=quantity]").val(num*3);
				ld(rowobj).find(" [detailcolumnname=sf4563]").val(num*3 - sf4351);
			}else if(baoyang_zhouqi == 6){
				ld(rowobj).find(" [detailcolumnname=quantity]").val(num*2);
				ld(rowobj).find(" [detailcolumnname=sf4563]").val(num*2 - sf4351);
			}else if(baoyang_zhouqi == 12){
				ld(rowobj).find(" [detailcolumnname=quantity]").val(num);
				ld(rowobj).find(" [detailcolumnname=sf4563]").val(num - sf4351);
			}
			popupobj.fieldformulaobj.NoInput_FocusFormula(rowindex);
		}
	});
	popupobj.fieldformulaobj.CountsubTotal();
	setProductDetailBatchesForHetao();
}
//chj 2022/10/18 能不能再新建或编辑的界面上就可以默认，因为当有多台饮水机重复选择滤芯时，他要将饮水机总数量手动修改默认值进行分摊，不一定全部都是等于饮水机总和。
function setProductDetailBatchesForHetao(){
	var popupobj=CrmPopup.getPopupObj('last');
	var trobjs=popupobj.getTrObjsByDelType("no");//获取没有删除的行 
	var num = 0;
	ld.each(trobjs,function(tmprowindex,rowobj){
		var productcategory = ld(rowobj).find(" [detailcolumnname=productcategory]").val();
		var sf8860 = ld(rowobj).find(" [detailcolumnname=sf8860]").val();	//饮水机数量
		var quantity = ld(rowobj).find(" [detailcolumnname=quantity]").val();	//总数量
		if(productcategory == '饮水机'){
			num += eval(quantity);
		}
	});
	ld.each(trobjs,function(tmprowindex,rowobj){
		var rowindex=ld(rowobj).attr("rowindex");
		var productcategory = ld(rowobj).find(" [detailcolumnname=productcategory]").val();
		if(productcategory == '滤芯'){
			ld(rowobj).find(" [detailcolumnname=sf8646]").val(num);
			popupobj.fieldformulaobj.NoInput_FocusFormula(rowindex);
		}
	});
	popupobj.fieldformulaobj.CountsubTotal();
}
//chj 2022/8/24 贺桃客户需求：服务卡的新建或编辑界面选择“年保开始日期”后，则“年保到期日”默认为开始日期的一年后。（不要用触发器做，触发器必须点保存后才触发或者年保到期日不一定是一年后无法修改）
function hetao_date(fieldname,date_val){
	if(fieldname == 'cf_4682' && !empty(date_val)){
		var date=new Date(date_val);
		date.setFullYear(date.getFullYear()+1);
		date.setDate(date.getDate()-1);
		var next_year_tody = date.toLocaleDateString().split('/').join('-');
		var lettimes=next_year_tody.split('-');
		constYear=lettimes[0];
		constMonth=lettimes[1];
		constDay=lettimes[2];

		if(constMonth.length===1){

			mounth='0'+constMonth

		}else{

			mounth = constMonth

		}
		if(constDay.length===1){

			day='0'+constDay

		}else{

			day=constDay

		}
		constNewtoday=constYear+'-'+mounth+'-'+day;
		var popupobj=CrmPopup.getPopupObj("last");
		ld("#"+popupobj.divid+" [name=cf_4683]").val(constNewtoday);

	}
}