USE DW_fire_police

GO

DECLARE @today_date date;
SET @today_date = '2022-01-01';
DECLARE @row_num int;
SELECT @row_num = COUNT (*) FROM RDB_fire_police_small_T1.dbo.Vehicle;

If (object_id('dbo.VehicleTemp') is not null) DROP TABLE dbo.VehicleTemp;
CREATE TABLE VehicleTemp(id_fault INT PRIMARY KEY,
	id INT IDENTITY(1,1),
	vin_number varchar(40), 
	brand_name VARCHAR(40),
	model VARCHAR(40),	
	size VARCHAR(30) CHECK (size IN('SMALL', 'MEDIUM', 'BIG','LARGE')),
	registration_number VARCHAR(40),
	how_old VARCHAR(10) CHECK (how_old IN('OLD', 'MEDIUM', 'NEW')),
	date_of_production date,
	departures_number VARCHAR(15)
	);

GO

INSERT INTO VehicleTemp(vin_number,brand_name, model,size,registration_number, departures_number,date_of_production) 
SELECT RDB_Vehicle.vin_number, RDB_Vehicle.brand_name, RDB_Vehicle.model,RDB_Vehicle.size, RDB_Vehicle.registration_number,RDB_Vehicle.departures_number,RDB_Vehicle.date_of_production
FROM RDB_fire_police_small_T1.dbo.Vehicle AS RDB_Vehicle;


CREATE VIEW etlVehicle AS
SELECT

	vin_number,
	brand_name,
	model,
	CASE 

		WHEN YEAR(@today_date) -  YEAR(@date_temporary) = 10 THEN 'CRITICAL'
		WHEN fault_severity > 6 THEN 'HIGH'
		WHEN fault_severity > 3 THEN 'MEDIUM'
		WHEN fault_severity > 0 THEN 'LOW'
		ELSE 'NONE'
	END AS fault_severity,

	
FROM
	VehicleTemp
go

INSERT INTO DW_fire_police.dbo.Fault (
	car_element_name,
	fault_severity,
	price)
SELECT
	car_element_name,
	fault_severity,
	price
FROM
	etlFault


DROP VIEW etlFault
DROP TABLE dbo.FaultTemp

SELECT * FROM DW_fire_police.dbo.Fault