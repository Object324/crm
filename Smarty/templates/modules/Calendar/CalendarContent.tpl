<script src='include/js/component/fullcalendar/index.global.js'></script>
<script src='include/js/component/fullcalendar/locales-all.global.js'></script>

{*hzx 20231215 列表页面页签优化*}
<div name="ld-ui-tabs" style="width: 100%;overflow: visible;display: flex;border-bottom: 1px solid #eaeaea;">
  {include file='ListViewNavBar.tpl'}
  <div style="width: 100%">
      <div name="calendarSettings" style="text-align: center;float: right;height: 100%;display: flex;align-items: center;width: 180px;justify-content: flex-end;" href="javascript:;">
        <span>{'CalendarSettings'|@getFixedLabel}</span>
      </div>
  </div>
</div>
<div id='crm_calendar_parent' style="overflow-y: auto">
  <div id='crm_calendar'></div>
</div>
<script>
  var Listpagepopupobj=new CrmPopup();
  Listpagepopupobj.type="calendarview";
  Listpagepopupobj.pagetype="calendarview";
  Listpagepopupobj.refreshpage='no';
  //edit:can date:20200813 42352: （https://61mis.com/kfbtest [^]）客户问题（长沙友捷信息），日程管理->日历视图界面，点击日程数据后，无法查看详情。预期结果：可以进入对应日程查看详情界面（需要补丁）
  Listpagepopupobj.divid="pagecontent1";
  Listpagepopupobj.searchtype="";//基本查询和高级查询，32156: 单据列表：设置高级查询后，切换查看范围时，不清空高级查询条件
  Listpagepopupobj.url='{$LISTPAGEURL}';
  Listpagepopupobj.module='Calendar';
  Listpagepopupobj.clearHighSearch=true;
  // Listpagepopupobj.ajax=false;
  Listpagepopupobj.alloweditpage='{$alloweditpage}';// XUQIU20240709-03 后台设置-系统参数设置，系统参数增加“列表和详情页是否启用小编辑功能”
  CrmPopup.global_listPopupObj.push(Listpagepopupobj);

  var linkmodulecustom = '{$LINKMODULECUSTOM}';
  var languageType = "{$LANUGAGETYPE}";
  // ljj 20231226 XUQIU1002423 日历视图界面，“消息提醒显示设置”修改为“日历设置”，可自定义日周月默认值及默认时间（陈钦帅）
  var defaultDisplay= "{$DEFAULTDISPLAY}";//默认显示
  var defaultStartTime= "{$DEFAULTSTARTTIME}";//默认开始时间
  var defaultTimeSlot= "{$DEFAULTTIMESLOT}";//默认时间槽
  var calendarsettingsarr= {$calendarSettings};//下拉框选项
  {literal}
  ld(function() {
    if(languageType=="en"){
      var initialLocaleCode = 'en';
    }else{
      var initialLocaleCode = 'zh-cn';
    }
    //BUG20240801-42 ls 240801 日历视图界面，编辑下周的日程后，日历视图会自动变成本周的日程视图，应该停留在编辑的周
    var savedView = localStorage.getItem('calendarView');
    var savedDate = localStorage.getItem('calendarDate');

    var calendarEl = document.getElementById('crm_calendar');
    calendar = new FullCalendar.Calendar(calendarEl, {
      headerToolbar: {
        left: 'dayGridMonth timeGridWeek timeGridDay today',//calendar\index.php $display_arr
        center: 'title',
        right: 'prev,next',
      },
      // themeSystem: 'bootstrap5',//主题，需要加载主题js
      timeZone: 'local',
      // initialView: defaultDisplay,//日历视图默认显示周   老版本叫 defaultView
      initialView: savedView || defaultDisplay,
      initialDate: savedDate || new Date(),
      // 其他选项
      datesSet: function(dateInfo) {
        // 当视图或日期更改时保存它们
        localStorage.setItem('calendarView', dateInfo.view.type);
        localStorage.setItem('calendarDate', formatDateString(calendar.getDate()));
      },
      eventColor: 'rgreen',//事件颜色,事件标题前面的小圆圈颜色
      displayEventEnd:true,
      // height: '100%',
      locale: initialLocaleCode,
      slotMinTime: defaultStartTime,//设置日时间段    //BUG20240605-36 240605 起始时间按设置开始显示
      // slotMaxTime: '23:00',
      slotDuration: defaultTimeSlot, // 设置每个时间槽的时长
      scrollTime: defaultStartTime, // 设置滚动到的默认时间点
      // timeFormat: 'H:mm',
      // axisFormat: 'H:mm',
      navLinks:true, // 可以单击日/周名称来导航视图   右上角小数字,比如今天15号,点击15后进日视图
      allDaySlot:false,//周日视图 是否显示全天的事件内容区块
      dayMaxEvents: true,// allow "more" link when too many events   问题：进入详情页后,弹窗不会消失
      // overlap: true, // 参数用于控制事件在同一时间段是否允许重叠。该参数在事件排列和显示时起到重要作用(也可以放在具体的事件内容里去设置)
      /*dateClick: function(info) {//test  当用户单击日期或时间时触发。比如日视图下点击  跟select事件重复了。
        console.log("dateClick");
        console.log(info);
        // change the day's background color just for fun
        // info.dayEl.style.backgroundColor = 'red';
      },*/
      selectable: true,//是否允许用户通过单击或拖动选择日历中的对象，包括天和时间
      selectMirror: true,//是否在用户拖动时绘制“占位符”事件。(选中背景颜色会加深来突出显示)
      // selectOverlap:false,//确定是否允许用户选择事件占用的时间段
      selectOverlap: true, // 允许在已有事件的日期上创建新事件  //BUG20240409-33  ls 240410 要求放开
      /*selectOverlap:function (event){
        calendar.refetchEvents();
        return false;
      },*/
      // selectMinDistance:1,//默认0，鼠标按下后、允许选择之前，用户鼠标必须移动的最小距离。非零值对于区分所选内容和 dateClick 非常有用，可以和select事件区分开。
      select: function(arg) { //选择日期/时间时触发   allDay:true 或 false 选择是否发生在全天单元格上。如果选择全天单元格，它将没有时间或时区部分，例如2018-09-01
        var startdate = formatDateString(arg.start);
        var enddate = formatDateString(arg.end);

        var objparams=new CreatePagePopup.params();
        objparams.params['refreshpage']='no';
        CreatePagePopup.showpage("Calendar","&start_date="+ startdate+"&end_date="+ enddate+"&Create=true",objparams);
      },
      editable: true,//允许拖拽
      events:function(arg, callback){
        var popupobj = CrmPopup.getlastPopupObjByPageType('calendarview');
        var divobj = ld('#'+popupobj.divid);
        var params = {};
        //获取查看范围
        if (divobj.find("#SmOwnerSearchScope").val() != undefined){
          var searchscope = divobj.find("#SmOwnerSearchScope").val();
          if(searchscope == 'smowner_search_senior'){
            var senioruserid = divobj.find('#scope_senioruserids').val();
            params['senioruserid'] = senioruserid;
          }
          params['SearchScope'] = searchscope;
        }
        //获取查询分类
        if (divobj.find('[name=viewname]').length > 0){
          var viewid = divobj.find('[name=viewname]').val();
          params['viewid'] = viewid;
          params['viewname'] = viewid;
        }


        //获取高级查找
        if (!popupobj.clearHighSearch){
          // var advft_criteria = divobj.find('[name=advft_criteria]').val();
          var advft_criteria = popupobj.advft_criteria;
          if (advft_criteria != '') {
            // var advft_criteria_groups = divobj.find('[name=advft_criteria_groups]').val();
            var advft_criteria_groups = popupobj.advft_criteria_groups;
            params['input'] = {'advft_criteria': advft_criteria,'advft_criteria_groups':advft_criteria_groups,'searchtype':'advance'}
          }
        }else {
          params['clearHighSearch'] = 'yes';
        }

        // console.log(arg);
        var url = "index.php?module=Calendar&action=CalendarAjax&file=getEventSources";
        params['start'] = formatDateString(arg.startStr);
        params['end'] = formatDateString(arg.endStr);
        ldAjax(url,params,function (data) {
          if (data.code == 1){
            var events =[];
            if(data.result.lst != null && data.result.lst.length>0){
              ld.each(data.result.lst,function(index,term){
                events.push({
                  overlap: false,
                  id:term.id,
                  start:term.start,
                  end:term.end,
                  title:term.title,
                  className:'fc-daygrid-dot-event-new',
                  allDay:false,//term.allDay, 需要判断后设置，如果都设为true，则周视图、日视图，不属于全天事件的就不显示了，设为true，全天事件也不显示了//BUG20240108-72 20240108 开启全天事件后,火狐浏览器界面异常,故先恢复到之前的版本设置
                  backgroundColor: term.backgroundColor,
                  textColor: term.textColor,
                  // display: 'background',//显示为背景突出显示的事件
                  // editable:true  //事件是否可编辑，可编辑是指可以移动, 改变大小等
                })
              });
            }
            divobj.find('#SearchContent').remove();
            divobj.find('.fc-header-toolbar .fc-toolbar-chunk:first').append(data.result.SearchContent);
            if (data.result.highsearchpopup_content != undefined){//加载高级查找
              divobj.find('#HighSearch_td').html(data.result.highsearchpopup_content);
              popupobj.clearHighSearch = false;
            }
            divobj.find("#showselectsearchscope_new").css("position","absolute").css("padding","0").css("top","67px").css("left","235px");
            divobj.find('.fc-header-toolbar .fc-toolbar-chunk:first').find('button').unbind('click').bind('click',function () {
              setCalenderHeight('');
            });
            divobj.find(' .fc-toolbar-chunk').css({'display':'flex','flex-direction':'row','align-items':'center'});
            divobj.find(' #showselectsearchscope_new').css({'position':'unset','display':'flex','align-items':'center'});
            //查询分类下拉框
            divobj.find('#shujufenlei_new_optionlistbg').css('z-index',999);

            //zxm  2021-0702 日程管理增加单据提醒
            if(data.result.listRemind.length>0) {
              ld.each(data.result.listRemind, function (idx, item) {
                events.push({
                  overlap: false,
                  id: 0,
                  record: item.record,
                  module: item.module,
                  start: item.start,
                  end: item.end,
                  title: item.content,
                  allDay: false, //其他模块单据不需要拖动
                  backgroundColor: item.backgroundColor,
                  editable:false,//其他模块单据不需要拖动
                })
              });
            }
            callback(events);
            setCalenderHeight(calendar.view.type);//name已经不用了改用type
          }
          DelProgressObjs();
        })

      },
      eventDidMount: function(info) {
        //BUG20240522-27 ls 240522 自定义颜色，全天事件生效，非全天事件不生效。
        // 设置事件背景颜色
        info.el.style.backgroundColor = info.event.backgroundColor;
        // 根据事件的 textColor 属性设置字体颜色
        info.el.style.color = info.event.textColor;
      },
      /*eventDrop:function (info){//当用户拖动事件到日历的不同位置时触发。被eventChange事件包含
        console.log("eventDrop");
        console.log(info);
      },
      eventResize:function (info){//当用户调整事件的持续时间时触发。被eventChange事件包含
        console.log("eventResize");
        console.log(info);
      },*/
      // 当事件被更改时触发
      eventChange: function(arg) {
        //更新单据开始结束时间
        var recordid = arg.event.id;
        if (recordid > 0) {
          var startdate = formatDateString(arg.event.start);//arg.event.startStr 也可以
          var enddate = formatDateString(arg.event.end);
          var urlstring = "index.php?module=Calendar&action=CalendarAjax&file=EditView&mode=eventChange";
          ldAjaxNoProgress(urlstring,{start_date: startdate,end_date: enddate,record: recordid},function(data){
          })
        }

      },
      eventClick:function(arg){
        var customParam = arg.event.extendedProps;// 自定义的参数集合
        if(arg.event.id > 0){
          DetailViewPage.showpage('Calendar',arg.event.id,'',{});
        }else{
          //zxm  2021-07-02 其他的是提醒  各自打开单据详情   日程管理增加单据提醒
          DetailViewPage.showpage(customParam.module,customParam.record,'',{});
        }

        // var popupobj=CrmPopup.getPopupObj('last');
        // ld("#"+popupobj.divid).css("z-Index", 10000);
      },
      // 视图渲染后的回调函数
      viewDidMount: function(arg) {
        // 获取当前视图类型
        var currentViewType = arg.view.type;
        console.log(arg.view);
        // console.log('当前视图类型：', currentViewType);

        var startDate = arg.view.currentStart;
        var endDate = arg.view.currentEnd;

        console.log('本月开始日期：', startDate);
        console.log('本月结束日期：', endDate);
      }

    });

    calendar.render();
    // calendar.changeView('timeGridDay');
    setCalenderHeight('');

  });

// ljj 20231226 XUQIU1002423 日历视图界面，“消息提醒显示设置”修改为“日历设置”，可自定义日周月默认值及默认时间（陈钦帅）
//加载下拉框
if(!empty(calendarsettingsarr)){
  setCalendarSettingsSelect(calendarsettingsarr);
}
function updateEventData(){
  //33003: 日程管理-日历视图--“日周月”界面： 新增日程管理弹出层，保存后不要进入明细界面，应该留在当前界面
  $("status").style.display="none";
  // ld('#crm_calendar').fullCalendar('refetchEvents');
  calendar.refetchEvents();

  var popupobj=CrmPopup.getPopupObj("last");//编辑页
  popupobj.CancelEvent();
  return false;
}


function setCalenderHeight(type){
  ld('body').css('overflow','hidden');
  // setTimeout(function() {
     var a = 55,//头部高度
     b = ld('[name=ld-ui-tabs]').outerHeight(),
     c = ld('.fc-toolbar').outerHeight(),//筛选高度
     d_height = 0,
     s_height = ld(window).height();

     if(b==null) b=0;
     if(c==null) c=0;
     d_height = s_height-a-b-c;
     ld('#crm_calendar').css('height',d_height-60);
     ld('#crm_calendar_parent').css('height',d_height+30);
    ld('.fc-scrollgrid-liquid').find("tbody:first").css('overflow-y','auto');//日历的tbody
    ld('.fc-scrollgrid-liquid').find("tbody:first").css('height',d_height-60);
     // if(type == 'dayGridMonth'){
       ld('.fc-scrollgrid-liquid').find("tbody:first").find("thead").css('overflow-y','scroll');
       ld('.fc-scrollgrid-liquid').find("tbody:first").find("thead").css('margin-right','0px');
     // }

    // calendar.updateSize(); //自动调整窗口大小
    calendar.scrollToTime(defaultStartTime);

  // }, 500);
}

// 创建格式化日期的函数
function formatDateString(dateobj) {
  var date= new Date(dateobj);

  const year = date.getFullYear();
  const month = (date.getMonth() + 1).toString().padStart(2, '0');
  const day = date.getDate().toString().padStart(2, '0');
  const hours = date.getHours().toString().padStart(2, '0');
  const minutes = date.getMinutes().toString().padStart(2, '0');
  const seconds = date.getSeconds().toString().padStart(2, '0');

  return `${year}-${month}-${day} ${hours}:${minutes}:${seconds}`;
}


{/literal}
</script>