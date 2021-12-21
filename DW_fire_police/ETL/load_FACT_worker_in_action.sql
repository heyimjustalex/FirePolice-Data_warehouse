USE DW_fire_police
ALTER TABLE DW_fire_police.dbo.FACT_Worker_in_action
	DROP CONSTRAINT PESEL_CHECK4

INSERT INTO DW_fire_police.dbo.FACT_Worker_in_action
SELECT
	id_crew,
	worker_pesel_number
	FROM
RDB_fire_police_small_T1.dbo.Worker_in_action;