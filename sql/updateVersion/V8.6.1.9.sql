UPDATE ld_desk SET fieldlabel='共选择 %d 条记录，成功 %d 条，失败 %d 条。' WHERE labelbol='APPROVE_BATCHSUBMITLOG_INFO' and Labeltype='fixedstr' and languagetype='zh';
delimiter;

UPDATE ld_desk SET fieldlabel = '请至少选择一个查询字段！' where labelbol='SetLeastOneFieldQuerying' and Labeltype='jspop' and languagetype='zh';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SetLeast3DisplayFields','请至少设置3个显示列字段！','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='SetLeast3DisplayFields' and Labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SetLeast3DisplayFields','Please set at least 3 display column fields!','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='SetLeast3DisplayFields' and Labeltype='jspop' and languagetype='en');
delimiter;

UPDATE `ld_customreport` SET `sqlstr`='SELECT\n	p_num.where_time,\n	p_num.group_time,\n	(\n		CASE\n		WHEN \'{timetype}\' = \'本年和去年-按季度\' THEN\n			CONCAT(\n				\'第\',\n				p_num.group_time,\n				\'季度\'\n			)\n		ELSE\n			CONCAT(p_num.group_time, \'月\')\n		END\n	) AS dispaly_group_time,\n	p_num.pre_tax_amount,\n	p_num.now_tax_amount\nFROM\n	(\n		SELECT\n			timetype_table.where_time AS where_time,\n			timetype_table.group_time AS group_time,\n			pre_salesorder.tax_amount AS pre_tax_amount,\n			now_salesorder.tax_amount AS now_tax_amount\n		FROM\n			(\n				SELECT\n					(\n						CASE\n						WHEN \'{timetype}\' = \'本年和去年-按月\' THEN\n							YEAR (NOW())\n						WHEN \'{timetype}\' = \'本年和去年-按季度\' THEN\n							YEAR (NOW())\n						WHEN \'{timetype}\' = \'本季度和上季度-按月\' THEN\n							QUARTER (NOW())\n						ELSE\n							YEAR (NOW())\n						END\n					) AS where_time,\n					(\n						CASE\n						WHEN \'{timetype}\' = \'本年和去年-按月\' THEN\n							MONTH (date)\n						WHEN \'{timetype}\' = \'本年和去年-按季度\' THEN\n							QUARTER (date)\n						WHEN \'{timetype}\' = \'本季度和上季度-按月\' THEN\n							MONTH (date)\n						ELSE\n							MONTH (date)\n						END\n					) AS group_time\n				FROM\n					tmp_date a\n				WHERE\n					date LIKE \'%2023%\'\n				GROUP BY\n					group_time\n			) timetype_table\n		LEFT JOIN (\n			SELECT\n				now_s_detail.id AS invoiceid,\n				(\n					CASE\n					WHEN \'{timetype}\' = \'本年和去年-按月\' THEN\n						YEAR (ld_invoice.invoicedate)\n					WHEN \'{timetype}\' = \'本年和去年-按季度\' THEN\n						YEAR (ld_invoice.invoicedate)\n					WHEN \'{timetype}\' = \'本季度和上季度-按月\' THEN\n						QUARTER (ld_invoice.invoicedate)\n					ELSE\n						YEAR (ld_invoice.invoicedate)\n					END\n				) AS where_time,\n				(\n					CASE\n					WHEN \'{timetype}\' = \'本年和去年-按月\' THEN\n						MONTH (ld_invoice.invoicedate)\n					WHEN \'{timetype}\' = \'本年和去年-按季度\' THEN\n						QUARTER (ld_invoice.invoicedate)\n					WHEN \'{timetype}\' = \'本季度和上季度-按月\' THEN\n						MONTH (ld_invoice.invoicedate)\n					ELSE\n						MONTH (ld_invoice.invoicedate)\n					END\n				) AS group_time,\n				sum(\n					now_s_detail.tax_amount / ld_invoice.conversion_rate\n				) AS tax_amount\n			FROM\n				ld_invoice\n			LEFT JOIN ld_invoicedetail now_s_detail ON now_s_detail.id = ld_invoice.invoiceid\n			LEFT JOIN ld_products ON ld_products.productid = now_s_detail.productid\n			WHERE\n				(\n					ld_products.productname = \'{productname}\'\n					OR \'{productname}\' = \'\'\n				)\n			AND (\n				\'{productcategory}\' = \'\'\n				OR FIND_IN_SET(\n					ld_products.productcategory,\n					\'{productcategory}\'\n				)\n			)\n			AND FIND_IN_SET(\n				ld_invoice.approvestatus,\n				\'{approvestatus}\'\n			)\n			AND FIND_IN_SET(\n				ld_invoice.smownerid,\n				\'{userscope}\'\n			)\n			AND (\n				ld_invoice.invoicedate BETWEEN \'{starttime}\'\n				AND \'{endtime}\'\n			)\n			GROUP BY\n				where_time,\n				group_time\n		) now_salesorder ON now_salesorder.where_time = timetype_table.where_time\n		AND now_salesorder.group_time = timetype_table.group_time\n		LEFT JOIN (\n			SELECT\n				pre_s_detail.id AS invoiceid,\n				(\n					CASE\n					WHEN \'{timetype}\' = \'本年和去年-按月\' THEN\n						YEAR (\n							DATE_ADD(\n								ld_invoice.invoicedate,\n								INTERVAL 1 YEAR\n							)\n						)\n					WHEN \'{timetype}\' = \'本年和去年-按季度\' THEN\n						YEAR (\n							DATE_ADD(\n								ld_invoice.invoicedate,\n								INTERVAL 1 YEAR\n							)\n						)\n					WHEN \'{timetype}\' = \'本季度和上季度-按月\' THEN\n						QUARTER (\n							DATE_ADD(\n								ld_invoice.invoicedate,\n								INTERVAL 1 QUARTER\n							)\n						)\n					ELSE\n						YEAR (\n							DATE_ADD(\n								ld_invoice.invoicedate,\n								INTERVAL 1 YEAR\n							)\n						)\n					END\n				) AS where_time,\n				(\n					CASE\n					WHEN \'{timetype}\' = \'本年和去年-按月\' THEN\n						MONTH (ld_invoice.invoicedate)\n					WHEN \'{timetype}\' = \'本年和去年-按季度\' THEN\n						QUARTER (ld_invoice.invoicedate)\n					WHEN \'{timetype}\' = \'本季度和上季度-按月\' THEN\n						MONTH (ld_invoice.invoicedate)\n					ELSE\n						MONTH (ld_invoice.invoicedate)\n					END\n				) AS group_time,\n				sum(\n					pre_s_detail.tax_amount / ld_invoice.conversion_rate\n				) AS tax_amount\n			FROM\n				ld_invoice\n			LEFT JOIN ld_invoicedetail pre_s_detail ON pre_s_detail.id = ld_invoice.invoiceid\n			LEFT JOIN ld_products ON ld_products.productid = pre_s_detail.productid\n			WHERE\n				(\n					ld_products.productname = \'{productname}\'\n					OR \'{productname}\' = \'\'\n				)\n			AND (\n				\'{productcategory}\' = \'\'\n				OR FIND_IN_SET(\n					ld_products.productcategory,\n					\'{productcategory}\'\n				)\n			)\n			AND FIND_IN_SET(\n				ld_invoice.approvestatus,\n				\'{approvestatus}\'\n			)\n			AND FIND_IN_SET(\n				ld_invoice.smownerid,\n				\'{userscope}\'\n			)\n			GROUP BY\n				where_time,\n				group_time\n		) pre_salesorder ON pre_salesorder.where_time = timetype_table.where_time\n		AND pre_salesorder.group_time = timetype_table.group_time\n		GROUP BY\n			timetype_table.group_time\n	) p_num\nGROUP BY\n	p_num.group_time' WHERE (`primaryname`='product_invoice_amount_y_to_y');
delimiter;

UPDATE `ld_customreport` SET `sqlstr`='SELECT\n	(\n		CASE\n		WHEN \'{timetype}\' = \'季度\' THEN\n			CONCAT(\n				p_num.where_time,\n				\'-\',\n				\'第\',\n				p_num.group_time,\n				\'季度\'\n			)\n		ELSE\n			DATE_FORMAT(\n				STR_TO_DATE(\n					CONCAT(\n						p_num.where_time,\n						\'-\',\n						p_num.group_time\n					),\n					\'%Y-%m\'\n				),\n				\'%Y-%m\'\n			)\n		END\n	) AS dispaly_group_time,\n	sum(p_num.pre_tax_amount) AS pre_tax_amount,\n	sum(p_num.now_tax_amount) AS now_tax_amount\nFROM\n	(\n		SELECT\n			timetype_table.group_time AS group_time,\n			timetype_table.where_time AS where_time,\n			pre_outboundorder.tax_amount AS pre_tax_amount,\n			now_outboundorder.tax_amount AS now_tax_amount\n		FROM\n			(\n				SELECT\n					(\n						CASE\n						WHEN \'{timetype}\' = \'月\' THEN\n							MONTH (date)\n						WHEN \'{timetype}\' = \'季度\' THEN\n							QUARTER (date)\n						ELSE\n							MONTH (date)\n						END\n					) AS group_time,\n					where_table.where_time AS where_time\n				FROM\n					tmp_date,\n					(\n						SELECT\n							YEAR (\n								DATE_ADD(\n									\'{starttime}\',\n									INTERVAL seq YEAR\n								)\n							) where_time\n						FROM\n							sequence\n						WHERE\n							YEAR (\n								DATE_ADD(\n									\'{starttime}\',\n									INTERVAL seq YEAR\n								)\n							) <= YEAR (\'{endtime}\')\n					) where_table\n				WHERE\n					date LIKE \'%2023%\'\n				GROUP BY\n					where_time,\n					group_time\n			) timetype_table\n		LEFT JOIN (\n			SELECT\n				ld_outboundorder.out_id,\n				YEAR (ld_outboundorder.outdate) AS where_time,\n				(\n					CASE\n					WHEN \'{timetype}\' = \'月\' THEN\n						MONTH (ld_outboundorder.outdate)\n					WHEN \'{timetype}\' = \'季度\' THEN\n						QUARTER (ld_outboundorder.outdate)\n					ELSE\n						MONTH (ld_outboundorder.outdate)\n					END\n				) AS group_time,\n				sum(\n					now_s_detail.tax_amount / ld_outboundorder.conversion_rate\n				) AS tax_amount\n			FROM\n				ld_outboundorder\n			LEFT JOIN ld_outboundorderdetail now_s_detail ON now_s_detail.id = ld_outboundorder.out_id\n			LEFT JOIN ld_products ON ld_products.productid = now_s_detail.productid\n			WHERE\n				(\n					ld_products.productname = \'{productname}\'\n					OR \'{productname}\' = \'\'\n				)\n			AND (\n				\'{productcategory}\' = \'\'\n				OR FIND_IN_SET(\n					ld_products.productcategory,\n					\'{productcategory}\'\n				)\n			)\n			AND FIND_IN_SET(\n				ld_outboundorder.approvestatus,\n				\'{approvestatus}\'\n			)\n			AND FIND_IN_SET(\n				ld_outboundorder.smownerid,\n				\'{userscope}\'\n			)\n			AND (\n				ld_outboundorder.outdate BETWEEN \'{starttime}\'\n				AND \'{endtime}\'\n			)\n			GROUP BY\n				where_time,\n				group_time\n		) now_outboundorder ON now_outboundorder.group_time = timetype_table.group_time\n		AND now_outboundorder.where_time = timetype_table.where_time\n		LEFT JOIN (\n			SELECT\n				ld_outboundorder.out_id,\n				(\n					CASE\n					WHEN \'{timetype}\' = \'月\' THEN\n						YEAR (\n							DATE_ADD(\n								ld_outboundorder.outdate,\n								INTERVAL 1 MONTH\n							)\n						)\n					WHEN \'{timetype}\' = \'季度\' THEN\n						YEAR (\n							DATE_ADD(\n								ld_outboundorder.outdate,\n								INTERVAL 1 QUARTER\n							)\n						)\n					ELSE\n						YEAR (\n							DATE_ADD(\n								ld_outboundorder.outdate,\n								INTERVAL 1 MONTH\n							)\n						)\n					END\n				) AS where_time,\n				(\n					CASE\n					WHEN \'{timetype}\' = \'月\' THEN\n						MONTH (\n							DATE_ADD(\n								ld_outboundorder.outdate,\n								INTERVAL 1 MONTH\n							)\n						)\n					WHEN \'{timetype}\' = \'季度\' THEN\n						QUARTER (\n							DATE_ADD(\n								ld_outboundorder.outdate,\n								INTERVAL 1 QUARTER\n							)\n						)\n					ELSE\n						MONTH (\n							DATE_ADD(\n								ld_outboundorder.outdate,\n								INTERVAL 1 MONTH\n							)\n						)\n					END\n				) AS group_time,\n				sum(\n					pre_s_detail.tax_amount / ld_outboundorder.conversion_rate\n				) AS tax_amount\n			FROM\n				ld_outboundorder\n			LEFT JOIN ld_outboundorderdetail pre_s_detail ON pre_s_detail.id = ld_outboundorder.out_id\n			LEFT JOIN ld_products ON ld_products.productid = pre_s_detail.productid\n			WHERE\n				(\n					ld_products.productname = \'{productname}\'\n					OR \'{productname}\' = \'\'\n				)\n			AND (\n				\'{productcategory}\' = \'\'\n				OR FIND_IN_SET(\n					ld_products.productcategory,\n					\'{productcategory}\'\n				)\n			)\n			AND FIND_IN_SET(\n				ld_outboundorder.approvestatus,\n				\'{approvestatus}\'\n			)\n			AND FIND_IN_SET(\n				ld_outboundorder.smownerid,\n				\'{userscope}\'\n			)\n			GROUP BY\n				where_time,\n				group_time\n		) pre_outboundorder ON pre_outboundorder.group_time = timetype_table.group_time\n		AND pre_outboundorder.where_time = timetype_table.where_time\n		GROUP BY\n			timetype_table.where_time,\n			timetype_table.group_time\n	) p_num\nGROUP BY\n	p_num.where_time,\n	p_num.group_time' WHERE (`primaryname`='product_outboundorder_amount_m_to_m');
delimiter;

UPDATE `ld_customreport` SET `sqlstr`='SELECT\n	p_num.where_time,\n	p_num.group_time,\n	(\n		CASE\n		WHEN \'{timetype}\' = \'本年和去年-按季度\' THEN\n			CONCAT(\n				\'第\',\n				p_num.group_time,\n				\'季度\'\n			)\n		ELSE\n			CONCAT(p_num.group_time, \'月\')\n		END\n	) AS dispaly_group_time,\n	p_num.pre_tax_amount,\n	p_num.now_tax_amount\nFROM\n	(\n		SELECT\n			timetype_table.where_time AS where_time,\n			timetype_table.group_time AS group_time,\n			pre_salesorder.tax_amount AS pre_tax_amount,\n			now_salesorder.tax_amount AS now_tax_amount\n		FROM\n			(\n				SELECT\n					(\n						CASE\n						WHEN \'{timetype}\' = \'本年和去年-按月\' THEN\n							YEAR (NOW())\n						WHEN \'{timetype}\' = \'本年和去年-按季度\' THEN\n							YEAR (NOW())\n						WHEN \'{timetype}\' = \'本季度和上季度-按月\' THEN\n							QUARTER (NOW())\n						ELSE\n							YEAR (NOW())\n						END\n					) AS where_time,\n					(\n						CASE\n						WHEN \'{timetype}\' = \'本年和去年-按月\' THEN\n							MONTH (date)\n						WHEN \'{timetype}\' = \'本年和去年-按季度\' THEN\n							QUARTER (date)\n						WHEN \'{timetype}\' = \'本季度和上季度-按月\' THEN\n							MONTH (date)\n						ELSE\n							MONTH (date)\n						END\n					) AS group_time\n				FROM\n					tmp_date a\n				WHERE\n					date LIKE \'%2023%\'\n				GROUP BY\n					group_time\n			) timetype_table\n		LEFT JOIN (\n			SELECT\n				now_s_detail.id AS out_id,\n				(\n					CASE\n					WHEN \'{timetype}\' = \'本年和去年-按月\' THEN\n						YEAR (ld_outboundorder.outdate)\n					WHEN \'{timetype}\' = \'本年和去年-按季度\' THEN\n						YEAR (ld_outboundorder.outdate)\n					WHEN \'{timetype}\' = \'本季度和上季度-按月\' THEN\n						QUARTER (ld_outboundorder.outdate)\n					ELSE\n						YEAR (ld_outboundorder.outdate)\n					END\n				) AS where_time,\n				(\n					CASE\n					WHEN \'{timetype}\' = \'本年和去年-按月\' THEN\n						MONTH (ld_outboundorder.outdate)\n					WHEN \'{timetype}\' = \'本年和去年-按季度\' THEN\n						QUARTER (ld_outboundorder.outdate)\n					WHEN \'{timetype}\' = \'本季度和上季度-按月\' THEN\n						MONTH (ld_outboundorder.outdate)\n					ELSE\n						MONTH (ld_outboundorder.outdate)\n					END\n				) AS group_time,\n				sum(\n					now_s_detail.tax_amount / ld_outboundorder.conversion_rate\n				) AS tax_amount,\n				sum(now_s_detail.quantity) AS quantity\n			FROM\n				ld_outboundorder\n			LEFT JOIN ld_outboundorderdetail now_s_detail ON now_s_detail.id = ld_outboundorder.out_id\n			LEFT JOIN ld_products ON ld_products.productid = now_s_detail.productid\n			WHERE\n				(\n					ld_products.productname = \'{productname}\'\n					OR \'{productname}\' = \'\'\n				)\n			AND (\n				\'{productcategory}\' = \'\'\n				OR FIND_IN_SET(\n					ld_products.productcategory,\n					\'{productcategory}\'\n				)\n			)\n			AND FIND_IN_SET(\n				ld_outboundorder.approvestatus,\n				\'{approvestatus}\'\n			)\n			AND FIND_IN_SET(\n				ld_outboundorder.smownerid,\n				\'{userscope}\'\n			)\n			AND (\n				ld_outboundorder.outdate BETWEEN \'{starttime}\'\n				AND \'{endtime}\'\n			)\n			GROUP BY\n				where_time,\n				group_time\n		) now_salesorder ON now_salesorder.where_time = timetype_table.where_time\n		AND now_salesorder.group_time = timetype_table.group_time\n		LEFT JOIN (\n			SELECT\n				pre_s_detail.id AS out_id,\n				(\n					CASE\n					WHEN \'{timetype}\' = \'本年和去年-按月\' THEN\n						YEAR (\n							DATE_ADD(\n								ld_outboundorder.outdate,\n								INTERVAL 1 YEAR\n							)\n						)\n					WHEN \'{timetype}\' = \'本年和去年-按季度\' THEN\n						YEAR (\n							DATE_ADD(\n								ld_outboundorder.outdate,\n								INTERVAL 1 YEAR\n							)\n						)\n					WHEN \'{timetype}\' = \'本季度和上季度-按月\' THEN\n						QUARTER (\n							DATE_ADD(\n								ld_outboundorder.outdate,\n								INTERVAL 1 QUARTER\n							)\n						)\n					ELSE\n						YEAR (\n							DATE_ADD(\n								ld_outboundorder.outdate,\n								INTERVAL 1 YEAR\n							)\n						)\n					END\n				) AS where_time,\n				(\n					CASE\n					WHEN \'{timetype}\' = \'本年和去年-按月\' THEN\n						MONTH (ld_outboundorder.outdate)\n					WHEN \'{timetype}\' = \'本年和去年-按季度\' THEN\n						QUARTER (ld_outboundorder.outdate)\n					WHEN \'{timetype}\' = \'本季度和上季度-按月\' THEN\n						MONTH (ld_outboundorder.outdate)\n					ELSE\n						MONTH (ld_outboundorder.outdate)\n					END\n				) AS group_time,\n				sum(\n					pre_s_detail.tax_amount / ld_outboundorder.conversion_rate\n				) AS tax_amount,\n				sum(pre_s_detail.quantity) AS quantity\n			FROM\n				ld_outboundorder\n			LEFT JOIN ld_outboundorderdetail pre_s_detail ON pre_s_detail.id = ld_outboundorder.out_id\n			LEFT JOIN ld_products ON ld_products.productid = pre_s_detail.productid\n			WHERE\n				(\n					ld_products.productname = \'{productname}\'\n					OR \'{productname}\' = \'\'\n				)\n			AND (\n				\'{productcategory}\' = \'\'\n				OR FIND_IN_SET(\n					ld_products.productcategory,\n					\'{productcategory}\'\n				)\n			)\n			AND FIND_IN_SET(\n				ld_outboundorder.approvestatus,\n				\'{approvestatus}\'\n			)\n			AND FIND_IN_SET(\n				ld_outboundorder.smownerid,\n				\'{userscope}\'\n			)\n			GROUP BY\n				where_time,\n				group_time\n		) pre_salesorder ON pre_salesorder.where_time = timetype_table.where_time\n		AND pre_salesorder.group_time = timetype_table.group_time\n		GROUP BY\n			timetype_table.group_time\n	) p_num\nGROUP BY\n	p_num.group_time' WHERE (`primaryname`='product_outboundorder_amount_y_to_y');
delimiter;

UPDATE `ld_customreport` SET `sqlstr`='SELECT\n	(\n		CASE\n		WHEN \'{timetype}\' = \'季度\' THEN\n			CONCAT(\n				p_num.where_time,\n				\'-\',\n				\'第\',\n				p_num.group_time,\n				\'季度\'\n			)\n		ELSE\n			DATE_FORMAT(\n				STR_TO_DATE(\n					CONCAT(\n						p_num.where_time,\n						\'-\',\n						p_num.group_time\n					),\n					\'%Y-%m\'\n				),\n				\'%Y-%m\'\n			)\n		END\n	) AS dispaly_group_time,\n	sum(p_num.pre_tax_amount) AS pre_tax_amount,\n	sum(p_num.now_tax_amount) AS now_tax_amount\nFROM\n	(\n		SELECT\n			timetype_table.group_time AS group_time,\n			timetype_table.where_time AS where_time,\n			pre_salesorder.tax_amount AS pre_tax_amount,\n			now_salesorder.tax_amount AS now_tax_amount\n		FROM\n			(\n				SELECT\n					(\n						CASE\n						WHEN \'{timetype}\' = \'月\' THEN\n							MONTH (date)\n						WHEN \'{timetype}\' = \'季度\' THEN\n							QUARTER (date)\n						ELSE\n							MONTH (date)\n						END\n					) AS group_time,\n					where_table.where_time AS where_time\n				FROM\n					tmp_date,\n					(\n						SELECT\n							YEAR (\n								DATE_ADD(\n									\'{starttime}\',\n									INTERVAL seq YEAR\n								)\n							) where_time\n						FROM\n							sequence\n						WHERE\n							YEAR (\n								DATE_ADD(\n									\'{starttime}\',\n									INTERVAL seq YEAR\n								)\n							) <= YEAR (\'{endtime}\')\n					) where_table\n				WHERE\n					date LIKE \'%2023%\'\n				GROUP BY\n					where_time,\n					group_time\n			) timetype_table\n		LEFT JOIN (\n			SELECT\n				ld_salesorder.salesorderid,\n				YEAR (ld_salesorder.signed_data) AS where_time,\n				(\n					CASE\n					WHEN \'{timetype}\' = \'月\' THEN\n						MONTH (ld_salesorder.signed_data)\n					WHEN \'{timetype}\' = \'季度\' THEN\n						QUARTER (ld_salesorder.signed_data)\n					ELSE\n						MONTH (ld_salesorder.signed_data)\n					END\n				) AS group_time,\n				sum(\n					now_s_detail.tax_amount / ld_salesorder.conversion_rate\n				) AS tax_amount\n			FROM\n				ld_salesorder\n			LEFT JOIN ld_salesorderdetail now_s_detail ON now_s_detail.id = ld_salesorder.salesorderid\n			LEFT JOIN ld_products ON ld_products.productid = now_s_detail.productid\n			WHERE\n				(\n					ld_products.productname = \'{productname}\'\n					OR \'{productname}\' = \'\'\n				)\n			AND (\n				\'{productcategory}\' = \'\'\n				OR FIND_IN_SET(\n					ld_products.productcategory,\n					\'{productcategory}\'\n				)\n			)\n			AND FIND_IN_SET(\n				ld_salesorder.approvestatus,\n				\'{approvestatus}\'\n			)\n			AND FIND_IN_SET(\n				ld_salesorder.smownerid,\n				\'{userscope}\'\n			)\n			AND (\n				ld_salesorder.signed_data BETWEEN \'{starttime}\'\n				AND \'{endtime}\'\n			)\n			GROUP BY\n				where_time,\n				group_time\n		) now_salesorder ON now_salesorder.group_time = timetype_table.group_time\n		AND now_salesorder.where_time = timetype_table.where_time\n		LEFT JOIN (\n			SELECT\n				ld_salesorder.salesorderid,\n				(\n					CASE\n					WHEN \'{timetype}\' = \'月\' THEN\n						YEAR (\n							DATE_ADD(\n								ld_salesorder.signed_data,\n								INTERVAL 1 MONTH\n							)\n						)\n					WHEN \'{timetype}\' = \'季度\' THEN\n						YEAR (\n							DATE_ADD(\n								ld_salesorder.signed_data,\n								INTERVAL 1 QUARTER\n							)\n						)\n					ELSE\n						YEAR (\n							DATE_ADD(\n								ld_salesorder.signed_data,\n								INTERVAL 1 MONTH\n							)\n						)\n					END\n				) AS where_time,\n				(\n					CASE\n					WHEN \'{timetype}\' = \'月\' THEN\n						MONTH (\n							DATE_ADD(\n								ld_salesorder.signed_data,\n								INTERVAL 1 MONTH\n							)\n						)\n					WHEN \'{timetype}\' = \'季度\' THEN\n						QUARTER (\n							DATE_ADD(\n								ld_salesorder.signed_data,\n								INTERVAL 1 QUARTER\n							)\n						)\n					ELSE\n						MONTH (\n							DATE_ADD(\n								ld_salesorder.signed_data,\n								INTERVAL 1 MONTH\n							)\n						)\n					END\n				) AS group_time,\n				sum(\n					pre_s_detail.tax_amount / ld_salesorder.conversion_rate\n				) AS tax_amount\n			FROM\n				ld_salesorder\n			LEFT JOIN ld_salesorderdetail pre_s_detail ON pre_s_detail.id = ld_salesorder.salesorderid\n			LEFT JOIN ld_products ON ld_products.productid = pre_s_detail.productid\n			WHERE\n				(\n					ld_products.productname = \'{productname}\'\n					OR \'{productname}\' = \'\'\n				)\n			AND (\n				\'{productcategory}\' = \'\'\n				OR FIND_IN_SET(\n					ld_products.productcategory,\n					\'{productcategory}\'\n				)\n			)\n			AND FIND_IN_SET(\n				ld_salesorder.approvestatus,\n				\'{approvestatus}\'\n			)\n			AND FIND_IN_SET(\n				ld_salesorder.smownerid,\n				\'{userscope}\'\n			)\n			GROUP BY\n				where_time,\n				group_time\n		) pre_salesorder ON pre_salesorder.group_time = timetype_table.group_time\n		AND pre_salesorder.where_time = timetype_table.where_time\n		GROUP BY\n			timetype_table.where_time,\n			timetype_table.group_time\n	) p_num\nGROUP BY\n	p_num.where_time,\n	p_num.group_time' WHERE (`primaryname`='product_salesorders_amount_m_to_m');
delimiter;

UPDATE `ld_customreport` SET `sqlstr`='SELECT\n	p_num.where_time,\n	p_num.group_time,\n	(\n		CASE\n		WHEN \'{timetype}\' = \'本年和去年-按季度\' THEN\n			CONCAT(\n				\'第\',\n				p_num.group_time,\n				\'季度\'\n			)\n		ELSE\n			CONCAT(p_num.group_time, \'月\')\n		END\n	) AS dispaly_group_time,\n	p_num.pre_tax_amount,\n	p_num.now_tax_amount\nFROM\n	(\n		SELECT\n			timetype_table.where_time AS where_time,\n			timetype_table.group_time AS group_time,\n			pre_salesorder.tax_amount AS pre_tax_amount,\n			now_salesorder.tax_amount AS now_tax_amount\n		FROM\n			(\n				SELECT\n					(\n						CASE\n						WHEN \'{timetype}\' = \'本年和去年-按月\' THEN\n							YEAR (NOW())\n						WHEN \'{timetype}\' = \'本年和去年-按季度\' THEN\n							YEAR (NOW())\n						WHEN \'{timetype}\' = \'本季度和上季度-按月\' THEN\n							QUARTER (NOW())\n						ELSE\n							YEAR (NOW())\n						END\n					) AS where_time,\n					(\n						CASE\n						WHEN \'{timetype}\' = \'本年和去年-按月\' THEN\n							MONTH (date)\n						WHEN \'{timetype}\' = \'本年和去年-按季度\' THEN\n							QUARTER (date)\n						WHEN \'{timetype}\' = \'本季度和上季度-按月\' THEN\n							MONTH (date)\n						ELSE\n							MONTH (date)\n						END\n					) AS group_time\n				FROM\n					tmp_date a\n				WHERE\n					date LIKE \'%2023%\'\n				GROUP BY\n					group_time\n			) timetype_table\n		LEFT JOIN (\n			SELECT\n				now_s_detail.id AS salesorderid,\n				(\n					CASE\n					WHEN \'{timetype}\' = \'本年和去年-按月\' THEN\n						YEAR (ld_salesorder.signed_data)\n					WHEN \'{timetype}\' = \'本年和去年-按季度\' THEN\n						YEAR (ld_salesorder.signed_data)\n					WHEN \'{timetype}\' = \'本季度和上季度-按月\' THEN\n						QUARTER (ld_salesorder.signed_data)\n					ELSE\n						YEAR (ld_salesorder.signed_data)\n					END\n				) AS where_time,\n				(\n					CASE\n					WHEN \'{timetype}\' = \'本年和去年-按月\' THEN\n						MONTH (ld_salesorder.signed_data)\n					WHEN \'{timetype}\' = \'本年和去年-按季度\' THEN\n						QUARTER (ld_salesorder.signed_data)\n					WHEN \'{timetype}\' = \'本季度和上季度-按月\' THEN\n						MONTH (ld_salesorder.signed_data)\n					ELSE\n						MONTH (ld_salesorder.signed_data)\n					END\n				) AS group_time,\n				sum(\n					now_s_detail.tax_amount / ld_salesorder.conversion_rate\n				) AS tax_amount\n			FROM\n				ld_salesorder\n			LEFT JOIN ld_salesorderdetail now_s_detail ON now_s_detail.id = ld_salesorder.salesorderid\n			LEFT JOIN ld_products ON ld_products.productid = now_s_detail.productid\n			WHERE\n				(\n					ld_products.productname = \'{productname}\'\n					OR \'{productname}\' = \'\'\n				)\n			AND (\n				\'{productcategory}\' = \'\'\n				OR FIND_IN_SET(\n					ld_products.productcategory,\n					\'{productcategory}\'\n				)\n			)\n			AND FIND_IN_SET(\n				ld_salesorder.approvestatus,\n				\'{approvestatus}\'\n			)\n			AND FIND_IN_SET(\n				ld_salesorder.smownerid,\n				\'{userscope}\'\n			)\n			AND (\n				ld_salesorder.signed_data BETWEEN \'{starttime}\'\n				AND \'{endtime}\'\n			)\n			GROUP BY\n				where_time,\n				group_time\n		) now_salesorder ON now_salesorder.where_time = timetype_table.where_time\n		AND now_salesorder.group_time = timetype_table.group_time\n		LEFT JOIN (\n			SELECT\n				pre_s_detail.id AS salesorderid,\n				(\n					CASE\n					WHEN \'{timetype}\' = \'本年和去年-按月\' THEN\n						YEAR (\n							DATE_ADD(\n								ld_salesorder.signed_data,\n								INTERVAL 1 YEAR\n							)\n						)\n					WHEN \'{timetype}\' = \'本年和去年-按季度\' THEN\n						YEAR (\n							DATE_ADD(\n								ld_salesorder.signed_data,\n								INTERVAL 1 YEAR\n							)\n						)\n					WHEN \'{timetype}\' = \'本季度和上季度-按月\' THEN\n						QUARTER (\n							DATE_ADD(\n								ld_salesorder.signed_data,\n								INTERVAL 1 QUARTER\n							)\n						)\n					ELSE\n						YEAR (\n							DATE_ADD(\n								ld_salesorder.signed_data,\n								INTERVAL 1 YEAR\n							)\n						)\n					END\n				) AS where_time,\n				(\n					CASE\n					WHEN \'{timetype}\' = \'本年和去年-按月\' THEN\n						MONTH (ld_salesorder.signed_data)\n					WHEN \'{timetype}\' = \'本年和去年-按季度\' THEN\n						QUARTER (signed_data)\n					WHEN \'{timetype}\' = \'本季度和上季度-按月\' THEN\n						MONTH (ld_salesorder.signed_data)\n					ELSE\n						MONTH (ld_salesorder.signed_data)\n					END\n				) AS group_time,\n				sum(\n					pre_s_detail.tax_amount / ld_salesorder.conversion_rate\n				) AS tax_amount\n			FROM\n				ld_salesorder\n			LEFT JOIN ld_salesorderdetail pre_s_detail ON pre_s_detail.id = ld_salesorder.salesorderid\n			LEFT JOIN ld_products ON ld_products.productid = pre_s_detail.productid\n			WHERE\n				(\n					ld_products.productname = \'{productname}\'\n					OR \'{productname}\' = \'\'\n				)\n			AND (\n				\'{productcategory}\' = \'\'\n				OR FIND_IN_SET(\n					ld_products.productcategory,\n					\'{productcategory}\'\n				)\n			)\n			AND FIND_IN_SET(\n				ld_salesorder.approvestatus,\n				\'{approvestatus}\'\n			)\n			AND FIND_IN_SET(\n				ld_salesorder.smownerid,\n				\'{userscope}\'\n			)\n			GROUP BY\n				where_time,\n				group_time\n		) pre_salesorder ON pre_salesorder.where_time = timetype_table.where_time\n		AND pre_salesorder.group_time = timetype_table.group_time\n		GROUP BY\n			timetype_table.group_time\n	) p_num\nGROUP BY\n	p_num.group_time' WHERE (`primaryname`='product_salesorders_amount_y_to_y');
delimiter;

UPDATE `ld_customreport` SET `sqlstr`='SELECT\n	(\n		CASE\n		WHEN \'{timetype}\' = \'季度\' THEN\n			CONCAT(\n				p_num.where_time,\n				\'-\',\n				\'第\',\n				p_num.group_time,\n				\'季度\'\n			)\n		ELSE\n			DATE_FORMAT(\n				STR_TO_DATE(\n					CONCAT(\n						p_num.where_time,\n						\'-\',\n						p_num.group_time\n					),\n					\'%Y-%m\'\n				),\n				\'%Y-%m\'\n			)\n		END\n	) AS dispaly_group_time,\n	sum(p_num.pre_tax_amount) AS pre_tax_amount,\n	sum(p_num.now_tax_amount) AS now_tax_amount\nFROM\n	(\n		SELECT\n			timetype_table.group_time AS group_time,\n			timetype_table.where_time AS where_time,\n			pre_invoice.tax_amount AS pre_tax_amount,\n			now_invoice.tax_amount AS now_tax_amount\n		FROM\n			(\n				SELECT\n					(\n						CASE\n						WHEN \'{timetype}\' = \'月\' THEN\n							MONTH (date)\n						WHEN \'{timetype}\' = \'季度\' THEN\n							QUARTER (date)\n						ELSE\n							MONTH (date)\n						END\n					) AS group_time,\n					where_table.where_time AS where_time\n				FROM\n					tmp_date,\n					(\n						SELECT\n							YEAR (\n								DATE_ADD(\n									\'{starttime}\',\n									INTERVAL seq YEAR\n								)\n							) where_time\n						FROM\n							sequence\n						WHERE\n							YEAR (\n								DATE_ADD(\n									\'{starttime}\',\n									INTERVAL seq YEAR\n								)\n							) <= YEAR (\'{endtime}\')\n					) where_table\n				WHERE\n					date LIKE \'%2023%\'\n				GROUP BY\n					where_time,\n					group_time\n			) timetype_table\n		LEFT JOIN (\n			SELECT\n				ld_invoice.invoiceid,\n				YEAR (ld_invoice.invoicedate) AS where_time,\n				(\n					CASE\n					WHEN \'{timetype}\' = \'月\' THEN\n						MONTH (ld_invoice.invoicedate)\n					WHEN \'{timetype}\' = \'季度\' THEN\n						QUARTER (ld_invoice.invoicedate)\n					ELSE\n						MONTH (ld_invoice.invoicedate)\n					END\n				) AS group_time,\n				sum(\n					now_s_detail.tax_amount / ld_invoice.conversion_rate\n				) AS tax_amount\n			FROM\n				ld_invoice\n			LEFT JOIN ld_invoicedetail now_s_detail ON now_s_detail.id = ld_invoice.invoiceid\n			LEFT JOIN ld_products ON ld_products.productid = now_s_detail.productid\n			WHERE\n				(\n					ld_products.productname = \'{productname}\'\n					OR \'{productname}\' = \'\'\n				)\n			AND (\n				\'{productcategory}\' = \'\'\n				OR FIND_IN_SET(\n					ld_products.productcategory,\n					\'{productcategory}\'\n				)\n			)\n			AND FIND_IN_SET(\n				ld_invoice.approvestatus,\n				\'{approvestatus}\'\n			)\n			AND FIND_IN_SET(\n				ld_invoice.smownerid,\n				\'{userscope}\'\n			)\n			AND (\n				ld_invoice.invoicedate BETWEEN \'{starttime}\'\n				AND \'{endtime}\'\n			)\n			GROUP BY\n				where_time,\n				group_time\n		) now_invoice ON now_invoice.group_time = timetype_table.group_time\n		AND now_invoice.where_time = timetype_table.where_time\n		LEFT JOIN (\n			SELECT\n				ld_invoice.invoiceid,\n				(\n					CASE\n					WHEN \'{timetype}\' = \'月\' THEN\n						YEAR (\n							DATE_ADD(\n								ld_invoice.invoicedate,\n								INTERVAL 1 MONTH\n							)\n						)\n					WHEN \'{timetype}\' = \'季度\' THEN\n						YEAR (\n							DATE_ADD(\n								ld_invoice.invoicedate,\n								INTERVAL 1 QUARTER\n							)\n						)\n					ELSE\n						YEAR (\n							DATE_ADD(\n								ld_invoice.invoicedate,\n								INTERVAL 1 MONTH\n							)\n						)\n					END\n				) AS where_time,\n				(\n					CASE\n					WHEN \'{timetype}\' = \'月\' THEN\n						MONTH (\n							DATE_ADD(\n								ld_invoice.invoicedate,\n								INTERVAL 1 MONTH\n							)\n						)\n					WHEN \'{timetype}\' = \'季度\' THEN\n						QUARTER (\n							DATE_ADD(\n								ld_invoice.invoicedate,\n								INTERVAL 1 QUARTER\n							)\n						)\n					ELSE\n						MONTH (\n							DATE_ADD(\n								ld_invoice.invoicedate,\n								INTERVAL 1 MONTH\n							)\n						)\n					END\n				) AS group_time,\n				sum(\n					pre_s_detail.tax_amount / ld_invoice.conversion_rate\n				) AS tax_amount\n			FROM\n				ld_invoice\n			LEFT JOIN ld_invoicedetail pre_s_detail ON pre_s_detail.id = ld_invoice.invoiceid\n			LEFT JOIN ld_products ON ld_products.productid = pre_s_detail.productid\n			WHERE\n				(\n					ld_products.productname = \'{productname}\'\n					OR \'{productname}\' = \'\'\n				)\n			AND (\n				\'{productcategory}\' = \'\'\n				OR FIND_IN_SET(\n					ld_products.productcategory,\n					\'{productcategory}\'\n				)\n			)\n			AND FIND_IN_SET(\n				ld_invoice.approvestatus,\n				\'{approvestatus}\'\n			)\n			AND FIND_IN_SET(\n				ld_invoice.smownerid,\n				\'{userscope}\'\n			)\n			GROUP BY\n				where_time,\n				group_time\n		) pre_invoice ON pre_invoice.group_time = timetype_table.group_time\n		AND pre_invoice.where_time = timetype_table.where_time\n		GROUP BY\n			timetype_table.where_time,\n			timetype_table.group_time\n	) p_num\nGROUP BY\n	p_num.where_time,\n	p_num.group_time' WHERE (`primaryname`='product_invoice_amount_m_to_m');
delimiter;

UPDATE `ld_customreport` SET `sqlstr`='SELECT\n	(\n		CASE\n		WHEN \'{timetype}\' = \'季度\' THEN\n			CONCAT(\n				p_num.where_time,\n				\'-\',\n				\'第\',\n				p_num.group_time,\n				\'季度\'\n			)\n		ELSE\n			DATE_FORMAT(\n				STR_TO_DATE(\n					CONCAT(\n						p_num.where_time,\n						\'-\',\n						p_num.group_time\n					),\n					\'%Y-%m\'\n				),\n				\'%Y-%m\'\n			)\n		END\n	) AS dispaly_group_time,\n	sum(p_num.pre_tax_amount) AS pre_tax_amount,\n	sum(p_num.now_tax_amount) AS now_tax_amount\nFROM\n	(\n		(\n			SELECT\n				timetype_table.group_time AS group_time,\n				timetype_table.where_time AS where_time,\n				pre_salesorder.tax_amount AS pre_tax_amount,\n				now_salesorder.tax_amount AS now_tax_amount\n			FROM\n				(\n					SELECT\n						(\n							CASE\n							WHEN \'{timetype}\' = \'月\' THEN\n								MONTH (date)\n							WHEN \'{timetype}\' = \'季度\' THEN\n								QUARTER (date)\n							ELSE\n								MONTH (date)\n							END\n						) AS group_time,\n						where_table.where_time AS where_time\n					FROM\n						tmp_date,\n						(\n							SELECT\n								YEAR (\n									DATE_ADD(\n										\'{starttime}\',\n										INTERVAL seq YEAR\n									)\n								) where_time\n							FROM\n								sequence\n							WHERE\n								YEAR (\n									DATE_ADD(\n										\'{starttime}\',\n										INTERVAL seq YEAR\n									)\n								) <= YEAR (\'{endtime}\')\n						) where_table\n					WHERE\n						date LIKE \'%2023%\'\n					GROUP BY\n						where_time,\n						group_time\n				) timetype_table\n			LEFT JOIN (\n				SELECT\n					ld_salesorder.salesorderid,\n					YEAR (ld_salesorder.signed_data) AS where_time,\n					(\n						CASE\n						WHEN \'{timetype}\' = \'月\' THEN\n							MONTH (ld_salesorder.signed_data)\n						WHEN \'{timetype}\' = \'季度\' THEN\n							QUARTER (ld_salesorder.signed_data)\n						ELSE\n							MONTH (ld_salesorder.signed_data)\n						END\n					) AS group_time,\n					sum(\n						now_s_detail.tax_amount / ld_salesorder.conversion_rate\n					) AS tax_amount\n				FROM\n					ld_salesorder\n				LEFT JOIN ld_salesorderdetail now_s_detail ON now_s_detail.id = ld_salesorder.salesorderid\n				LEFT JOIN ld_products ON ld_products.productid = now_s_detail.productid\n				WHERE\n					(\n						ld_products.productname = \'{productname}\'\n						OR \'{productname}\' = \'\'\n					)\n				AND (\n					\'{productcategory}\' = \'\'\n					OR FIND_IN_SET(\n						ld_products.productcategory,\n						\'{productcategory}\'\n					)\n				)\n				AND FIND_IN_SET(\n					ld_salesorder.approvestatus,\n					\'{approvestatus}\'\n				)\n				AND FIND_IN_SET(\n					ld_salesorder.smownerid,\n					\'{userscope}\'\n				)\n				AND (\n					ld_salesorder.signed_data BETWEEN \'{starttime}\'\n					AND \'{endtime}\'\n				)\n				GROUP BY\n					where_time,\n					group_time\n			) now_salesorder ON now_salesorder.group_time = timetype_table.group_time\n			AND now_salesorder.where_time = timetype_table.where_time\n			LEFT JOIN (\n				SELECT\n					ld_salesorder.salesorderid,\n					(\n						CASE\n						WHEN \'{timetype}\' = \'月\' THEN\n							YEAR (\n								DATE_ADD(\n									ld_salesorder.signed_data,\n									INTERVAL 1 MONTH\n								)\n							)\n						WHEN \'{timetype}\' = \'季度\' THEN\n							YEAR (\n								DATE_ADD(\n									ld_salesorder.signed_data,\n									INTERVAL 1 QUARTER\n								)\n							)\n						ELSE\n							YEAR (\n								DATE_ADD(\n									ld_salesorder.signed_data,\n									INTERVAL 1 MONTH\n								)\n							)\n						END\n					) AS where_time,\n					(\n						CASE\n						WHEN \'{timetype}\' = \'月\' THEN\n							MONTH (\n								DATE_ADD(\n									ld_salesorder.signed_data,\n									INTERVAL 1 MONTH\n								)\n							)\n						WHEN \'{timetype}\' = \'季度\' THEN\n							QUARTER (\n								DATE_ADD(\n									ld_salesorder.signed_data,\n									INTERVAL 1 QUARTER\n								)\n							)\n						ELSE\n							MONTH (\n								DATE_ADD(\n									ld_salesorder.signed_data,\n									INTERVAL 1 MONTH\n								)\n							)\n						END\n					) AS group_time,\n					sum(\n						pre_s_detail.tax_amount / ld_salesorder.conversion_rate\n					) AS tax_amount\n				FROM\n					ld_salesorder\n				LEFT JOIN ld_salesorderdetail pre_s_detail ON pre_s_detail.id = ld_salesorder.salesorderid\n				LEFT JOIN ld_products ON ld_products.productid = pre_s_detail.productid\n				WHERE\n					(\n						ld_products.productname = \'{productname}\'\n						OR \'{productname}\' = \'\'\n					)\n				AND (\n					\'{productcategory}\' = \'\'\n					OR FIND_IN_SET(\n						ld_products.productcategory,\n						\'{productcategory}\'\n					)\n				)\n				AND FIND_IN_SET(\n					ld_salesorder.approvestatus,\n					\'{approvestatus}\'\n				)\n				AND FIND_IN_SET(\n					ld_salesorder.smownerid,\n					\'{userscope}\'\n				)\n				GROUP BY\n					where_time,\n					group_time\n			) pre_salesorder ON pre_salesorder.group_time = timetype_table.group_time\n			AND pre_salesorder.where_time = timetype_table.where_time\n			GROUP BY\n				timetype_table.group_time\n		)\n		UNION ALL\n			(\n				SELECT\n					timetype_table.group_time AS group_time,\n					timetype_table.where_time AS where_time,\n					pre_servicecontracts.tax_amount AS pre_tax_amount,\n					now_servicecontracts.tax_amount AS now_tax_amount\n				FROM\n					(\n						SELECT\n							(\n								CASE\n								WHEN \'{timetype}\' = \'月\' THEN\n									MONTH (date)\n								WHEN \'{timetype}\' = \'季度\' THEN\n									QUARTER (date)\n								ELSE\n									MONTH (date)\n								END\n							) AS group_time,\n							where_table.where_time AS where_time\n						FROM\n							tmp_date,\n							(\n								SELECT\n									YEAR (\n										DATE_ADD(\n											\'{starttime}\',\n											INTERVAL seq YEAR\n										)\n									) where_time\n								FROM\n									sequence\n								WHERE\n									YEAR (\n										DATE_ADD(\n											\'{starttime}\',\n											INTERVAL seq YEAR\n										)\n									) <= YEAR (\'{endtime}\')\n							) where_table\n						WHERE\n							date LIKE \'%2023%\'\n						GROUP BY\n							where_time,\n							group_time\n					) timetype_table\n				LEFT JOIN (\n					SELECT\n						ld_servicecontracts.servicecontractsid,\n						YEAR (due_date) AS where_time,\n						(\n							CASE\n							WHEN \'{timetype}\' = \'月\' THEN\n								MONTH (due_date)\n							WHEN \'{timetype}\' = \'季度\' THEN\n								QUARTER (due_date)\n							ELSE\n								MONTH (due_date)\n							END\n						) AS group_time,\n						sum(\n							now_sv_detail.tax_amount / ld_servicecontracts.conversion_rate\n						) AS tax_amount\n					FROM\n						ld_servicecontracts\n					LEFT JOIN ld_servicecontractsdetail now_sv_detail ON now_sv_detail.id = ld_servicecontracts.servicecontractsid\n					LEFT JOIN ld_products ON ld_products.productid = now_sv_detail.productid\n					WHERE\n						(\n							ld_products.productname = \'{productname}\'\n							OR \'{productname}\' = \'\'\n						)\n					AND (\n						\'{productcategory}\' = \'\'\n						OR FIND_IN_SET(\n							ld_products.productcategory,\n							\'{productcategory}\'\n						)\n					)\n					AND FIND_IN_SET(\n						ld_servicecontracts.approvestatus,\n						\'{approvestatus}\'\n					)\n					AND FIND_IN_SET(\n						ld_servicecontracts.smownerid,\n						\'{userscope}\'\n					)\n					AND (\n						ld_servicecontracts.due_date BETWEEN \'{starttime}\'\n						AND \'{endtime}\'\n					)\n					GROUP BY\n						where_time,\n						group_time\n				) now_servicecontracts ON now_servicecontracts.group_time = timetype_table.group_time\n				AND now_servicecontracts.where_time = timetype_table.where_time\n				LEFT JOIN (\n					SELECT\n						ld_servicecontracts.servicecontractsid,\n						(\n							CASE\n							WHEN \'{timetype}\' = \'月\' THEN\n								YEAR (\n									DATE_ADD(\n										ld_servicecontracts.due_date,\n										INTERVAL 1 MONTH\n									)\n								)\n							WHEN \'{timetype}\' = \'季度\' THEN\n								YEAR (\n									DATE_ADD(\n										ld_servicecontracts.due_date,\n										INTERVAL 1 QUARTER\n									)\n								)\n							ELSE\n								YEAR (\n									DATE_ADD(\n										ld_servicecontracts.due_date,\n										INTERVAL 1 MONTH\n									)\n								)\n							END\n						) AS where_time,\n						(\n							CASE\n							WHEN \'{timetype}\' = \'月\' THEN\n								MONTH (\n									DATE_ADD(\n										ld_servicecontracts.due_date,\n										INTERVAL 1 MONTH\n									)\n								)\n							WHEN \'{timetype}\' = \'季度\' THEN\n								QUARTER (\n									DATE_ADD(\n										ld_servicecontracts.due_date,\n										INTERVAL 1 QUARTER\n									)\n								)\n							ELSE\n								MONTH (\n									DATE_ADD(\n										ld_servicecontracts.due_date,\n										INTERVAL 1 MONTH\n									)\n								)\n							END\n						) AS group_time,\n						sum(\n							pre_sv_detail.tax_amount / ld_servicecontracts.conversion_rate\n						) AS tax_amount\n					FROM\n						ld_servicecontracts\n					LEFT JOIN ld_servicecontractsdetail pre_sv_detail ON pre_sv_detail.id = ld_servicecontracts.servicecontractsid\n					LEFT JOIN ld_products ON ld_products.productid = pre_sv_detail.productid\n					WHERE\n						(\n							ld_products.productname = \'{productname}\'\n							OR \'{productname}\' = \'\'\n						)\n					AND (\n						\'{productcategory}\' = \'\'\n						OR FIND_IN_SET(\n							ld_products.productcategory,\n							\'{productcategory}\'\n						)\n					)\n					AND FIND_IN_SET(\n						ld_servicecontracts.approvestatus,\n						\'{approvestatus}\'\n					)\n					AND FIND_IN_SET(\n						ld_servicecontracts.smownerid,\n						\'{userscope}\'\n					)\n					GROUP BY\n						where_time,\n						group_time\n				) pre_servicecontracts ON pre_servicecontracts.group_time = timetype_table.group_time\n				AND pre_servicecontracts.where_time = timetype_table.where_time\n				GROUP BY\n					timetype_table.where_time,\n					timetype_table.group_time\n			)\n	) p_num\nGROUP BY\n	p_num.where_time,\n	p_num.group_time' WHERE (`primaryname`='product_contracted_amount_m_to_m');
delimiter;

UPDATE `ld_customreport` SET `sqlstr`='SELECT\n	p_num.where_time,\n	p_num.group_time,\n	(\n		CASE\n		WHEN \'{timetype}\' = \'本年和去年-按季度\' THEN\n			CONCAT(\n				\'第\',\n				p_num.group_time,\n				\'季度\'\n			)\n		ELSE\n			CONCAT(p_num.group_time, \'月\')\n		END\n	) AS dispaly_group_time,\n	sum(p_num.pre_tax_amount) AS pre_tax_amount,\n	sum(p_num.now_tax_amount) AS now_tax_amount\nFROM\n	(\n		(\n			SELECT\n				timetype_table.where_time AS where_time,\n				timetype_table.group_time AS group_time,\n				pre_salesorder.salesorderid AS pre_id,\n				pre_salesorder.tax_amount AS pre_tax_amount,\n				now_salesorder.salesorderid AS now_id,\n				now_salesorder.tax_amount AS now_tax_amount\n			FROM\n				(\n					SELECT\n						(\n							CASE\n							WHEN \'{timetype}\' = \'本年和去年-按月\' THEN\n								YEAR (NOW())\n							WHEN \'{timetype}\' = \'本年和去年-按季度\' THEN\n								YEAR (NOW())\n							WHEN \'{timetype}\' = \'本季度和上季度-按月\' THEN\n								QUARTER (NOW())\n							ELSE\n								YEAR (NOW())\n							END\n						) AS where_time,\n						(\n							CASE\n							WHEN \'{timetype}\' = \'本年和去年-按月\' THEN\n								MONTH (date)\n							WHEN \'{timetype}\' = \'本年和去年-按季度\' THEN\n								QUARTER (date)\n							WHEN \'{timetype}\' = \'本季度和上季度-按月\' THEN\n								MONTH (date)\n							ELSE\n								MONTH (date)\n							END\n						) AS group_time\n					FROM\n						tmp_date a\n					WHERE\n						date LIKE \'%2023%\'\n					GROUP BY\n						group_time\n				) timetype_table\n			LEFT JOIN (\n				SELECT\n					ld_salesorder.salesorderid,\n					(\n						CASE\n						WHEN \'{timetype}\' = \'本年和去年-按月\' THEN\n							YEAR (ld_salesorder.signed_data)\n						WHEN \'{timetype}\' = \'本年和去年-按季度\' THEN\n							YEAR (ld_salesorder.signed_data)\n						WHEN \'{timetype}\' = \'本季度和上季度-按月\' THEN\n							QUARTER (ld_salesorder.signed_data)\n						ELSE\n							YEAR (ld_salesorder.signed_data)\n						END\n					) AS where_time,\n					(\n						CASE\n						WHEN \'{timetype}\' = \'本年和去年-按月\' THEN\n							MONTH (ld_salesorder.signed_data)\n						WHEN \'{timetype}\' = \'本年和去年-按季度\' THEN\n							QUARTER (ld_salesorder.signed_data)\n						WHEN \'{timetype}\' = \'本季度和上季度-按月\' THEN\n							MONTH (ld_salesorder.signed_data)\n						ELSE\n							MONTH (ld_salesorder.signed_data)\n						END\n					) AS group_time,\n					sum(\n						now_s_detail.tax_amount / ld_salesorder.conversion_rate\n					) AS tax_amount\n				FROM\n					ld_salesorder\n				LEFT JOIN ld_salesorderdetail now_s_detail ON now_s_detail.id = ld_salesorder.salesorderid\n				LEFT JOIN ld_products ON ld_products.productid = now_s_detail.productid\n				WHERE\n					(\n						ld_products.productname = \'{productname}\'\n						OR \'{productname}\' = \'\'\n					)\n				AND (\n					\'{productcategory}\' = \'\'\n					OR FIND_IN_SET(\n						ld_products.productcategory,\n						\'{productcategory}\'\n					)\n				)\n				AND FIND_IN_SET(\n					ld_salesorder.approvestatus,\n					\'{approvestatus}\'\n				)\n				AND FIND_IN_SET(\n					ld_salesorder.smownerid,\n					\'{userscope}\'\n				)\n				AND (\n					ld_salesorder.signed_data BETWEEN \'{starttime}\'\n					AND \'{endtime}\'\n				)\n				GROUP BY\n					where_time,\n					group_time\n			) now_salesorder ON now_salesorder.where_time = timetype_table.where_time\n			AND now_salesorder.group_time = timetype_table.group_time\n			LEFT JOIN (\n				SELECT\n					ld_salesorder.salesorderid,\n					(\n						CASE\n						WHEN \'{timetype}\' = \'本年和去年-按月\' THEN\n							YEAR (\n								DATE_ADD(\n									ld_salesorder.signed_data,\n									INTERVAL 1 YEAR\n								)\n							)\n						WHEN \'{timetype}\' = \'本年和去年-按季度\' THEN\n							YEAR (\n								DATE_ADD(\n									ld_salesorder.signed_data,\n									INTERVAL 1 YEAR\n								)\n							)\n						WHEN \'{timetype}\' = \'本季度和上季度-按月\' THEN\n							QUARTER (\n								DATE_ADD(\n									ld_salesorder.signed_data,\n									INTERVAL 1 QUARTER\n								)\n							)\n						ELSE\n							YEAR (\n								DATE_ADD(\n									ld_salesorder.signed_data,\n									INTERVAL 1 YEAR\n								)\n							)\n						END\n					) AS where_time,\n					(\n						CASE\n						WHEN \'{timetype}\' = \'本年和去年-按月\' THEN\n							MONTH (ld_salesorder.signed_data)\n						WHEN \'{timetype}\' = \'本年和去年-按季度\' THEN\n							QUARTER (signed_data)\n						WHEN \'{timetype}\' = \'本季度和上季度-按月\' THEN\n							MONTH (ld_salesorder.signed_data)\n						ELSE\n							MONTH (ld_salesorder.signed_data)\n						END\n					) AS group_time,\n					sum(\n						pre_s_detail.tax_amount / ld_salesorder.conversion_rate\n					) AS tax_amount\n				FROM\n					ld_salesorder\n				LEFT JOIN ld_salesorderdetail pre_s_detail ON pre_s_detail.id = ld_salesorder.salesorderid\n				LEFT JOIN ld_products ON ld_products.productid = pre_s_detail.productid\n				WHERE\n					(\n						ld_products.productname = \'{productname}\'\n						OR \'{productname}\' = \'\'\n					)\n				AND (\n					\'{productcategory}\' = \'\'\n					OR FIND_IN_SET(\n						ld_products.productcategory,\n						\'{productcategory}\'\n					)\n				)\n				AND FIND_IN_SET(\n					ld_salesorder.approvestatus,\n					\'{approvestatus}\'\n				)\n				AND FIND_IN_SET(\n					ld_salesorder.smownerid,\n					\'{userscope}\'\n				)\n				GROUP BY\n					where_time,\n					group_time\n			) pre_salesorder ON pre_salesorder.where_time = timetype_table.where_time\n			AND pre_salesorder.group_time = timetype_table.group_time\n			GROUP BY\n				timetype_table.group_time\n		)\n		UNION ALL\n			(\n				SELECT\n					timetype_table.where_time AS where_time,\n					timetype_table.group_time AS group_time,\n					pre_servicecontracts.servicecontractsid AS pre_id,\n					pre_servicecontracts.tax_amount AS pre_tax_amount,\n					now_servicecontracts.servicecontractsid AS now_id,\n					now_servicecontracts.tax_amount AS now_tax_amount\n				FROM\n					(\n						SELECT\n							(\n								CASE\n								WHEN \'{timetype}\' = \'本年和去年-按月\' THEN\n									YEAR (NOW())\n								WHEN \'{timetype}\' = \'本年和去年-按季度\' THEN\n									YEAR (NOW())\n								WHEN \'{timetype}\' = \'本季度和上季度-按月\' THEN\n									QUARTER (NOW())\n								ELSE\n									YEAR (NOW())\n								END\n							) AS where_time,\n							(\n								CASE\n								WHEN \'{timetype}\' = \'本年和去年-按月\' THEN\n									MONTH (date)\n								WHEN \'{timetype}\' = \'本年和去年-按季度\' THEN\n									QUARTER (date)\n								WHEN \'{timetype}\' = \'本季度和上季度-按月\' THEN\n									MONTH (date)\n								ELSE\n									MONTH (date)\n								END\n							) AS group_time\n						FROM\n							tmp_date a\n						WHERE\n							date LIKE \'%2023%\'\n						GROUP BY\n							group_time\n					) timetype_table\n				LEFT JOIN (\n					SELECT\n						ld_servicecontracts.servicecontractsid,\n						(\n							CASE\n							WHEN \'{timetype}\' = \'本年和去年-按月\' THEN\n								YEAR (due_date)\n							WHEN \'{timetype}\' = \'本年和去年-按季度\' THEN\n								YEAR (due_date)\n							WHEN \'{timetype}\' = \'本季度和上季度-按月\' THEN\n								QUARTER (due_date)\n							ELSE\n								YEAR (due_date)\n							END\n						) AS where_time,\n						(\n							CASE\n							WHEN \'{timetype}\' = \'本年和去年-按月\' THEN\n								MONTH (due_date)\n							WHEN \'{timetype}\' = \'本年和去年-按季度\' THEN\n								QUARTER (due_date)\n							WHEN \'{timetype}\' = \'本季度和上季度-按月\' THEN\n								MONTH (due_date)\n							ELSE\n								MONTH (due_date)\n							END\n						) AS group_time,\n						sum(\n							now_sv_detail.tax_amount / ld_servicecontracts.conversion_rate\n						) AS tax_amount\n					FROM\n						ld_servicecontracts\n					LEFT JOIN ld_servicecontractsdetail now_sv_detail ON now_sv_detail.id = ld_servicecontracts.servicecontractsid\n					LEFT JOIN ld_products ON ld_products.productid = now_sv_detail.productid\n					WHERE\n						(\n							ld_products.productname = \'{productname}\'\n							OR \'{productname}\' = \'\'\n						)\n					AND (\n						\'{productcategory}\' = \'\'\n						OR FIND_IN_SET(\n							ld_products.productcategory,\n							\'{productcategory}\'\n						)\n					)\n					AND FIND_IN_SET(\n						ld_servicecontracts.approvestatus,\n						\'{approvestatus}\'\n					)\n					AND FIND_IN_SET(\n						ld_servicecontracts.smownerid,\n						\'{userscope}\'\n					)\n					AND (\n						ld_servicecontracts.due_date BETWEEN \'{starttime}\'\n						AND \'{endtime}\'\n					)\n					GROUP BY\n						where_time,\n						group_time\n				) now_servicecontracts ON now_servicecontracts.where_time = timetype_table.where_time\n				AND now_servicecontracts.group_time = timetype_table.group_time\n				LEFT JOIN (\n					SELECT\n						ld_servicecontracts.servicecontractsid,\n						(\n							CASE\n							WHEN \'{timetype}\' = \'本年和去年-按月\' THEN\n								YEAR (\n									DATE_ADD(\n										ld_servicecontracts.due_date,\n										INTERVAL 1 YEAR\n									)\n								)\n							WHEN \'{timetype}\' = \'本年和去年-按季度\' THEN\n								YEAR (\n									DATE_ADD(\n										ld_servicecontracts.due_date,\n										INTERVAL 1 YEAR\n									)\n								)\n							WHEN \'{timetype}\' = \'本季度和上季度-按月\' THEN\n								QUARTER (\n									DATE_ADD(\n										ld_servicecontracts.due_date,\n										INTERVAL 1 QUARTER\n									)\n								)\n							ELSE\n								YEAR (\n									DATE_ADD(\n										ld_servicecontracts.due_date,\n										INTERVAL 1 YEAR\n									)\n								)\n							END\n						) AS where_time,\n						(\n							CASE\n							WHEN \'{timetype}\' = \'本年和去年-按月\' THEN\n								MONTH (\n									ld_servicecontracts.due_date\n								)\n							WHEN \'{timetype}\' = \'本年和去年-按季度\' THEN\n								QUARTER (\n									ld_servicecontracts.due_date\n								)\n							WHEN \'{timetype}\' = \'本季度和上季度-按月\' THEN\n								MONTH (\n									ld_servicecontracts.due_date\n								)\n							ELSE\n								MONTH (\n									ld_servicecontracts.due_date\n								)\n							END\n						) AS group_time,\n						sum(\n							pre_sv_detail.tax_amount / ld_servicecontracts.conversion_rate\n						) AS tax_amount\n					FROM\n						ld_servicecontracts\n					LEFT JOIN ld_servicecontractsdetail pre_sv_detail ON pre_sv_detail.id = ld_servicecontracts.servicecontractsid\n					LEFT JOIN ld_products ON ld_products.productid = pre_sv_detail.productid\n					WHERE\n						(\n							ld_products.productname = \'{productname}\'\n							OR \'{productname}\' = \'\'\n						)\n					AND (\n						\'{productcategory}\' = \'\'\n						OR FIND_IN_SET(\n							ld_products.productcategory,\n							\'{productcategory}\'\n						)\n					)\n					AND FIND_IN_SET(\n						ld_servicecontracts.approvestatus,\n						\'{approvestatus}\'\n					)\n					AND FIND_IN_SET(\n						ld_servicecontracts.smownerid,\n						\'{userscope}\'\n					)\n					GROUP BY\n						where_time,\n						group_time\n				) pre_servicecontracts ON pre_servicecontracts.where_time = timetype_table.where_time\n				AND pre_servicecontracts.group_time = timetype_table.group_time\n				GROUP BY\n					timetype_table.group_time\n			)\n	) p_num\nGROUP BY\n	p_num.group_time' WHERE (`primaryname`='product_contracted_amount_y_to_y');
delimiter;

SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='Leads');
SET @actionid=(SELECT actionid FROM ld_actionmapping where actionname = 'accountdatadup' AND actionlabel='ACCOUNTDUPLICATECHECK');
SET @beforeactionid=(SELECT actionid FROM ld_actionmapping where actionname = 'Delete');
SET @new_seq=IFNULL((SELECT IFNULL(sequence,0) FROM ld_profileallpermission where tabid=@tabid and operation = @beforeactionid),0);
INSERT INTO ld_profileallpermission(tabid,operation,sequence)
SELECT @tabid,@actionid,@new_seq FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_profileallpermission WHERE tabid =@tabid AND operation=@actionid);
delimiter;
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='Leads');
SET @actionid=(SELECT actionid FROM ld_actionmapping where actionname = 'Merge' AND actionlabel='Merge');
SET @beforeactionid=(SELECT actionid FROM ld_actionmapping where actionname = 'Export');
SET @new_seq=IFNULL((SELECT IFNULL(sequence,0) FROM ld_profileallpermission where tabid=@tabid and operation = @beforeactionid),0);
INSERT INTO ld_profileallpermission(tabid,operation,sequence)
SELECT @tabid,@actionid,@new_seq FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_profileallpermission WHERE tabid =@tabid AND operation=@actionid);
delimiter;
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='Leads');
SET @actionid=(SELECT actionid FROM ld_actionmapping where actionname = 'dup_and_merge' AND actionlabel='CHECKMERGE');
SET @beforeactionid=(SELECT actionid FROM ld_actionmapping where actionname = 'CustomView');
SET @new_seq=IFNULL((SELECT IFNULL(sequence,0) FROM ld_profileallpermission where tabid=@tabid and operation = @beforeactionid),0);
INSERT INTO ld_profileallpermission(tabid,operation,sequence)
SELECT @tabid,@actionid,@new_seq FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_profileallpermission WHERE tabid =@tabid AND operation=@actionid);
delimiter;
SET @i = 0;
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='Leads');
update ld_profileallpermission set sequence=(@i:=@i+1) where tabid=@tabid ORDER BY sequence;
delimiter;

DROP PROCEDURE IF EXISTS `ldcrm_add_profile_for_default_leads_dup_20231207`;
delimiter ||
CREATE PROCEDURE `ldcrm_add_profile_for_default_leads_dup_20231207`(in `tmp_tabname` varchar(50) , in `tmp_actionname` varchar(200))
BEGIN

	DECLARE tmp_profileid INT(19) DEFAULT 0;
	DECLARE MYCUSOR CURSOR FOR SELECT profileid FROM ld_profile WHERE profileid>0;
DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET tmp_profileid = NULL;
	SET @tabid=(select tabid from ld_tab  where name=`tmp_tabname`);
	set @operation = (SELECT actionid from ld_actionmapping where actionname = `tmp_actionname`);

	IF NOT EXISTS (SELECT 1 FROM ld_profile2standardpermissions WHERE tabid=@tabid and operation = @operation) THEN
		OPEN MYCUSOR;
FETCH MYCUSOR INTO tmp_profileid;
WHILE(tmp_profileid IS NOT NULL) DO
				SET @profileid=tmp_profileid;
INSERT INTO ld_profile2standardpermissions(profileid,tabid,operation,permissions,sequence)
SELECT @profileid AS profileid,@tabid AS tabid,@operation,0,0 FROM dual
WHERE not exists(select 1 from ld_profile2standardpermissions where tabid=@tabid and operation=@operation and profileid=@profileid) LIMIT 1;

FETCH MYCUSOR INTO tmp_profileid;
END WHILE;
CLOSE MYCUSOR;
END IF;
END ||
delimiter;

CALL ldcrm_add_profile_for_default_leads_dup_20231207('Leads','accountdatadup');
CALL ldcrm_add_profile_for_default_leads_dup_20231207('Leads','Merge');
CALL ldcrm_add_profile_for_default_leads_dup_20231207('Leads','dup_and_merge');
DROP PROCEDURE IF EXISTS `ldcrm_add_profile_for_default_leads_dup_20231207`;
delimiter;
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='Leads');
update ld_field set uitype=2 where tabid=@tabid and columnname = 'accountname' and uitype=1;
delimiter;

CALL addtableIndex('ld_cashbilldebuctiondetail','cashbillid','cashbillid');
CALL addtableIndex('ld_cashbilldebuctiondetail','debuctionid','debuctionid');
delimiter;

INSERT INTO ld_desk (languagetype, labelbol, fieldlabel, labeltype )
SELECT'zh','HEADERSETTINGS','顶部导航定制', 'fixedstr' FROM DUAL
where NOT EXISTS ( SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol = 'HEADERSETTINGS' AND labeltype = 'fixedstr' );
INSERT INTO ld_desk(languagetype, labelbol, fieldlabel, labeltype )
SELECT'en','HEADERSETTINGS','Top navigation bar settings', 'fixedstr'FROM DUAL
where NOT EXISTS ( SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol = 'HEADERSETTINGS' AND labeltype = 'fixedstr' );
delimiter;

INSERT INTO ld_desk (languagetype, labelbol, fieldlabel, labeltype )
SELECT'zh','SHOWICON','仅显示图标', 'fixedstr' FROM DUAL
where NOT EXISTS ( SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol = 'SHOWICON' AND labeltype = 'fixedstr' );
INSERT INTO ld_desk(languagetype, labelbol, fieldlabel, labeltype )
SELECT'en','SHOWICON','Show icon', 'fixedstr'FROM DUAL
where NOT EXISTS ( SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol = 'SHOWICON' AND labeltype = 'fixedstr' );
delimiter;

INSERT INTO ld_desk (languagetype, labelbol, fieldlabel, labeltype )
SELECT'zh','SHOWTEXT','仅显示文字', 'fixedstr' FROM DUAL
where NOT EXISTS ( SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol = 'SHOWTEXT' AND labeltype = 'fixedstr' );
INSERT INTO ld_desk(languagetype, labelbol, fieldlabel, labeltype )
SELECT'en','SHOWTEXT','Show text', 'fixedstr'FROM DUAL
where NOT EXISTS ( SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol = 'SHOWTEXT' AND labeltype = 'fixedstr' );
delimiter;

INSERT INTO ld_desk (languagetype, labelbol, fieldlabel, labeltype )
SELECT'zh','SHOWAVATAR','仅显示头像', 'fixedstr' FROM DUAL
where NOT EXISTS ( SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol = 'SHOWAVATAR' AND labeltype = 'fixedstr' );
INSERT INTO ld_desk(languagetype, labelbol, fieldlabel, labeltype )
SELECT'en','SHOWAVATAR','Show avatar', 'fixedstr'FROM DUAL
where NOT EXISTS ( SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol = 'SHOWAVATAR' AND labeltype = 'fixedstr' );
delimiter;

INSERT INTO ld_desk (languagetype, labelbol, fieldlabel, labeltype )
SELECT'zh','QUICKFINDDISPLAYMODE','全局查找显示方式', 'fixedstr' FROM DUAL
where NOT EXISTS ( SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol = 'QUICKFINDDISPLAYMODE' AND labeltype = 'fixedstr' );
INSERT INTO ld_desk(languagetype, labelbol, fieldlabel, labeltype )
SELECT'en','QUICKFINDDISPLAYMODE','Global Search Dispaly Mode', 'fixedstr'FROM DUAL
where NOT EXISTS ( SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol = 'QUICKFINDDISPLAYMODE' AND labeltype = 'fixedstr' );
delimiter;

INSERT INTO ld_desk (languagetype, labelbol, fieldlabel, labeltype )
SELECT'zh','QUICKCREATEDISPLAYMODE','快速创建显示方式', 'fixedstr' FROM DUAL
where NOT EXISTS ( SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol = 'QUICKCREATEDISPLAYMODE' AND labeltype = 'fixedstr' );
INSERT INTO ld_desk(languagetype, labelbol, fieldlabel, labeltype )
SELECT'en','QUICKCREATEDISPLAYMODE','Qucik Create Dispaly Mode', 'fixedstr'FROM DUAL
where NOT EXISTS ( SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol = 'QUICKCREATEDISPLAYMODE' AND labeltype = 'fixedstr' );
delimiter;

INSERT INTO ld_desk (languagetype, labelbol, fieldlabel, labeltype )
SELECT'zh','APPROVALREMINDSDISPLAYMODE','审批与消息显示方式', 'fixedstr' FROM DUAL
where NOT EXISTS ( SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol = 'APPROVALREMINDSDISPLAYMODE' AND labeltype = 'fixedstr' );
INSERT INTO ld_desk(languagetype, labelbol, fieldlabel, labeltype )
SELECT'en','APPROVALREMINDSDISPLAYMODE','Approval-Reminds Dispaly Mode', 'fixedstr'FROM DUAL
where NOT EXISTS ( SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol = 'APPROVALREMINDSDISPLAYMODE' AND labeltype = 'fixedstr' );
delimiter;

INSERT INTO ld_desk (languagetype, labelbol, fieldlabel, labeltype )
SELECT'zh','PERSONALINFORMATIONDISPLAYMODE','个人信息显示方式', 'fixedstr' FROM DUAL
where NOT EXISTS ( SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol = 'PERSONALINFORMATIONDISPLAYMODE' AND labeltype = 'fixedstr' );
INSERT INTO ld_desk(languagetype, labelbol, fieldlabel, labeltype )
SELECT'en','PERSONALINFORMATIONDISPLAYMODE','Personal Information Dispaly Mode', 'fixedstr'FROM DUAL
where NOT EXISTS ( SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol = 'PERSONALINFORMATIONDISPLAYMODE' AND labeltype = 'fixedstr' );
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','NoBusinessCardContactAdminToSet','无法生成电子名片，可能还未配置相关功能。请先联系管理员进行“小程序设置”','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='NoBusinessCardContactAdminToSet' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','NoBusinessCardContactAdminToSet','Unable to generate electronic business card,relevant functions may not have been configured yet. Please contact the administrator first for "Mini Program Settings"','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='NoBusinessCardContactAdminToSet' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','NoQRCodeContactAdminToSet','无法生成二维码，可能还未配置相关功能。请先联系管理员进行“小程序设置”','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='NoQRCodeContactAdminToSet' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','NoQRCodeContactAdminToSet','Unable to generate QR code,relevant functions may not have been configured yet. Please contact the administrator first for "Mini Program Settings"','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='NoQRCodeContactAdminToSet' and Labeltype='fixedstr' and languagetype='en');
delimiter;

call AddColumn('00_stylechangelog','menufont','varchar',100,'');
call AddColumn('00_stylechangelog','background_color','varchar',100,'');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','festivalred','节日红','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='festivalred' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','festivalred',"Festival Red",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='festivalred' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','midnightblack','午夜黑','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='midnightblack' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','midnightblack',"Midnight Black",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='midnightblack' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','backgroundone','背景一','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='backgroundone' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','backgroundone',"Background One",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='backgroundone' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','backgroundtwo','背景二','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='backgroundtwo' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','backgroundtwo',"Background Two",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='backgroundtwo' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','backgroundthree','背景三','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='backgroundthree' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','backgroundthree',"Background Three",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='backgroundthree' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','backgroundfour','背景四','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='backgroundfour' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','backgroundfour',"Background Four",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='backgroundfour' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','presetappearance','预设外观','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='presetappearance' and labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','presetappearance',"Preset appearance",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='presetappearance' and labeltype='jspop');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','presetbackground','预设背景色','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='presetbackground' and labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','presetbackground',"Preset background",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='presetbackground' and labeltype='jspop');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','customappearance','自定义','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='customappearance' and labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','customappearance',"Custom appearance",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='customappearance' and labeltype='jspop');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','entervalidcolor','请输入有效颜色','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='entervalidcolor' and labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','entervalidcolor',"Please enter a valid color",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='entervalidcolor' and labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','menuselectionfontcolor','菜单选中字体颜色','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='menuselectionfontcolor' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','menuselectionfontcolor',"Menu selection font color",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='menuselectionfontcolor' and labeltype='fixedstr');
delimiter;

CALL AddColumn('ld_account_public_pool','sequence','int','10','');
CALL AddColumn('ld_account_public_pool','default_pool','varchar','20','');
delimiter;
CALL AddColumn('ld_leads_public_pool','sequence','int','10','');
CALL AddColumn('ld_leads_public_pool','default_pool','varchar','20','');
delimiter;

set @i = 0;
UPDATE ld_account_public_pool set sequence = (@i:=@i+1) WHERE deleted = 0;
delimiter;

set @i = 0;
UPDATE ld_leads_public_pool set sequence = (@i:=@i+1) WHERE deleted = 0;
delimiter;

set @tabid = (select tabid from ld_tab where `name`='ContactRecords');
UPDATE ld_field SET advance_demand_groups = NULL WHERE tabid=@tabid AND columnname='accountid';
delimiter;
-- 2023-12-17

SET @tabid = (select tabid from ld_tab where `name` = 'Accounts');
UPDATE ld_field SET displaytype = 2 WHERE fieldname = 'earlyservicedate' and tabid = @tabid;
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','NoApprovalShowEmpty','无默认审批流时显示为空','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='NoApprovalShowEmpty' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','NoApprovalShowEmpty','Display empty if no default approval process','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='NoApprovalShowEmpty' and Labeltype='fixedstr' and languagetype='en');
delimiter;

call addtableIndex('ld_producttoolprofile','detail_fieldid','producttoolfieldid');
call addtableIndex('ld_producttoolprofile','detail_fieldtype','profilefieldtype');
call addtableIndex('ld_tabdetailprofile','tabdetail_fieldid','tabdetailfieldid');
call addtableIndex('ld_tabdetailprofile','tabdetail_fieldtype','profilefieldtype');
delimiter;


UPDATE ld_desk SET fieldlabel='已选合计' WHERE labelbol='TOTALOFSELECTEDDOCUMENTS' AND languagetype='zh' AND fieldlabel='已选单据合计';

delimiter;

set @labelbol = 'Conversionratecalculationmethod';
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh',@labelbol,'转换率计算方式','jspop' from dual
where not exists(select 1 from ld_desk where labelbol=@labelbol and Labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en',@labelbol,'Conversion rate calculation method','jspop' from dual
where not exists(select 1 from ld_desk where labelbol=@labelbol and Labeltype='jspop' and languagetype='en');
delimiter;

set @labelbol = 'ByOpportunityAmount';
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh',@labelbol,'按商机金额','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol=@labelbol and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en',@labelbol,'By Opportunity Amount','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol=@labelbol and Labeltype='fixedstr' and languagetype='en');
delimiter;

set @labelbol = 'ByOpportunityCount';
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh',@labelbol,'按商机数量','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol=@labelbol and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en',@labelbol,'By number of business opportunities','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol=@labelbol and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CONTINUE','继续','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='CONTINUE' and Labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','CONTINUE','Continue','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='CONTINUE' and Labeltype='jspop' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CREATREPORTTEXT1','使用该报表模板的报表已存在','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='CREATREPORTTEXT1' and Labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','CREATREPORTTEXT1','A report using this report template already exists','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='CREATREPORTTEXT1' and Labeltype='jspop' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CREATREPORTTEXT2','点击继续将另存为新命名的报表模板文件，点击保存将覆盖原先的报表模板文件','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='CREATREPORTTEXT2' and Labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','CREATREPORTTEXT2','Click to continue saving as a newly named report template file, click save to overwrite the original report template file','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='CREATREPORTTEXT2' and Labeltype='jspop' and languagetype='en');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','PRESETCOLOR','预设色','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='PRESETCOLOR' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','PRESETCOLOR','Preset color','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='PRESETCOLOR' and labeltype='fixedstr');
delimiter;
CREATE TABLE if not EXISTS `ld_picklist_presetcolor` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `color` varchar(10) COMMENT '颜色',
    `type` varchar(20) COMMENT '颜色分类',
    `sequence` int(11) COMMENT '排序',
    PRIMARY KEY (`id`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;
insert into ld_picklist_presetcolor(color,type,sequence) select '#ED84A2','preset',1 from dual where not exists(select 1 from ld_picklist_presetcolor where color = '#ED84A2' and type='preset');
insert into ld_picklist_presetcolor(color,type,sequence) select '#E35C7E','preset',6 from dual where not exists(select 1 from ld_picklist_presetcolor where color = '#E35C7E' and type='preset');
insert into ld_picklist_presetcolor(color,type,sequence) select '#F29B8F','preset',11 from dual where not exists(select 1 from ld_picklist_presetcolor where color = '#F29B8F' and type='preset');
insert into ld_picklist_presetcolor(color,type,sequence) select '#F18770','preset',16 from dual where not exists(select 1 from ld_picklist_presetcolor where color = '#F18770' and type='preset');
delimiter;
insert into ld_picklist_presetcolor(color,type,sequence) select '#A1B5BC','preset',2 from dual where not exists(select 1 from ld_picklist_presetcolor where color = '#A1B5BC' and type='preset');
insert into ld_picklist_presetcolor(color,type,sequence) select '#6D94A0','preset',7 from dual where not exists(select 1 from ld_picklist_presetcolor where color = '#6D94A0' and type='preset');
insert into ld_picklist_presetcolor(color,type,sequence) select '#BF97A0','preset',12 from dual where not exists(select 1 from ld_picklist_presetcolor where color = '#BF97A0' and type='preset');
insert into ld_picklist_presetcolor(color,type,sequence) select '#AF7680','preset',17 from dual where not exists(select 1 from ld_picklist_presetcolor where color = '#AF7680' and type='preset');
delimiter;
insert into ld_picklist_presetcolor(color,type,sequence) select '#9BA4B6','preset',3 from dual where not exists(select 1 from ld_picklist_presetcolor where color = '#9BA4B6' and type='preset');
insert into ld_picklist_presetcolor(color,type,sequence) select '#5D7289','preset',8 from dual where not exists(select 1 from ld_picklist_presetcolor where color = '#5D7289' and type='preset');
insert into ld_picklist_presetcolor(color,type,sequence) select '#99C39C','preset',13 from dual where not exists(select 1 from ld_picklist_presetcolor where color = '#99C39C' and type='preset');
insert into ld_picklist_presetcolor(color,type,sequence) select '#8AD7BD','preset',18 from dual where not exists(select 1 from ld_picklist_presetcolor where color = '#8AD7BD' and type='preset');
delimiter;
insert into ld_picklist_presetcolor(color,type,sequence) select '#9CC3DF','preset',4 from dual where not exists(select 1 from ld_picklist_presetcolor where color = '#9CC3DF' and type='preset');
insert into ld_picklist_presetcolor(color,type,sequence) select '#6A9BBF','preset',9 from dual where not exists(select 1 from ld_picklist_presetcolor where color = '#6A9BBF' and type='preset');
insert into ld_picklist_presetcolor(color,type,sequence) select '#F1C64C','preset',14 from dual where not exists(select 1 from ld_picklist_presetcolor where color = '#F1C64C' and type='preset');
insert into ld_picklist_presetcolor(color,type,sequence) select '#E1984D','preset',19 from dual where not exists(select 1 from ld_picklist_presetcolor where color = '#E1984D' and type='preset');
delimiter;
insert into ld_picklist_presetcolor(color,type,sequence) select '#C19CC9','preset',5 from dual where not exists(select 1 from ld_picklist_presetcolor where color = '#C19CC9' and type='preset');
insert into ld_picklist_presetcolor(color,type,sequence) select '#856E8A','preset',10 from dual where not exists(select 1 from ld_picklist_presetcolor where color = '#856E8A' and type='preset');
insert into ld_picklist_presetcolor(color,type,sequence) select '#AB9791','preset',15 from dual where not exists(select 1 from ld_picklist_presetcolor where color = '#AB9791' and type='preset');
insert into ld_picklist_presetcolor(color,type,sequence) select '#A27569','preset',20 from dual where not exists(select 1 from ld_picklist_presetcolor where color = '#A27569' and type='preset');
delimiter;
-- 2023-12-22

SET @disable_triggers=NULL;
UPDATE ld_field_seq SET id=(SELECT MAX(fieldid) FROM ld_field);
UPDATE ld_blocks_seq SET id=(SELECT MAX(blockid) FROM ld_blocks);
UPDATE ld_relatedlists_seq SET id=(SELECT MAX(relation_id) FROM ld_relatedlists);
UPDATE ld_customview_seq SET id = (SELECT MAX(cvid) FROM ld_customview);
UPDATE ld_links_seq SET id=(SELECT MAX(linkid) FROM ld_links);
UPDATE ld_picklist_dependency_seq SET id=(SELECT MAX(id) FROM ld_picklist_dependency);
UPDATE ld_crmentity_seq SET id=(SELECT MAX(crmid) FROM ld_crmentity);
UPDATE ld_approve_seq SET id=(SELECT MAX(id) FROM ld_approve);
UPDATE ld_approvestep_seq SET id=(SELECT MAX(id) FROM ld_approvestep);
UPDATE ld_autotask_seq SET id = (SELECT MAX(autotaskid) FROM ld_autotask);
UPDATE ld_currency_info_seq SET id=(SELECT MAX(id) FROM ld_currency_info);
UPDATE ld_users_seq SET id=(SELECT MAX(id) FROM ld_users);
UPDATE ld_tabdetailfield_seq SET id=(SELECT MAX(tabdetailfieldid) FROM ld_tabdetailfield);
UPDATE ld_customreport_info_seq SET id=(SELECT MAX(report_id) FROM ld_customreport_info);
UPDATE ld_producttoolfield_seq SET id=(SELECT MAX(producttoolfieldid) FROM ld_producttoolfield);
UPDATE ld_settings_field_seq SET id=(SELECT MAX(fieldid) FROM ld_settings_field);
UPDATE ld_workreport_field_seq SET id=(SELECT MAX(id) FROM ld_workreport_field);
delimiter;

UPDATE ld_version SET old_version='V8.6.1.9',current_version='V8.6.1.9',remark='V8.6.1.9-20231222',wx_version='V8.6.1.9';
delimiter;