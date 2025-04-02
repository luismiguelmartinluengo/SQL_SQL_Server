--1. Agregar una columna llamada “Ranking” con el ranking de ventas en función del monto (SalesOrderHeader.TotalDue)
SELECT [SalesOrderID], 
	[TotalDue],
	RANK() OVER (ORDER BY [TotalDue] DESC) AS Ranking
FROM [Sales].[SalesOrderHeader];

--2. Agregar una columna llamada “Ranking” por territorio con el ranking de ventas en función del monto y territorio. 
--Mostrar el nombre del Territorio, SalesOrderID, OrderDate, TotalDue y Ranking
SELECT st.Name, soh.SalesOrderID, soh.OrderDate, soh.TotalDue,
	RANK() OVER (PARTITION BY st.Name ORDER BY soh.TotalDue DESC) as Ranking
FROM [Sales].[SalesOrderHeader] soh
	INNER JOIN [Sales].[SalesTerritory] st
		ON soh.TerritoryID = st.TerritoryID;

--3. Agregar una columna en la tabla SalesPerson que muestre la contribución de esa persona a las ventas del año (SalesYTD / total de SalesYTD)
SELECT [BusinessEntityID],
	ROUND([SalesYTD] / SUM([SalesYTD]) OVER (), 4) AS Contribucion
FROM [Sales].[SalesPerson]
ORDER BY [SalesYTD] DESC;

--4. En la tabla CurrencyRate, buscar los registros que reflejen el tipo de cambio Dólar a Euro 
--y calcular cual fue la máxima fluctuación de un día a otro (considerar el AverageRate).
SELECT TOP 1 [CurrencyRateDate] AS Fecha,
	COALESCE(ABS([AverageRate] - LAG([AverageRate]) OVER (ORDER BY [CurrencyRateDate])),0) AS DiferenciaAverageRateAbs
FROM [Sales].[CurrencyRate]
WHERE FromCurrencyCode = 'USD'
	AND ToCurrencyCode = 'EUR'
ORDER BY DiferenciaAverageRateAbs DESC;

--5. De los dos vendedores (SalesPersonID) que hayan tenido mayor cantidad de ventas (SalesYTD) en toda la historia, 
-- mostrar sus 5 ventas más altas (TotalDue). 
--La tabla debe tener Nombre y apellido del vendedor (tabla Person), JobTitle, OrderDate y TotalDue

WITH TopSalesPerson AS (
	SELECT TOP 2 sp.BusinessEntityID, sp.SalesYTD, p.FirstName, p.LastName, e.JobTitle
	FROM  [Sales].[SalesPerson] sp
		INNER JOIN [Person].[Person] p
			ON sp.BusinessEntityID = p.BusinessEntityID
		INNER JOIN [HumanResources].[Employee] e
			ON sp.BusinessEntityID = e.BusinessEntityID
	ORDER BY [SalesYTD] DESC
)--End TopSalesPerson

SELECT tsp.FirstName, tsp.LastName, tsp.JobTitle, soh.OrderDate, soh.TotalDue
FROM TopSalesPerson tsp
	OUTER APPLY (SELECT TOP(5) soh.[OrderDate], soh.[TotalDue]
				FROM [Sales].[SalesOrderHeader] soh
				WHERE soh.[SalesPersonID] = tsp.BusinessEntityID
				ORDER BY TotalDue DESC) soh;

--6. En la tabla Production.WorkOrder mostrar los datos de el o los días (DueDate) que más piezas se hayan pedido (OrderQty) 
--de las piezas que tengan un precio de lista mayor a 3000 (Product.ListPrice). 
--Mostrar ProductID, DueDate, OrderQty y ListPrice

SELECT p.[ProductID], p.[ListPrice], wo.DueDate, wo.OrderQty
	FROM [Production].[Product] p
	CROSS APPLY (SELECT wo.[DueDate], wo.[OrderQty],
				RANK() OVER (PARTITION BY wo.[ProductID] ORDER BY wo.OrderQty DESC) AS Ranking
				FROM [Production].[WorkOrder] wo
				WHERE wo.ProductID = p.ProductID) wo
WHERE p.[ListPrice] > 3000
	AND wo.Ranking = 1;

--7. Buscar cuales fueron los dos compradores que mayores compras realizaron por cada territorio (ver tabla Sales.SalesOrderHeader). 
--Indicar nombre del territorio, id del cliente y cantidad de compras

WITH RankingComprasClienteTerritorio AS (
	SELECT [TerritoryID], [CustomerID],
		COUNT(*) AS CantidadCompras,
		SUM([TotalDue]) AS TotalDue,
		RANK() OVER (PARTITION BY [TerritoryID] ORDER BY SUM([TotalDue]) DESC) AS RankingCompras
	FROM [Sales].[SalesOrderHeader]
	GROUP BY [TerritoryID], [CustomerID]
)--End RankingComprasClienteTerritorio
SELECT st.Name, rcct.CustomerID, rcct.CantidadCompras, rcct.TotalDue
FROM RankingComprasClienteTerritorio rcct
	INNER JOIN [Sales].[SalesTerritory] st
		ON rcct.TerritoryID = st.TerritoryID
WHERE rcct.RankingCompras < 3
ORDER BY st.Name, rcct.CustomerID

--8. Mostar una tabla que tenga en las filas los territorios y en las columnas las categorías de productos (Production.ProductCategory) . 
--La misma debe contener la cantidad de unidades vendidas (OrderQty) por cada categoría y territorio respectivamente.

WITH Ventas AS (
	SELECT st.Name As Territorio, pc.Name AS Categoria, sod.[OrderQty] AS UnidadesVendidas
	FROM [Sales].[SalesOrderDetail] sod
		INNER JOIN [Sales].[SalesOrderHeader] soh
			ON sod.SalesOrderID = soh.SalesOrderID
		INNER JOIN [Production].[Product] p
			ON sod.ProductID = p.ProductID
		INNER JOIN [Production].[ProductSubcategory] ps
			ON p.ProductSubcategoryID = ps.ProductSubcategoryID
		INNER JOIN [Production].[ProductCategory] pc
			ON ps.ProductCategoryID = pc.ProductCategoryID
		INNER JOIN [Sales].[SalesTerritory] st
			ON soh.TerritoryID = st.TerritoryID
)--End Ventas
SELECT *
FROM Ventas
PIVOT (
	SUM(UnidadesVendidas)
	FOR Categoria IN ([Accessories],[Bikes],[Clothing],[Components])
	) AS Pivotada
ORDER BY Territorio

--E1. Cuales fueron los 5 productos con más ventas en 2012. 
-- Mostrar los 3 compradores (Customer) que gastaron mas dinero (LineTotal) de cada uno de estos durante este año.
--pista: los productos correspondientes a cada orden de compra estan en “Sales.SalesOrderDetail” 

WITH Detalle AS (
	SELECT soh.CustomerID, sod.ProductID, sod.OrderQty, sod.LineTotal
	FROM [Sales].[SalesOrderHeader] soh
		INNER JOIN [Sales].[SalesOrderDetail] sod ON soh.SalesOrderID = sod.SalesOrderID
	WHERE DATEPART(YEAR, soh.OrderDate) = 2012
),--End Detalle
TopProductos AS (
	SELECT TOP(5) d.ProductID, SUM(d.OrderQty) AS UnidadesVendidas
	FROM Detalle d
	GROUP BY d.ProductID
	ORDER BY UnidadesVendidas DESC
)--End TopProductos
SELECT TOP 5 p.FirstName, p.LastName,
	SUM(d.LineTotal) AS GastoTotalOnTopProductos
FROM Detalle d
	INNER JOIN [Sales].[Customer] c ON d.CustomerID = c.CustomerID
	INNER JOIN [Person].[Person] p ON c.PersonID = p.BusinessEntityID
WHERE d.ProductID IN (SELECT tp.ProductID
						FROM TopProductos tp)
GROUP BY p.FirstName, p.LastName
ORDER BY GastoTotalOnTopProductos DESC

--E2. Cual es el nombre de los 5 mejores vendedores (SalesYTD) de cada territorio? (aclarar nombre de territorio)

WITH TopVendedoresPorTerritorio AS (
	SELECT sp.TerritoryID, sp.BusinessEntityID, sp.SalesYTD,
		ROW_NUMBER() OVER (PARTITION BY sp.TerritoryID ORDER BY sp.SalesYTD DESC) As Ranking
	FROM [Sales].[SalesPerson] sp
)--End TopVendedoresPorTerritorio
SELECT st.Name, tvpt.Ranking, p.FirstName, p.LastName, tvpt.SalesYTD
FROM TopVendedoresPorTerritorio tvpt
	INNER JOIN [Person].[Person] p ON tvpt.BusinessEntityID = p.BusinessEntityID
	INNER JOIN [Sales].[SalesTerritory] st ON tvpt.TerritoryID = st.TerritoryID
WHERE tvpt.Ranking < 6

--E3. Cuantos productos de la categoría &#39;Bikes&#39; (Production.ProductCategory) se vendieron
--con algún tipo de descuento? ( SpecialOfferID != 1 , en la tabla “Sales.SalesOrderDetail”)
--pista: la cantidad de productos vendidos por orden de compra esta en “Sales.SalesOrderDetail”

--SELECT sod.ProductID, sod.OrderQty, sod.SpecialOfferID, p.ProductSubcategoryID, ps.ProductCategoryID, pc.Name
SELECT SUM(sod.OrderQty) AS ProductosBikesVendidosConDescuento
FROM [Sales].[SalesOrderDetail] sod
	INNER JOIN [Production].[Product] p ON sod.ProductID = p.ProductID
	INNER JOIN [Production].[ProductSubcategory] ps ON p.ProductSubcategoryID = ps.ProductSubcategoryID
	INNER JOIN [Production].[ProductCategory] pc ON ps.ProductCategoryID = pc.ProductCategoryID
WHERE sod.SpecialOfferID != 1
	AND pc.Name = 'Bikes'

--E4. Buscar el top 5 de clientes (Customer) que hayan comprado mayor cantidad de
--unidades de cascos (subcategoría ‘Helmets’) por cada territorio
--Los territorios se encuentran en Sales.SalesTerritory

WITH CascosCompradosPorClienteYTerritorio AS (
	SELECT soh.TerritoryID, soh.CustomerID, SUM(sod.OrderQty) AS CascosComprados
	FROM [Sales].[SalesOrderDetail] sod
		INNER JOIN [Production].[Product] p ON sod.ProductID = p.ProductID
		INNER JOIN [Production].[ProductSubcategory] ps ON p.ProductSubcategoryID = ps.ProductSubcategoryID
		INNER JOIN [Sales].[SalesOrderHeader] soh ON sod.SalesOrderID = soh.SalesOrderID
	WHERE ps.Name = 'Helmets'
	GROUP BY soh.TerritoryID, soh.CustomerID
),--End CascosCompradosPorClienteYTerritorio
Ranking AS (
SELECT *, ROW_NUMBER() OVER (PARTITION BY ccpcyt.TerritoryID ORDER BY ccpcyt.CascosComprados DESC) AS Ranking
FROM CascosCompradosPorClienteYTerritorio ccpcyt
)--End Ranking
SELECT st.Name, r.Ranking, p.FirstName, p.LastName, r.CascosComprados
FROM Ranking r
	INNER JOIN [Sales].[SalesTerritory] st ON r.TerritoryID = st.TerritoryID
	INNER JOIN [Sales].[Customer] c ON r.CustomerID = c.CustomerID
	INNER JOIN [Person].[Person] p ON c.PersonID = p.BusinessEntityID
WHERE r.Ranking < 6
ORDER BY st.Name, r.Ranking

--5. Cual fue el producto con mayor cantidad de unidades vendidas de las transacciones
--realizadas en dólares australianos(ToCurrencyCode = &#39;AUD&#39; en la tabla Sales.CurrencyRate )

SELECT TOP 1 p.Name, SUM(sod.OrderQty) CantidadVendida
FROM [Sales].[SalesOrderDetail] sod
	INNER JOIN [Sales].[SalesOrderHeader] soh ON sod.SalesOrderID = soh.SalesOrderID
	INNER JOIN [Sales].[CurrencyRate] cr ON soh.CurrencyRateID = cr.CurrencyRateID
	INNER JOIN [Production].[Product] p ON sod.ProductID = p.ProductID
WHERE cr.ToCurrencyCode = 'AUD'
GROUP BY p.Name
ORDER BY CantidadVendida DESC

--6. Buscar cuales el país (CountryRegionCode) en el que viven menos empleados
--tablas de interes: ‘Person.Address’ y ‘Person.StateProvince’

WITH EmpleadosPorPais AS (
	SELECT sp.CountryRegionCode, COUNT(p.[BusinessEntityID]) as Empleados
	FROM [Person].[Person] p
		INNER JOIN [HumanResources].[Employee] e ON p.BusinessEntityID = e.BusinessEntityID
		INNER JOIN [Person].[BusinessEntityAddress] bea ON p.BusinessEntityID = bea.BusinessEntityID
		INNER JOIN [Person].[Address] a ON bea.AddressID = a.AddressID
		INNER JOIN [Person].[StateProvince] sp ON a.StateProvinceID = sp.StateProvinceID
	GROUP BY sp.CountryRegionCode
),--End EmpleadosPorPais
Ranking AS (
	SELECT epp.*,
		RANK() OVER(ORDER BY epp.Empleados ASC) AS Ranking
	FROM EmpleadosPorPais epp
)--End Ranking
SELECT r.CountryRegionCode, r.Empleados
FROM Ranking r
WHERE r.Ranking = 1


--7. Buscar el id de la tarjeta de credito que estaba más cerca de su vencimiento al
--momento de realizar una orden de compra y mostrar cuantos días faltaban para el
--vencimiento. Suponer que las tarjetas vencen el último día del mes (posiblemente
--necesites usar las funciones DATEFROMPARTS, EOMONTH y DATEDIFF).
--tablas de utilidad: ‘Sales.SalesOrderHeader’ y ‘Sales.CreditCard’

SELECT TOP 1 
	soh.CreditCardID, CAST(soh.OrderDate AS DATE) FechaOrden, 
	DATEADD(YEAR, 10, EOMONTH(DATEFROMPARTS(cc.ExpYear, cc.ExpMonth, 1))) As FechaExpiracion,
	DATEDIFF(DAY, soh.OrderDate, DATEADD(YEAR, 10, EOMONTH(DATEFROMPARTS(cc.ExpYear, cc.ExpMonth, 1)))) AS DiasHastaExpiracion
FROM [Sales].[SalesOrderHeader] soh
	INNER JOIN [Sales].[CreditCard] cc ON soh.CreditCardID = cc.CreditCardID
ORDER BY DiasHastaExpiracion ASC
