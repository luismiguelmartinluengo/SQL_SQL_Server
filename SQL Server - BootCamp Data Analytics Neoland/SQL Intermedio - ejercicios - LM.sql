/*1. ¿Cuántas filas hay dentro de la tabla personas?*/
SELECT COUNT(*) AS TotalFilas
FROM Person.Person

/*2. Indicar la cantidad de empleados cuyos apellidos empiecen con una letra inferior a “D”*/
SELECT COUNT(*) As Empleados
FROM [HumanResources].[Employee] e
	LEFT JOIN [Person].[Person] p
		ON e.BusinessEntityID = p.BusinessEntityID
WHERE p.LastName like '[A-C]%'

SELECT COUNT(*) As Empleados
FROM [HumanResources].[Employee] e
	LEFT JOIN [Person].[Person] p
		ON e.BusinessEntityID = p.BusinessEntityID
WHERE p.LastName < 'D'
	

/*3. ¿Cuál es el promedio de StandardCost para cada producto donde StandardCost es mayor a $0? (Production.Product)*/
SELECT AVG([StandardCost]) As PromedioStandarCost
FROM [Production].[Product]
WHERE  [StandardCost] > 0

/*4. En la tabla personas ¿cuántas personas están asociadas con cada tipo de persona (PersonType)?*/
SELECT [PersonType], COUNT(*) AS Personas
FROM [Person].[Person]
GROUP BY [PersonType]

/*5. ¿Cuántos productos en Production.Product hay que son rojos (red) y cuántos que son negros (black)?*/
SELECT [Color], COUNT(*) AS Productos
FROM [Production].[Product]
WHERE [Color] in ('Black','Red')
GROUP BY [Color]

/*6. ¿Cuáles son las ventas (Sumatoria de “TotalDue”) por territorio para todas las filas de Sales.SalesOrderHeader? 
Traer sólo los territorios que se pasen de $10 millones en ventas históricas, traer el total de las ventas y el TerritoryID.*/
SELECT [TerritoryID], SUM([TotalDue]) AS TotalVentas
FROM [Sales].[SalesOrderHeader]
GROUP BY [TerritoryID]
HAVING SUM([TotalDue]) > 10000000

/*7. Usando la query anterior, hacer un join hacia Sales.SalesTerritory y reemplazar el TerritoryID con el nombre del territorio.*/
SELECT st.Name, SUM([TotalDue]) AS TotalVentas
FROM [Sales].[SalesOrderHeader] soh
	INNER JOIN [Sales].[SalesTerritory] st
		ON soh.TerritoryID = st.TerritoryID
GROUP BY st.Name
HAVING SUM([TotalDue]) > 10000000

/*8. ¿Cuántas filas en Person.Person no tienen NULL en MiddleName?*/
SELECT COUNT(*) AS PersonsWithMiddleName
FROM [Person].[Person]
WHERE [MiddleName] IS NOT NULL

/*9. Usando Production.Product encontrar cuántos productos están asociados con cada color. 
Ignorar las filas donde el color no tenga datos (NULL). 
Luego de agruparlos, devolver sólo los colores que tienen al menos 20 productos en ese color.*/
SELECT [Color], COUNT(*) AS Productos
FROM  [Production].[Product]
WHERE Color IS NOT NULL
GROUP BY Color
HAVING COUNT(*) >= 20

/*10. Hacer un join entre Production.Product y Production.ProductInventory sólo cuando los productos aparecen en ambas tablas. 
Hacerlo sobre el ProductID. Production.ProductInventory tiene la cantidad de cada producto, 
si se vende cada producto con un ListPrice mayor a cero, ¿cuánto fue el total facturado? (precio * cantidad)*/
SELECT SUM(p.ListPrice * i.Quantity) AS TotalFacturado
FROM [Production].[Product] p
	INNER JOIN [Production].[ProductInventory] i
		ON p.ProductID = i.ProductID
WHERE p.ListPrice > 0

/*11. Traer FirstName y LastName de Person.Person. 
Crear una tercera columna donde se lea “Promo 1” si el EmailPromotion es 0, “Promo 2” si el valor es 1 o “Promo 3” si es 2 */
SELECT [FirstName], [LastName],
	CONCAT('Promo ', EmailPromotion + 1) as Promo
FROM  [Person].[Person]

SELECT [FirstName], [LastName],
	CASE [EmailPromotion] 
		WHEN 0 THEN 'Promo 1' 
		WHEN 1 THEN 'Promo 2'
		WHEN 2 THEN 'Promo 3'
		ELSE 'Otro' 
	END as Promo
FROM  [Person].[Person]

/*12. Traer el BusinessEntityID y SalesYTD de Sales.SalesPerson, 
juntarla con Sales.SalesTerritory de tal manera que Sales.SalesPerson devuelva valores aunque no tenga asignado un territorio. 
Traes el nombre de Sales.SalesTerritory.*/
SELECT sp.BusinessEntityID, sp.SalesYTD, st.Name
FROM [Sales].[SalesPerson] sp
	LEFT OUTER JOIN [Sales].[SalesTerritory] st
		ON sp.TerritoryID = st.TerritoryID

/*13.Usando el ejemplo anterior, vamos a hacerlo un poco más complejo. 
Unir Person.Person para traer también el nombre y apellido. Sólo traer las filas cuyo territorio sea “Northeast” o “Central”. */
SELECT p.FirstName, p.LastName, sp.BusinessEntityID, sp.SalesYTD, st.Name
FROM [Sales].[SalesPerson] sp
	LEFT OUTER JOIN [Sales].[SalesTerritory] st
		ON sp.TerritoryID = st.TerritoryID
	LEFT OUTER JOIN [Person].[Person] p
		on sp.BusinessEntityID = p.BusinessEntityID
WHERE st.Name IN ('Northeast','Central')

/*14. Usando Person.Person y Person.Password hacer un INNER JOIN trayendo FirstName, LastName y PasswordHash.*/
SELECT p.FirstName, p.LastName, pwd.PasswordHash
FROM [Person].[Person] p
	INNER JOIN [Person].[Password] pwd
		ON p.BusinessEntityID = pwd.BusinessEntityID

/*15. Traer el título de Person.Person. Si es NULL devolver “No hay título”.*/
SELECT [FirstName], [LastName], COALESCE([Title], 'No hay título') AS Título
FROM [Person].[Person]

/*16. De Person.Person, Si MiddleName es NULL devolver FirstName y LastName concatenados, con un espacio de por medio. 
Si MiddeName no es NULL devolver FirstName, MiddleName y LastName concatenados, con espacios de por medio.*/
SELECT CONCAT([FirstName], 
				' ', 
				IIF([MiddleName] IS NULL, 
					'', 
					CONCAT([MiddleName], 
							' ')
				),
				[LastName]) AS NombreCompleto,
		CONCAT_WS(' ', [FirstName], [MiddleName], [LastName]) AS NombreCompleto2
FROM [Person].[Person]



/*17. Usando Production.Product si las columnas MakeFlag y FinishedGoodsFlag son iguales, que devuelva NULL. 
En caso contrario devolver ambos valores concatenados.*/
SELECT [MakeFlag], [FinishedGoodsFlag],
	IIF([MakeFlag] = [FinishedGoodsFlag],
		NULL,
		CONCAT_WS('-', [MakeFlag], [FinishedGoodsFlag])
	) As Flags
FROM [Production].[Product]

/*18. Usando Production.Product si el valor en color es NULL devolver “Sin color”. 
Si el color sí está, devolver el color. Se puede hacer de por lo menos dos maneras, desarrollar ambas (buscar funciones ISNULL y COALESCE).*/
SELECT COALESCE([Color], 'Sin color') AS ColorCoalesce,
	ISNULL([Color], 'Sin color') AS ColorIsNull
FROM [Production].[Product]

/*19. Traer el primer nombre y el apellido de los empleados que sean solteros. 
Resolverlo de 3 formas diferentes: con una CTE, subquery de lista y una de tabla
tablas : Person.Person , HumanResources.Employee */

-- 19.1 --
SELECT [FirstName], [LastName], [MaritalStatus]
FROM [Person].[Person] p
	INNER JOIN [HumanResources].[Employee] e
		ON p.BusinessEntityID = e.BusinessEntityID
WHERE e.MaritalStatus = 'S';

--19.2--
SELECT [FirstName], [LastName]
FROM [Person].[Person] p
WHERE P.BusinessEntityID IN (SELECT e.BusinessEntityID
							FROM [HumanResources].[Employee] e
							WHERE e.MaritalStatus = 'S');

--19.3--
WITH SingleEmployees AS (
	SELECT * 
	FROM [HumanResources].[Employee]
	WHERE [MaritalStatus] = 'S'
)--End SingleEmployees

SELECT [FirstName], [LastName]
FROM [Person].[Person] p
	INNER JOIN SingleEmployees se
		ON p.BusinessEntityID = se.BusinessEntityID

--19.4--
SELECT [FirstName], [LastName]
FROM [Person].[Person] p
	INNER JOIN (SELECT * 
				FROM [HumanResources].[Employee]
				WHERE [MaritalStatus] = 'S') s
		ON p.BusinessEntityID = s.BusinessEntityID

/*20. Traer el ID, nombre,segundo nombre,apellido, fecha de cumpleaños y edad  de los empleados mayores a 30 años.*/
SELECT p.BusinessEntityID, [FirstName], [MiddleName], [LastName], e.BirthDate,
	DATEDIFF(year, e.BirthDate, GETDATE()) AS Edad
FROM [Person].[Person] p
	INNER JOIN [HumanResources].[Employee] e
		ON p.BusinessEntityID = e.BusinessEntityID
WHERE DATEDIFF(year, e.BirthDate, GETDATE()) > 30
ORDER BY BirthDate

--21. Indicar el número de entidad de negocio y los tres primeros números del número de identificación nacional de cada uno de los empleados. 
--Renombrar la nueva columna como id_tres.
--Keywords: BusinessEntityId, NationalIDNumber, HumanResources.Employee.
SELECT [BusinessEntityID], LEFT([NationalIDNumber], 3) AS id_tres
FROM [HumanResources].[Employee]

--22. Indicar el id de dirección, la línea 1 de dirección (Addressline1) y los cuatro últimos dígitos del código postal 
-- de cada dirección registrada y renombrarla postal_4. 
-- Eliminar los espacios en el inicio y el final de los valores resultantes de addressline1. 
--Keywords: addressid, Addresline1, postalcode,person.Address
SELECT [AddressID], TRIM([AddressLine1]) AS AddressLine1, RIGHT([PostalCode],4) AS postal_4
FROM [Person].[Address]

--23. Indicar el id de provincia-estado y la concatenación de los campos codigo de region-país, nombre y código de provincia-estado.  
-- El resultado debe utilizar dos separadores: primero barra inclinada (/) y luego guión (-). Ejemplo: CA/California-CA. 
-- Renombrar la nueva columna como región. Los resultados de la nueva columna deben estar en mayúsculas. 
--Keywords: stateprovinceid, countryregioncode, name, stateprovinceid, Person.stateProvince
SELECT [StateProvinceID],
	UPPER(CONCAT([CountryRegionCode], '/', [Name], '-', [StateProvinceCode])) as Region
FROM [Person].[StateProvince]

--24. indicar el id de la foto producto y el nombre de archivo de foto. 
--Reemplazar el tipo de archivo gif por jpeg en cada uno de los registros. 
--Renombrar la nueva columna como foto. 
--Keywords: productphotoid, thumbnailphotofilename, productphoto,production.ProductPhoto
SELECT [ProductPhotoID], 
	REPLACE([ThumbnailPhotoFileName], 'gif','jpeg') AS Foto
FROM [Production].[ProductPhoto]

--25. Indicar el código de unidad de medida, el nombre y el año en el que fue modificado cada registro. 
-- Renombrar la nueva columna como anio_modificacion.
--Keywords: unitmeasurecode, name, modifieddate, production.unitMeasure.
SELECT [UnitMeasureCode],  [Name],
	DATEPART(YEAR, [ModifiedDate]) AS anio_modificacion
FROM [Production].[UnitMeasure]

--26. Indicar el id de tarjeta de crédito, el tipo de tarjeta y el mes en el que fue modificado cada registro almacenado para las tarjetas de crédito. 
--Renombrar a la nueva columna Mes_modificacion. 
-- Keywords: Creditcardid, cardtype, modifieddate, creditcard, sales.CreditCard.
SELECT [CreditCardID], [CardType], DATEPART(MONTH, [ModifiedDate]) AS Mes_modificacion
FROM [Sales].[CreditCard]

--27. Indicar el id del producto,la suma de la cantidad de producto y el día de la semana(ej: lunes, martes, etc) de la transacción. 
-- Ordenar descentente por id producto. Prestar atención a la agrupación para que solo aparezca un día de la semana por producto 
-- Keywords: transactionid, referenceorderid, transactiondate, transactionhistoryarchive, production.TransactionHistoryArchive.
SET LANGUAGE Spanish;

WITH Cantidades AS (
	SELECT [ProductID], 
		DATENAME(WEEKDAY, [TransactionDate]) AS DiaSemana, 
		DATEPART(WEEKDAY, [TransactionDate]) AS NumDiaSemana, 
		SUM([Quantity]) AS CantidadProducto
	FROM [Production].[TransactionHistoryArchive]
	GROUP BY [ProductID], DATENAME(WEEKDAY, [TransactionDate]), DATEPART(WEEKDAY, [TransactionDate])
)--End Cantidades
SELECT ProductID, DiaSemana, CantidadProducto
FROM Cantidades
ORDER BY ProductID DESC, NumDiaSemana ASC;

--28. Indicar el id de orden de pedido, la fecha de inicio y cual seria la fecha de entrega, 
--si cada orden debe ser recibida 30 días después de su inicio. 
--Consultar para cada orden de pedido registrada. Renombrar la nueva columna como entrega_estimada.
--Keywords: workorderid, startdate, workorder, production.workOrder.

SELECT [WorkOrderID], [StartDate], DATEADD(DAY, 30, [StartDate]) AS entrega_estimada
FROM [Production].[WorkOrder]

--29. Indicar el id de orden de pedido y cuántos dias hay entre la fecha programada de inicio y la fecha programada de fin, 
--para los id de orden comprendidos entre 72060 y 72070. 
--Se requiere la información correspondiente a la máxima fecha de registro, sin agregar la fecha de forma manual. 
--Renombrar la nueva columna como diferencia_dias. 
-- Keywords: workorderid, scheduledstartdate, scheduledenddate, modifieddate, production.WorkOrderRouting

SELECT TOP(1) [WorkOrderID], [ScheduledStartDate], [ScheduledEndDate],
	DATEDIFF(DAY, [ScheduledStartDate], [ScheduledEndDate]) AS diferencia_dias
FROM [Production].[WorkOrderRouting]
WHERE [WorkOrderID] BETWEEN 72060 AND 72070
ORDER BY [ModifiedDate] DESC


--30. Para el número de orden 43659: 
--Indicar el número de orden de venta y el número entero correspondiente al precio unitario de todos los registros de los detalles de ventas. 
--Se requiere la información correspondiente a la mínima fecha de registro, sin agregar la condición de fecha de forma manual. 
-- Renombrar la nueva columna como precio_en_enteros. 
--Keywords: salesorderid, unitprice, salesorderdetail, modifieddate, Sales.salesOrderDetail

SELECT TOP(1)
	[SalesOrderID], 
	CAST(FLOOR([UnitPrice]) AS INT) AS precio_en_enteros, [ModifiedDate] as t
FROM [Sales].[SalesOrderDetail]
WHERE [SalesOrderID] = 43659
ORDER BY [ModifiedDate] ASC