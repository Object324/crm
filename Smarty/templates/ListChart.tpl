{if $MODULE eq 'ContactRecords'}
    {if $CHART_CONTACTRECORDTYPE eq 'yes'}
    <li>
        <a href="javascript:ChartOpen('index.php?module=ListViewReport&action=ListViewReport&&columnname=count( distinct ld_contactrecords.contactRecordid)//B/as//B/sumcountrecordtype,CASE//B/LENGTH(IFNULL(contactrecordtype,//N/空//N/))//B/WHEN//B/0//B/then//B///N/空//N///B/ELSE//B/IFNULL(contactrecordtype,//N/空//N/)//B/end//B/as//B/contactrecordtypes&queryowner={$CHARTOWNER}&countlabel=sumcountrecordtype&relatedmodule={$MODULE}&pagetitle=CONTACTRECORDSTYPE&chartx=1&currency=no&groupby=contactrecordtypes&xtotal=1&ytotal=1&htmltabletype=0&rotateNames=0&MultiSerials=0','{$CHARTFROM}','{$CHARTWHERE}')">
            <span class="charts-searchterm-name">
                {'ContactRecords'|@gettranslabelfields:'contactrecordtype'}{'STATISTICALDISTRIBUTION'|@getFixedLabel}
            </span>
        </a>
    </li>
    {/if}
    <li>
        <a href="javascript:ChartOpen('index.php?module=ListViewReport&action=ListViewReport&columnname=users_assigned_user_id.last_name,date_format(ld_contactrecords.contactdate,//N/%Y-%m//N/),count(distinct ld_contactrecords.contactRecordid)//B/as//B/countrecord&querytype=1&querywhere={$CHARTWHERE}&queryowner={$CHARTOWNER}&countlabel=countrecord&relatedmodule={$MODULE}&pagetitle=CONTACTRECORDSQUANTITY&chartx=1&groupby=date_format(ld_contactrecords.contactdate,//N/%Y-%m//N/),users_assigned_user_id.last_name&xtotal=1&ytotal=1&htmltabletype=2&rotateNames=1&MultiSerials=1&orderby=date_format(ld_contactrecords.contactdate,//N/%Y-%m//N/)//B/asc,countrecord desc','{$CHARTFROM}','{$CHARTWHERE}')">
            <span class="charts-searchterm-name">
                {'CONTACTRECORDSQUANTITY'|@getFixedLabel}
            </span>
        </a>
    </li>
    <li>
        <a href="javascript:ChartOpen('index.php?module=ListViewReport&action=ListViewReport&columnname=&queryowner={$CHARTOWNER}&countlabel=countrecord&relatedmodule={$MODULE}&relatedaction=ListViewReport&functionname=getassignUserMonthAccount&pagetitle=LEADTRACKNUM&chartx=1&querytype=2&groupby=&xtotal=1&ytotal=1&htmltabletype=2&rotateNames=0&MultiSerials=1&orderby=&relatedtable=account&relatedfrom=left//B/join//B/ld_account//B/on//B/ld_account.accountid=ld_contactrecords.accountid','{$CHARTFROM}','{$CHARTWHERE}')">
            <span class="charts-searchterm-name">
                {'LEADTRACKNUM'|@getFixedLabel}
            </span>
        </a>
    </li>
    {if $CHAR_CONTANCTRECORD_ACCOUNT eq 'yes'}
    <li>
        <a href="javascript:ChartOpen('index.php?module=ListViewReport&action=ListViewReport&columnname=&queryowner={$CHARTOWNER}&countlabel=sumCountContact&relatedmodule={$MODULE}&relatedaction=ListViewReport&functionname=getTopTen&pagetitle=CUSTOMERCONTACTNUMTEN&chartx=0&groupby=&xtotal=1&ytotal=1&htmltabletype=1&rotateNames=0&MultiSerials=0&orderby=&relatedtable=account&relatedfrom=left//B/join//B/ld_account//B/on//B/ld_account.accountid=ld_contactrecords.accountid','{$CHARTFROM}','{$CHARTWHERE}')">
            <span class="charts-searchterm-name">
                {'CUSTOMERCONTACTNUMTEN'|@getFixedLabel}
            </span>
        </a>
    </li>
    <li>
        <a href="javascript:ChartOpen('index.php?module=ListViewReport&action=ListViewReport&columnname=&queryowner={$CHARTOWNER}&countlabel=sumCountContact&relatedmodule={$MODULE}&relatedaction=ListViewReport&functionname=getFifthTen&pagetitle=CUSTOMERCONTACTNUMFIFTY&chartx=0&groupby=&xtotal=1&ytotal=1&currency=no&htmltabletype=0&rotateNames=0&MultiSerials=0&orderby=&relatedtable=account&relatedfrom=left//B/join//B/ld_account//B/on//B/ld_account.accountid=ld_contactrecords.accountid','{$CHARTFROM}','{$CHARTWHERE}')">
            <span class="charts-searchterm-name">
                {'CUSTOMERCONTACTNUMFIFTY'|@getFixedLabel}
            </span>
        </a>
    </li>
    {/if}
{elseif $MODULE eq 'Accounts' || $MODULE eq 'ServiceCharge'}
<form>
</form>
    <form name="Calendaractivitytype" method="post" onsubmit='openSpecfiyWindown()' target="chart" action="index.php?module=ListViewReport&action=ListViewReport&&columnname=ld_accountscf.leadsource,count(distinct ld_account.Accountid)//B/as//B/sumleadsource&queryowner={$CHARTOWNER}&countlabel=sumleadsource&relatedmodule={$MODULE}&pagetitle=CUSTOMERSOURCEDISSTATIST&chartx=0&groupby=ld_accountscf.leadsource&xtotal=1&ytotal=1&htmltabletype=1&rotateNames=0&MultiSerials=0&relatedtable=accountscf&relatedfrom= left join ld_accountscf on ld_accountscf.accountid=ld_account.accountid">
        <input type="hidden" name="queryfrom" value="{$CHARTFROM}"/>
        <input type="hidden" value="{$CHARTWHERE}" name="querywhere"/>
        <input type="submit" style="display:none" id="ChartButton" />
    </form>    
    <form name="Accountstype" method="post" onsubmit='openSpecfiyWindown()' target="chart" action="index.php?module=ListViewReport&action=ListViewReport&&columnname=ld_account.account_type,count(distinct ld_account.accountid)//B/as//B/sumaccounttype&queryowner={$CHARTOWNER}&countlabel=sumaccounttype&relatedmodule={$MODULE}&pagetitle=CUSTOMERTYPEDISSTATIS&chartx=0&groupby=ld_account.account_type&xtotal=1&ytotal=1&htmltabletype=1&rotateNames=0&MultiSerials=0">
        <input type="hidden" name="queryfrom" value="{$CHARTFROM}"/>
        <input type="hidden" value="{$CHARTWHERE}" name="querywhere"/>
        <input type="submit" style="display:none" id="ChartButton" />
    </form>
    <form name="AccountsRating" method="post" onsubmit='openSpecfiyWindown()' target="chart" action="index.php?module=ListViewReport&action=ListViewReport&&columnname=ld_account.rating,count(distinct ld_account.accountid)//B/as//B/sumrating&queryowner={$CHARTOWNER}&countlabel=sumrating&relatedmodule={$MODULE}&pagetitle=CUSTOMERSTATE&chartx=0&groupby=ld_account.rating&xtotal=1&ytotal=1&htmltabletype=1&rotateNames=0&MultiSerials=0">
        <input type="hidden" name="queryfrom" value="{$CHARTFROM}"/>
        <input type="hidden" value="{$CHARTWHERE}" name="querywhere"/>
        <input type="submit" style="display:none" id="ChartButton" />
    </form>
    <form name="AccountsRatingType" method="post" onsubmit='openSpecfiyWindown()' target="chart" action="index.php?module=ListViewReport&action=ListViewReport&columnname=&queryowner={$CHARTOWNER}&countlabel=sumTypeRating&relatedmodule={$MODULE}&pagetitle=CUSTOMERTYPESTATE&chartx=1&xtotal=1&ytotal=1&htmltabletype=2&rotateNames=0&MultiSerials=1&relatedaction=ListViewReport&functionname=getAccountByactivitytype">
        <input type="hidden" name="queryfrom" value="{$CHARTFROM}"/>
        <input type="hidden" value="{$CHARTWHERE}" name="querywhere"/>
        <input type="submit" style="display:none" id="ChartButton" />
    </form>
    <form name="Accountsindustry" method="post" onsubmit='openSpecfiyWindown()' target="chart" action="index.php?module=ListViewReport&action=ListViewReport&&columnname=ld_account.industry,count(distinct ld_account.accountid)//B/as//B/sumindustry&queryowner={$CHARTOWNER}&countlabel=sumindustry&relatedmodule={$MODULE}&pagetitle=CUSTOMERINDUSTRY&chartx=0&groupby=ld_account.industry&xtotal=1&ytotal=1&htmltabletype=1&rotateNames=0&MultiSerials=0">
        <input type="hidden" name="queryfrom" value="{$CHARTFROM}"/>
        <input type="hidden" value="{$CHARTWHERE}" name="querywhere"/>
        <input type="submit" style="display:none" id="ChartButton" />
    </form>
    <form name="Accountsaccountsize" method="post" onsubmit='openSpecfiyWindown()' target="chart" action="index.php?module=ListViewReport&action=ListViewReport&&columnname=ld_accountscf.accountsize,count(distinct ld_account.accountid)//B/as//B/sumaccountsize&queryowner={$CHARTOWNER}&countlabel=sumaccountsize&relatedmodule={$MODULE}&pagetitle=CUSTOMERSIZESTAFF&chartx=0&groupby=ld_accountscf.accountsize&xtotal=1&ytotal=1&htmltabletype=1&rotateNames=0&MultiSerials=0&relatedtable=accountscf&relatedfrom= left join ld_accountscf on ld_accountscf.accountid=ld_account.accountid&form_name=accountsize">
        <input type="hidden" name="queryfrom" value="{$CHARTFROM}"/>
        <input type="hidden" value="{$CHARTWHERE}" name="querywhere"/>
        <input type="submit" style="display:none" id="ChartButton" />
    </form>
    <form name="Accountsaccountproperty" method="post" onsubmit='openSpecfiyWindown()' target="chart" action="index.php?module=ListViewReport&action=ListViewReport&&columnname=accountproperty,count(distinct ld_account.accountid)//B/as//B/sumaccountproperty&queryowner={$CHARTOWNER}&countlabel=sumaccountproperty&relatedmodule={$MODULE}&pagetitle=CUSTOMERNATURE&chartx=0&groupby=ld_accountscf.accountproperty&xtotal=1&ytotal=1&htmltabletype=1&rotateNames=0&MultiSerials=0&relatedtable=accountscf&relatedfrom= left join ld_accountscf on ld_accountscf.accountid=ld_account.accountid">
        <input type="hidden" name="queryfrom" value="{$CHARTFROM}"/>
        <input type="hidden" value="{$CHARTWHERE}" name="querywhere"/>
        <input type="submit" style="display:none" id="ChartButton" />
    </form>
    <form name="Accountsimportantlevel" method="post" onsubmit='openSpecfiyWindown()' target="chart" action="index.php?module=ListViewReport&action=ListViewReport&&columnname=important_level,count(distinct ld_account.accountid)//B/as//B/sumimportant_level&queryowner={$CHARTOWNER}&countlabel=sumimportant_level&relatedmodule={$MODULE}&pagetitle=CUSTOMERIMPORTANT&chartx=0&groupby=ld_accountscf.important_level&xtotal=1&ytotal=1&htmltabletype=1&rotateNames=0&MultiSerials=0&relatedtable=accountscf&relatedfrom= left join ld_accountscf on ld_accountscf.accountid=ld_account.accountid">
        <input type="hidden" name="queryfrom" value="{$CHARTFROM}"/>
        <input type="hidden" value="{$CHARTWHERE}" name="querywhere"/>
        <input type="submit" style="display:none" id="ChartButton" />
    </form>
    <form name="Accountsaccountrelationship" method="post" onsubmit='openSpecfiyWindown()' target="chart" action="index.php?module=ListViewReport&action=ListViewReport&&columnname=accountrelationship,count(distinct ld_account.accountid)//B/as//B/sumaccountrelationship&queryowner={$CHARTOWNER}&countlabel=sumaccountrelationship&relatedmodule={$MODULE}&pagetitle=CUSTOMERRELATEION&chartx=0&groupby=ld_accountscf.accountrelationship&xtotal=1&ytotal=1&htmltabletype=1&rotateNames=0&MultiSerials=0&relatedtable=accountscf&relatedfrom= left join ld_accountscf on ld_accountscf.accountid=ld_account.accountid">
        <input type="hidden" name="queryfrom" value="{$CHARTFROM}"/>
        <input type="hidden" value="{$CHARTWHERE}" name="querywhere"/>
        <input type="submit" style="display:none" id="ChartButton" />
    </form>    
    <form name="Accountsregisteredcapital" method="post" onsubmit='openSpecfiyWindown()' target="chart" action="index.php?module=ListViewReport&action=ListViewReport&&columnname=ld_accountscf.registeredcapital,count(distinct ld_account.accountid)//B/as//B/sumregisteredcapital&queryowner={$CHARTOWNER}&countlabel=sumregisteredcapital&relatedmodule={$MODULE}&pagetitle=CUSTOMERREGISTERRMB&chartx=0&groupby=ld_accountscf.registeredcapital&xtotal=1&ytotal=1&htmltabletype=1&rotateNames=0&MultiSerials=0&relatedtable=accountscf&relatedfrom= left join ld_accountscf on ld_accountscf.accountid=ld_account.accountid&form_name=Accountsregisteredcapital ">
        <input type="hidden" name="queryfrom" value="{$CHARTFROM}"/>
        <input type="hidden" value="{$CHARTWHERE}" name="querywhere"/>
        <input type="submit" style="display:none" id="ChartButton" />
    </form>
    <form name="Accountsannualincome" method="post" onsubmit='openSpecfiyWindown()' target="chart" action="index.php?module=ListViewReport&action=ListViewReport&&columnname=ld_accountscf.annualincome,count(distinct ld_account.accountid)//B/as//B/sumannualincome&queryowner={$CHARTOWNER}&countlabel=sumannualincome&relatedmodule={$MODULE}&pagetitle=CUSTOMERTURNOVER&chartx=0&groupby=ld_accountscf.annualincome&xtotal=1&ytotal=1&htmltabletype=1&rotateNames=0&MultiSerials=0&relatedtable=accountscf&relatedfrom= left join ld_accountscf on ld_accountscf.accountid=ld_account.accountid&form_name=Accountsannualincome ">
        <input type="hidden" name="queryfrom" value="{$CHARTFROM}"/>
        <input type="hidden" value="{$CHARTWHERE}" name="querywhere"/>
        <input type="submit" style="display:none" id="ChartButton" />
    </form>
    <form name="Accountssmownerid" method="post" onsubmit='openSpecfiyWindown()' target="chart" action="index.php?module=ListViewReport&action=ListViewReport&columnname=ld_users.last_name,count(distinct ld_account.accountid)//B/as//B/sumAccountSmownerid&querywhere={$CHARTWHERE}&queryowner={$CHARTOWNER}&countlabel=sumAccountSmownerid&relatedmodule={$MODULE}&pagetitle=CUSTOMERCHARGE&chartx=0&groupby=ld_users.last_name&xtotal=1&ytotal=1&htmltabletype=1&rotateNames=0&MultiSerials=0">
        <input type="hidden" name="queryfrom" value="{$CHARTFROM}"/>
        <input type="hidden" value="{$CHARTWHERE}" name="querywhere"/>
        <input type="submit" style="display:none" id="ChartButton" />
    </form>
    <form name="AccountsCONTRACTAMOUNTTEN" method="post" onsubmit='openSpecfiyWindown()' target="chart" action="index.php?module=ListViewReport&action=ListViewReport&columnname=&queryowner={$CHARTOWNER}&countlabel=sumAccountTopTentotal&relatedmodule={$MODULE}&pagetitle=CONTRACTAMOUNTTEN&chartx=1&xtotal=1&ytotal=1&htmltabletype=0&rotateNames=0&MultiSerials=0&relatedaction=ListViewReport&functionname=getAccountByTopTentotal">
        <input type="hidden" name="queryfrom" value="{$CHARTFROM}"/>
        <input type="hidden" value="{$CHARTWHERE}" name="querywhere"/>
        <input type="submit" style="display:none" id="ChartButton" />
    </form>
    <form name="AccountsCONTRACTAMOUNTFIFTY" method="post" onsubmit='openSpecfiyWindown()' target="chart" action="index.php?module=ListViewReport&action=ListViewReport&columnname=&queryowner={$CHARTOWNER}&countlabel=sumAccountTopFiftytotal&relatedmodule={$MODULE}&pagetitle=CONTRACTAMOUNTFIFTY&chartx=1&xtotal=1&ytotal=1&htmltabletype=0&rotateNames=0&MultiSerials=0&relatedaction=ListViewReport&functionname=getAccountByTopFiftytotal">
        <input type="hidden" name="queryfrom" value="{$CHARTFROM}"/>
        <input type="hidden" value="{$CHARTWHERE}" name="querywhere"/>
        <input type="submit" style="display:none" id="ChartButton" />
    </form>
    <form name="AccountsPAYMENTAMOUNTTEN" method="post" onsubmit='openSpecfiyWindown()' target="chart" action="index.php?module=ListViewReport&action=ListViewReport&columnname=&queryowner={$CHARTOWNER}&countlabel=sumAccountTopTeninvoicetotal&relatedmodule={$MODULE}&pagetitle=PAYMENTAMOUNTTEN&chartx=1&xtotal=1&ytotal=1&htmltabletype=0&rotateNames=0&MultiSerials=0&relatedaction=ListViewReport&functionname=getAccountByTopTeninvoicetotal">
        <input type="hidden" name="queryfrom" value="{$CHARTFROM}"/>
        <input type="hidden" value="{$CHARTWHERE}" name="querywhere"/>
        <input type="submit" style="display:none" id="ChartButton" />
    </form>    
    <form name="AccountsPAYMENTAMOUNTFIFTY" method="post" onsubmit='openSpecfiyWindown()' target="chart" action="index.php?module=ListViewReport&action=ListViewReport&columnname=&queryowner={$CHARTOWNER}&countlabel=sumAccountTopFiftyinvoicetotal&relatedmodule={$MODULE}&pagetitle=PAYMENTAMOUNTFIFTY&chartx=1&xtotal=1&ytotal=1&htmltabletype=0&rotateNames=0&MultiSerials=0&relatedaction=ListViewReport&functionname=getAccountByTopFiftyinvoicetotal">
        <input type="hidden" name="queryfrom" value="{$CHARTFROM}"/>
        <input type="hidden" value="{$CHARTWHERE}" name="querywhere"/>
        <input type="submit" style="display:none" id="ChartButton" />
    </form>    
    <form name="AccountsCUSTOMERRECEIVERANK" method="post" onsubmit='openSpecfiyWindown()' target="chart" action="index.php?module=ListViewReport&action=ListViewReport&columnname=&queryowner={$CHARTOWNER}&countlabel=sumAccountTopTenreceivable&relatedmodule={$MODULE}&pagetitle=CUSTOMERRECEIVERANK&chartx=1&xtotal=1&ytotal=1&htmltabletype=0&rotateNames=0&MultiSerials=0&relatedaction=ListViewReport&functionname=getAccountByTopTenreceivable">
        <input type="hidden" name="queryfrom" value="{$CHARTFROM}"/>
        <input type="hidden" value="{$CHARTWHERE}" name="querywhere"/>
        <input type="submit" style="display:none" id="ChartButton" />
    </form>    
    <form name="AccountsRECEIVECHARGE" method="post" onsubmit='openSpecfiyWindown()' target="chart" action="index.php?module=ListViewReport&action=ListViewReport&columnname=&queryowner={$CHARTOWNER}&countlabel=sumAccountreceivablesmowner&relatedmodule={$MODULE}&pagetitle=RECEIVECHARGE&chartx=1&xtotal=1&ytotal=1&htmltabletype=0&rotateNames=0&MultiSerials=0&relatedaction=ListViewReport&functionname=getAccountByreceivablesmowner&orderby=sumaccounttoptenreceivable  //B/DESC">
        <input type="hidden" name="queryfrom" value="{$CHARTFROM}"/>
        <input type="hidden" value="{$CHARTWHERE}" name="querywhere"/>
        <input type="submit" style="display:none" id="ChartButton" />
    </form>    
    <form name="AccountsCUSTOMERSCHEDULECONTACT" method="post" onsubmit='openSpecfiyWindown()' target="chart" action="index.php?module=ListViewReport&action=ListViewReport&columnname=&queryowner={$CHARTOWNER}&countlabel=sumAccountCalendarContactRecords&relatedmodule={$MODULE}&pagetitle=CUSTOMERSCHEDULECONTACT&chartx=1&xtotal=1&ytotal=1&currency=no&htmltabletype=0&rotateNames=0&MultiSerials=0&relatedaction=ListViewReport&functionname=getAccountByCalendarContactRecords">
        <input type="hidden" name="queryfrom" value="{$CHARTFROM}"/>
        <input type="hidden" value="{$CHARTWHERE}" name="querywhere"/>
        <input type="submit" style="display:none" id="ChartButton" />
    </form>    
    <form name="AccountsBillState" method="post" onsubmit='openSpecfiyWindown()' target="chart" action="index.php?module=ListViewReport&action=ListViewReport&queryowner={$CHARTOWNER}&countlabel=sumbill_state&relatedmodule={$MODULE}&pagetitle=CUSTOMERBILLSTATE&chartx=0&xtotal=1&ytotal=1&htmltabletype=1&rotateNames=0&MultiSerials=0&relatedaction=ListViewReport&functionname=getAccountsBillState">
        <input type="hidden" name="queryfrom" value="{$CHARTFROM}"/>
        <input type="hidden" value="{$CHARTWHERE}" name="querywhere"/>
        <input type="submit" style="display:none" id="ChartButton" />
    </form>    
    <form name="AccountsBillCity" method="post" onsubmit='openSpecfiyWindown()' target="chart" action="index.php?module=ListViewReport&action=ListViewReport&queryowner={$CHARTOWNER}&countlabel=sumbill_city&relatedmodule={$MODULE}&pagetitle=CUSTOMERBILLCITY&chartx=0&xtotal=1&ytotal=1&htmltabletype=1&rotateNames=0&MultiSerials=0&relatedaction=ListViewReport&functionname=getAccountsBillCity">
        <input type="hidden" name="queryfrom" value="{$CHARTFROM}"/>
        <input type="hidden" value="{$CHARTWHERE}" name="querywhere"/>
        <input type="submit" style="display:none" id="ChartButton" />
    </form> 
    {if $CHART_LEADSOURCE eq 'yes'}
    <li>
        <a href='javascript:CalendarChart(this,"Calendaractivitytype")'>
            <span class="charts-searchterm-name">
                {'Accounts'|@gettranslabelfields:'leadsource'}{'STATISTICALDISTRIBUTION'|@getFixedLabel}
            </span>        
        </a>
    </li>
    {/if}
    {if $CHART_ACCOUNTTYPE eq 'yes'} 
    <li>          
        <a href='javascript:CalendarChart(this,"Accountstype")'>
            <span class="charts-searchterm-name">
                {'Accounts'|@gettranslabelfields:'account_type'}{'STATISTICALDISTRIBUTION'|@getFixedLabel}
            </span>        
        </a>
    </li>
    {/if}
    {if $CHART_RATING eq 'yes'}  
    <li>           
        <a href='javascript:CalendarChart(this,"AccountsRating")'>
            <span class="charts-searchterm-name">
                {'Accounts'|@gettranslabelfields:'rating'}{'STATISTICALDISTRIBUTION'|@getFixedLabel}
            </span>        
        </a>
    </li>
    {/if}
    {if $CHART_ACCOUNTTYPE_RATING eq 'yes'} 
    <li>           
        <a href='javascript:CalendarChart(this,"AccountsRatingType")'>
            <span class="charts-searchterm-name">
                {'Accounts'|@gettranslabelfields:'account_type'}{'Accounts'|@gettranslabelfields:'rating'}{'STATISTICALDISTRIBUTION'|@getFixedLabel}
            </span>
        </a>
    </li>
    {/if}
    {if $CHART_INDUSTRY eq 'yes'} 
    <li>
        <a href='javascript:CalendarChart(this,"Accountsindustry")'>
            <span class="charts-searchterm-name">
                {'Accounts'|@gettranslabelfields:'industry'}{'STATISTICALDISTRIBUTION'|@getFixedLabel}
            </span>
        </a>
    </li>
    {/if}
    {if $CHART_ACCOUNTSIZE eq 'yes'} 
    <li>
        <a href='javascript:CalendarChart(this,"Accountsaccountsize")'>
            <span class="charts-searchterm-name">
                {'Accounts'|@gettranslabelfields:'accountsize'}{'STATISTICALDISTRIBUTION'|@getFixedLabel}
            </span>
        </a>
    </li>
    {/if}
    {if $CHART_ACCOUNTPROPERTY eq 'yes'} 
    <li>
        <a href='javascript:CalendarChart(this,"Accountsaccountproperty")'>
            <span class="charts-searchterm-name">
                {'Accounts'|@gettranslabelfields:'accountproperty'}{'STATISTICALDISTRIBUTION'|@getFixedLabel}
            </span>
        </a>
    </li>
    {/if}
    {if $CHART_IMPORTTANT_LEVEL eq 'yes'} 
    <li>
        <a href='javascript:CalendarChart(this,"Accountsimportantlevel")'>
            <span class="charts-searchterm-name">
                {'Accounts'|@gettranslabelfields:'important_level'}{'STATISTICALDISTRIBUTION'|@getFixedLabel}
            </span>
        </a>
    </li>
    {/if}
    {if $CHART_ACCOUNTRELATIONSHIP eq 'yes'} 
    <li>
        <a href='javascript:CalendarChart(this,"Accountsaccountrelationship")'>
            <span class="charts-searchterm-name">
                {'Accounts'|@gettranslabelfields:'accountrelationship'}{'STATISTICALDISTRIBUTION'|@getFixedLabel}
            </span>
        </a>
    </li>
    {/if}
    {if $CHART_REGISTERREDCAPITAL eq 'yes'} 
    <li>
        <a href='javascript:CalendarChart(this,"Accountsregisteredcapital")'>
            <span class="charts-searchterm-name">
                {'Accounts'|@gettranslabelfields:'registeredcapital'}{'STATISTICALDISTRIBUTION'|@getFixedLabel}
            </span>
        </a>            
    </li>
    {/if}
    {if $CHART_ANNUALINCOME eq 'yes'} 
    <li>
        <a href='javascript:CalendarChart(this,"Accountsannualincome")'>
            <span class="charts-searchterm-name">
                {'Accounts'|@gettranslabelfields:'annualincome'}{'STATISTICALDISTRIBUTION'|@getFixedLabel}
            </span>
        </a>
    </li>
    {/if}
    <li>
        <a href='javascript:CalendarChart(this,"Accountssmownerid")'>
            <span class="charts-searchterm-name">
                {'Accounts'|@gettranslabelfields:'smownerid'}{'STATISTICALDISTRIBUTION'|@getFixedLabel}
            </span>
        </a>
    </li>
    <li>
        <a href='javascript:CalendarChart(this,"AccountsCONTRACTAMOUNTTEN")'>
            <span class="charts-searchterm-name">
                {'CONTRACTAMOUNTTEN'|@getFixedLabel}
            </span>
        </a>
    </li>
    <li>
        <a href='javascript:CalendarChart(this,"AccountsCONTRACTAMOUNTFIFTY")'>
            <span class="charts-searchterm-name">
                {'CONTRACTAMOUNTFIFTY'|@getFixedLabel}
            </span>
        </a>
    </li>
    <li>
        <a href='javascript:CalendarChart(this,"AccountsPAYMENTAMOUNTTEN")'>
            <span class="charts-searchterm-name">
                {'PAYMENTAMOUNTTEN'|@getFixedLabel}
            </span>
        </a>
    </li>
    <li>
        <a href='javascript:CalendarChart(this,"AccountsPAYMENTAMOUNTFIFTY")'>
            <span class="charts-searchterm-name">
                {'PAYMENTAMOUNTFIFTY'|@getFixedLabel}
            </span>
        </a>
    </li>
    <li>
        <a href='javascript:CalendarChart(this,"AccountsCUSTOMERRECEIVERANK")'>
            <span class="charts-searchterm-name">
                {'CUSTOMERRECEIVERANK'|@getFixedLabel}
            </span>
        </a>
    </li>
    <li>
        <a href='javascript:CalendarChart(this,"AccountsRECEIVECHARGE")'>
            <span class="charts-searchterm-name">
                {'RECEIVECHARGE'|@getFixedLabel}
            </span>
        </a>
    </li>
    <li>
        <a href='javascript:CalendarChart(this,"AccountsCUSTOMERSCHEDULECONTACT")'>
            <span class="charts-searchterm-name">
                {'CUSTOMERSCHEDULECONTACT'|@getFixedLabel}
            </span>
        </a>
    </li>                                     
    {if $CHART_BILL_STATE eq 'yes'}
    <li> 
        <a href='javascript:CalendarChart(this,"AccountsBillState")'>
            <span class="charts-searchterm-name">
                {'Accounts'|@gettranslabelfields:'bill_state'}{'STATISTICALDISTRIBUTION'|@getFixedLabel}
            </span>
        </a>
    </li>
    {/if}
    {if $CHART_BILL_CITY eq 'yes'}
    <li> 
        <a href='javascript:CalendarChart(this,"AccountsBillCity")'>
            <span class="charts-searchterm-name">
                {'Accounts'|@gettranslabelfields:'bill_city'}{'STATISTICALDISTRIBUTION'|@getFixedLabel}
            </span>
        </a>
    </li>
    {/if}
{elseif $MODULE eq 'Campaigns'}
    {if $CHART_CAMPAINSTATUS eq 'yes'}
    <li>
        <a href="javascript:ChartOpen('index.php?module=ListViewReport&action=ListViewReport&&columnname=campaignstatus,count(distinct ld_campaign.campaignid)//B/as//B/sumCampaignscampaignstatus&queryowner={$CHARTOWNER}&countlabel=sumCampaignscampaignstatus&relatedmodule={$MODULE}&pagetitle=MARKETSTATE&chartx=0&groupby=ld_Campaign.campaignstatus&xtotal=1&ytotal=1&htmltabletype=1&rotateNames=0&MultiSerials=0&orderby=sumCampaignscampaignstatus //B/DESC','{$CHARTFROM}','{$CHARTWHERE}')">
            <span class="charts-searchterm-name">
                {'Campaigns'|@gettranslabelfields:'campaignstatus'}{'STATISTICALDISTRIBUTION'|@getFixedLabel}
            </span>
        </a>
    </li>
    {/if}
    {if $CHART_CAMPAIGNTYPE eq 'yes'}
    <li>
        <a href="javascript:ChartOpen('index.php?module=ListViewReport&action=ListViewReport&&columnname=campaigntype,count(distinct ld_campaign.campaignid)//B/as//B/sumCampaignscampaigntype&queryowner={$CHARTOWNER}&countlabel=sumCampaignscampaigntype&relatedmodule={$MODULE}&pagetitle=MARKETTYPE&chartx=0&groupby=ld_Campaign.campaigntype&xtotal=1&ytotal=1&htmltabletype=1&rotateNames=0&MultiSerials=0&orderby=sumCampaignscampaigntype  //B/DESC','{$CHARTFROM}','{$CHARTWHERE}')">
            <span class="charts-searchterm-name">
                {'Campaigns'|@gettranslabelfields:'campaigntype'}{'STATISTICALDISTRIBUTION'|@getFixedLabel}
            </span>
        </a>
    </li>
    {/if}
    {if $CHART_EXPECTEDRESPONSE eq 'yes'}
    <li>
        <a href="javascript:ChartOpen('index.php?module=ListViewReport&action=ListViewReport&&columnname=expectedresponse,count(distinct ld_campaign.campaignid)//B/as//B/sumCampaignsexpectedresponse&queryowner={$CHARTOWNER}&countlabel=sumCampaignsexpectedresponse&relatedmodule={$MODULE}&pagetitle=EXPECTEDRESPONSE&chartx=0&groupby=ld_Campaign.expectedresponse&xtotal=1&ytotal=1&htmltabletype=1&rotateNames=0&MultiSerials=0','{$CHARTFROM}','{$CHARTWHERE}')">
            <span class="charts-searchterm-name">
                {'Campaigns'|@gettranslabelfields:'expectedresponse'}{'STATISTICALDISTRIBUTION'|@getFixedLabel}
            </span>
        </a>
    </li>
    {/if}
    <li>
        <a href="javascript:ChartOpen('index.php?module=ListViewReport&action=ListViewReport&columnname=users_assigned_user_id.last_name,count(distinct ld_campaign.campaign_no)//B/as//B/sumCampaignssmownerid&querywhere={$CHARTWHERE}&queryowner={$CHARTOWNER}&countlabel=sumCampaignssmownerid&relatedmodule={$MODULE}&pagetitle=MARKETCHARTDIS&chartx=0&groupby=users_assigned_user_id.last_name&xtotal=1&ytotal=1&htmltabletype=1&rotateNames=0&MultiSerials=0&orderby=sumCampaignssmownerid  //B/DESC','{$CHARTFROM}','{$CHARTWHERE}')">
            <span class="charts-searchterm-name">
                {'Campaigns'|@gettranslabelfields:'smownerid'}{'STATISTICALDISTRIBUTION'|@getFixedLabel}
            </span>
        </a>
    </li>
{elseif $MODULE eq 'Calendar'}
<form>
</form>
    <form name="Calendaractivitytype" method="post" onsubmit='openSpecfiyWindown()' target="chart" action="index.php?module=ListViewReport&action=ListViewReport&columnname=&queryowner={$CHARTOWNER}&countlabel=sumCalendaractivitytype&relatedmodule={$MODULE}&pagetitle=CALENDARTYPE&chartx=0&xtotal=1&ytotal=1&htmltabletype=1&rotateNames=0&MultiSerials=0&relatedaction=ListViewReport&functionname=getCalendarByactivitytype&orderby=sumCalendaractivitytype //B/DESC">
        <input type="hidden" name="queryfrom" value="{$CHARTFROM}"/>
        <input type="hidden" value="{$CHARTWHERE}" name="querywhere"/>
        <input type="submit" style="display:none" id="ChartButton" />
    </form>    
    <form name="Calendareventstatus" method="post" onsubmit='openSpecfiyWindown()' target="chart" action="index.php?module=ListViewReport&action=ListViewReport&columnname=&queryowner={$CHARTOWNER}&countlabel=sumCalendareventstatus&relatedmodule={$MODULE}&pagetitle=CALENDARSTATUS&chartx=0&xtotal=1&ytotal=1&htmltabletype=1&rotateNames=0&MultiSerials=0&relatedaction=ListViewReport&functionname=getCalendarByaeventstatus&orderby=sumCalendareventstatus //B/DESC">
        <input type="hidden" name="queryfrom" value="{$CHARTFROM}"/>
        <input type="hidden" value="{$CHARTWHERE}" name="querywhere"/>
        <input type="submit" style="display:none" id="ChartButton" />
    </form>    
    <form name="CalendarSmownerid" method="post" onsubmit='openSpecfiyWindown()' target="chart" action="index.php?module=ListViewReport&action=ListViewReport&columnname=&queryowner={$CHARTOWNER}&countlabel=sumCalendarSmownerid&relatedmodule={$MODULE}&pagetitle=CALENDARCHARGE&chartx=0&xtotal=1&ytotal=1&htmltabletype=1&rotateNames=0&MultiSerials=0&relatedaction=ListViewReport&functionname=getCalendarBySmownerid&orderby=sumCalendarSmownerid  //B/DESC">
        <input type="hidden" name="queryfrom" value="{$CHARTFROM}"/>
        <input type="hidden" value="{$CHARTWHERE}" name="querywhere"/>
        <input type="submit" style="display:none" id="ChartButton" />
    </form>
    <form name="CalendarTopTenCount" method="post" onsubmit='openSpecfiyWindown()' target="chart" action="index.php?module=ListViewReport&action=ListViewReport&columnname=&queryowner={$CHARTOWNER}&countlabel=sumCalendarTopTenCount&relatedmodule={$MODULE}&pagetitle=CUSTOMERCALENDARCONTACTTEN&chartx=1&xtotal=1&ytotal=1&htmltabletype=0&rotateNames=0&MultiSerials=0&relatedaction=ListViewReport&functionname=getCalendarByTopTenCount">
        <input type="hidden" name="queryfrom" value="{$CHARTFROM}"/>
        <input type="hidden" value="{$CHARTWHERE}" name="querywhere"/>
        <input type="hidden" value="no" name="currency"/>
        <input type="submit" style="display:none" id="ChartButton" />
    </form>
    <form name="CalendarTopFiftyCount" method="post" onsubmit='openSpecfiyWindown()' target="chart" action="index.php?module=ListViewReport&action=ListViewReport&columnname=&queryowner={$CHARTOWNER}&countlabel=sumCalendarTopFiftyCount&relatedmodule={$MODULE}&pagetitle=CUSTOMERCALENDARCONTACTTEN&chartx=1&xtotal=1&ytotal=1&htmltabletype=0&rotateNames=0&MultiSerials=0&relatedaction=ListViewReport&functionname=getCalendarByTopFiftyCount">
        <input type="hidden" name="queryfrom" value="{$CHARTFROM}"/>
        <input type="hidden" value="{$CHARTWHERE}" name="querywhere"/>
        <input type="submit" style="display:none" id="ChartButton" />
    </form>     
    {if $CALENDAR_ACTIVITYTYPE eq 'yes'} 
    <li>
        <a href='javascript:CalendarChart(this,"Calendaractivitytype")'>
            <span class="charts-searchterm-name">
                {'Events'|@gettranslabelfields:'activitytype'}{'STATISTICALDISTRIBUTION'|@getFixedLabel}
            </span>
        </a>
    </li>
    {/if}
    {if $CALENDAR_EVENTSTATUS eq 'yes'} 
    <li>
        <a href="javascript:CalendarChart(this,'Calendareventstatus')">
            <span class="charts-searchterm-name">
                {'Events'|@gettranslabelfields:'eventstatus'}{'STATISTICALDISTRIBUTION'|@getFixedLabel}
            </span>
        </a>
    </li>
    {/if}
    <li>
        <a href='javascript:CalendarChart(this,"CalendarSmownerid")'>
            <span class="charts-searchterm-name">
                {'Events'|@gettranslabelfields:'smownerid'}{'STATISTICALDISTRIBUTION'|@getFixedLabel}
            </span>
        </a>
    </li>
    <li>
        <a href="javascript:CalendarChart(this,'CalendarTopTenCount')">
            <span class="charts-searchterm-name">
                {'CUSTOMERCALENDARCONTACTTEN'|@getFixedLabel}
            </span>
        </a>
    </li>
{elseif $MODULE eq 'Potentials'}
    {if $CHART_POTENTIALTYPE eq 'yes'} 
    <li>
        <a href="javascript:ChartOpen('index.php?module=ListViewReport&action=ListViewReport&&columnname=potentialtype,count(distinct ld_potential.potentialid)//B/as//B/sumPotentialspotentialtype&queryowner={$CHARTOWNER}&countlabel=sumPotentialspotentialtype&relatedmodule={$MODULE}&pagetitle=BUSINESSTYPE&chartx=0&groupby=ld_potential.potentialtype&xtotal=1&ytotal=1&htmltabletype=1&rotateNames=0&MultiSerials=0','{$CHARTFROM}','{$CHARTWHERE}')">
            <span class="charts-searchterm-name">
                {'Potentials'|@gettranslabelfields:'potentialtype'}{'STATISTICALDISTRIBUTION'|@getFixedLabel}
            </span>
        </a>
    </li>
    {/if}
    {if $CHART_POTENTIAL_LEADSOURCE eq 'yes'} 
    <li>
        <a href="javascript:ChartOpen('index.php?module=ListViewReport&action=ListViewReport&&columnname=leadsource,count(distinct ld_potential.potentialid)//B/as//B/sumPotentialsleadsource&queryowner={$CHARTOWNER}&countlabel=sumPotentialsleadsource&relatedmodule={$MODULE}&pagetitle=BUSINESSSOURCE&chartx=0&groupby=ld_potential.leadsource&xtotal=1&ytotal=1&htmltabletype=1&rotateNames=0&MultiSerials=0&orderby=sumPotentialsleadsource //B/DESC','{$CHARTFROM}','{$CHARTWHERE}')">
            <span class="charts-searchterm-name">
                {'Potentials'|@gettranslabelfields:'leadsource'}{'STATISTICALDISTRIBUTION'|@getFixedLabel}
            </span>
        </a>
    </li>
    {/if}
    {if $CHART_POTENTIAL_POSSIBILITY eq 'yes'} 
    <li>
        <a href="javascript:ChartOpen('index.php?module=ListViewReport&action=ListViewReport&&columnname=possibility//B/as//B/possibility,count(distinct ld_potential.potentialid)//B/as//B/sumPotentialspossibility&queryowner={$CHARTOWNER}&countlabel=sumPotentialspossibility&relatedmodule={$MODULE}&pagetitle=LIKELIHOODPERCENT&chartx=0&groupby=ld_potentialscf.possibility&xtotal=1&ytotal=1&htmltabletype=1&rotateNames=0&MultiSerials=0','{$CHARTFROM}','{$CHARTWHERE}')">
            <span class="charts-searchterm-name">
                {'Potentials'|@gettranslabelfields:'possibility'}{'STATISTICALDISTRIBUTION'|@getFixedLabel}
            </span>
        </a>
    </li>
    {/if}
    {if $CHART_POTENTIAL_SALES_STAGE eq 'yes'} 
    <li>
        <a href="javascript:ChartOpen('index.php?module=ListViewReport&action=ListViewReport&&columnname=sales_stage,count(distinct ld_potential.potentialid)//B/as//B/sumpotentialssales_stage&queryowner={$CHARTOWNER}&countlabel=sumPotentialssales_stage&relatedmodule={$MODULE}&pagetitle=SALESSTATE&chartx=0&groupby=ld_potential.sales_stage&xtotal=1&ytotal=1&htmltabletype=1&rotateNames=0&MultiSerials=0','{$CHARTFROM}','{$CHARTWHERE}')">
            <span class="charts-searchterm-name">
                {'Potentials'|@gettranslabelfields:'sales_stage'}{'STATISTICALDISTRIBUTION'|@getFixedLabel}
            </span>
        </a>
    </li>
    {/if}
    <li>           
        <a href="javascript:ChartOpen('index.php?module=ListViewReport&action=ListViewReport&columnname=users_assigned_user_id.last_name,count(users_assigned_user_id.last_name)//B/as//B/sumpotentialssmownerid&querywhere={$CHARTWHERE}&queryowner={$CHARTOWNER}&countlabel=sumPotentialssmownerid&relatedmodule={$MODULE}&pagetitle=CHARGEDISTRIBUTION&chartx=0&groupby=users_assigned_user_id.last_name&xtotal=1&ytotal=1&htmltabletype=1&rotateNames=0&MultiSerials=0&orderby=sumpotentialssmownerid //B/DESC','{$CHARTFROM}','{$CHARTWHERE}')">
            <span class="charts-searchterm-name">
                {'Potentials'|@gettranslabelfields:'smownerid'}{'STATISTICALDISTRIBUTION'|@getFixedLabel}
            </span>
        </a>
    </li>
    {if $CHART_POTENTIAL_CREATEDTIME eq 'yes'} 
    <li>
        <a href="javascript:ChartOpen('index.php?module=ListViewReport&action=ListViewReport&columnname=&queryowner={$CHARTOWNER}&countlabel=sumPotentialsCreatedtime&relatedmodule={$MODULE}&pagetitle=OPPORTUNITYCREATETIME&chartx=0&xtotal=1&ytotal=1&htmltabletype=1&rotateNames=0&MultiSerials=0&relatedaction=ListViewReport&functionname=getPotentialsByCreatedtime','{$CHARTFROM}','{$CHARTWHERE}')">
            <span class="charts-searchterm-name">
                {'Potentials'|@gettranslabelfields:'createdtime'}{'STATISTICALDISTRIBUTION'|@getFixedLabel}
            </span>
        </a>
    </li>
    {/if}
    {if $CHART_POTENTIAL_CLOSINGDATE eq 'yes'} 
    <li>
        <a href="javascript:ChartOpen('index.php?module=ListViewReport&action=ListViewReport&&columnname=date_format(ld_potential.closingdate,//N/%Y-%m//N/),count(distinct ld_potential.potentialid)//B/as//B/sumPotentialsclosingdate&queryowner={$CHARTOWNER}&countlabel=sumPotentialsclosingdate&relatedmodule={$MODULE}&pagetitle=OPPORTUNITYEXPECTEDBILL&chartx=0&groupby=date_format(ld_potential.closingdate,//N/%Y-%m//N/)&xtotal=1&ytotal=1&htmltabletype=1&rotateNames=0&MultiSerials=0','{$CHARTFROM}','{$CHARTWHERE}')">
            <span class="charts-searchterm-name">
                {'Potentials'|@gettranslabelfields:'closingdate'}{'STATISTICALDISTRIBUTION'|@getFixedLabel}
            </span>
        </a>
    </li>
    {/if}
    <li>
        <a href="javascript:ChartOpen('index.php?module=ListViewReport&action=ListViewReport&columnname=&queryowner={$CHARTOWNER}&countlabel=sumpotentialsSmowneridCreatetime&relatedmodule={$MODULE}&pagetitle=REPONSIBLEPERSONOPPORTUNITY&chartx=1&xtotal=1&ytotal=1&htmltabletype=2&rotateNames=1&MultiSerials=1&relatedaction=ListViewReport&functionname=getPotentialsBySmowneridCreatetime&orderby=ld_potential.createdtime  //B/asc','{$CHARTFROM}','{$CHARTWHERE}')">
            <span class="charts-searchterm-name">
                {'Potentials'|@gettranslabelfields:'smownerid'}{'Potentials'|@gettranslabelfields:'createdtime'}{'STATISTICALDISTRIBUTION'|@getFixedLabel}
            </span>
        </a>
    </li>
{/if}