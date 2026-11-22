function DateTime(datevalue)
{    
    this.datevalue=datevalue;
}
DateTime.FormatStr=
{
    'Date' : "YYYY-mm-dd",
    'DateTime':"YYYY-mm-dd hh:mm:ss",
    'Time':"hh:mm:ss",
    'ShortTime':"hh:mm"
}

/**
edit:can
reason:日期添加天数,月份，年，小时，分钟，
**/
DateTime.prototype.addNumber=function(number,type)
{
    this.datevalue = this.datevalue.replace(/-/g,"/"); //更改日期格式  
    var d=new Date(this.datevalue);
    switch(type.toLowerCase()){
        case 'day':
            if(navigator.userAgent.indexOf("MSIE")>0)//ie
            {
                d = d.valueOf();  
                d = d + number * 24 * 60 * 60 * 1000;  
                d=new Date(d);
                var m=d.getMonth()+1;
                this.datevalue=d.getFullYear()+'-'+m+'-'+d.getDate()+" "+ d.getHours()+":"+d.getMinutes()+":"+d.getSeconds();
            }
            else
            {
                d.setDate(d.getDate()+parseInt(number,10));
                var m=d.getMonth()+1;
                this.datevalue=d.getFullYear()+'-'+m+'-'+d.getDate()+" "+ d.getHours()+":"+d.getMinutes()+":"+d.getSeconds();
             
            }
            break;
        case 'month':
            d.setMonth(d.getMonth()+parseInt(number,10));
            var m=d.getMonth()+1;
            this.datevalue=d.getFullYear()+'-'+m+'-'+d.getDate()+" "+ d.getHours()+":"+d.getMinutes()+":"+d.getSeconds();
            //this.datevalue=this.addmulMonth(this.datevalue,number);
            break;
        case 'year':
            d.setYear(d.getFullYear()+parseInt(number,10));
            var m=d.getMonth()+1;
            this.datevalue=d.getFullYear()+'-'+m+'-'+d.getDate()+" "+ d.getHours()+":"+d.getMinutes()+":"+d.getSeconds();
            break; 
        case 'hour':
            this.addHours(number);
            break;
        case 'minute':
            this.addMinutes(number);
            break;
        case 'second':
            this.addSeconds(number);
            break;
    }
    return this.datevalue;
}
/**
edit:can
reason:时间添加小时
**/
DateTime.prototype.addHours=function(hours)
{
    var d=new Date(this.datevalue);
    d.setHours(d.getHours()+parseInt(hours,10));
    var m=d.getMonth()+1;
    this.datevalue=d.getFullYear()+'-'+m+'-'+d.getDate()+" "+ d.getHours()+":"+d.getMinutes()+":"+d.getSeconds();
    return this.datevalue;
}
/**
edit:can
reason:时间添加分钟
**/
DateTime.prototype.addMinutes=function(mintues)
{   
    var d=new Date(this.datevalue);
    d.setMinutes(d.getMinutes()+parseInt(mintues,10));
    var m=d.getMonth()+1;
    this.datevalue=d.getFullYear()+'-'+m+'-'+d.getDate()+" "+ d.getHours()+":"+d.getMinutes()+":"+d.getSeconds();
    return this.datevalue;
}
/**
edit:can
reason:时间添加秒
**/
DateTime.prototype.addSeconds=function(seconds)
{
    var d=new Date(this.datevalue);
    d.setSeconds(d.getSeconds()+parseInt(seconds,10));
    var m=d.getMonth()+1;
    this.datevalue=d.getFullYear()+'-'+m+'-'+d.getDate()+" "+ d.getHours()+":"+d.getMinutes()+":"+d.getSeconds();
    return this.datevalue;
}
/**
edit:can
reason:计算两个日期间隔天数
**/
DateTime.prototype.timeHourdiff=function(secondValue)
{
    var arrDate, objDate1, objDate2, intDays;
    if(secondValue==''|| this.datevalue=='')
    {
        return '';
    }
    var nextvalue=secondValue;
    this.datevalue=sta_str = (this.datevalue).replace(/-/g,"/");  
    var firstvalue=new Date(this.datevalue);
    this.datevalue=sta_str = (secondValue).replace(/-/g,"/");  
    secondValue=new Date(secondValue);
    intHours = parseFloat(Math.abs(firstvalue - secondValue) / 1000 / 60 / 60 ).toFixed(1);
    return intHours;
}
/**
edit:can
reason:计算两个日期间隔天数
**/
DateTime.prototype.diff=function(secondValue)
{
    var firstvalue=new Date(this.datevalue);
    secondValue=new Date(secondValue);
    var diffdays=(firstvalue.getTime()-secondValue.getTime())/(24 * 60 * 60 * 1000);
    return Math.abs(parseInt(diffdays,10));
}
/**
edit:can
reason:YYYY-mm-dd格式
**/
DateTime.prototype.dateStr=function()
{
    var str='';
    var strsplit=this.datevalue.split('-');
    var m=strsplit[1];
    if(parseInt(m,10)<10)
    {
        m="0"+m;
    }
    var day=strsplit[2].substr(0,2);
    if(parseInt(trim(day),10)<10)
    {
        day="0"+trim(day);
    }
    str=strsplit[0]+"-"+m+"-"+day;
    return str;
}
/**
edit:can
reason:HH:mm:ss格式
**/
DateTime.prototype.timeStr=function(){
    var strsplit=this.datevalue.split('-');
    var strtime=strsplit[2].substr(2);//获取时间字符串
    strsplit=strtime.split(':');
    var hours=strsplit[0];
    if(parseInt(hours)<10)
    {
        hours="0"+trim(hours);
    }
    var minutes=strsplit[1];
    if(parseInt(minutes)<10)
    {
        minutes="0"+minutes;
    }
    var seconds=strsplit[2];
    if(parseInt(seconds,10)<10)
    {
        seconds="0"+seconds;
    }
    var str=hours+":"+minutes+":"+seconds;
    return str;
}
/**
edit:can
reason:HH:mm 格式
**/
DateTime.prototype.shortTimeStr=function()
{
    var strsplit=this.datevalue.split('-');
    var strtime=strsplit[2].substr(2);//获取时间字符串
    strsplit=strtime.split(':');
    var hours=strsplit[0];
    if(parseInt(hours,10)<10)
    {
        hours="0"+hours;
    }
    var minutes=strsplit[1];
    if(parseInt(minutes)<10)
    {
        minutes="0"+minutes;
    }
    var seconds=strsplit[2];
    if(parseInt(seconds,10)<10)
    {
        seconds="0"+seconds;
    }
    var str=hours+":"+minutes;
    return str;
}
/**
edit:can
reason:日期格式化
**/
DateTime.prototype.FormatDate=function(format)
{     
    if(format==DateTime.FormatStr['Date'])
    {
        return this.dateStr();
    }
    else if(format==DateTime.FormatStr['Time'])
    {
        return this.timeStr();
    }
    else if(format==DateTime.FormatStr['DateTime'])
    {
        return this.dateStr()+" "+trim(this.timeStr());
    }
    else if(format==DateTime.FormatStr['ShortTime'])
    {
        return this.shortTimeStr();
    }
}