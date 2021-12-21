USE DW_fire_police

GO
If (object_id('dbo.MechanicTmp') is not null) DROP TABLE dbo.MechanicTmp;
CREATE TABLE MechanicTmp(id_fault INT PRIMARY KEY,
   vin_number VARCHAR(40),
   registration_number VARCHAR(40),
   date_send DATE,
   date_fixed DATE,
   milage INT,
   car_element_name VARCHAR(50) NOT NULL,
   fault_severity INT,
   price INT,
   komentarz VARCHAR(100))
GO

BULK INSERT MechanicTmp
    FROM 'C:\Users\qente\OneDrive\Pulpit\HD\FirePolice-Data_warehouse-master\Other_data_sources\Small\MechanicReport.csv'
    WITH
    (
        FIRSTROW = 2,
        FIELDTERMINATOR = ';',
        ROWTERMINATOR = '0x0A',
        TABLOCK
    )
go

GO
CREATE TABLE code_and_location(
	code VARCHAR(6), 
	region VARCHAR(40) NOT NULL,
	city VARCHAR(40) NOT NULL)
GO
--Pobieranie tablicy dekoduj¹cej code
INSERT INTO code_and_location (code,region,city) 
SELECT code,region,city
FROM RDB_fire_police_small_T1.dbo.Facility
go
--Widok pomocniczy
CREATE VIEW etlMechanic AS
SELECT
	id_fault,
	car_element_name,
	CASE 
		WHEN fault_severity = 10 THEN 'CRITICAL'
		WHEN fault_severity > 6 THEN 'HIGH'
		WHEN fault_severity > 3 THEN 'MEDIUM'
		WHEN fault_severity > 0 THEN 'LOW'
		ELSE 'NONE'
	END AS fault_severity,

	CASE
		WHEN price > 9000 THEN 'LARGE'
		WHEN price > 6000 THEN 'BIG'
		WHEN price > 3000 THEN 'MEDIUM'
		WHEN price > 0 THEN 'LOW'
		ELSE 'NONE'
	END AS priceType
FROM
	MechanicTmp
go

SELECT * FROM etlMechanic

INSERT INTO DW_fire_police.dbo.FACT_vehicle_inspection(
	id_vehicle_vin,
	id_fault,
	id_facility_location,
	id_date_of_visit_at_mechanics,
	days_fix_duration,
	cost)

SELECT
	MechanicTmp.vin_number as id_vehicle_vin ,
	Fault.id_fault,
	Location.id_location as id_facility_location,
	Date.id_date as id_date_of_visit_at_mechanics,
	DATEDIFF(DAY, date_send,date_fixed)+1 as IloscDni,
	MechanicTmp.price as cost
FROM 
	MechanicTmp 
	--lokalizacja
	INNER JOIN RDB_fire_police_small_T1.dbo.Vehicle ON MechanicTmp.vin_number = Vehicle.vin_number
	INNER JOIN RDB_fire_police_small_T1.dbo.Facility ON RDB_fire_police_small_T1.dbo.Vehicle.code_facility = Facility.code
	INNER JOIN DW_fire_police.dbo.Location ON Location.closest_city = Facility.city and Location.region = Facility.region and Location.name = 'Straz'
	--usterka
	INNER JOIN DW_fire_police.dbo.etlMechanic ON MechanicTmp.id_fault = etlMechanic.id_fault 
	INNER JOIN DW_fire_police.dbo.Fault ON etlMechanic.priceType = Fault.price AND etlMechanic.fault_severity = Fault.fault_severity AND etlMechanic.car_element_name = Fault.car_element_name
	--data
	INNER JOIN DW_fire_police.dbo.Date ON Date.year = year(date_send) AND Date.month = month(date_send) AND Date.day= day(date_send)

DROP TABLE code_and_location
DROP TABLE dbo.MechanicTmp
DROP VIEW etlMechanic
--SELECT vin_number,code_facility FROM RDB_fire_police_small_T1.dbo.Vehicle
--SELECT code,city FROM RDB_fire_police_small_T1.dbo.Facility

SELECT * FROM DW_fire_police.dbo.FACT_vehicle_inspection

