use DW_fire_police
GO

create table temporary_COI(
	id INT IDENTITY(1,1),
	id_intervention INT,
	id_intervention_type INT, 
	vehicle_vin VARCHAR(40), 
	id_departure_location INT,
	id_facility_location INT,
	date_of_intervention date, 
	time_of_intervention time, 
	id_notification INT, 
	time_since_notification INT, 
	days_intervention_duration INT,
	time_intervention_duration INT,
	number_of_impacted_people INT, 
	number_of_dead_people INT, 
	success_of_intervention INT 


);


INSERT INTO temporary_COI(id_notification,id_intervention,vehicle_vin,date_of_intervention,time_of_intervention) 
SELECT id_notification,intervention_id,id_vehicle,date_intervention_start,time_intervention_start
FROM RDB_fire_police_small_T1.dbo.Crew_on_intervention;

DECLARE @row_num int;
SELECT @row_num = COUNT (*) FROM temporary_COI

DECLARE @i int;
SET @i = 1;
SET @row_num = 1000;
PRINT(@row_num);
while @i < @row_num+1
BEGIN
	DECLARE @facility_location_code VARCHAR(10);
	DECLARE @current_id_notification INT;
	DECLARE @current_id_intervention INT;
	DECLARE @id_intervention_type INT;
	DECLARE @number_of_impacted_people INT;
	DECLARE @number_of_dead_people INT;
	DECLARE @time_notification_start time;
	DECLARE @time_intervention_start time;
	DECLARE @date_notification_start date;
	DECLARE @date_intervention_start date;
	DECLARE @date_intervention_end date;
	DECLARE @time_intervention_end time;


	--select id_notification from temp table
	SELECT @current_id_notification=[id_notification] 
	FROM temporary_COI
	WHERE id = @i;
		
	--select single row from RDB Notifcation to determine which facitlity does id_notification relate to
	
	SELECT 
	@facility_location_code = [code_facility],
	@time_notification_start=time_start,
	@date_notification_start=date_start
	FROM RDB_fire_police_small_T1.dbo.Notification
	WHERE id = @current_id_notification;
	
	DECLARE @facility_closest_city VARCHAR(40);
	DECLARE @facility_region VARCHAR(40);	
	DECLARE @facility_district INT;
	DECLARE @facility_name VARCHAR(50);
	SET @facility_name = 'LocationOfFirePolice'

	--SELECT FACILITY LOCATION THAT CORRESPONDS TO THE CURRENT NOTIFICAITON
	SELECT 
	@facility_closest_city = city,
	@facility_region=region,
	@facility_district=district
	FROM RDB_fire_police_small_T1.dbo.Facility
	WHERE code = @facility_location_code;

	

	-- SELECT FALCILITY LOCATION FROM DW.LOCATION THAT CORRESPONDS TO RDB.FACLITIY 
	DECLARE @facility_id_location INT;
	SELECT TOP 1 @facility_id_location  = id_location FROM DW_fire_police.dbo.Location
	WHERE closest_city = @facility_closest_city AND
	region = @facility_region AND
	district = @facility_district AND
	name =  @facility_name;
	--
	--PRINT(@facility_location_code)

	--SELECT departure location
	

	
	--select id_intervention from temp table
	SELECT @current_id_intervention=[id_intervention] 
	FROM temporary_COI
	WHERE id = @i;

	DECLARE @departure_closest_city VARCHAR(40);
	DECLARE @departure_region VARCHAR(40);
	DECLARE @departure_name VARCHAR(40);
	SET @departure_name = 'LocationOfIntervention';

	-- SELECT LOCATION FROM RDB
	SELECT @departure_closest_city = closest_city, @departure_region = region 
	FROM RDB_fire_police_small_T1.dbo.Intervention
	WHERE id = @current_id_intervention;


	PRINT('closest city');
	PRINT(@departure_closest_city);
	PRINT('closest city');
	
	-- MAP RDB LOCATION INTERVENTION TO LOCATION DEPARTURE DW
	DECLARE @departure_id_location INT;
	SELECT TOP 1 @departure_id_location = id_location FROM DW_fire_police.dbo.Location
	WHERE closest_city = @departure_closest_city AND
	region = @departure_region AND
	name = @departure_name;

	--select id_intervention_type from temp table
	SELECT @id_intervention_type=[code] 
	FROM RDB_fire_police_small_T1.dbo.Intervention_type
	WHERE code = @current_id_intervention;

	--CALCULATE MEASURES
	SELECT 
	@time_intervention_start = time_intervention_start, 
	@date_intervention_start = date_intervention_start, 
	@date_intervention_end = date_intervention_end,
	@time_intervention_end = time_intervention_end
	FROM RDB_fire_police_small_T1.dbo.Crew_on_intervention
	WHERE  id_action_crew = @i;

	
	--PRINT(@time_notification_start)
	--PRINT(@time_intervention_start)
	--PRINT(@date_notification_start)
	--PRINT(@date_intervention_start)
	
	--Combine dates with time
	DECLARE @combined_intervention_datetime_start DATETIME;
	DECLARE @combined_notification_datetime_start DATETIME;
	DECLARE @combined_intervention_datetime_end DATETIME;

	SELECT @combined_intervention_datetime_start = CAST(CONCAT(@date_intervention_start, ' ', @time_intervention_start) AS datetime2(0));
	SELECT @combined_notification_datetime_start = CAST(CONCAT(@date_notification_start, ' ', @time_notification_start) AS datetime2(0));
	SELECT @combined_intervention_datetime_end = CAST(CONCAT(@date_intervention_end, ' ', @time_intervention_end) AS datetime2(0));

	--PRINT('combined start and end');
	--Print(@combined_intervention_datetime_start);
	--Print(@combined_intervention_datetime_end);

	--calculate difference beetween notification and intervention
	DECLARE @dateDiffDay INT;
	DECLARE @dateDiffMinute INT;	

	SELECT @dateDiffMinute = DATEDIFF(MINUTE, @combined_notification_datetime_start ,@combined_intervention_datetime_start);
	   
	DECLARE @time_since_notification INT;
	SET @time_since_notification = @dateDiffMinute;
	
	--calculate difference beetween intervention_start and intervention_end
	SELECT @dateDiffDay = DATEDIFF(DAY, @combined_intervention_datetime_start ,@combined_intervention_datetime_end);
	SELECT @dateDiffMinute = DATEDIFF(MINUTE, @combined_intervention_datetime_start ,@combined_intervention_datetime_end);
	
	DECLARE @days_intervention_duration INT;
	SET @days_intervention_duration=@dateDiffDay;		

	DECLARE @time_intervention_duration INT;	
	SET @time_intervention_duration = @dateDiffMinute;  

		   
--number_of_dead_people = @number_of_dead_people
	--update columns
	DECLARE @no_of_impacted_ppl INT;	
	DECLARE @no_of_dead_ppl INT;	

	SELECT 
	@no_of_impacted_ppl = number_of_impacted_people, 
	@no_of_dead_ppl = number_of_dead_people
	FROM RDB_fire_police_small_T1.dbo.Intervention 
	WHERE id = @current_id_intervention;

	PRINT('PPL');
	PRINT(@no_of_impacted_ppl);
	PRINT('PPL2');
	PRINT(@no_of_dead_ppl);

	--calculate success
	DECLARE @success_of_intervention INT;

	IF @time_since_notification < 15
	BEGIN
		SET @success_of_intervention = 5;
	END
	ELSE IF @time_since_notification >=15 AND @time_since_notification < 30
	BEGIN
		SET @success_of_intervention = 4;
	END
	ELSE IF @time_since_notification >=30 AND @time_since_notification < 60
	BEGIN
		SET @success_of_intervention = 3;
	END
	ELSE IF @time_since_notification >=60 AND @time_since_notification < 180
	BEGIN
		SET @success_of_intervention = 2;
	END
	ELSE IF @time_since_notification >=180
	BEGIN
		SET @success_of_intervention = 1;
	END

	UPDATE temporary_COI
	SET 
	id_intervention_type = @id_intervention_type, 
	id_departure_location = @departure_id_location,
	id_facility_location = @facility_id_location,
	time_since_notification = @time_since_notification,
	days_intervention_duration = @days_intervention_duration,
	time_intervention_duration = @time_intervention_duration,
	number_of_impacted_people = @no_of_impacted_ppl,
	number_of_dead_people = @no_of_dead_ppl,
	success_of_intervention = @success_of_intervention
	

	WHERE  id = @i;


	SET @i = @i +1;
	--PRINT(@days_intervention_duration)
	--PRINT(@time_since_notification_duration)
	
END;


--drop temporary table
SELECT * FROM temporary_COI;
DROP TABLE temporary_COI;