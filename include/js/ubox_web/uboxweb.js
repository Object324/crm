
var  CODER_ALAW		= 0;
var  CODER_PCM		= 1;
var	 CODER_G729		= 3;
var	 CODER_SPEEX		= 20;
var	 CODER_ULAW		= 100;

var   UBOX_MODE_RECORD	= 0;		//录音模式， 通常使用的模式
var	  UBOX_MODE_DIAG		= 1;		//诊断模式， 用于捕获线路信息，供信号分析之用，支持的语音编码方式是CODER_PCM
var	  UBOX_MODE_CONFIG	= 2;		//配置模式，
var  hdl = -1;

var     UBOX_STATE_RESET     = 1;			//复位态，表示既非振铃也非摘机的状态。如果此前为振铃态，则此状态表示振铃已停止，如果此前为摘机态，则此状态表示已挂机。
var		UBOX_STATE_RINGING   = 2;			//振铃态，表示已检测到线路振铃信号，如果振铃停止，则将触发 UBOX_EVENT_RESET 事件，并汇报 UBOX_STATE_RESET 状态。
var		UBOX_STATE_HOOK_OFF  = 3;			//摘机态，
var		UBOX_STATE_HANG		 = 4;			  //悬空态，



function AppendStatus(szStatus)
{
	if(document.getElementById("StatusArea") != undefined){
		document.getElementById("StatusArea").value +=szStatus;
		document.getElementById("StatusArea").value +="\r\n";
	}
}

function Ubox_Plug_In(uboxhdl)
{
   hdl = uboxhdl;
   var outdata = "设备插入 句柄号:"+hdl;
  // document.getElementById('callcenterImg').style.display="";
   //alert('可以打了');
   //AppendStatus(outdata);

}

function Ubox_hookoff(uboxhdl)
{
  
   var outdata = "设备"+uboxhdl;

    AppendStatus(outdata+" 摘机");

  // AppendStatus(outdata);
}

function Ubox_hookon(uboxhdl)
{
   var outdata = "设备"+uboxhdl;

    AppendStatus(outdata+" 挂机");

}

function Ubox_CallId(uboxHandle,callerNumber,callerTime,callerName)
{
  
   var outdata = "设备"+uboxHandle+"号码："+callerNumber+"时间："+callerTime ;

    AppendStatus(outdata);

}


function ubox_Ring(uboxhdl)
{
   var outdata = "设备"+uboxhdl;

    AppendStatus(outdata+" 振铃");

}

function ubox_RingCancel(uboxhdl)
{
   var outdata = "设备"+uboxhdl;

    AppendStatus(outdata+" 振铃取消");

}

function ubox_RingStop(uboxhdl)
{
   var outdata = "设备"+uboxhdl;

    AppendStatus(outdata+" 停振");

}

function ubox_ToneBusy(uboxhdl)
{
   var outdata = "设备"+uboxhdl;

    AppendStatus(outdata+" 忙音");

}

function ubox_DeviceAlarm(uboxhdl)
{
   var outdata = "设备"+uboxhdl;

    AppendStatus(outdata+" 警告，重启软件");

}

function ubox_DeviceError(uboxhdl)
{
   var outdata = "设备"+uboxhdl;

    AppendStatus(outdata+" 错误，重启软件");

}

function ubox_DtmfKey(uboxHandle,dtmfCode)
{

   var outdata = "设备"+uboxHandle+"按键:"+(dtmfCode-48);

    AppendStatus(outdata);

}

function ubox_HangIng(uboxhdl)
{
   var outdata = "设备"+uboxhdl;

    AppendStatus(outdata+" 悬空");

}

function ubox_LineVoltage(uboxhdl,voltage)
{
   var outdata = "设备"+uboxhdl+"线路电压:"+voltage;

    AppendStatus(outdata);

}

function ubox_PlayEnd(uboxhdl)
{
   var outdata = "设备"+uboxhdl;

    AppendStatus(outdata+" 放音结束");

}

function ubox_PlugOut(uboxhdl)
{
   var outdata = "设备"+uboxhdl;

    AppendStatus(outdata+" 拨出");
   hdl=-1;

}

function ubox_PlayError(uboxhdl)
{
   var outdata = "设备"+uboxhdl;

    AppendStatus(outdata+" 放音错误");

}

function ubox_openDevice(id)
{

 try{
 	
 	var uChannelNum=Phonic_usb.OpenDevice(UBOX_MODE_RECORD);
 	if(uChannelNum== 0)
 	{
 		AppendStatus("打开设备成功");

 	}
	else
 	{
	 	AppendStatus("打开设备失败");		
 	}
 }catch(e)
 {
 }

}

function ubox_CloseDevice()
{
   if(document.all)
   {
        Phonic_usb.CloseDevice();
    	AppendStatus("关闭设备完成.");
   }
	

}


function ubox_RecordFile()
{

	var rec_name = "d:\\rec.wav";
	if(Phonic_usb.RecordFile(hdl,rec_name,CODER_ALAW) !=0)
	{
       AppendStatus("录音失败")
	}
	
}

function ubox_StopRecord()
{

	if(Phonic_usb.StopRecord(hdl) !=0)
	{
       AppendStatus("停止录音失败")
	}
}

function ubox_deviceClose()
{
	Phonic_usb.CloseDevice();
}



function ubox_playfile(szFile)
{
	uPlayFileID=Phonic_usb.PlayFile(hdl,szFile);
	if(uPlayFileID < 0)
	{
	 	AppendStatus("播放失败:"+szFile);	
	}else
	{
		AppendStatus("开始播放文件:"+szFile);
	}
}

function ubox_stopplay()
{
	Phonic_usb.StopPlay(hdl);
	AppendStatus("停止播放");
}

function ubox_dialnum(szCode)
{
	if(Phonic_usb.GetLineState(hdl) != UBOX_STATE_HOOK_OFF )
       alert('请摘起电话机');
    else
	{
	  if(Phonic_usb.SendDtmf(hdl,szCode) == 0)
	  {
		AppendStatus("拨号:"+szCode);
		return true;
	  }else
	  {
		alert('拨号失败');
	  }
	}
}


function ubox_Start_read_line_voltage()
{
  if(Phonic_usb.StartReadLineVoltage(hdl) == 0)
     AppendStatus("开始量线路电压成功");
  else
     AppendStatus("开始量线路电压失败");
}

function ubox_Stop_read_line_voltage()
{
  if(Phonic_usb.StopReadLineVoltage(hdl) == 0)
     AppendStatus("停止量线路电压成功");
  else
     AppendStatus("停止量线路电压失败");
}

function ubox_Get_DeviceVersion()
{
  var ver = Phonic_usb.GetDeviceVersionNum(hdl);
     AppendStatus("硬件版本号"+ver);

}

function ubox_Get_User()
{
  var use_num = Phonic_usb.GetUsernum(hdl);
     AppendStatus("用户号:"+use_num);
}

function ubox_read_eeprom()
{
   var read_data = Phonic_usb.ReadEepromex2(hdl,0,8);
     AppendStatus("读eepromEx:"+read_data);

}


function ubox_write_eeprom()
{
    var write_data = "A23456B9";
	if(Phonic_usb.WriteEepromex(hdl,0,write_data,8)==0)
	{
		AppendStatus("写eeprom成功");
	}
	else
	{
      AppendStatus("写eeprom失败");
	}
}

function ubox_hook_off()
{

         //fi3102A fi3101A 支持

	  if(Phonic_usb.SoftHookoff(hdl)==0)
       {
		AppendStatus("摘机成功");
       }
	   else
	   {
         AppendStatus("摘机失败");
	   }

}

function ubox_hook_on()
{
        //fi3102A fi3101A 支持
 	if(Phonic_usb.SoftHookon(hdl)==0)
       {
		AppendStatus("挂机成功");
       }
	   else
	   {
         AppendStatus("挂机失败");
	   }
	
}

 function   OCXRegistered(strID)
{  
  var   ocx=null;  
  try{  
      ocx=new   ActiveXObject(strID);  
     }catch(e){  
     return   false;  
    }  
  if(ocx!=null)
  {  
    ocx=null;  
    return   true;  
  }
  else  
     return   false;  
  }  