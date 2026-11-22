<script language="javascript" type="text/javascript" src="include/js/ubox_web/uboxweb.js"></script>
{assign var='phonice' value='55'|@getSys_deploy}
<span>
<OBJECT ID="Phonic_usb" WIDTH="" HEIGHT="" CLASSID="CLSID:BB4780D9-391E-41B5-B366-434ADCFD7D10" ></OBJECT>
</span>
<SCRIPT   LANGUAGE="javascript"  type = "text/javascript" FOR="Phonic_usb"   EVENT=PlugIn(uboxHandle)  >  
Ubox_Plug_In(uboxHandle)
</SCRIPT>

<SCRIPT   LANGUAGE="javascript"  type = "text/javascript"  FOR="Phonic_usb"   EVENT=HookOff(uboxHandle)  >  
Ubox_hookoff(uboxHandle)
</SCRIPT>

<SCRIPT   LANGUAGE="javascript"  type = "text/javascript"  FOR="Phonic_usb"   EVENT=HangUp(uboxHandle) >  
Ubox_hookon(uboxHandle)
</SCRIPT>

<SCRIPT   LANGUAGE="javascript"  type = "text/javascript"  FOR="Phonic_usb"   EVENT=CallId(uboxHandle,callerNumber,callerTime,callerName)  >  
Ubox_CallId(uboxHandle,callerNumber,callerTime,callerName)
</SCRIPT> 

<SCRIPT   LANGUAGE="javascript"  type = "text/javascript"  FOR="Phonic_usb"   EVENT=DeviceAlarm(uboxHandle)  >  
ubox_DeviceAlarm(uboxHandle)
</SCRIPT> 

<SCRIPT   LANGUAGE="javascript"  type = "text/javascript"  FOR="Phonic_usb"   EVENT=DeviceError(uboxHandle)  >  
ubox_DeviceError(uboxHandle)
</SCRIPT> 

<SCRIPT   LANGUAGE="javascript"  type = "text/javascript"  FOR="Phonic_usb"   EVENT=DtmfKey(uboxHandle,dtmfCode) >  
ubox_DtmfKey(uboxHandle,dtmfCode)
</SCRIPT> 

<SCRIPT   LANGUAGE="javascript"  type = "text/javascript"  FOR="Phonic_usb"   EVENT=HangIng(uboxHandle)  >  
ubox_HangIng(uboxHandle)
</SCRIPT> 

<SCRIPT   LANGUAGE="javascript"  type = "text/javascript"  FOR="Phonic_usb"   EVENT=LineVoltage(uboxHandle,voltage)  >  
ubox_LineVoltage(uboxHandle,voltage)
</SCRIPT> 

<SCRIPT   LANGUAGE="javascript"  type = "text/javascript"  FOR="Phonic_usb"   EVENT=PlayEnd(uboxHandle)  >  
ubox_PlayEnd(uboxHandle)
</SCRIPT> 

<SCRIPT   LANGUAGE="javascript"  type = "text/javascript"  FOR="Phonic_usb"   EVENT=PlayError(uboxHandle)  >  
ubox_PlayError(uboxHandle)
</SCRIPT> 

<SCRIPT   LANGUAGE="javascript"  type = "text/javascript"  FOR="Phonic_usb"   EVENT=PlugOut(uboxHandle)  >  
ubox_PlugOut(uboxHandle)
</SCRIPT>

<SCRIPT   LANGUAGE="javascript"  type = "text/javascript"  FOR="Phonic_usb"   EVENT=Ring(uboxHandle)  >  
ubox_Ring(uboxHandle)
</SCRIPT>


<SCRIPT   LANGUAGE="javascript"  type = "text/javascript"  FOR="Phonic_usb"   EVENT=RingCancel(uboxHandle)  >  
ubox_RingCancel(uboxHandle)
</SCRIPT>

<SCRIPT   LANGUAGE="javascript"  type = "text/javascript"  FOR="Phonic_usb"   EVENT=RingStop(uboxHandle) >  
ubox_RingStop(uboxHandle)
</SCRIPT>

<SCRIPT   LANGUAGE="javascript"  type = "text/javascript"  FOR="Phonic_usb"   EVENT=StreamVoice(uboxHandle, pVoice, size)  >  
//alert("电话挂机")
</SCRIPT>

<SCRIPT   LANGUAGE="javascript"  type = "text/javascript"  FOR="Phonic_usb"   EVENT=ToneBusy(uboxHandle)  >  
ubox_ToneBusy(uboxHandle)
</SCRIPT>

<SCRIPT LANGUAGE="JavaScript" FOR="window" EVENT="onLoad()">
<!--
ubox_CloseDevice();
ubox_openDevice();
-->
</SCRIPT> 
<SCRIPT LANGUAGE="JavaScript" FOR="window" EVENT="onunLoad()">
<!--
ubox_CloseDevice();
-->
</SCRIPT> 

