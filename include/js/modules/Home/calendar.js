// 默认是周一开始
var sundayStart = false;

// 当某月的天数
function getDaysInOneMonth(date) {
  const year = date.getFullYear();
  const month = date.getMonth() + 1;
  const d = new Date(year, month, 0);
  return d.getDate();
}

// 向前空几个
function getMonthweek(date) {
  const year = date.getFullYear();
  const month = date.getMonth() + 1;
  const dateFirstOne = new Date(year + '/' + month + '/1');
  return sundayStart ?
    dateFirstOne.getDay() == 0 ? 7 : dateFirstOne.getDay() :
    dateFirstOne.getDay() == 0 ? 6 : dateFirstOne.getDay() - 1;
}

/**
   * 获取当前日期上个月或者下个月
  */
function getOtherMonth(date, str = 'nextMonth') {
  const timeArray = this.dateFormat(date).split('/');
  const year = timeArray[0];
  const month = timeArray[1];
  const day = timeArray[2];
  let year2 = year;
  let month2;
  if (str === 'nextMonth') {
    month2 = parseInt(month) + 1;
    if (month2 == 13) {
      year2 = parseInt(year2) + 1;
      month2 = 1;
    }
  } else {
    month2 = parseInt(month) - 1;
    if (month2 == 0) {
      year2 = parseInt(year2) - 1;
      month2 = 12;
    }
  }
  let day2 = day;
  const days2 = new Date(year2, month2, 0).getDate();
  if (day2 > days2) {
    day2 = days2;
  }
  if (month2 < 10) {
    month2 = '0' + month2;
  }
  if (day2 < 10) {
    day2 = '0' + day2;
  }
  const t2 = year2 + '/' + month2 + '/' + day2;
  return new Date(t2);
}

// 上个月末尾的一些日期
function getLeftArr(date) {
  const arr = [];
  const leftNum = this.getMonthweek(date);
  const num = this.getDaysInOneMonth(this.getOtherMonth(date, 'preMonth')) - leftNum + 1;
  const preDate = this.getOtherMonth(date, 'preMonth');
  // 上个月多少开始
  for (let i = 0; i < leftNum; i++) {
    const nowTime = preDate.getFullYear() + '/' + (preDate.getMonth() + 1) + '/' + (num + i);
    arr.push({
      id: num + i,
      date: nowTime,
      isToday: false,
      otherMonth: 'preMonth',
    });
  }
  return arr;
}

// 下个月末尾的一些日期
function getRightArr(date) {
  const arr = [];
  const nextDate = this.getOtherMonth(date, 'nextMonth');
  const leftLength = this.getDaysInOneMonth(date) + this.getMonthweek(date);
  const _length = 7 - leftLength % 7;
  for (let i = 0; i < _length; i++) {
    const nowTime = nextDate.getFullYear() + '/' + (nextDate.getMonth() + 1) + '/' + (i + 1);
    arr.push({
      id: i + 1,
      date: nowTime,
      isToday: false,
      otherMonth: 'nextMonth',
    });
  }
  return arr;
}

// format日期
function dateFormat(date) {
  date = typeof date === 'string' ? new Date(date.replace(/\-/g, '/')) : date;
  return date.getFullYear() + '/' + (date.getMonth() + 1) + '/'
    + date.getDate();
}

// 获取某月的列表不包括上月和下月
function getMonthListNoOther(date) {
  const arr = [];
  const num = this.getDaysInOneMonth(date);
  const year = date.getFullYear();
  const month = date.getMonth() + 1;
  const toDay = this.dateFormat(new Date());

  for (let i = 0; i < num; i++) {
    const nowTime = year + '/' + month + '/' + (i + 1);
    arr.push({
      id: i + 1,
      date: nowTime,
      month: month,
      isToday: toDay === nowTime,
      otherMonth: 'nowMonth',
    });
  }
  return arr;
}

// 获取某月的列表 用于渲染
function getMonthList(date) {
  return [...this.getLeftArr(date), ...this.getMonthListNoOther(date), ...this.getRightArr(date)];
}
/*
* editor:ljj
* time:20240110
* reason:XUQIU1002379
* content:看板组件的长宽高适配，针对日程管理组件在工作台显示（直接借鉴纷享）
* node:获取date时间那周的日期
* */
function getWeekList(date){
  const arr = [];
  const day=date.getDate();
  const weekday=date.getDay()==0?7:date.getDay();
  const year = date.getFullYear();
  var month = date.getMonth()+1;
  const toDay = this.dateFormat(new Date());
  for (let i=0;i<7;i++){
    var otherMonth='';
    const now=new Date(year,(month-1),(day-weekday)+(i+1));
    const nowday=now.getDate();
    var nowmonth=now.getMonth()+1;
    const nowyear=now.getFullYear();
    const nowTime = nowyear + '/' + nowmonth + '/' + nowday;
    if (nowmonth<month){
      otherMonth='preMonth';
    }else if(nowmonth>month){
      otherMonth='nextMonth';
    }else if(nowmonth==month) {
      otherMonth='nowMonth';
    }
    arr.push({
      id: nowday,
      date: nowTime,
      month: nowmonth,
      isToday: toDay === nowTime,
      otherMonth: otherMonth,
    });
  }
  return arr;
}