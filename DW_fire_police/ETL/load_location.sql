USE DW_fire_police

GO
If (object_id('dbo.FaultTemp') is not null) DROP TABLE dbo.FaultTemp;
CREATE TABLE LocationTemp(
   id_location INT IDENTITY(1,1) PRIMARY KEY,
   name VARCHAR(50),
   region VARCHAR(40),
   district VARCHAR(10),
   closest_city VARCHAR(40));
GO

INSERT INTO LocationTemp (name,region,district,closest_city) 
SELECT 'LocationOfFirePolice',f.region,f.district,f.city 
FROM RDB_fire_police_small_T1.dbo.Facility AS f;

INSERT INTO LocationTemp (name,region,closest_city) 
SELECT 'LocationOfIntervention',region,closest_city 
FROM RDB_fire_police_small_T1.dbo.Intervention;


INSERT INTO DW_fire_police.dbo.Location (
	name,
	region,
	district,
	closest_city
	)
SELECT
	name,region,district,closest_city
FROM 
	LocationTemp
GROUP BY
name,region, district, closest_city



DROP TABLE dbo.LocationTemp

SELECT * FROM DW_fire_police.dbo.Location 