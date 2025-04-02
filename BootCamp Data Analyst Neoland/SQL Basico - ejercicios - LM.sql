-- 1. Seleccionar todos los registros de la tabla Persons
SELECT *
FROM Person.Person;

-- 2. Seleccionar todos los registros de la tabla Address
SELECT *
FROM Person.Address;

-- 3. Seleccionar todos los registros de la tabla Employee

SELECT *
FROM HumanResources.Employee;

-- 4. Seleccionar las columnas FirstName, MiddleName y LastName de la tabla Persons
SELECT FirstName, MiddleName, LastName
FROM Person.Person;

-- 5. Seleccionar los valores únicos de la columna City de la tabla Adress
SELECT DISTINCT(a.City)
FROM Person.Address a

-- 6. Seleccionar las primeras 10 filas de la tabla Persons
SELECT TOP(10) *
FROM Person.Person;

-- 7.Traer las 100 primeras filas de Production.Product donde el ListPrice no es 0
SELECT TOP(100) *
FROM Production.Product p
where p.ListPrice != 0;

/* 8. Seleccionar las columnas FirstName, MiddleName y LastName de la tabla Persons, 
con los nombre PrimerNombre, SegundoNombre y Apellido respectivamente */
SELECT p.FirstName AS PrimerNombre,
	p.MiddleName AS SegundoNombre,
	p.LastName AS Apellido
FROM Person.Person p

-- 9. Indicar el nombre de los productos (bicicletas) que sean de color negro.
SELECT DISTINCT(p.Name)
FROM Production.Product p
WHERE p.Color = 'Black'
	AND p.ProductSubcategoryID IN (SELECT DISTINCT(S.ProductSubcategoryID)
									FROM [Production].[ProductSubcategory] s
									where s.ProductCategoryID = (SELECT c.ProductCategoryID
																FROM [Production].[ProductCategory] c
																where c.Name = 'Bikes'
																)
									);

/* 10. Indicar el nombre de los productos (bicicletas) que sean de color negro, su precio de lista sea mayor a 500, 
el tamaño de la rueda esté entre 40 y 58, y que su número de producto inicie con “BK” */
SELECT *
FROM Production.Product p
WHERE p.Color = 'Black'
	AND p.ListPrice > 500
	AND P.ProductNumber like 'BK%'
	AND P.Size BETWEEN 40 AND 58
	AND p.ProductSubcategoryID IN (SELECT DISTINCT(S.ProductSubcategoryID)
									FROM [Production].[ProductSubcategory] s
									where s.ProductCategoryID = (SELECT c.ProductCategoryID
																FROM [Production].[ProductCategory] c
																where c.Name = 'Bikes'
																)
									)
;

/* 11. Indicar qué personas son empleados en una nueva columna llamada “IsEmployee”. 
La condición para que una persona sea empleado es que el tipo de persona sea EM (empleado) o SP (sales person). 
En caso de que sea empleado la columna debe tener el valor “SI”, en caso contrario “NO”. */
SELECT CONCAT(p.LastName, ', ', p.FirstName, IIF(p.MiddleName IS NULL, '', CONCAT(' ', p.MiddleName, IIF(LEN(p.MiddleName) = 1, '.',''))))as Nombre,
	case when p.PersonType in ('EM','SP') then 'SI'
		else 'NO'
	end AS IsEmployee
FROM Person.Person p;

/*12. Indicar el nombre y el apellido de todas aquellas personas que no tengan segundo nombre.*/
SELECT p.FirstName, p.LastName
FROM Person.Person p
WHERE p.MiddleName IS NULL;

