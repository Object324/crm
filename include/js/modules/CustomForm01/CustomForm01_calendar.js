function CustomForm01_calendar(type=''){
    var that=this;
    var myDate = new Date();
    var chooseDate = '';
    var workcanceldar = new Array();
    var last_click_month = '';

    that.intStart = function (){
        var textTopWeeks = '';
        var textTop = ["一", "二", "三", "四", "五", "六", "日"];
        if(current_language=="en"){
            textTop = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
        }
        for(i=0;i<textTop.length;i++){
            textTopWeeks += "<div class='wh_content_item'>";
            textTopWeeks += "<div class='wh_top_tag'>"+textTop[i]+"</div>";
            textTopWeeks += "</div>";
        }
        ld(' .wh_content_weeks').html(textTopWeeks);
        //加载日历js
        getScriptBackWithURL('include/js/modules/Home/calendar.js',function(){
            that.getDataList();
        });
        // 上月
        ld(' .wh_top_changge li:first-child').unbind('click');
        ld(' .wh_top_changge li:first-child').click(function(){
            that.myDate = dateFormat(that.myDate);
            that.myDate = getOtherMonth(that.myDate, "preMonth");
            workcanceldar = new Array();
            chooseDate = '';
            last_click_month = '';
            that.dateclick = true;
            that.getDataList();
        });
        // 下月
        ld(' .wh_top_changge li:last-child').unbind('click');
        ld(' .wh_top_changge li:last-child').click(function(){
            that.myDate = dateFormat(that.myDate);
            that.myDate = getOtherMonth(that.myDate, "nextMonth");
            workcanceldar = new Array();
            chooseDate = '';
            last_click_month = '';
            that.dateclick = true;
            that.getDataList();
        });
    }

    that.setclickDate = function(date){
        date = date.replace(/-/g,'/');
        var myDate = new Date(date);
        that.myDate = myDate;
    }

    that.getDataList = function (){
        // 月份数组
        var month_en = new Array('Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec');
        //当前日期
        var myDate = that.myDate;
        var cur_year = myDate.getFullYear();
        var cur_month = myDate.getMonth() + 1;
        var cur_date = myDate.getDate();//@edit:zhouxiaomei,2020-09-10,reason:获取当前日期
        if(current_language=="en"){
            var dateTop = month_en[cur_month-1] +' '+ cur_year;
        }else{
            if(cur_month < 10)
                cur_month = '0'+cur_month;
            var dateTop = cur_year + '年' + cur_month + '月';
        }
        ld(' .wh_content_li').html(dateTop);
        ld(' .wh_content_li').attr('data-yearmonth',cur_year + '年' + cur_month + '月');
        //获取当前月所有日期
        var dayArr = getMonthList(that.myDate);
        //日期
        var textTopDays = '';
        if(that.dateclick){
            that.chooseDateClick(dateTop,cur_date);
        }
        for(var  i=0;i<dayArr.length;i++){
            textTopDays += "<div class='wh_content_item' tag='"+ dayArr[i]['date'] +"' otherMonth='"+ dayArr[i]['otherMonth'] +"'>";
            let days_class = '';
            let tag = '';
            if(dayArr[i]['otherMonth'] != 'nowMonth'){
                days_class = 'wh_other_dayhide';
            }else{
                tag = 'tag="'+dayArr[i]['id']+'"';
            }
            if(dayArr[i]['isToday']){
                days_class = 'wh_isToday';
            }
            textTopDays += "<div "+tag+" class='wh_item_date "+ days_class +"'>"+dayArr[i]['id']+"</div>";
            textTopDays += "</div>";
        }
        ld(' .wh_content_days').html(textTopDays);
        // 选择日期
        ld(' .wh_content_days .wh_content_item').click(function(){
            var  otherMonth = ld(this).attr('otherMonth');
            ld(' .wh_item_date').removeClass('wh_chose_day');
            if (otherMonth === "nowMonth") {
                let dateNum = ld(this).find(' .wh_item_date').attr('tag')
                that.chooseDateClick(dateTop,dateNum);
            }else if(otherMonth === "preMonth"){
                ld(' .wh_top_changge li:first-child').click();
            }else{
                ld(' .wh_top_changge li:last-child').click();
            }
            ld(this).find(' .wh_item_date').addClass('wh_chose_day');
        });
        that.dateclick = false;
    }
  
    that.chooseDateClick = function (dateTop,dateNum){
        var divid='ListViewContents';
        var urlstring = "module=CustomForm01&action=CustomForm01Ajax&file=ListView&date="+dateTop+"&frommodule=CustomForm01&dateNum="+dateNum;
        urlstring += "&ajax=yes";
        if (typeof $('search_url') != 'undefined' && $('search_url').value != '') {
            urlstring += $('search_url').value;
        }
    
	 	var listview_page=new ListView_Page('CustomForm01',urlstring,divid);
		listview_page.callback_fun=function() {
            if(document.getElementById('listview_advanced') != undefined){
                document.getElementById('listview_advanced').disabled = false;
            }
            // wym 230731 BUG0070337 圣拉维-档期预约-点击非当前月份的日期，两秒后选中效果自动消失
            ld(' .wh_content_days  .wh_content_item [tag=' + dateNum + ']').addClass("wh_chose_day");
        }
        listview_page.page();
    }
    
    that.setDateCount=function(daterowcount) {
        ld.each(daterowcount,function(index,rowcount){
            ld(' .wh_content_days  .wh_content_item [tag=' + index + ']').html(index + "<i class='wh_top_tag_spot'></i>");
            if(rowcount>1) {
                ld(' .wh_content_days  .wh_content_item [tag=' + index + ']').html(index + "<i class='wh_top_tag_spot' style='left: calc(50% - 8px);'></i> <i class='wh_top_tag_spot' style='left:calc(50% + 4px);'></i>");
            }
        })
    }

    that.setColor=function(colorarr){
         let color = colorarr;
         if( color!=undefined && color != '') {
            ld.each(color,function(index,item){
                ld(' .wh_content_days  .wh_content_item [tag=' + index + ']').addClass("wh_change_color");
                ld(' .wh_content_days  .wh_content_item [tag=' + index + ']').css("background-color",item);
            })
        }
    }
}