
USE fire_police_dw
BULK INSERT Time
FROM 'C:\Users\root\Desktop\dw_db_fiinal\Time.csv'
WITH 
(
    FIELDTERMINATOR = ',', 
	ROWTERMINATOR = '0x0A',
    TABLOCK
);


USE fire_police_dw
BULK INSERT Worker
FROM 'C:\Users\root\Desktop\dw_db_fiinal\Worker.csv'
WITH (
    FIELDTERMINATOR = ',', 
	ROWTERMINATOR = '0x0A',
    TABLOCK
);

USE fire_police_dw
BULK INSERT Vehicle
FROM 'C:\Users\root\Desktop\dw_db_fiinal\Vehicle.csv'
WITH (
    FIELDTERMINATOR = ',', 
	ROWTERMINATOR = '0x0A',
    TABLOCK
);

USE fire_police_dw
BULK INSERT Date
FROM 'C:\Users\root\Desktop\dw_db_fiinal\Date.csv'
WITH 
(
	FIRSTROW = 2,
    FIELDTERMINATOR = ',', 
	ROWTERMINATOR = '0x0A',
    TABLOCK
);

USE fire_police_dw
BULK INSERT Location
FROM 'C:\Users\root\Desktop\dw_db_fiinal\Location.csv'
WITH 
(
	FIRSTROW = 2,
    FIELDTERMINATOR = ',', 
	ROWTERMINATOR = '0x0A',
    TABLOCK
);

USE fire_police_dw
BULK INSERT Intervention_type
FROM 'C:\Users\root\Desktop\dw_db_fiinal\Intervention_type.csv'
WITH 
(
	FIRSTROW = 2,
    FIELDTERMINATOR = ',', 
	ROWTERMINATOR = '0x0A',
    TABLOCK
);

USE fire_police_dw
BULK INSERT Fault
FROM 'C:\Users\root\Desktop\dw_db_fiinal\Fault.csv'
WITH 
(
	FIRSTROW = 2,
    FIELDTERMINATOR = ',', 
	ROWTERMINATOR = '0x0A',
    TABLOCK
);


USE fire_police_dw
BULK INSERT FACT_vehicle_inspection
FROM 'C:\Users\root\Desktop\dw_db_fiinal\FACT_vehicle_inspection.csv'
WITH 
(
	FIRSTROW = 2,
    FIELDTERMINATOR = ',', 
	ROWTERMINATOR = '0x0A',
    TABLOCK
);

USE fire_police_dw
BULK INSERT FACT_Worker_in_action
FROM 'C:\Users\root\Desktop\dw_db_fiinal\FACT_Worker_in_action.csv'
WITH 
(
	FIRSTROW = 2,
    FIELDTERMINATOR = ',', 
	ROWTERMINATOR = '0x0A',
    TABLOCK
);

USE fire_police_dw
BULK INSERT FACT_crew_on_intervention
FROM 'C:\Users\root\Desktop\dw_db_fiinal\FACT_crew_on_intervention.csv'
WITH 
(
	FIRSTROW = 2,
    FIELDTERMINATOR = ',', 
	ROWTERMINATOR = '0x0A',
    TABLOCK
);