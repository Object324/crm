

<form name="EditView">
<script language="JavaScript" type="text/javascript" src="include/language/{$LANUGAGETYPE}.js"></script>
<div style="background-color: #FFF;padding:10px;" >{*f0f4fc*}
        <table class="DetailContentTable linefeed" width="100%" style="border: 0px; margin: 0px auto;" cellpadding="0" border="0">
            <tr style="background-color: #FFF;">
                <td width="5%" class=" " align="left">
                    <font color="red"></font>{$fieldlabels['projectid']}：
                </td>
                <td width="20%" align="left"  class="DetailedTd2Info">
                    <input name="projectid_name" fieldname="projectid" id = "projectid_name" type="text"   value="{$projectinfo['projectname']}"{if $projectinfo['projectname'] neq ''}style="cursor: not-allowed;" disabled="disabled" {/if} class="commonDetailedTextBox gwidth70 bgwhite"  onkeyup="getKeyWords(this,1,'Project',event)" onkeypress="userEnterKey(getKeyWords,[this,1,'Project',event],event)"     autocomplete="off" >
                    <input id="projectid" name="projectid" type="hidden" onchange="getaccountsByprojectid(this)" value="{$projectinfo['projectid']}" >
                    {if $ischoseproject neq 'no'}
                        <a class="icon-homeimg icon-select" href="javascript:;" title="{'SELECT'|@getFixedLabel}" onclick='showrelatedlist("ProjectTask","Project","qc","","projectid");'></a>
                        <input class="icon-homeimg icon-clear inpb-reset" type="button" title="{'CLEAR'|@getFixedLabel}" onclick="clear_relatedfielddata('Project','projectid','projectid_name','projectname','ProjectTask','popupselectfield');return false;"/>
                    {/if}
                    <br />

                    <div class="SearchResult" style="z-index:1100;max-height:220px;overflow:auto;"></div>
                </td>
                <td width="5%" class=" " align="left">
					<font color="red"></font>{$fieldlabels['accountid']}：
				</td>
                <td width="20%" align="left"  class="DetailedTd2Info">
					<input name="account_id_name" fieldname="account_id" id = "single_accountid" type="text"   value="{$projectinfo['accountname']}"{if $projectinfo['accountname'] neq ''}style="cursor: not-allowed;" disabled="disabled" {/if} class="commonDetailedTextBox gwidth70 bgwhite"  onkeyup="getKeyWords(this,1,'Accounts',event)" onkeypress="userEnterKey(getKeyWords,[this,1,'Accounts',event],event)"     autocomplete="off" >
					<input name="account_id" type="hidden" value="{$projectinfo['accountid']}" >
					{if $ischoseproject neq 'no'}
						<a class="icon-homeimg icon-select" href="javascript:;" title="{'SELECT'|@getFixedLabel}" onclick='showrelatedlist("Project","Accounts","ganttselect","","account_id");'></a>
						<input class="icon-homeimg icon-clear inpb-reset" type="button" title="{'CLEAR'|@getFixedLabel}" onclick="clear_relatedfielddata('Accounts','account_id','account_id_name','accountname','Project','popupselectfield');return false;"/>
					{/if}        
					<br />
					<div class="SearchResult" style="z-index:1100;max-height:220px;overflow:auto;"></div>
				</td>

                <td width="10%">{$fieldlabels['smownerid']}：<span id="xm_owner">{$projectinfo['xm_owner']}</span>
                </td>
                <td width="10%">
                    {if $ischoseproject neq 'no'}
                        <input class="createauto" type="button" onclick="getganttviewByproject()" value="{'ClicktoViewGantt'|@getFixedLabel}"/>
                    {/if}
                </td>
            </tr>
        </table>
</div>
<div style="background-color: #F9F9F9;padding:10px;margin-bottom:10px;" >
    <table style="border-width:0px;border-collapse:collapse;" width="100%" cellspacing="0" cellpadding="0" border="0">
	<tbody>
        <tr style="height:23px;">
            <td>{$fieldlabels['project_no']}：{$projectinfo['projectno']}</td>
            <td>{$fieldlabels['projectname']}：{$projectinfo['projectname']}</td>
            <td style="width: 400px;">
                <div style="float: left;">
                    <div style="background-color: rgb(197, 206, 252);height: 12px;width: 12px;border-radius: 50%;float: left;margin-right: 5px;"></div>
                    <div style="float: left;">{'SCHEDULED'|@getFixedLabel}-{'ONTIME'|@getFixedLabel}&nbsp;&nbsp;</div>
                </div>
                <div style="float: left;">
                    <div style="float: left;background-color: rgb(212, 206, 254);height: 12px;width: 12px;border-radius: 50%;margin-right: 5px;"></div>
                    <div style="float: left;">{'INPROGRESS'|@getFixedLabel}-{'ONTIME'|@getFixedLabel}</div>
                </div>
            </td>
            {*<a class="ld_list_href_name tip-items-list" lasturl="" fieldname="projectname" module="Project" record="{$projectinfo['projectid']}" href="javascript:;" onclick="ListLinkClick(ld(this),event)" data-tip="{$projectinfo['projectname']}" data-direction="top" data-type="position">{$projectinfo['projectname']}</a>*}
            <input id="gantprojectname" type="hidden" value="{$projectinfo['projectname']}"/>
            </td>
        </tr>
        <tr style="height:23px;">
            <td>{'PLANS'|@getFixedLabel}{'CallStartTime'|@getFixedLabel}：{$projectinfo['jh_startdate']}</td>
            <td>{'PLANS'|@getFixedLabel}{'EndTime'|@getFixedLabel}：{$projectinfo['jh_endate']}</td>
            <td>
                <div style="float: left;">
                    <div style="background-color: rgb(97, 128, 237);height: 12px;width: 12px;border-radius: 50%;float: left;margin-right: 5px;"></div>
                    <div style="float: left;">{'COMPLETED'|@getFixedLabel}-{'ONTIME'|@getFixedLabel}&nbsp;&nbsp;</div>
                </div>
                <div style="float: left;">
                    <div style="float: left;background-color: rgb(157, 107, 204);height: 12px;width: 12px;border-radius: 50%;margin-right: 5px;"></div>
                    <div style="float: left;">{'SCHEDULED'|@getFixedLabel}-{'OVERDUE'|@getFixedLabel}</div>
                </div>
            </td>
        </tr>
        <tr style="height:23px;">
            <td>{'Actual'|@getFixedLabel}{'CallStartTime'|@getFixedLabel}{$projectinfo['sj_startdate']}</td>
            <td>{'Actual'|@getFixedLabel}{'EndTime'|@getFixedLabel}{$projectinfo['sj_endate']}</td>
            <td>
                <div style="float: left;">
                    <div style="background-color: rgb(209, 181, 239);height: 12px;width: 12px;border-radius: 50%;float: left;margin-right: 5px;"></div>
                    <div style="float: left;">{'INPROGRESS'|@getFixedLabel}-{'OVERDUE'|@getFixedLabel}&nbsp;&nbsp;</div>
                </div>
                <div style="float: left;">
                    <div style="float: left;background-color: rgb(245, 109, 121);height: 12px;width: 12px;border-radius: 50%;margin-right: 5px;"></div>
                    <div style="float: left;">{'COMPLETED'|@getFixedLabel}-{'OVERDUE'|@getFixedLabel}</div>
                </div>
            </td>
        </tr>
        <tr style="height:23px;">
            <td>{$fieldlabels['projectstatus']}：{$projectinfo['projectstatus']}</td>
            <td >{$fieldlabels['progress']}：{$projectinfo['completetask']}</td>
            <td >
                <div style="float: left;margin-top: 5px;">
                    <div style="background-color: rgb(238, 242, 254);height: 12px;width: 12px;border-radius: 50%;float: left;margin-right: 5px;"></div>
                    <div style="float: left;">{'PlanColumnColorFill'|@getFixedLabel}&nbsp;&nbsp;</div>
                </div>
                <div style="float: left;margin-top: 5px;">
                    <div style="float: left;background-color: rgb(192, 207, 251);height: 12px;width: 12px;border-radius: 50%;margin-right: 5px;"></div>
                    <div style="float: left;">{'TodayColumnColorFill'|@getFixedLabel}</div>
                </div>
            </td>
        </tr>
        <tr {if $jhdateshowflag eq true }style="display:none;"{/if}>
            <td colspan="4" style="text-align: center;"><div style="font-size: 26px;margin-top: 25px;">{$jhdatenoshowstr}</div></td>
        </tr>
    </tbody></table>
</div>
    <table style="border-width:0px;border-collapse:collapse;" cellspacing="0" cellpadding="0" border="0">
	<tbody>
        <tr>
            <td >
            <div id="ganttChart"></div>
            <br/><br/>
            <div id="eventMessage"></div>
            </td>
        </tr>
    </tbody></table>

 </form>
     