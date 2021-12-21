USE DW_fire_police

GO
If (object_id('dbo.InterventionType') is not null) DROP TABLE dbo.InterventionType;
CREATE TABLE InterventionTypeTemp(
   code INT IDENTITY(1,1),
   name VARCHAR(40),
   severity INT);
GO

INSERT INTO InterventionTypeTemp(name,severity) 
SELECT name,severity FROM RDB_fire_police_small_T1.dbo.Intervention_type;

GO

CREATE VIEW etlInterventionType_View AS
SELECT
	name,
	CASE 
		WHEN severity = 10 THEN 'CRITICAL'
		WHEN severity > 6 THEN 'HIGH'
		WHEN severity> 3 THEN 'MEDIUM'
		WHEN severity > 0 THEN 'LOW'
		ELSE 'NONE'
	END AS severity
	
FROM
	InterventionTypeTemp
go

INSERT INTO DW_fire_police.dbo.Intervention_type(	
	name,
	severity)
SELECT
	
	name,
	severity
FROM
	etlInterventionType_View


DROP VIEW etlInterventionType_View
DROP TABLE InterventionTypeTemp

SELECT * FROM DW_fire_police.dbo.Intervention_type