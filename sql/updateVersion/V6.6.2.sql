update ld_desk set fieldlabel = '暂无审批人，请检查审批流程步骤！' where labelbol = 'NONEXTAPPROVER' and Labeltype = 'jspop' and languagetype = 'zh';
delimiter;

DROP PROCEDURE IF EXISTS `update_sales_total1`;
delimiter ||
CREATE  PROCEDURE `update_sales_total1`(
)
BEGIN
	
	declare tmp_entitytypeid int default 0;
	declare tmp_entitytype varchar(200) default NULL;

	declare cur1 CURSOR FOR SELECT DISTINCT
										entitytypeid,
										entitytype
									FROM (
										select
											b.entitytypeid,
											b.entitytype
										from ld_cashbill a 
										LEFT JOIN ld_cashbill2paymentplan b on a.cashbillid=b.CashBillID
										where a.deleted=0 and b.entitytypeid>0 and length(b.entitytype)>1
										UNION
										select 
												c.entitytypeid,
												c.entitytype
										from ld_cashbill a 
										LEFT JOIN ld_cashbill2paymentplan b on a.cashbillid=b.CashBillID
										INNER JOIN ld_paymentplan c on c.paymentplanid=b.entitytypeid
										where a.deleted=0 and b.entitytypeid>0 and length(b.entitytype)>1) a
									ORDER BY entitytypeid;
	
	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' set tmp_entitytypeid = NULL;
	
	select ifnull(deploy_value,0) into @deploy_value from ld_systems_deploy where deploy_type=83;
	
	OPEN cur1;
	Fetch cur1 into tmp_entitytypeid,tmp_entitytype;
	while(tmp_entitytypeid is not null) DO
	
		set @tmp_entitytypeid=0;
		set @tmp_entitytypeid=tmp_entitytypeid;
		
		
		set @cnt1=0;	
		IF tmp_entitytype='SalesOrder' THEN
			select 
				count(DISTINCT currency_id) into @cnt1 
			from (
				select currency_id from ld_salesorder where salesorderid=@tmp_entitytypeid and deleted=0
				UNION ALL
					select 
						a.currency_id 
					from ld_cashbill a
					LEFT JOIN ld_cashbill2paymentplan b on a.cashbillid=b.CashBillID
					where b.entitytypeid=@tmp_entitytypeid and a.deleted=0
						and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)
				UNION ALL
					select 
						a.currency_id 
					from ld_cashbill a
					LEFT JOIN ld_cashbill2paymentplan b on a.cashbillid=b.CashBillID
					LEFT JOIN ld_paymentplan c on b.entitytypeid=c.paymentplanid
					where c.entitytypeid=@tmp_entitytypeid and a.deleted=0 and c.deleted=0
						and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)) c;
		ELSEIF tmp_entitytype='ServiceContracts' THEN
			select 
				count(DISTINCT currency_id) into @cnt1 
			from (
				select currency_id from ld_servicecontracts where servicecontractsid=@tmp_entitytypeid and deleted=0
				UNION ALL
					select 
						a.currency_id 
					from ld_cashbill a
					LEFT JOIN ld_cashbill2paymentplan b on a.cashbillid=b.CashBillID
					where b.entitytypeid=@tmp_entitytypeid and a.deleted=0
						and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)
				UNION ALL
					select 
						a.currency_id 
					from ld_cashbill a
					LEFT JOIN ld_cashbill2paymentplan b on a.cashbillid=b.CashBillID
					LEFT JOIN ld_paymentplan c on b.entitytypeid=c.paymentplanid
					where c.entitytypeid=@tmp_entitytypeid and a.deleted=0 and c.deleted=0
						and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)) c;
		ELSEIF tmp_entitytype='PaymentPlan' THEN
			select 
				count(DISTINCT currency_id) into @cnt1 
			from (
				select currency_id from ld_paymentplan where paymentplanid=@tmp_entitytypeid and deleted=0
				UNION ALL
					select 
						a.currency_id 
					from ld_cashbill a
					LEFT JOIN ld_cashbill2paymentplan b on a.cashbillid=b.CashBillID
					where b.entitytypeid=@tmp_entitytypeid and a.deleted=0
						and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)) c;
		ELSEIF tmp_entitytype='Invoice' THEN
			select 
				count(DISTINCT currency_id) into @cnt1 
			from (
				select currency_id from ld_invoice where invoiceid=@tmp_entitytypeid and deleted=0
				UNION ALL
					select 
						a.currency_id 
					from ld_cashbill a
					LEFT JOIN ld_cashbill2paymentplan b on a.cashbillid=b.CashBillID
					where b.entitytypeid=@tmp_entitytypeid and a.deleted=0
						and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)) c;
		ELSEIF tmp_entitytype='OutboundOrder' THEN
			select 
				count(DISTINCT currency_id) into @cnt1 
			from (
				select currency_id from ld_outboundorder where out_id=@tmp_entitytypeid and deleted=0
				UNION ALL
					select 
						a.currency_id 
					from ld_cashbill a
					LEFT JOIN ld_cashbill2paymentplan b on a.cashbillid=b.CashBillID
					where b.entitytypeid=@tmp_entitytypeid and a.deleted=0
						and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)) c;
		END IF;
	
		-- 如果没有多币种的收款
		IF @cnt1=1 THEN
			set @sales_total=0.00;
			set @sales_date='0000-00-00';
			set @sales_total2=0.00;
			set @sales_date2='0000-00-00';
				
			select
				sum(h.amount) into @sales_total
			from (
				select 
					a.cashbillid,
					b.entitytypeid,
					b.amount
				from ld_cashbill a 
				INNER JOIN ld_cashbill2paymentplan b on a.cashbillid=b.CashBillID  
				where a.deleted=0 and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)
				UNION ALL
				select * from (
					select 
						e.cashbillid,
						f.entitytypeid,
						e.NoPaymentplan as amount
					from ld_cashbill e
					inner JOIN (select * from (
							select CashBillID,entitytypeid 
								from ld_cashbill2paymentplan 
								order by CashBillID,sequence) t group by CashBillID) f on e.cashbillid=f.CashBillID
							where e.deleted=0 and e.NoPaymentplan<>0 and f.entitytypeid>0 
								and IF(e.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)) as g) as h
			where h.entitytypeid=@tmp_entitytypeid
			group by h.entitytypeid;

			select
				max(a.cashbilldate) into @sales_date
			from ld_cashbill a 
			INNER JOIN ld_cashbill2paymentplan b on a.cashbillid=b.CashBillID
			where a.deleted=0 and b.entitytypeid=@tmp_entitytypeid 
				and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)
			group by b.entitytypeid;

			-- 计算合同订单已收金额时，需要考虑合同订单对应的回款计划的收款
			select
				sum(h.amount) into @sales_total2
			from (
				select 
					a.cashbillid,
					b.entitytypeid,
					b.amount
				from ld_cashbill a 
				INNER JOIN ld_cashbill2paymentplan b on a.cashbillid=b.CashBillID 
				where a.deleted=0 and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)
				UNION ALL
				select * from (
					select 
						e.cashbillid,
						f.entitytypeid,
						e.NoPaymentplan as amount
					from ld_cashbill e
					inner JOIN (select * from (
							select CashBillID,entitytypeid 
								from ld_cashbill2paymentplan 
								order by CashBillID,sequence) t group by CashBillID) f on e.cashbillid=f.CashBillID
							where e.deleted=0 and e.NoPaymentplan<>0 and f.entitytypeid>0 
								and IF(e.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)) as g) as h
			LEFT JOIN ld_paymentplan i on h.entitytypeid=i.paymentplanid
			where i.entitytypeid=@tmp_entitytypeid
			group by i.entitytypeid;
							
			select
				max(a.cashbilldate) into @sales_date2
			from ld_cashbill a 
			INNER JOIN ld_cashbill2paymentplan b on a.cashbillid=b.CashBillID
			LEFT JOIN ld_paymentplan c on b.entitytypeid=c.paymentplanid
			where a.deleted=0 and c.entitytypeid=@tmp_entitytypeid
				and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)
			group by c.entitytypeid;
				

			IF tmp_entitytype='SalesOrder' THEN
				update ld_salesorder set received_amount=round(@sales_total,2)+round(@sales_total2,2),receivable_balance=round(total-received_amount,2),cashbilldate=IF(@sales_date>@sales_date2,@sales_date,@sales_date2) where salesorderid=@tmp_entitytypeid;
			ELSEIF tmp_entitytype='ServiceContracts' THEN
				update ld_servicecontracts set received_amount=round(@sales_total,2)+round(@sales_total2,2),receivable_balance=round(total-received_amount,2),cashbilldate=IF(@sales_date>@sales_date2,@sales_date,@sales_date2) where servicecontractsid=@tmp_entitytypeid;
			ELSEIF tmp_entitytype='PaymentPlan' THEN
				update ld_paymentplan set actualamount=round(@sales_total,2),receivable_balance=round(amount-@sales_total,2),actualdate=@sales_date where paymentplanid=@tmp_entitytypeid;
				update ld_paymentplan set paymentstatus='未收' where paymentplanid=@tmp_entitytypeid and IFNULL(actualamount,0)=0;
				update ld_paymentplan set paymentstatus='部分已收' where paymentplanid=@tmp_entitytypeid and IFNULL(actualamount,0)>0 and IFNULL(receivable_balance,0)>0;  
			ELSEIF tmp_entitytype='Invoice' THEN
				update ld_invoice set received_amount=round(@sales_total,2),receivable_balance=round(total-@sales_total,2),cashbilldate=@sales_date where invoiceid=@tmp_entitytypeid; 
			ELSEIF tmp_entitytype='OutboundOrder' THEN
				update ld_outboundorder set received_amount=round(@sales_total,2),receivable_balance=round(total-@sales_total,2),cashbilldate=@sales_date where out_id=@tmp_entitytypeid; 
			END IF;
				
		-- 如果有多币种的收款
		ELSE
			set @sales_total=0.00;
			set @sales_date='0000-00-00';
			set @sales_total2=0.00;
			set @sales_date2='0000-00-00';
				
			select
				sum(h.amount) into @sales_total
			from (
				select 
					a.cashbillid,
					b.entitytypeid,
					b.amount/a.conversion_rate as amount
				from ld_cashbill a 
				INNER JOIN ld_cashbill2paymentplan b on a.cashbillid=b.CashBillID
				where a.deleted=0 and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)
				UNION ALL
				select * from (
					select 
						e.cashbillid,
						f.entitytypeid,
						e.NoPaymentplan/e.conversion_rate as amount
					from ld_cashbill e
					inner JOIN (select * from (
							select CashBillID,entitytypeid 
								from ld_cashbill2paymentplan 
								order by CashBillID,sequence) t group by CashBillID) f on e.cashbillid=f.CashBillID
							where e.deleted=0 and e.NoPaymentplan<>0 and f.entitytypeid>0 
								and IF(e.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)) as g) as h
			where h.entitytypeid=@tmp_entitytypeid
			group by h.entitytypeid;

			select
				max(a.cashbilldate) into @sales_date
			from ld_cashbill a 
			INNER JOIN ld_cashbill2paymentplan b on a.cashbillid=b.CashBillID
			where a.deleted=0 and b.entitytypeid=@tmp_entitytypeid
				and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)
			group by b.entitytypeid;
						
			-- 计算合同订单已收金额时，需要考虑合同订单对应的回款计划的收款	
			select
				sum(h.amount) into @sales_total2
			from (
				select 
					a.cashbillid,
					b.entitytypeid,
					b.amount/a.conversion_rate as amount
				from ld_cashbill a 
				INNER JOIN ld_cashbill2paymentplan b on a.cashbillid=b.CashBillID
				where a.deleted=0 and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)
				UNION ALL
				select * from (
					select 
						e.cashbillid,
						f.entitytypeid,
						e.NoPaymentplan/e.conversion_rate as amount
					from ld_cashbill e
					inner JOIN (select * from (
							select CashBillID,entitytypeid 
								from ld_cashbill2paymentplan 
								order by CashBillID,sequence) t group by CashBillID) f on e.cashbillid=f.CashBillID
							where e.deleted=0 and e.NoPaymentplan<>0 and f.entitytypeid>0 
								and IF(e.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)) as g) as h
			LEFT JOIN ld_paymentplan i on h.entitytypeid=i.paymentplanid
			where i.entitytypeid=@tmp_entitytypeid
			group by i.entitytypeid;
						
			select
				max(a.cashbilldate) into @sales_date2
			from ld_cashbill a 
			INNER JOIN ld_cashbill2paymentplan b on a.cashbillid=b.CashBillID 
			LEFT JOIN ld_paymentplan c on b.entitytypeid=c.paymentplanid
			where a.deleted=0 and c.entitytypeid=@tmp_entitytypeid
				and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)
			group by c.entitytypeid;
				
			IF tmp_entitytype='SalesOrder' THEN
				update ld_salesorder set received_amount=round(@sales_total*conversion_rate,2)+round(@sales_total2*conversion_rate,2),receivable_balance=round(total-received_amount,2),cashbilldate=IF(@sales_date>@sales_date2,@sales_date,@sales_date2) where salesorderid=@tmp_entitytypeid;
			ELSEIF tmp_entitytype='ServiceContracts' THEN
				update ld_servicecontracts set received_amount=round(@sales_total*conversion_rate,2)+round(@sales_total2*conversion_rate,2),receivable_balance=round(total-received_amount,2),cashbilldate=IF(@sales_date>@sales_date2,@sales_date,@sales_date2) where servicecontractsid=@tmp_entitytypeid;
			ELSEIF tmp_entitytype='PaymentPlan' THEN	
				update ld_paymentplan set actualamount=round(@sales_total*conversion_rate,2),receivable_balance=round(amount-round(@sales_total*conversion_rate,2),2),actualdate=@sales_date where paymentplanid=@tmp_entitytypeid;
				update ld_paymentplan set paymentstatus='未收' where paymentplanid=@tmp_entitytypeid and IFNULL(actualamount,0)=0;
				update ld_paymentplan set paymentstatus='部分已收' where paymentplanid=@tmp_entitytypeid and IFNULL(actualamount,0)>0 and IFNULL(receivable_balance,0)>0;   
			ELSEIF tmp_entitytype='Invoice' THEN	
				update ld_invoice set received_amount=round(@sales_total*conversion_rate,2),receivable_balance=round(total-round(@sales_total*conversion_rate,2),2),cashbilldate=@sales_date where invoiceid=@tmp_entitytypeid; 
			ELSEIF tmp_entitytype='OutboundOrder' THEN	
				update ld_outboundorder set received_amount=round(@sales_total*conversion_rate,2),receivable_balance=round(total-round(@sales_total*conversion_rate,2),2),cashbilldate=@sales_date where out_id=@tmp_entitytypeid;
			END IF;
		End IF;
	Fetch cur1 into tmp_entitytypeid,tmp_entitytype;
	end while;
	close cur1;
end ||
delimiter;

DROP PROCEDURE IF EXISTS `update_sales_total2`;
delimiter ||
CREATE  PROCEDURE `update_sales_total2`(
	tmp_entitytypeid int(19),
	tmp_entitytype varchar(100)
)
BEGIN
		
	select ifnull(deploy_value,0) into @deploy_value from ld_systems_deploy where deploy_type=83;
	
	set @tmp_entitytypeid=0;
	set @tmp_entitytypeid=tmp_entitytypeid;
	
	set @cnt1=0;	
	IF tmp_entitytype='SalesOrder' THEN
		select 
			count(DISTINCT currency_id) into @cnt1 
		from (
			select currency_id from ld_salesorder where salesorderid=@tmp_entitytypeid and deleted=0
			UNION ALL
				select 
					a.currency_id 
				from ld_cashbill a
				LEFT JOIN ld_cashbill2paymentplan b on a.cashbillid=b.CashBillID
				where b.entitytypeid=@tmp_entitytypeid and a.deleted=0
					and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)
			UNION ALL
				select 
					a.currency_id 
				from ld_cashbill a
				LEFT JOIN ld_cashbill2paymentplan b on a.cashbillid=b.CashBillID
				LEFT JOIN ld_paymentplan c on b.entitytypeid=c.paymentplanid
				where c.entitytypeid=@tmp_entitytypeid and a.deleted=0 and c.deleted=0
					and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)) c;
	ELSEIF tmp_entitytype='ServiceContracts' THEN
		select 
			count(DISTINCT currency_id) into @cnt1 
		from (
			select currency_id from ld_servicecontracts where servicecontractsid=@tmp_entitytypeid and deleted=0
			UNION ALL
				select 
					a.currency_id 
				from ld_cashbill a
				LEFT JOIN ld_cashbill2paymentplan b on a.cashbillid=b.CashBillID
				where b.entitytypeid=@tmp_entitytypeid and a.deleted=0
					and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)
			UNION ALL
				select 
					a.currency_id 
				from ld_cashbill a
				LEFT JOIN ld_cashbill2paymentplan b on a.cashbillid=b.CashBillID
				LEFT JOIN ld_paymentplan c on b.entitytypeid=c.paymentplanid
				where c.entitytypeid=@tmp_entitytypeid and a.deleted=0 and c.deleted=0
					and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)) c;
	ELSEIF tmp_entitytype='PaymentPlan' THEN
		select 
			count(DISTINCT currency_id) into @cnt1 
		from (
			select currency_id from ld_paymentplan where paymentplanid=@tmp_entitytypeid and deleted=0
			UNION ALL
				select 
					a.currency_id 
				from ld_cashbill a
				LEFT JOIN ld_cashbill2paymentplan b on a.cashbillid=b.CashBillID
				where b.entitytypeid=@tmp_entitytypeid and a.deleted=0
					and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)) c;
	ELSEIF tmp_entitytype='Invoice' THEN
		select 
			count(DISTINCT currency_id) into @cnt1 
		from (
			select currency_id from ld_invoice where invoiceid=@tmp_entitytypeid and deleted=0
			UNION ALL
				select 
					a.currency_id 
				from ld_cashbill a
				LEFT JOIN ld_cashbill2paymentplan b on a.cashbillid=b.CashBillID
				where b.entitytypeid=@tmp_entitytypeid and a.deleted=0
					and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)) c;
	ELSEIF tmp_entitytype='OutboundOrder' THEN
		select 
			count(DISTINCT currency_id) into @cnt1 
		from (
			select currency_id from ld_outboundorder where out_id=@tmp_entitytypeid and deleted=0
			UNION ALL
				select 
					a.currency_id 
				from ld_cashbill a
				LEFT JOIN ld_cashbill2paymentplan b on a.cashbillid=b.CashBillID
				where b.entitytypeid=@tmp_entitytypeid and a.deleted=0
					and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)) c;
	END IF;

	-- 如果没有多币种的收款
	IF @cnt1=1 THEN
		set @sales_total=0.00;
		set @sales_date='0000-00-00';
		set @sales_total2=0.00;
		set @sales_date2='0000-00-00';
			
		select
			sum(h.amount) into @sales_total
		from (
			select 
				a.cashbillid,
				b.entitytypeid,
				b.amount
			from ld_cashbill a 
			INNER JOIN ld_cashbill2paymentplan b on a.cashbillid=b.CashBillID  
			where a.deleted=0 and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)
			UNION ALL
			select * from (
				select 
					e.cashbillid,
					f.entitytypeid,
					e.NoPaymentplan as amount
				from ld_cashbill e
				inner JOIN (select * from (
						select CashBillID,entitytypeid 
							from ld_cashbill2paymentplan 
							order by CashBillID,sequence) t group by CashBillID) f on e.cashbillid=f.CashBillID
						where e.deleted=0 and e.NoPaymentplan<>0 and f.entitytypeid>0 
							and IF(e.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)) as g) as h
		where h.entitytypeid=@tmp_entitytypeid
		group by h.entitytypeid;

		select
			max(a.cashbilldate) into @sales_date
		from ld_cashbill a 
		INNER JOIN ld_cashbill2paymentplan b on a.cashbillid=b.CashBillID
		where a.deleted=0 and b.entitytypeid=@tmp_entitytypeid 
			and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)
		group by b.entitytypeid;

		-- 计算合同订单已收金额时，需要考虑合同订单对应的回款计划的收款
		select
			sum(h.amount) into @sales_total2
		from (
			select 
				a.cashbillid,
				b.entitytypeid,
				b.amount
			from ld_cashbill a 
			INNER JOIN ld_cashbill2paymentplan b on a.cashbillid=b.CashBillID 
			where a.deleted=0 and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)
			UNION ALL
			select * from (
				select 
					e.cashbillid,
					f.entitytypeid,
					e.NoPaymentplan as amount
				from ld_cashbill e
				inner JOIN (select * from (
						select CashBillID,entitytypeid 
							from ld_cashbill2paymentplan 
							order by CashBillID,sequence) t group by CashBillID) f on e.cashbillid=f.CashBillID
						where e.deleted=0 and e.NoPaymentplan<>0 and f.entitytypeid>0 
							and IF(e.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)) as g) as h
		LEFT JOIN ld_paymentplan i on h.entitytypeid=i.paymentplanid
		where i.entitytypeid=@tmp_entitytypeid
		group by i.entitytypeid;
						
		select
			max(a.cashbilldate) into @sales_date2
		from ld_cashbill a 
		INNER JOIN ld_cashbill2paymentplan b on a.cashbillid=b.CashBillID
		LEFT JOIN ld_paymentplan c on b.entitytypeid=c.paymentplanid
		where a.deleted=0 and c.entitytypeid=@tmp_entitytypeid
			and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)
		group by c.entitytypeid;
			

		IF tmp_entitytype='SalesOrder' THEN
			update ld_salesorder set received_amount=round(@sales_total,2)+round(@sales_total2,2),receivable_balance=round(total-received_amount,2),cashbilldate=IF(@sales_date>@sales_date2,@sales_date,@sales_date2) where salesorderid=@tmp_entitytypeid;
		ELSEIF tmp_entitytype='ServiceContracts' THEN
			update ld_servicecontracts set received_amount=round(@sales_total,2)+round(@sales_total2,2),receivable_balance=round(total-received_amount,2),cashbilldate=IF(@sales_date>@sales_date2,@sales_date,@sales_date2) where servicecontractsid=@tmp_entitytypeid;
		ELSEIF tmp_entitytype='PaymentPlan' THEN
			update ld_paymentplan set actualamount=round(@sales_total,2),receivable_balance=round(amount-@sales_total,2),actualdate=@sales_date where paymentplanid=@tmp_entitytypeid;
			update ld_paymentplan set paymentstatus='未收' where paymentplanid=@tmp_entitytypeid and IFNULL(actualamount,0)=0;
			update ld_paymentplan set paymentstatus='部分已收' where paymentplanid=@tmp_entitytypeid and IFNULL(actualamount,0)>0 and IFNULL(receivable_balance,0)>0;  
		ELSEIF tmp_entitytype='Invoice' THEN
			update ld_invoice set received_amount=round(@sales_total,2),receivable_balance=round(total-@sales_total,2),cashbilldate=@sales_date where invoiceid=@tmp_entitytypeid; 
		ELSEIF tmp_entitytype='OutboundOrder' THEN
			update ld_outboundorder set received_amount=round(@sales_total,2),receivable_balance=round(total-@sales_total,2),cashbilldate=@sales_date where out_id=@tmp_entitytypeid; 
		END IF;
			
	-- 如果有多币种的收款
	ELSE
		set @sales_total=0.00;
		set @sales_date=NULL;
		set @sales_total2=0.00;
		set @sales_date2=NULL;
			
		select
			sum(h.amount) into @sales_total
		from (
			select 
				a.cashbillid,
				b.entitytypeid,
				b.amount/a.conversion_rate as amount
			from ld_cashbill a 
			INNER JOIN ld_cashbill2paymentplan b on a.cashbillid=b.CashBillID
			where a.deleted=0 and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)
			UNION ALL
			select * from (
				select 
					e.cashbillid,
					f.entitytypeid,
					e.NoPaymentplan/e.conversion_rate as amount
				from ld_cashbill e
				inner JOIN (select * from (
						select CashBillID,entitytypeid 
							from ld_cashbill2paymentplan 
							order by CashBillID,sequence) t group by CashBillID) f on e.cashbillid=f.CashBillID
						where e.deleted=0 and e.NoPaymentplan<>0 and f.entitytypeid>0 
							and IF(e.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)) as g) as h
		where h.entitytypeid=@tmp_entitytypeid
		group by h.entitytypeid;

		select
			max(a.cashbilldate) into @sales_date
		from ld_cashbill a 
		INNER JOIN ld_cashbill2paymentplan b on a.cashbillid=b.CashBillID
		where a.deleted=0 and b.entitytypeid=@tmp_entitytypeid
			and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)
		group by b.entitytypeid;
					
		-- 计算合同订单已收金额时，需要考虑合同订单对应的回款计划的收款	
		select
			sum(h.amount) into @sales_total2
		from (
			select 
				a.cashbillid,
				b.entitytypeid,
				b.amount/a.conversion_rate as amount
			from ld_cashbill a 
			INNER JOIN ld_cashbill2paymentplan b on a.cashbillid=b.CashBillID
			where a.deleted=0 and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)
			UNION ALL
			select * from (
				select 
					e.cashbillid,
					f.entitytypeid,
					e.NoPaymentplan/e.conversion_rate as amount
				from ld_cashbill e
				inner JOIN (select * from (
						select CashBillID,entitytypeid 
							from ld_cashbill2paymentplan 
							order by CashBillID,sequence) t group by CashBillID) f on e.cashbillid=f.CashBillID
						where e.deleted=0 and e.NoPaymentplan<>0 and f.entitytypeid>0 
							and IF(e.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)) as g) as h
		LEFT JOIN ld_paymentplan i on h.entitytypeid=i.paymentplanid
		where i.entitytypeid=@tmp_entitytypeid
		group by i.entitytypeid;
					
		select
			max(a.cashbilldate) into @sales_date2
		from ld_cashbill a 
		INNER JOIN ld_cashbill2paymentplan b on a.cashbillid=b.CashBillID 
		LEFT JOIN ld_paymentplan c on b.entitytypeid=c.paymentplanid
		where a.deleted=0 and c.entitytypeid=@tmp_entitytypeid
			and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)
		group by c.entitytypeid;
			
		IF tmp_entitytype='SalesOrder' THEN
			update ld_salesorder set received_amount=round(@sales_total*conversion_rate,2)+round(@sales_total2*conversion_rate,2),receivable_balance=round(total-received_amount,2),cashbilldate=IF(@sales_date>@sales_date2,@sales_date,@sales_date2) where salesorderid=@tmp_entitytypeid;
		ELSEIF tmp_entitytype='ServiceContracts' THEN
			update ld_servicecontracts set received_amount=round(@sales_total*conversion_rate,2)+round(@sales_total2*conversion_rate,2),receivable_balance=round(total-received_amount,2),cashbilldate=IF(@sales_date>@sales_date2,@sales_date,@sales_date2) where servicecontractsid=@tmp_entitytypeid;
		ELSEIF tmp_entitytype='PaymentPlan' THEN	
			update ld_paymentplan set actualamount=round(@sales_total*conversion_rate,2),receivable_balance=round(amount-round(@sales_total*conversion_rate,2),2),actualdate=@sales_date where paymentplanid=@tmp_entitytypeid;
			update ld_paymentplan set paymentstatus='未收' where paymentplanid=@tmp_entitytypeid and IFNULL(actualamount,0)=0;
			update ld_paymentplan set paymentstatus='部分已收' where paymentplanid=@tmp_entitytypeid and IFNULL(actualamount,0)>0 and IFNULL(receivable_balance,0)>0;   
		ELSEIF tmp_entitytype='Invoice' THEN	
			update ld_invoice set received_amount=round(@sales_total*conversion_rate,2),receivable_balance=round(total-round(@sales_total*conversion_rate,2),2),cashbilldate=@sales_date where invoiceid=@tmp_entitytypeid; 
		ELSEIF tmp_entitytype='OutboundOrder' THEN	
			update ld_outboundorder set received_amount=round(@sales_total*conversion_rate,2),receivable_balance=round(total-round(@sales_total*conversion_rate,2),2),cashbilldate=@sales_date where out_id=@tmp_entitytypeid;
		END IF;
	End IF;
end ||
delimiter;

DROP PROCEDURE IF EXISTS `update_sales_total3`;
delimiter ||
CREATE  PROCEDURE `update_sales_total3`(
)
BEGIN
	
	declare tmp_entitytypeid int default 0;
	declare tmp_entitytype varchar(200) default NULL;

	declare cur1 CURSOR FOR SELECT DISTINCT
										entitytypeid,
										entitytype
									FROM (
										select
											b.entitytypeid,
											b.entitytype
										from ld_cashbill a 
										LEFT JOIN ld_cashbill2paymentplan b on a.cashbillid=b.CashBillID
										where a.deleted=0 and b.entitytypeid>0 and length(b.entitytype)>1
										UNION
										select 
												c.entitytypeid,
												c.entitytype
										from ld_cashbill a 
										LEFT JOIN ld_cashbill2paymentplan b on a.cashbillid=b.CashBillID
										INNER JOIN ld_paymentplan c on c.paymentplanid=b.entitytypeid
										where a.deleted=0 and b.entitytypeid>0 and length(b.entitytype)>1) a
									where entitytype in ('PaymentPlan','Invoice','OutboundOrder')
									ORDER BY entitytypeid;					
									
	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' set tmp_entitytypeid = NULL;
	
	select ifnull(deploy_value,0) into @deploy_value from ld_systems_deploy where deploy_type=83;
	
	OPEN cur1;
	Fetch cur1 into tmp_entitytypeid,tmp_entitytype;
	while(tmp_entitytypeid is not null) DO
	
		set @tmp_entitytypeid=0;
		set @tmp_entitytypeid=tmp_entitytypeid;
		
		
		set @cnt1=0;	
		IF tmp_entitytype='SalesOrder' THEN
			select 
				count(DISTINCT currency_id) into @cnt1 
			from (
				select currency_id from ld_salesorder where salesorderid=@tmp_entitytypeid and deleted=0
				UNION ALL
					select 
						a.currency_id 
					from ld_cashbill a
					LEFT JOIN ld_cashbill2paymentplan b on a.cashbillid=b.CashBillID
					where b.entitytypeid=@tmp_entitytypeid and a.deleted=0
						and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)
				UNION ALL
					select 
						a.currency_id 
					from ld_cashbill a
					LEFT JOIN ld_cashbill2paymentplan b on a.cashbillid=b.CashBillID
					LEFT JOIN ld_paymentplan c on b.entitytypeid=c.paymentplanid
					where c.entitytypeid=@tmp_entitytypeid and a.deleted=0 and c.deleted=0
						and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)) c;
		ELSEIF tmp_entitytype='ServiceContracts' THEN
			select 
				count(DISTINCT currency_id) into @cnt1 
			from (
				select currency_id from ld_servicecontracts where servicecontractsid=@tmp_entitytypeid and deleted=0
				UNION ALL
					select 
						a.currency_id 
					from ld_cashbill a
					LEFT JOIN ld_cashbill2paymentplan b on a.cashbillid=b.CashBillID
					where b.entitytypeid=@tmp_entitytypeid and a.deleted=0
						and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)
				UNION ALL
					select 
						a.currency_id 
					from ld_cashbill a
					LEFT JOIN ld_cashbill2paymentplan b on a.cashbillid=b.CashBillID
					LEFT JOIN ld_paymentplan c on b.entitytypeid=c.paymentplanid
					where c.entitytypeid=@tmp_entitytypeid and a.deleted=0 and c.deleted=0
						and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)) c;
		ELSEIF tmp_entitytype='PaymentPlan' THEN
			select 
				count(DISTINCT currency_id) into @cnt1 
			from (
				select currency_id from ld_paymentplan where paymentplanid=@tmp_entitytypeid and deleted=0
				UNION ALL
					select 
						a.currency_id 
					from ld_cashbill a
					LEFT JOIN ld_cashbill2paymentplan b on a.cashbillid=b.CashBillID
					where b.entitytypeid=@tmp_entitytypeid and a.deleted=0
						and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)) c;
		ELSEIF tmp_entitytype='Invoice' THEN
			select 
				count(DISTINCT currency_id) into @cnt1 
			from (
				select currency_id from ld_invoice where invoiceid=@tmp_entitytypeid and deleted=0
				UNION ALL
					select 
						a.currency_id 
					from ld_cashbill a
					LEFT JOIN ld_cashbill2paymentplan b on a.cashbillid=b.CashBillID
					where b.entitytypeid=@tmp_entitytypeid and a.deleted=0
						and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)) c;
		ELSEIF tmp_entitytype='OutboundOrder' THEN
			select 
				count(DISTINCT currency_id) into @cnt1 
			from (
				select currency_id from ld_outboundorder where out_id=@tmp_entitytypeid and deleted=0
				UNION ALL
					select 
						a.currency_id 
					from ld_cashbill a
					LEFT JOIN ld_cashbill2paymentplan b on a.cashbillid=b.CashBillID
					where b.entitytypeid=@tmp_entitytypeid and a.deleted=0
						and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)) c;
		END IF;
	
		-- 如果没有多币种的收款
		IF @cnt1=1 THEN
			set @sales_total=0.00;
			set @sales_date='0000-00-00';
			set @sales_total2=0.00;
			set @sales_date2='0000-00-00';
				
			select
				sum(h.amount) into @sales_total
			from (
				select 
					a.cashbillid,
					b.entitytypeid,
					b.amount
				from ld_cashbill a 
				INNER JOIN ld_cashbill2paymentplan b on a.cashbillid=b.CashBillID  
				where a.deleted=0 and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)
				UNION ALL
				select * from (
					select 
						e.cashbillid,
						f.entitytypeid,
						e.NoPaymentplan as amount
					from ld_cashbill e
					inner JOIN (select * from (
							select CashBillID,entitytypeid 
								from ld_cashbill2paymentplan 
								order by CashBillID,sequence) t group by CashBillID) f on e.cashbillid=f.CashBillID
							where e.deleted=0 and e.NoPaymentplan<>0 and f.entitytypeid>0 
								and IF(e.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)) as g) as h
			where h.entitytypeid=@tmp_entitytypeid
			group by h.entitytypeid;

			select
				max(a.cashbilldate) into @sales_date
			from ld_cashbill a 
			INNER JOIN ld_cashbill2paymentplan b on a.cashbillid=b.CashBillID
			where a.deleted=0 and b.entitytypeid=@tmp_entitytypeid 
				and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)
			group by b.entitytypeid;

			-- 计算合同订单已收金额时，需要考虑合同订单对应的回款计划的收款
			select
				sum(h.amount) into @sales_total2
			from (
				select 
					a.cashbillid,
					b.entitytypeid,
					b.amount
				from ld_cashbill a 
				INNER JOIN ld_cashbill2paymentplan b on a.cashbillid=b.CashBillID 
				where a.deleted=0 and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)
				UNION ALL
				select * from (
					select 
						e.cashbillid,
						f.entitytypeid,
						e.NoPaymentplan as amount
					from ld_cashbill e
					inner JOIN (select * from (
							select CashBillID,entitytypeid 
								from ld_cashbill2paymentplan 
								order by CashBillID,sequence) t group by CashBillID) f on e.cashbillid=f.CashBillID
							where e.deleted=0 and e.NoPaymentplan<>0 and f.entitytypeid>0 
								and IF(e.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)) as g) as h
			LEFT JOIN ld_paymentplan i on h.entitytypeid=i.paymentplanid
			where i.entitytypeid=@tmp_entitytypeid
			group by i.entitytypeid;
							
			select
				max(a.cashbilldate) into @sales_date2
			from ld_cashbill a 
			INNER JOIN ld_cashbill2paymentplan b on a.cashbillid=b.CashBillID
			LEFT JOIN ld_paymentplan c on b.entitytypeid=c.paymentplanid
			where a.deleted=0 and c.entitytypeid=@tmp_entitytypeid
				and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)
			group by c.entitytypeid;
				

			IF tmp_entitytype='SalesOrder' THEN
				update ld_salesorder set received_amount=round(@sales_total,2)+round(@sales_total2,2),receivable_balance=round(total-received_amount,2),cashbilldate=IF(@sales_date>@sales_date2,@sales_date,@sales_date2) where salesorderid=@tmp_entitytypeid;
			ELSEIF tmp_entitytype='ServiceContracts' THEN
				update ld_servicecontracts set received_amount=round(@sales_total,2)+round(@sales_total2,2),receivable_balance=round(total-received_amount,2),cashbilldate=IF(@sales_date>@sales_date2,@sales_date,@sales_date2) where servicecontractsid=@tmp_entitytypeid;
			ELSEIF tmp_entitytype='PaymentPlan' THEN
				update ld_paymentplan set actualamount=round(@sales_total,2),receivable_balance=round(amount-@sales_total,2),actualdate=@sales_date where paymentplanid=@tmp_entitytypeid;
				update ld_paymentplan set paymentstatus='未收' where paymentplanid=@tmp_entitytypeid and IFNULL(actualamount,0)=0;
				update ld_paymentplan set paymentstatus='部分已收' where paymentplanid=@tmp_entitytypeid and IFNULL(actualamount,0)>0 and IFNULL(receivable_balance,0)>0;  
			ELSEIF tmp_entitytype='Invoice' THEN
				update ld_invoice set received_amount=round(@sales_total,2),receivable_balance=round(total-@sales_total,2),cashbilldate=@sales_date where invoiceid=@tmp_entitytypeid; 
			ELSEIF tmp_entitytype='OutboundOrder' THEN
				update ld_outboundorder set received_amount=round(@sales_total,2),receivable_balance=round(total-@sales_total,2),cashbilldate=@sales_date where out_id=@tmp_entitytypeid; 
			END IF;
				
		-- 如果有多币种的收款
		ELSE
		  set @sales_total=0.00;
			set @sales_date='0000-00-00';
			set @sales_total2=0.00;
			set @sales_date2='0000-00-00';
				
			select
				sum(h.amount) into @sales_total
			from (
				select 
					a.cashbillid,
					b.entitytypeid,
					b.amount/a.conversion_rate as amount
				from ld_cashbill a 
				INNER JOIN ld_cashbill2paymentplan b on a.cashbillid=b.CashBillID
				where a.deleted=0 and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)
				UNION ALL
				select * from (
					select 
						e.cashbillid,
						f.entitytypeid,
						e.NoPaymentplan/e.conversion_rate as amount
					from ld_cashbill e
					inner JOIN (select * from (
							select CashBillID,entitytypeid 
								from ld_cashbill2paymentplan 
								order by CashBillID,sequence) t group by CashBillID) f on e.cashbillid=f.CashBillID
							where e.deleted=0 and e.NoPaymentplan<>0 and f.entitytypeid>0 
								and IF(e.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)) as g) as h
			where h.entitytypeid=@tmp_entitytypeid
			group by h.entitytypeid;

			select
				max(a.cashbilldate) into @sales_date
			from ld_cashbill a 
			INNER JOIN ld_cashbill2paymentplan b on a.cashbillid=b.CashBillID
			where a.deleted=0 and b.entitytypeid=@tmp_entitytypeid
				and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)
			group by b.entitytypeid;
						
			-- 计算合同订单已收金额时，需要考虑合同订单对应的回款计划的收款	
			select
				sum(h.amount) into @sales_total2
			from (
				select 
					a.cashbillid,
					b.entitytypeid,
					b.amount/a.conversion_rate as amount
				from ld_cashbill a 
				INNER JOIN ld_cashbill2paymentplan b on a.cashbillid=b.CashBillID
				where a.deleted=0 and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)
				UNION ALL
				select * from (
					select 
						e.cashbillid,
						f.entitytypeid,
						e.NoPaymentplan/e.conversion_rate as amount
					from ld_cashbill e
					inner JOIN (select * from (
							select CashBillID,entitytypeid 
								from ld_cashbill2paymentplan 
								order by CashBillID,sequence) t group by CashBillID) f on e.cashbillid=f.CashBillID
							where e.deleted=0 and e.NoPaymentplan<>0 and f.entitytypeid>0 
								and IF(e.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)) as g) as h
			LEFT JOIN ld_paymentplan i on h.entitytypeid=i.paymentplanid
			where i.entitytypeid=@tmp_entitytypeid
			group by i.entitytypeid;
						
			select
				max(a.cashbilldate) into @sales_date2
			from ld_cashbill a 
			INNER JOIN ld_cashbill2paymentplan b on a.cashbillid=b.CashBillID 
			LEFT JOIN ld_paymentplan c on b.entitytypeid=c.paymentplanid
			where a.deleted=0 and c.entitytypeid=@tmp_entitytypeid
				and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)
			group by c.entitytypeid;
				
			IF tmp_entitytype='SalesOrder' THEN
				update ld_salesorder set received_amount=round(@sales_total*conversion_rate,2)+round(@sales_total2*conversion_rate,2),receivable_balance=round(total-received_amount,2),cashbilldate=IF(@sales_date>@sales_date2,@sales_date,@sales_date2) where salesorderid=@tmp_entitytypeid;
			ELSEIF tmp_entitytype='ServiceContracts' THEN
				update ld_servicecontracts set received_amount=round(@sales_total*conversion_rate,2)+round(@sales_total2*conversion_rate,2),receivable_balance=round(total-received_amount,2),cashbilldate=IF(@sales_date>@sales_date2,@sales_date,@sales_date2) where servicecontractsid=@tmp_entitytypeid;
			ELSEIF tmp_entitytype='PaymentPlan' THEN	
				update ld_paymentplan set actualamount=round(@sales_total*conversion_rate,2),receivable_balance=round(amount-round(@sales_total*conversion_rate,2),2),actualdate=@sales_date where paymentplanid=@tmp_entitytypeid;
				update ld_paymentplan set paymentstatus='未收' where paymentplanid=@tmp_entitytypeid and IFNULL(actualamount,0)=0;
				update ld_paymentplan set paymentstatus='部分已收' where paymentplanid=@tmp_entitytypeid and IFNULL(actualamount,0)>0 and IFNULL(receivable_balance,0)>0;
			ELSEIF tmp_entitytype='Invoice' THEN	
				update ld_invoice set received_amount=round(@sales_total*conversion_rate,2),receivable_balance=round(total-round(@sales_total*conversion_rate,2),2),cashbilldate=@sales_date where invoiceid=@tmp_entitytypeid; 
			ELSEIF tmp_entitytype='OutboundOrder' THEN	
				update ld_outboundorder set received_amount=round(@sales_total*conversion_rate,2),receivable_balance=round(total-round(@sales_total*conversion_rate,2),2),cashbilldate=@sales_date where out_id=@tmp_entitytypeid;
			END IF;
		End IF;
	Fetch cur1 into tmp_entitytypeid,tmp_entitytype;
	end while;
	close cur1;
end ||
delimiter;

DROP PROCEDURE IF EXISTS update_attachmentsforbills_id;
delimiter ||
CREATE PROCEDURE update_attachmentsforbills_id(
)
begin

		set @cnt=0;
		set @maxid=0;
		set @i=0;
		SELECT count(1) into @cnt from ld_attachmentsforbills;

		IF @cnt>0 and exists (select 1 from ld_attachmentsforbills where attachmentsid not in (select crmid from ld_crmentity)) THEN
			
			SELECT max(crmid) into @maxid from ld_crmentity;
			
			-- 更新 ld_crmentity_seq
			UPDATE ld_crmentity_seq set id=@maxid+@cnt;
			
			-- 更新 ld_attachmentsforbills 表的 attachmentsid
			update ld_attachmentsforbills set attachmentsid=attachmentsid+10000000;
			update ld_attachmentsforbills set attachmentsid=@maxid+(@i:=@i+1) order by attachmentsid;

			delete from ld_crmentity where setype='Attachment';
			-- 插入 attachmentsid 到 ld_crmentity
			INSERT INTO ld_crmentity(crmid,setype) SELECT attachmentsid,'Attachment' FROM ld_attachmentsforbills;
	END IF;
end ||
delimiter;

CALL update_attachmentsforbills_id();
delimiter;
-- 2017-01-24

update ld_field_seq set id=(select max(fieldid) from ld_field);
update ld_blocks_seq set id=(select max(blockid) from ld_blocks);
update ld_relatedlists_seq set id=(select max(relation_id) from ld_relatedlists);
update ld_customview_seq set id = (select max(cvid) from ld_customview);
update ld_links_seq set id=(select max(linkid) from ld_links);
update ld_picklist_dependency_seq set id=(select max(id) from ld_picklist_dependency);
update ld_crmentity_seq set id=(select max(crmid) from ld_crmentity);
update ld_approve_seq set id=(select max(id) from ld_approve);
update ld_approvestep_seq set id=(select max(id) from ld_approvestep);
update ld_autotask_seq set id = (select MAX(autotaskid) from ld_autotask);
update ld_currency_info_seq set id=(select max(id) from ld_currency_info);
update ld_users_seq set id=(select max(id) from ld_users);
update ld_tabdetailfield_seq set id=(select max(tabdetailfieldid) from ld_tabdetailfield);
update ld_customreport_info_seq set id=(select max(report_id) from ld_customreport_info);
delimiter;

update ld_version set old_version='V6.6.2' ,current_version='V6.6.2' ,remark='V6.6.2-20170124';
delimiter;