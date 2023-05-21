/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.
Занятие "02 - Оператор SELECT и простые фильтры, JOIN".

Задания выполняются с использованием базы данных WideWorldImporters.

Бэкап БД WideWorldImporters можно скачать отсюда:
https://github.com/Microsoft/sql-server-samples/releases/download/wide-world-importers-v1.0/WideWorldImporters-Full.bak

Описание WideWorldImporters от Microsoft:
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-what-is
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-oltp-database-catalog
*/

-- ---------------------------------------------------------------------------
-- Задание - написать выборки для получения указанных ниже данных.
-- ---------------------------------------------------------------------------

USE WideWorldImporters

/*
1. Все товары, в названии которых есть "urgent" или название начинается с "Animal".
Вывести: ИД товара (StockItemID), наименование товара (StockItemName).
Таблицы: Warehouse.StockItems.
*/

select 
StockItemID, 
StockItemName 
from Warehouse.StockItems 
where (StockItemName like 'Animal%') or (StockItemName like '%urgent%')


/*
2. Поставщиков (Suppliers), у которых не было сделано ни одного заказа (PurchaseOrders).
Сделать через JOIN, с подзапросом задание принято не будет.
Вывести: ИД поставщика (SupplierID), наименование поставщика (SupplierName).
Таблицы: Purchasing.Suppliers, Purchasing.PurchaseOrders.
По каким колонкам делать JOIN подумайте самостоятельно.
*/

select 
a.SupplierID,
SupplierName
from Purchasing.Suppliers a ---поставщик
left join Purchasing.PurchaseOrders b on a.SupplierID=b.SupplierID
where b.SupplierID is null
/*
3. Заказы (Orders) с ценой товара (UnitPrice) более 100$ 
либо количеством единиц (Quantity) товара более 20 штук
и присутствующей датой комплектации всего заказа (PickingCompletedWhen).
Вывести:
* OrderID
* дату заказа (OrderDate) в формате ДД.ММ.ГГГГ
* название месяца, в котором был сделан заказ
* номер квартала, в котором был сделан заказ
* треть года, к которой относится дата заказа (каждая треть по 4 месяца)
* имя заказчика (Customer)
Добавьте вариант этого запроса с постраничной выборкой,
пропустив первую 1000 и отобразив следующие 100 записей.

Сортировка должна быть по номеру квартала, трети года, дате заказа (везде по возрастанию).

Таблицы: Sales.Orders, Sales.OrderLines, Sales.Customers.
*/

select distinct
a.OrderID,
convert(varchar,(a.OrderDate),103) as 'Дата заказа',
datename(month,a.OrderDate) as 'Название месяца',
datepart(quarter,a.OrderDate) as 'Номер квартала',
case when month(a.OrderDate) between 1 and 4 then 1
when month(a.OrderDate) between 4 and 8 then 2
when month(a.OrderDate) between 8 and 12 then 3 end as 'Треть года',
c.CustomerName
from Sales.Orders a ---заказы
join Sales.OrderLines b on a.OrderID=b.OrderID
join Sales.Customers c on a.CustomerID=c.CustomerID
where (b.UnitPrice>100 or  b.Quantity>20) and b.PickingCompletedWhen is not null
order by [номер квартала],[Треть года],[Дата заказа] asc

--второй вариант с ограничениями по выьорке строк 

select distinct
a.OrderID,
convert(varchar,(a.OrderDate),103) as 'Дата заказа',
datename(month,a.OrderDate) as 'Название месяца',
datepart(quarter,a.OrderDate) as 'Номер квартала',
case when month(a.OrderDate) between 1 and 4 then 1
when month(a.OrderDate) between 4 and 8 then 2
when month(a.OrderDate) between 8 and 12 then 3 end as 'Треть года',
c.CustomerName
from Sales.Orders a ---заказы
join Sales.OrderLines b on a.OrderID=b.OrderID
join Sales.Customers c on a.CustomerID=c.CustomerID
where (b.UnitPrice>100 or  b.Quantity>20) and b.PickingCompletedWhen is not null
order by [номер квартала],[Треть года],[Дата заказа] asc
offset 1000 rows fetch  first 100 rows only 

/*
4. Заказы поставщикам (Purchasing.Suppliers),
которые должны быть исполнены (ExpectedDeliveryDate) в январе 2013 года
с доставкой "Air Freight" или "Refrigerated Air Freight" (DeliveryMethodName)
и которые исполнены (IsOrderFinalized).
Вывести:
* способ доставки (DeliveryMethodName)
* дата доставки (ExpectedDeliveryDate)
* имя поставщика
* имя контактного лица принимавшего заказ (ContactPerson)

Таблицы: Purchasing.Suppliers, Purchasing.PurchaseOrders, Application.DeliveryMethods, Application.People.
*/

select
c.DeliveryMethodName,
b.ExpectedDeliveryDate,
a.SupplierName,
g.FullName
from  Purchasing.Suppliers a  -- заказы поставщикам
join Purchasing.PurchaseOrders b on a.SupplierID=b.SupplierID
join Application.DeliveryMethods c on b.LastEditedBy=c.DeliveryMethodID
join  Application.People g on g.PersonID=b.ContactPersonID
where b.ExpectedDeliveryDate between '2013-01-01' and '2013-01-31'
and (c.DeliveryMethodName='Air Freight' or c.DeliveryMethodName='Refrigerated Air Freight')
and b.IsOrderFinalized=1

/*
5. Десять последних продаж (по дате продажи) с именем клиента и именем сотрудника,
который оформил заказ (SalespersonPerson).
Сделать без подзапросов.
*/
select  top 10 
b.CustomerName,
a.OrderDate  ---где взять имя сотрудника, не смог найти в витринах
FROM sales.Orders a
join sales.Customers b on a.CustomerID=b.CustomerID
order by OrderDate desc

/*
6. Все ид и имена клиентов и их контактные телефоны,
которые покупали товар "Chocolate frogs 250g".
Имя товара смотреть в таблице Warehouse.StockItems.
*/

select  
c.CustomerID,
c.CustomerName,
c.PhoneNumber
 from Warehouse.StockItemTransactions a
join Warehouse.StockItems b on a.StockItemID=b.StockItemID
join sales.Customers c on c.CustomerID=a.CustomerID
where b.StockItemName='Chocolate frogs 250g'
group by c.CustomerID,
c.CustomerName,
c.PhoneNumber
